-- Small explicit widget API mock: execute the real UI rather than mirror its code.
local context = ForeverProfilesTestContext
local F = context.F
local widgets, named = {}, {}
local methods = {}
local function Widget(kind, name, parent)
    local widget = setmetatable({kind = kind, name = name, parent = parent, scripts = {},
        points = {}, shown = true, enabled = true, width = 0, height = 0,
        fontSize = 12, value = 0, layer = "ARTWORK"}, {__index = methods})
    widgets[#widgets + 1] = widget
    widget.index = #widgets
    if name then named[name] = widget; _G[name] = widget end
    return widget
end
function methods:SetSize(w, h) self.width, self.height = w, h end
function methods:SetWidth(w) self.width = w end
function methods:SetHeight(h) self.height = h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetPoint(point, relative, relativePoint, x, y)
    if type(relative) == "number" then x, y, relative, relativePoint = relative, relativePoint, self.parent, point end
    relative = relative or self.parent
    relativePoint = relativePoint or point
    self.points[#self.points + 1] = {point = point, relative = relative,
        relativePoint = relativePoint, x = x or 0, y = y or 0}
end
function methods:GetPoint()
    local p = self.points[1]
    return p.point, p.relative, p.relativePoint, p.x, p.y
end
function methods:ClearAllPoints() self.points = {} end
function methods:SetAllPoints(relative) self.allPoints = relative or self.parent end
function methods:SetScript(kind, fn) self.scripts[kind] = fn end
function methods:RegisterEvent() end
function methods:Show()
    if self.shown then return end
    self.shown = true
    if self.scripts.OnShow then self.scripts.OnShow(self) end
end
function methods:Hide()
    if not self.shown then return end
    self.shown = false
    if self.scripts.OnHide then self.scripts.OnHide(self) end
end
function methods:SetShown(show) if show then self:Show() else self:Hide() end end
function methods:IsShown() return self.shown end
function methods:SetEnabled(enable) self.enabled = enable end
function methods:IsEnabled() return self.enabled end
function methods:SetAlpha(alpha) self.alpha = alpha end
function methods:SetColorTexture(...) self.color = {...} end
function methods:SetTextColor(...) self.textColor = {...} end
function methods:SetFont(font, size, flags) self.font, self.fontSize = font, size end
function methods:GetFont() return "Fonts\\FRIZQT__.TTF", self.fontSize, "" end
function methods:SetFontObject() end
function methods:SetText(text) self.text = tostring(text or "") end
function methods:GetText() return self.text or "" end
function methods:SetJustifyH(value) self.justifyH = value end
function methods:SetJustifyV(value) self.justifyV = value end
function methods:SetSpacing(value) self.spacing = value end
function methods:SetWordWrap(value) self.wordWrap = value end
function methods:SetFrameStrata(value) self.strata = value end
function methods:SetFrameLevel(value) self.level = value end
function methods:GetFrameLevel() return self.level or 1 end
function methods:SetScale(value) self.scale = value end
function methods:SetMovable(value) self.movable = value end
function methods:GetScale() return self.scale or 1 end
function methods:StartMoving() self.moving = true end
function methods:StopMovingOrSizing() self.moving = false end
function methods:SetChecked(value) self.checked = value end
function methods:GetChecked() return self.checked end
function methods:SetMinMaxValues(low, high) self.minimum, self.maximum = low, high end
function methods:SetValue(value)
    local new = math.max(self.minimum or 0, math.min(self.maximum or 0, value))
    if new == self.value then return end
    self.value = new
    if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self, new) end
end
function methods:GetValue() return self.value end
function methods:SetVerticalScroll(value) self.scroll = value end
function methods:SetScrollChild(child) self.scrollChild = child end
function methods:CreateTexture(name, layer)
    local texture = Widget("Texture", name, self); texture.layer = layer; return texture
end
function methods:CreateFontString(name, layer)
    local text = Widget("FontString", name, self); text.layer = layer; return text
end
function methods:SetThumbTexture(texture) self.thumb = texture end
function methods:Click()
    if not self.enabled then return end
    if self.kind == "CheckButton" then self.checked = not self.checked end
    if self.scripts.OnClick then return self.scripts.OnClick(self) end
end
function methods:SetOwner() end
function methods:AddLine() end
for _, name in ipairs({"SetClampedToScreen", "EnableMouse", "RegisterForDrag",
    "EnableMouseWheel", "SetOrientation", "SetValueStep", "SetAutoFocus", "SetMaxLetters",
    "SetFocus", "ClearFocus", "HighlightText", "SetObeyStepOnDrag", "Raise"}) do
    methods[name] = function() end
