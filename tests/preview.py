"""Approximate the actual Lua widget layout for visual QA, without running WoW."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


def render(runtime, destination):
    state = runtime.globals().ForeverProfilesMockUI
    widgets = {int(w["index"]): w for w in state["widgets"].values()}
    current = state["F"]["UI"]
    roots = {int(current["window"]["index"]), int(current["quickBar"]["index"])}
    geometry = {}

    def index(widget):
        return int(widget["index"]) if widget is not None else None

    def anchor(point):
        return (0 if "LEFT" in point else 1 if "RIGHT" in point else 0.5,
                0 if "TOP" in point else 1 if "BOTTOM" in point else 0.5)

    def rect(widget):
        key = index(widget)
        if key in geometry:
            return geometry[key]
        if widget["allPoints"] is not None:
            geometry[key] = rect(widget["allPoints"])
            return geometry[key]
        width, height = float(widget["width"] or 0), float(widget["height"] or 0)
        equations = []
        for p in widget["points"].values():
            relative = p["relative"] or widget["parent"]
            rx, ry, rw, rh = rect(relative) if relative is not None else (0, 0, 1280, 720)
            ax, ay = anchor(p["point"])
            bx, by = anchor(p["relativePoint"])
            equations.append((ax, ay, rx + bx * rw + p["x"], ry + by * rh - p["y"]))
        if not equations:
            px, py, _, _ = rect(widget["parent"]) if widget["parent"] is not None else (0, 0, 0, 0)
            x, y = px, py
        else:
            if width == 0:
                for first in equations:
                    for second in equations:
                        if first[0] != second[0]:
                            width = (second[2] - first[2]) / (second[0] - first[0])
            if height == 0:
                for first in equations:
                    for second in equations:
                        if first[1] != second[1]:
                            height = (second[3] - first[3]) / (second[1] - first[1])
            ax, ay, target_x, target_y = equations[0]
            x, y = target_x - ax * width, target_y - ay * height
        geometry[key] = (x, y, max(0, width), max(0, height))
        return geometry[key]

    def visible(widget):
        reached = False
        while widget is not None:
            if widget["shown"] is False:
                return False
            reached = reached or index(widget) in roots
            widget = widget["parent"]
        return reached

    def clip(widget):
        box = [0, 0, 1280, 720]
        widget = widget["parent"]
        while widget is not None:
            if widget["kind"] == "ScrollFrame":
                x, y, width, height = rect(widget)
                box = [max(box[0], x), max(box[1], y), min(box[2], x + width), min(box[3], y + height)]
            widget = widget["parent"]
        return tuple(int(n) for n in box)

    def rgba(table, default=(230, 239, 247, 255)):
        if table is None:
            return default
        numbers = [table[i] for i in range(1, 5)]
        return tuple(round(255 * (n if n is not None else 1)) for n in numbers)

    image = Image.new("RGBA", (1280, 720), (25, 33, 42, 255))
    clipped_buttons = []
    def paint_order(widget):
        cursor = widget
        strata = "MEDIUM"
        while cursor is not None:
            if cursor["strata"] is not None:
                strata = cursor["strata"]
                break
            cursor = cursor["parent"]
        return ({"BACKGROUND": 0, "LOW": 1, "MEDIUM": 2, "HIGH": 3, "DIALOG": 4, "TOOLTIP": 5}.get(strata, 2), widget["index"])

    for widget in sorted(widgets.values(), key=paint_order):
        if not visible(widget) or widget["kind"] not in ("Texture", "FontString"):
            continue
        x, y, width, height = rect(widget)
        layer = Image.new("RGBA", image.size)
        draw = ImageDraw.Draw(layer)
        if widget["kind"] == "Texture" and widget["color"] is not None:
            draw.rectangle((x, y, x + max(1, width) - 1, y + max(1, height) - 1), fill=rgba(widget["color"]))
        elif widget["kind"] == "FontString" and widget["text"]:
            text = str(widget["text"])
            font = ImageFont.truetype("C:/Windows/Fonts/georgia.ttf", max(8, round(widget["fontSize"])))
            wrap = widget["wordWrap"] is not False
            lines = []
            for paragraph in text.split("\n"):
                if wrap:
                    line = ""
                    for word in paragraph.split(" "):
                        candidate = (line + " " + word).strip()
                        if line and font.getlength(candidate) > width:
                            lines.append(line); line = word
                        else:
                            line = candidate
                    lines.append(line)
                else:
                    if font.getlength(paragraph) > width and widget["parent"]["kind"] == "Button":
                        clipped_buttons.append(paragraph)
                    while font.getlength(paragraph) > width and len(paragraph) > 1:
                        paragraph = paragraph[:-2] + "…"
                    lines.append(paragraph)
            line_height = round(widget["fontSize"] * 1.2 + (widget["spacing"] or 0))
            if widget["justifyV"] == "MIDDLE":
                y += max(0, (height - len(lines) * line_height) / 2)
            for number, line in enumerate(lines):
                offset = max(0, width - font.getlength(line))
                tx = x + (offset / 2 if widget["justifyH"] == "CENTER" else offset if widget["justifyH"] == "RIGHT" else 0)
                draw.text((tx, y + number * line_height), line, font=font, fill=rgba(widget["textColor"]), anchor="lt")
        bounds = clip(widget)
        if bounds[0] < bounds[2] and bounds[1] < bounds[3]:
            image.alpha_composite(layer.crop(bounds), dest=bounds[:2])
    draw = ImageDraw.Draw(image)
    draw.text((20, 685), "Simulated Lua layout — approximate fonts, without a running WoW client", font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 12), fill=(141, 159, 177))
    destination = Path(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(destination)
    print(f"UI layout preview: {destination}")
    if clipped_buttons:
        print("Button text exceeding approximate font width:", ", ".join(clipped_buttons))
