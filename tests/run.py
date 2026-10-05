"""Run the addon in Lua 5.1 with a mocked WoW client; no live game settings touched."""
from pathlib import Path
import os
import sys
import xml.etree.ElementTree as ET

try:
    from lupa.lua51 import LuaRuntime
except ImportError:
    sys.exit("This runner requires Python's lupa package with the Lua 5.1 runtime.")

addon = Path(__file__).resolve().parents[1]
os.chdir(addon)
runtime = LuaRuntime(unpack_returned_tuples=True)
compile_lua = runtime.eval("function(source, name) local fn, err = loadstring(source, name); assert(fn, err); return fn end")
for source in sorted(addon.glob("*.lua")):
    compile_lua(source.read_text(encoding="utf-8"), "@" + source.name)
bindings = ET.parse(addon / "Bindings.xml").getroot()
assert bindings.tag == "Bindings" and not bindings.attrib, "Bindings.xml must use the dedicated binding format without the UI namespace"
assert len(bindings) == 5 and all(binding.tag == "Binding" for binding in bindings), "Expected the five addon bindings"
for line in (addon / "ForeverProfiles.toc").read_text(encoding="utf-8").splitlines():
    if line.strip() and not line.startswith("#"):
        assert Path(line.replace("\\", "/")).name.lower() != "bindings.xml", "Bindings.xml is discovered by WoW's binding loader and must not be listed in the TOC"
        assert (addon / line).is_file(), f"Missing TOC file: {line}"
runtime.execute((addon / "tests" / "run.lua").read_text(encoding="utf-8"))
runtime.execute((addon / "tests" / "ui_mock.lua").read_text(encoding="utf-8"))
binding_targets = {
    "FOREVERPROFILES_TOGGLE": ("toggle", None),
    "FOREVERPROFILES_FAVORITE1": ("favorite", 1),
    "FOREVERPROFILES_FAVORITE2": ("favorite", 2),
    "FOREVERPROFILES_FAVORITE3": ("favorite", 3),
    "FOREVERPROFILES_RESTORE": ("restore", None),
}
calls = []
globals_ = runtime.globals()
globals_.ForeverProfiles_Toggle = lambda: calls.append(("toggle", None))
globals_.ForeverProfiles_ApplyFavorite = lambda slot: calls.append(("favorite", slot))
globals_.ForeverProfiles_Restore = lambda: calls.append(("restore", None))
seen_bindings = set()
for binding in bindings:
    name = binding.attrib["name"]
    assert name not in seen_bindings and name in binding_targets, f"Duplicate or unknown binding: {name}"
    seen_bindings.add(name)
    assert globals_["BINDING_NAME_" + name], f"Missing binding label: {name}"
    if "header" in binding.attrib:
        assert globals_["BINDING_HEADER_" + binding.attrib["header"]], "Missing binding header"
    calls.clear()
    compile_lua(binding.text or "", "@Bindings.xml:" + name)()
    assert calls == [binding_targets[name]], f"Binding {name} dispatches to the wrong action: {calls}"
print("PASS dedicated binding discovery, XML format, labels and all five shortcut actions")
if "--preview" in sys.argv:
    from preview import render
    destination = Path(sys.argv[sys.argv.index("--preview") + 1])
    render(runtime, destination)
    ui = runtime.globals().ForeverProfilesTestContext["F"]["UI"]
    ui.SelectTab("favorites")
    render(runtime, destination.with_stem(destination.stem + "-favorites"))
    ui.SelectTab("profiles")
print("Lua 5.1 syntax, binding XML, and TOC file checks passed.")