end
CreateFrame = Widget
UIParent = Widget("Frame", "UIParent")
UIParent:SetSize(1280, 720)
UISpecialFrames = {}
GameTooltip = Widget("Tooltip", "GameTooltip", UIParent)
GameTooltip:Hide()
GameFontHighlight = {}
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
assert(loadfile("UI.lua"))("ForeverProfiles", F)
context.start(nil)
local U = F.UI
assert(not U.window and not U.quickBar)
U.Refresh(); assert(not U.window and not U.quickBar, "UI must remain lazy")
U.Show()
assert(U.window:IsShown() and U.listEmpty:IsShown())
assert(not U.apply:IsEnabled())
U.create:Click(); assert(U.modal:IsShown())
U.modal.edit:SetText(""); U.modal.accept:Click()
assert(U.modal:IsShown() and U.modal.error:GetText() ~= "")
U.modal.edit:SetText("Haute qualité"); U.modal.accept:Click()
assert(not U.modal:IsShown() and #F.Profiles.List() == 1)
assert(U.apply:IsEnabled())
local first = F.Profiles.List()[1]
U.favorite:Click()
assert(#F.Profiles.Favorites() == 1)
U.quickCheck:Click(); assert(U.quickBar and U.quickBar:IsShown())
U.rename:Click(); U.modal.edit:SetText("Qualité élevée"); U.modal.accept:Click()
assert(F.Profiles.Get(first.id).name == "Qualité élevée")
U.duplicate:Click(); U.modal.edit:SetText("Performance"); U.modal.accept:Click()
assert(#F.Profiles.List() == 2)
local second = F.Profiles.List()[2]
F.Profiles.SetSelected(second.id)
U.Refresh()
U.delete:Click(); U.modal.cancel:Click()
assert(#F.Profiles.List() == 2)
U.update:Click(); U.modal.cancel:Click()
assert(not U.modal:IsShown())
F.Profiles.SetSelected(first.id)
U.Refresh()
F.busy = true; U.Refresh()
assert(not U.apply:IsEnabled() and not U.quickBar.buttons[1]:IsEnabled())
F.busy = nil; U.Refresh()
assert(U.apply:IsEnabled())
F.results[first.id] = {success = false, failed = {}}
-- The next case changes an effective value and therefore must expose the difference.
local oldGet = C_CVar.GetCVar
C_CVar.GetCVar = function(name)
    if string.lower(name) == "graphicsshadowquality" then return "0" end
    return oldGet(name)
end
U.Refresh()
assert(U.summaryRows[1].label:GetText() == "Settings that differ")
C_CVar.GetCVar = oldGet; F.results[first.id] = nil
GetLocale = function() return "frFR" end
-- Recreate widgets so labels set during construction also use French.
U.window = nil; U.quickBar = nil; U.modal = nil
U.Show(); F.SetQuickBarVisible(true)
assert(U.create.label:GetText() == "Enregistrer les réglages")
assert(F.L["Apply profile"] == "Appliquer le profil")
U.Toggle(); assert(not U.window:IsShown())
U.Toggle(); assert(U.window:IsShown())
U.create:Click(); U.modal.cancel:Click()
local bar = U.quickBar
U.window:Hide()
bar:ClearAllPoints()
bar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 120, -75)
bar.grip.scripts.OnDragStart(bar.grip)
assert(bar.moving)
bar.grip.scripts.OnDragStop(bar.grip)
assert(not bar.moving and not U.window:IsShown(), "Dragging the bar must not open the window")
assert(F.Profiles.GetDB().ui.quickBarPosition.x == 120)
assert(F.Profiles.GetDB().ui.quickBarPosition.y == -75)
bar.handle:Click(); assert(U.window:IsShown(), "FP must still open the window")
U.quickScale:SetValue(160)
assert(F.Profiles.GetDB().ui.quickBarScale == 1.6 and bar:GetScale() == 1.6)
assert(U.quickScaleValue:GetText() == "160%")
U.RefreshQuickBar(); assert(bar:GetScale() == 1.6, "Refresh must not reset the bar scale")
bar.grip.scripts.OnMouseWheel(bar.grip, -1)
assert(F.Profiles.GetDB().ui.quickBarScale == 1.5 and bar:GetScale() == 1.5)
F.ToggleFavorite(second.id)
assert(bar:GetScale() == 1.5, "Changing favorites must retain the requested scale")
F.ToggleFavorite(second.id)
bar.scripts.OnDragStart(bar)
bar:Hide()
assert(not bar.moving, "Hiding the bar must stop dragging")
local saved = F.Profiles.GetDB()
assert(F.Profiles.Initialize(saved))
U.quickBar = nil
U.RefreshQuickBar()
assert(U.quickBar:GetScale() == 1.5, "Recreating the bar must restore its saved scale")
local _, _, _, x, y = U.quickBar:GetPoint()
assert(x == 120 and y == -75, "Recreating the bar must restore its saved position")
F.SetQuickBarScale(1)
U.Refresh()
bar = U.quickBar
local width = bar:GetWidth()
bar.scripts.OnDragStart(bar)
assert(bar.moving)
U.quickLock:Click()
assert(F.Profiles.GetDB().ui.quickBarLocked and U.quickLock:GetChecked())
assert(not bar.moving and bar.movable == false and not bar.grip:IsShown())
assert(bar:GetWidth() == width - 24, "Locked bar should remove the space for its drag handle")
bar.scripts.OnDragStart(bar)
bar.grip.scripts.OnDragStart(bar.grip)
assert(not bar.moving, "Locked bar must reject background and handle dragging")
bar.grip.scripts.OnMouseWheel(bar.grip, 1)
assert(F.Profiles.GetDB().ui.quickBarScale == 1, "Hidden handle must not resize a locked bar")
bar.handle:Click(); assert(not U.window:IsShown())
bar.handle:Click(); assert(U.window:IsShown(), "Locked bar must keep the FP button usable")
bar.buttons[1]:Click(); context.flush()
assert(F.Graphics.Compare(first.modules.graphics).matches, "Locked bar must keep favorite buttons usable")
saved = F.Profiles.GetDB()
assert(F.Profiles.Initialize(saved))
bar:Hide(); U.quickBar = nil
U.Refresh()
bar = U.quickBar
assert(bar.movable == false and not bar.grip:IsShown(), "Recreated bar must retain its lock")
U.quickLock:Click()
assert(not F.Profiles.GetDB().ui.quickBarLocked and bar.grip:IsShown() and bar.movable)
bar.scripts.OnDragStart(bar); assert(bar.moving)
bar.scripts.OnDragStop(bar); assert(not bar.moving)
U.SetNotice(F.L["Changes made in the game options do not overwrite your saved profiles."], false)
print("PASS UI lifecycle, dialogs, actions, favorites, busy state, differences, localization, movement, sizing and persistent locking")
ForeverProfilesMockUI = {widgets = widgets, named = named, F = F}
