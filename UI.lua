local _, F = ...
local U = {}
F.UI = U

local L = F.L
local WIDTH, HEIGHT = 780, 550
local color = {
    background = { 0.098, 0.090, 0.075, 1 },
    panel = { 0.063, 0.059, 0.051, 1 },
    border = { 0.451, 0.408, 0.353, 1 },
    text = { 0.933, 0.890, 0.812, 1 },
    muted = { 0.64, 0.60, 0.53, 1 },
    accent = { 0.843, 0.706, 0.420, 1 },
    active = { 0.54, 0.76, 0.46, 1 },
    warning = { 0.98, 0.68, 0.37, 1 },
}

local function Plain(value)
    return (tostring(value or ""):gsub("|", "||"))
end

local function ShortName(name)
    -- Stored names have already been validated as UTF-8. Leave room for the
    -- English copy suffix without cutting an accented character in half.
    local index, count = 1, 0
    while index <= #name and count < 42 do
        local byte = string.byte(name, index)
        index = index + (byte < 128 and 1 or byte < 224 and 2 or byte < 240 and 3 or 4)
        count = count + 1
    end
    return string.sub(name, 1, index - 1)
end

local function DB()
    return F.Profiles and F.Profiles.GetDB()
end

local function CloseMenu()
    if U.menu then U.menu:Hide() end
    if U.menuBlocker then U.menuBlocker:Hide() end
    U.menuProfileID = nil
end

local function Fill(parent, tint, layer)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetAllPoints()
    texture:SetColorTexture(unpack(tint))
    return texture
end

local function Rim(parent, tint)
    local edges = {}
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local edge = parent:CreateTexture(nil, "BORDER")
        edge:SetColorTexture(unpack(tint or color.border))
        if side == "TOP" or side == "BOTTOM" then
            edge:SetPoint(side .. "LEFT")
            edge:SetPoint(side .. "RIGHT")
            edge:SetHeight(1)
        else
            edge:SetPoint("TOP" .. side)
            edge:SetPoint("BOTTOM" .. side)
            edge:SetWidth(1)
        end
        edges[#edges + 1] = edge
    end
    return edges
end

local function Skin(parent, tint)
    Fill(parent, tint or color.background)
    Rim(parent, color.border)
    local bevel = parent:CreateTexture(nil, "BORDER")
    bevel:SetPoint("TOPLEFT", 1, -1)
    bevel:SetPoint("TOPRIGHT", -1, -1)
    bevel:SetHeight(1)
    bevel:SetColorTexture(0.28, 0.25, 0.20, 1)
end

local function Text(parent, size, tint, width, height)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local font, _, flags = text:GetFont()
    text:SetFont(font or STANDARD_TEXT_FONT, size, flags or "")
    text:SetTextColor(unpack(tint or color.text))
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if width then text:SetWidth(width) end
    if height then text:SetHeight(height) end
    return text
end

local function Surface(parent, width, height, tint)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(width, height)
    Skin(panel, tint or color.panel)
    return panel
end

local function Tooltip(owner, title, description)
    if not GameTooltip then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(title or "", 0.91, 0.94, 0.97)
    if description then GameTooltip:AddLine(description, 0.7, 0.76, 0.83, true) end
    GameTooltip:Show()
end

local function HideTooltip()
    if GameTooltip then GameTooltip:Hide() end
end

local function PaintButton(button, hovered)
    local tint
    if button.primary then
        tint = hovered and { 0.53, 0.15, 0.10, 1 } or { 0.38, 0.10, 0.065, 1 }
    elseif button.selected then
        tint = hovered and { 0.32, 0.26, 0.15, 1 } or { 0.25, 0.20, 0.115, 1 }
    else
        tint = hovered and { 0.29, 0.245, 0.18, 1 } or { 0.20, 0.17, 0.13, 1 }
    end
    button.background:SetColorTexture(unpack(tint))
    for _, edge in ipairs(button.rim or {}) do
        edge:SetColorTexture(unpack(button.selected and color.accent or color.border))
    end
    button.label:SetTextColor(unpack(button.selected and color.accent or color.text))
end

local function Button(parent, label, width, height, primary)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height or 30)
    button.primary = primary
    button.background = Fill(button, { 0.20, 0.17, 0.13, 1 })
    button.rim = Rim(button)
    local highlight = button:CreateTexture(nil, "BORDER")
    highlight:SetPoint("TOPLEFT", 1, -1)
    highlight:SetPoint("TOPRIGHT", -1, -1)
    highlight:SetHeight(1)
    highlight:SetColorTexture(0.42, 0.35, 0.24, 0.65)
    local shadow = button:CreateTexture(nil, "BORDER")
    shadow:SetPoint("BOTTOMLEFT", 1, 1)
    shadow:SetPoint("BOTTOMRIGHT", -1, 1)
    shadow:SetHeight(1)
    shadow:SetColorTexture(0.04, 0.03, 0.02, 1)
    button.label = Text(button, 12, color.text, width - 12, height or 30)
    button.label:SetPoint("CENTER")
    button.label:SetJustifyH("CENTER")
    button.label:SetJustifyV("MIDDLE")
    button.label:SetWordWrap(false)
    button.label:SetText(label)
    button:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            PaintButton(self, true)
        end
        if self.tooltipTitle then Tooltip(self, self.tooltipTitle, self.tooltipText) end
    end)
    button:SetScript("OnLeave", function(self)
        PaintButton(self)
        HideTooltip()
    end)
    PaintButton(button)
    return button
end

local function Enabled(button, enabled)
    button:SetEnabled(not not enabled)
    button:SetAlpha(enabled and 1 or 0.42)
end

local function Fit(frame, width, height)
    local scale = math.min(1, (UIParent:GetWidth() - 32) / width, (UIParent:GetHeight() - 32) / height)
    frame:SetScale(math.max(0.25, scale))
end

local function Position(frame, key, point, relativePoint, x, y)
    local db = DB()
    local saved = db and db.ui and db.ui[key]
    frame:ClearAllPoints()
    if saved then
        frame:SetPoint(saved.point or point, UIParent, saved.relativePoint or relativePoint, saved.x or x, saved.y or y)
    else
        frame:SetPoint(point, UIParent, relativePoint, x, y)
    end
end

local function SavePosition(frame, key)
    frame:StopMovingOrSizing()
    local db = DB()
    if not db then return end
    db.ui = db.ui or {}
    local point, _, relativePoint, x, y = frame:GetPoint(1)
    db.ui[key] = { point = point, relativePoint = relativePoint, x = x, y = y }
end

-- Native clipping and a small slider keep long profile lists and summaries usable.
local function ScrollArea(parent, width, height, x, y)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(width, height)
    holder:SetPoint("TOPLEFT", x, y)
    holder.viewport = CreateFrame("ScrollFrame", nil, holder)
    holder.viewport:SetPoint("TOPLEFT")
    holder.viewport:SetSize(width - 14, height)
    holder.content = CreateFrame("Frame", nil, holder.viewport)
    holder.content:SetSize(width - 14, 1)
    holder.viewport:SetScrollChild(holder.content)
    holder.slider = CreateFrame("Slider", nil, holder)
    holder.slider:SetPoint("TOPRIGHT", -1, 0)
    holder.slider:SetSize(7, height)
    holder.slider:SetOrientation("VERTICAL")
    holder.slider:SetValueStep(1)
    holder.slider:SetMinMaxValues(0, 0)
    Fill(holder.slider, { 0.13, 0.115, 0.085, 1 })
    local thumb = holder.slider:CreateTexture(nil, "ARTWORK")
    thumb:SetColorTexture(unpack(color.border))
    thumb:SetSize(7, 34)
    holder.slider:SetThumbTexture(thumb)
    holder.slider:SetScript("OnValueChanged", function(_, value)
        holder.viewport:SetVerticalScroll(value)
    end)
    holder.viewport:EnableMouseWheel(true)
    holder.viewport:SetScript("OnMouseWheel", function(_, delta)
        holder.slider:SetValue(math.max(0, math.min(holder.maximum or 0, holder.slider:GetValue() - delta * 34)))
    end)
    function holder:SetContentHeight(contentHeight, reset)
        self.content:SetHeight(math.max(1, contentHeight))
        self.maximum = math.max(0, contentHeight - height)
        self.slider:SetMinMaxValues(0, self.maximum)
        self.slider:SetValue(reset and 0 or math.min(self.slider:GetValue(), self.maximum))
        self.slider:SetShown(self.maximum > 0)
        if self.maximum == 0 then self.viewport:SetVerticalScroll(0) end
    end
    return holder
end

local function QuickBarSlider(parent, label, bottom, minimum, maximum, step, onChange, help)
    local heading = Text(parent, 12, color.text, 184, 20)
    heading:SetPoint("BOTTOMLEFT", 16, bottom + 2)
    heading:SetJustifyV("MIDDLE")
    heading:SetText(label)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetSize(334, 24)
    slider:SetPoint("BOTTOMLEFT", 210, bottom)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minimum, maximum)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetHeight(4)
    track:SetColorTexture(unpack(color.border))
    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(12, 20)
    thumb:SetColorTexture(unpack(color.accent))
    slider:SetThumbTexture(thumb)
    slider:SetScript("OnValueChanged", onChange)
    slider:SetScript("OnEnter", function(self) Tooltip(self, label, help) end)
    slider:SetScript("OnLeave", HideTooltip)
    local value = Text(parent, 12, color.text, 80, 24)
    value:SetPoint("BOTTOMLEFT", 560, bottom)
    value:SetJustifyV("MIDDLE")
    value:SetJustifyH("RIGHT")
    return slider, heading, value
end

local function Selected()
    local db = DB()
    return db and F.Profiles.Get(db.lastSelectedID)
end

local function Select(id)
    CloseMenu()
    F.Profiles.SetSelected(id)
    U.summarySelection = nil
    U.Refresh()
end

local function Status(id)
    local status = F.GetProfileStatus and F.GetProfileStatus(id) or L["Saved"]
    return L[status] or status
end

local function StatusColor(status)
    if status == L["Active"] then return color.active end
    if status == L["Applied partially"] then return color.warning end
    return color.muted
end

local function FavoriteMap()
    local result = {}
    for _, profile in ipairs(F.Profiles.Favorites()) do
        result[type(profile) == "table" and profile.id or profile] = true
    end
    return result
end

local function Modal()
    if U.modal then return U.modal end
    local modal = CreateFrame("Frame", "ForeverProfilesDialog", U.window)
    modal:SetAllPoints()
    modal:SetFrameLevel(U.window:GetFrameLevel() + 30)
    modal:EnableMouse(true)
    Fill(modal, { 0.025, 0.020, 0.015, 0.90 })
    local panel = Surface(modal, 450, 260, color.background)
    panel:SetPoint("CENTER")
    panel:SetFrameLevel(modal:GetFrameLevel() + 1)
    modal.panel = panel
    modal.title = Text(panel, 18, color.text, 406, 28)
    modal.title:SetPoint("TOPLEFT", 22, -20)
    modal.body = Text(panel, 12, color.muted, 406, 64)
    modal.body:SetPoint("TOPLEFT", 22, -58)
    modal.body:SetSpacing(3)
    modal.editSurface = Surface(panel, 406, 34, color.panel)
    modal.editSurface:SetPoint("TOPLEFT", 22, -128)
    modal.edit = CreateFrame("EditBox", nil, modal.editSurface)
    modal.edit:SetPoint("TOPLEFT", 10, -5)
    modal.edit:SetPoint("BOTTOMRIGHT", -10, 5)
    modal.edit:SetFontObject(GameFontHighlight)
    modal.edit:SetAutoFocus(false)
    modal.edit:SetMaxLetters(48)
    modal.edit:SetScript("OnEscapePressed", function() modal:Hide() end)
    modal.error = Text(panel, 11, color.warning, 406, 36)
    modal.error:SetPoint("TOPLEFT", 22, -169)
    modal.accept = Button(panel, L["Save"], 170, 32, true)
    modal.accept:SetPoint("BOTTOMRIGHT", -22, 18)
    modal.cancel = Button(panel, L["Cancel"], 100, 32)
    modal.cancel:SetPoint("RIGHT", modal.accept, "LEFT", -10, 0)
    modal.cancel:SetScript("OnClick", function() modal:Hide() end)
    modal.accept:SetScript("OnClick", function()
        if F.busy or not modal.callback then return end
        local success, err = modal.callback(modal.edit:GetText())
        if success then
            modal:Hide()
            U.Refresh()
        else
            modal.error:SetText(err or L["Unable to save this profile."])
        end
    end)
    modal.edit:SetScript("OnEnterPressed", function() modal.accept:Click() end)
    modal:SetScript("OnHide", function()
        modal.edit:ClearFocus()
        modal.callback = nil
    end)
    modal:Hide()
    UISpecialFrames[#UISpecialFrames + 1] = "ForeverProfilesDialog"
    U.modal = modal
    return modal
end

local function NameDialog(mode, profile)
    if F.busy then return end
    local modal = Modal()
    modal.error:SetText("")
    modal.editSurface:Show()
    if mode == "create" then
        modal.title:SetText(L["Save current settings"])
        modal.body:SetText(L["First apply your graphics settings in the game options, then give this configuration a name."])
        modal.edit:SetText("")
        modal.accept.label:SetText(L["Save profile"])
        modal.callback = function(name)
            local result, err = F.CreateProfile(name)
            if result and type(result) == "table" then F.Profiles.SetSelected(result.id) end
            return result, err
        end
    elseif mode == "rename" then
        modal.title:SetText(L["Rename profile"])
        modal.body:SetText(L["Choose a name that makes this configuration easy to recognize."])
        modal.edit:SetText(profile.name)
        modal.accept.label:SetText(L["Rename"])
        modal.callback = function(name) return F.RenameProfile(profile.id, name) end
    else
        modal.title:SetText(L["Duplicate profile"])
        modal.body:SetText(L["Create a copy of the saved configuration under a new name."])
        modal.edit:SetText(ShortName(profile.name) .. " " .. L["copy"])
        modal.accept.label:SetText(L["Duplicate"])
        modal.callback = function(name)
            local result, err = F.DuplicateProfile(profile.id, name)
            if result and type(result) == "table" then F.Profiles.SetSelected(result.id) end
            return result, err
        end
    end
    modal:Show()
    modal.edit:SetFocus()
    modal.edit:HighlightText()
end

local function ConfirmDialog(mode, profile)
    if F.busy then return end
    local modal = Modal()
    modal.error:SetText("")
    modal.editSurface:Hide()
    if mode == "update" then
        modal.title:SetText(L["Update saved settings"])
        modal.body:SetText(string.format(L['Replace the saved settings for "%s" with your current game settings?'], Plain(profile.name)))
        modal.accept.label:SetText(L["Update profile"])
        modal.callback = function() return F.UpdateProfile(profile.id) end
    else
        modal.title:SetText(L["Delete profile"])
        modal.body:SetText(string.format(L['Delete "%s"? Your current game settings will stay as they are.'], Plain(profile.name)))
        modal.accept.label:SetText(L["Delete"])
        modal.callback = function() return F.DeleteProfile(profile.id) end
    end
    modal:Show()
end

local function SummaryRow(parent, width)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width, 24)
    row.label = Text(row, 11, color.muted, width - 170, 24)
    row.label:SetPoint("LEFT")
    row.label:SetJustifyV("MIDDLE")
    row.label:SetWordWrap(false)
    row.value = Text(row, 11, color.text, 155, 24)
    row.value:SetPoint("RIGHT")
    row.value:SetJustifyH("RIGHT")
    row.value:SetJustifyV("MIDDLE")
    row.value:SetWordWrap(false)
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if self.tooltipTitle then Tooltip(self, self.tooltipTitle, self.tooltipText) end
    end)
    row:SetScript("OnLeave", HideTooltip)
    return row
end

local function RefreshSummary(profile)
    local scroll = U.summaryScroll
    for _, row in ipairs(U.summaryRows) do row:Hide() end
    local snapshot = profile and profile.modules and profile.modules.graphics
    local allSummaries = snapshot and F.Graphics and F.Graphics.GetSummary(snapshot) or {}
    local mode, summaries = U.summaryMode or "normal", {}
    for _, setting in ipairs(allSummaries) do
        if setting.group == mode or setting.group == "common" then
            summaries[#summaries + 1] = setting
        end
    end
    for key, button in pairs(U.summaryTabs or {}) do
        button.selected = key == mode
        PaintButton(button)
    end
    local lastGroup, y, rowIndex = nil, 0, 0
    local groups = {
        normal = L["General"],
        raid = L["Raid / instance"],
        common = L["Shared"],
    }
    local function NextRow()
        rowIndex = rowIndex + 1
        local row = U.summaryRows[rowIndex]
        if not row then
            row = SummaryRow(scroll.content, scroll.content:GetWidth())
            U.summaryRows[rowIndex] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -y)
        row:Show()
        return row
    end
    local application = profile and F.results and F.results[profile.id]
    if snapshot and application and not application.success and not F.busy then
        local comparison = F.Graphics.Compare(snapshot)
        if #comparison.differences > 0 then
            local heading = NextRow()
            heading.label:SetWidth(scroll.content:GetWidth() - 170)
            heading.label:SetTextColor(unpack(color.warning))
            heading.label:SetText(L["Settings that differ"])
            heading.value:SetText(L["Saved / current"])
            heading.tooltipTitle = nil
            y = y + 26
            local settings = {}
            for _, entry in ipairs(F.Graphics.catalog or {}) do settings[entry.name] = entry end
            local reasons = {}
            for _, entry in ipairs(application.failed or {}) do reasons[entry.name] = entry.reason end
            for _, entry in ipairs(application.skipped or {}) do reasons[entry.name] = entry.reason end
            for _, difference in ipairs(comparison.differences) do
                local entry = settings[difference.name]
                local row = NextRow()
                row.label:SetWidth(scroll.content:GetWidth() - 170)
                row.label:SetTextColor(unpack(color.warning))
                local label = entry and L[entry.label] or difference.name
                row.label:SetText(label)
                local current = difference.actual or L["Unavailable"]
                local expected = difference.expected or L["Unavailable"]
                row.value:SetText(Plain(expected) .. " / " .. Plain(current))
                row.tooltipTitle = label
                row.tooltipText = (entry and ((groups[entry.group] or entry.group) .. "\n") or "")
                    .. L["Saved"] .. ": " .. Plain(expected) .. "\n"
                    .. L["Current"] .. ": " .. Plain(current) .. "\n"
                    .. L[reasons[difference.name] or difference.reason or "Value differs"]
                y = y + 24
            end
            y = y + 12
        end
    end
    for _, setting in ipairs(summaries) do
        if setting.group ~= lastGroup then
            if rowIndex > 0 then y = y + 8 end
            local heading = NextRow()
            heading.label:SetWidth(scroll.content:GetWidth())
            heading.label:SetTextColor(unpack(color.accent))
            heading.label:SetText(groups[setting.group] or L[setting.group or "Graphics settings"])
            heading.value:SetText("")
            heading.tooltipTitle = nil
            y = y + 24
            lastGroup = setting.group
        end
        local row = NextRow()
        row.label:SetWidth(scroll.content:GetWidth() - 170)
        row.label:SetTextColor(unpack(color.muted))
        row.label:SetText(L[setting.label] or setting.label)
        row.value:SetText(Plain(L[tostring(setting.value)] or setting.value))
        row.tooltipTitle = L[setting.label] or setting.label
        row.tooltipText = Plain(L[tostring(setting.value)] or setting.value)
        y = y + 24
    end
    U.summaryEmpty:SetShown(#summaries == 0)
    scroll:SetContentHeight(y, U.summarySelection ~= (profile and profile.id))
    U.summarySelection = profile and profile.id
end

local function ProfileRow(parent, width)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, 56)
    row.background = Fill(row, { 0.105, 0.095, 0.075, 1 })
    row.indicator = row:CreateTexture(nil, "ARTWORK")
    row.indicator:SetColorTexture(unpack(color.accent))
    row.indicator:SetPoint("TOPLEFT")
    row.indicator:SetPoint("BOTTOMLEFT")
    row.indicator:SetWidth(3)
    row.title = Text(row, 13, color.text, width - 24, 20)
    row.title:SetPoint("TOPLEFT", 12, -9)
    row.title:SetWordWrap(false)
    row.status = Text(row, 10, color.muted, width - 24, 16)
    row.status:SetPoint("TOPLEFT", 12, -32)
    row.status:SetWordWrap(false)
    row:SetScript("OnClick", function(self) if self.profile then Select(self.profile.id) end end)
    row:SetScript("OnEnter", function(self)
        self.background:SetColorTexture(0.22, 0.185, 0.12, 1)
        if self.profile then Tooltip(self, Plain(self.profile.name), L["Select this profile to view its saved settings."]) end
    end)
    row:SetScript("OnLeave", function(self)
        self.background:SetColorTexture(unpack(self.selected and { 0.205, 0.165, 0.09, 1 } or { 0.105, 0.095, 0.075, 1 }))
        HideTooltip()
    end)
    return row
end

function U.Initialize()
    if U.window then return U.window end
    local window = CreateFrame("Frame", "ForeverProfilesWindow", UIParent)
    U.window = window
    window:SetSize(WIDTH, HEIGHT)
    window:SetFrameStrata("DIALOG")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    Skin(window, color.background)
    Position(window, "windowPosition", "CENTER", "CENTER", 0, 0)
    local drag = CreateFrame("Frame", nil, window)
    drag:SetPoint("TOPLEFT")
    drag:SetPoint("TOPRIGHT", -58, 0)
    drag:SetHeight(50)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() window:StartMoving() end)
    drag:SetScript("OnDragStop", function() SavePosition(window, "windowPosition") end)
    local title = Text(window, 23, color.accent, 600, 30)
    title:SetPoint("TOPLEFT", 20, -15)
    title:SetText("Forever Profiles")
    local close = Button(window, "X", 28, 28)
    close:SetPoint("TOPRIGHT", -16, -14)
    close.tooltipTitle = L["Close"]
    close:SetScript("OnClick", function() window:Hide() end)
    UISpecialFrames[#UISpecialFrames + 1] = "ForeverProfilesWindow"

    U.profilePanel = CreateFrame("Frame", nil, window)
    U.profilePanel:SetSize(744, 398)
    U.profilePanel:SetPoint("TOPLEFT", 18, -60)
    local listPanel = Surface(U.profilePanel, 232, 338)
    listPanel:SetPoint("TOPLEFT")
    U.listTitle = Text(listPanel, 13, color.accent, 208, 20)
    U.listTitle:SetPoint("TOPLEFT", 12, -12)
    U.listScroll = ScrollArea(listPanel, 208, 231, 12, -43)
    U.profileRows = {}
    U.listEmpty = Text(U.listScroll.content, 12, color.muted, 187, 140)
    U.listEmpty:SetPoint("TOPLEFT", 4, -14)
    U.listEmpty:SetSpacing(4)
    U.listEmpty:SetText(L["No profiles yet. Configure your graphics in the game options, then save your current settings."])
    U.create = Button(listPanel, L["Save current settings"], 208, 32)
    U.create:SetPoint("BOTTOMLEFT", 12, 12)
    U.create:SetScript("OnClick", function() NameDialog("create") end)

    local detail = Surface(U.profilePanel, 494, 338)
    detail:SetPoint("TOPLEFT", 250, 0)
    U.detail = detail
    U.profileName = Text(detail, 19, color.accent, 312, 29)
    U.profileName:SetPoint("TOPLEFT", 16, -13)
    U.profileName:SetWordWrap(false)
    local nameTooltip = CreateFrame("Frame", nil, detail)
    nameTooltip:SetSize(312, 29)
    nameTooltip:SetPoint("TOPLEFT", 16, -13)
    nameTooltip:EnableMouse(true)
    nameTooltip:SetScript("OnEnter", function(self)
        local profile = Selected()
        if profile then Tooltip(self, Plain(profile.name)) end
    end)
    nameTooltip:SetScript("OnLeave", HideTooltip)
    U.favorite = Button(detail, L["Favorite"], 96, 25)
    U.favorite:SetPoint("TOPRIGHT", -56, -15)
    U.favorite.tooltipTitle = L["Quick access"]
    U.favorite.tooltipText = L["Keep up to three favorite profiles in the quick bar."]
    U.favorite:SetScript("OnClick", function()
        local profile = Selected()
        if profile and not F.busy then F.ToggleFavorite(profile.id) end
    end)
    U.menuButton = Button(detail, "...", 30, 25)
    U.menuButton:SetPoint("TOPRIGHT", -16, -15)
    U.menuButton.tooltipTitle = L["Profile actions"]
    U.status = Text(detail, 12, color.muted, 462, 30)
    U.status:SetPoint("TOPLEFT", 16, -49)
    U.status:SetSpacing(2)
    U.summaryTabs = {}
    U.summaryTabs.normal = Button(detail, L["General"], 110, 25)
    U.summaryTabs.normal:SetPoint("TOPLEFT", 16, -87)
    U.summaryTabs.raid = Button(detail, L["Raid / instance"], 145, 25)
    U.summaryTabs.raid:SetPoint("LEFT", U.summaryTabs.normal, "RIGHT", 6, 0)
    U.summaryTabs.normal:SetScript("OnClick", function() U.SetSummaryMode("normal") end)
    U.summaryTabs.raid:SetScript("OnClick", function() U.SetSummaryMode("raid") end)
    U.summaryScroll = ScrollArea(detail, 462, 155, 16, -125)
    U.summaryRows = {}
    U.summaryEmpty = Text(U.summaryScroll, 13, color.muted, 405, 95)
    U.summaryEmpty:SetPoint("TOPLEFT", 4, -10)
    U.summaryEmpty:SetSpacing(4)
    U.summaryEmpty:SetText(L["Save a profile to see its graphics settings here."])
    U.apply = Button(detail, L["Apply profile"], 174, 32, true)
    U.apply:SetPoint("BOTTOMRIGHT", -16, 12)
    U.apply:SetScript("OnClick", function()
        local profile = Selected()
        if profile and not F.busy then F.ApplyProfile(profile.id) end
    end)
    U.update = Button(detail, L["Update"], 128, 32)
    U.update:SetPoint("BOTTOMLEFT", 16, 12)
    U.update.tooltipTitle = L["Update saved settings"]
    U.update.tooltipText = L["Replace this profile with your current game settings."]
    U.update:SetScript("OnClick", function()
        local profile = Selected()
        if profile then ConfirmDialog("update", profile) end
    end)
    U.restore = Button(U.profilePanel, L["Restore previous settings"], 255, 32)
    U.restore:SetPoint("BOTTOMLEFT", 0, 12)
    U.restore.tooltipTitle = L["Restore previous settings"]
    U.restore.tooltipText = L["Return to the settings captured just before your last profile application."]
    U.restore:SetScript("OnClick", function() if not F.busy then F.RestorePrevious() end end)
    local selectionHint = Text(U.profilePanel, 11, color.muted, 450, 32)
    selectionHint:SetPoint("LEFT", U.restore, "RIGHT", 20, 0)
    selectionHint:SetJustifyV("MIDDLE")
    selectionHint:SetText(L["Selecting a profile does not apply it."])

    -- An owned dismissal layer avoids touching Blizzard's global dropdowns.
    U.menuBlocker = CreateFrame("Frame", nil, window)
    U.menuBlocker:SetAllPoints(UIParent)
    U.menuBlocker:SetFrameLevel(window:GetFrameLevel() + 15)
    U.menuBlocker:EnableMouse(true)
    U.menuBlocker:SetScript("OnMouseDown", CloseMenu)
    U.menuBlocker:Hide()
    U.menu = CreateFrame("Frame", "ForeverProfilesMenu", window)
    U.menu:SetSize(152, 106)
    U.menu:SetPoint("TOPRIGHT", U.menuButton, "BOTTOMRIGHT", 0, -4)
    U.menu:SetFrameLevel(window:GetFrameLevel() + 16)
    U.menu:EnableMouse(true)
    Skin(U.menu, color.background)
    U.menu:SetScript("OnHide", function()
        U.menuBlocker:Hide()
        U.menuProfileID = nil
    end)
    U.menu:Hide()
    UISpecialFrames[#UISpecialFrames + 1] = "ForeverProfilesMenu"
    U.rename = Button(U.menu, L["Rename"], 136, 26)
    U.rename:SetPoint("TOPLEFT", 8, -8)
    U.duplicate = Button(U.menu, L["Duplicate"], 136, 26)
    U.duplicate:SetPoint("TOPLEFT", 8, -40)
    U.delete = Button(U.menu, L["Delete"], 136, 26)
    U.delete:SetPoint("TOPLEFT", 8, -72)
    local function MenuProfile()
        return (U.menuProfileID and F.Profiles.Get(U.menuProfileID)) or Selected()
    end
    U.rename:SetScript("OnClick", function()
        local profile = MenuProfile()
        CloseMenu()
        if profile then NameDialog("rename", profile) end
    end)
    U.duplicate:SetScript("OnClick", function()
        local profile = MenuProfile()
        CloseMenu()
        if profile then NameDialog("duplicate", profile) end
    end)
    U.delete:SetScript("OnClick", function()
        local profile = MenuProfile()
        CloseMenu()
        if profile then ConfirmDialog("delete", profile) end
    end)
    U.menuButton:SetScript("OnClick", function()
        if U.menu:IsShown() then CloseMenu(); return end
        local profile = Selected()
        if not profile or F.busy then return end
        U.menuProfileID = profile.id
        U.menuBlocker:Show()
        U.menu:Show()
    end)

    U.barPanel = Surface(window, 744, 398)
    U.barPanel:SetPoint("TOPLEFT", 18, -60)
    local barTitle = Text(U.barPanel, 18, color.accent, 680, 26)
    barTitle:SetPoint("TOPLEFT", 16, -12)
    barTitle:SetText(L["Favorite bar"])
    local barHelp = Text(U.barPanel, 12, color.muted, 700, 34)
    barHelp:SetPoint("TOPLEFT", 16, -44)
    barHelp:SetSpacing(2)
    barHelp:SetText(L["Choose up to three profiles for one-click access. Add or remove them with Favorite in the Profiles tab."])
    U.quickCheck = CreateFrame("CheckButton", nil, U.barPanel, "UICheckButtonTemplate")
    U.quickCheck:SetSize(26, 26)
    U.quickCheck:SetPoint("TOPLEFT", 12, -90)
    U.quickCheck.label = Text(U.barPanel, 12, color.text, 260, 28)
    U.quickCheck.label:SetPoint("LEFT", U.quickCheck, "RIGHT", 5, 0)
    U.quickCheck.label:SetJustifyV("MIDDLE")
    U.quickCheck.label:SetText(L["Show favorite quick bar"])
    U.quickCheck:SetScript("OnClick", function(self) F.SetQuickBarVisible(self:GetChecked() and true or false) end)
    U.quickCheck:SetScript("OnEnter", function(self)
        Tooltip(self, L["Show favorite quick bar"], L["Apply a favorite profile in one click. Drag the dotted handle to move the bar."])
    end)
    U.quickCheck:SetScript("OnLeave", HideTooltip)
    U.quickLock = CreateFrame("CheckButton", nil, U.barPanel, "UICheckButtonTemplate")
    U.quickLock:SetSize(26, 26)
    U.quickLock:SetPoint("TOPLEFT", 330, -90)
    U.quickLock.label = Text(U.barPanel, 12, color.text, 300, 28)
    U.quickLock.label:SetPoint("LEFT", U.quickLock, "RIGHT", 5, 0)
    U.quickLock.label:SetJustifyV("MIDDLE")
    U.quickLock.label:SetText(L["Lock favorite bar"])
    U.quickLock:SetScript("OnClick", function(self) F.SetQuickBarLocked(self:GetChecked() and true or false) end)
    U.quickLock:SetScript("OnEnter", function(self)
        Tooltip(self, L["Lock favorite bar"], L["Keep the bar in place and hide its drag handle."])
    end)
    U.quickLock:SetScript("OnLeave", HideTooltip)
    U.quickWidth, U.quickWidthLabel, U.quickWidthValue = QuickBarSlider(U.barPanel,
        L["Favorite bar width"], 230, 160, 1000, 10, function(_, value)
        if U.refreshingDimensions then return end
        F.SetQuickBarWidth(math.max(160, math.min(1000, math.floor(value / 10 + 0.5) * 10)))
    end, L["Adjust the bar width without changing its height or text size."])
    U.quickHeight, U.quickHeightLabel, U.quickHeightValue = QuickBarSlider(U.barPanel,
        L["Favorite bar height"], 194, 28, 120, 2, function(_, value)
        if U.refreshingDimensions then return end
        F.SetQuickBarHeight(math.max(28, math.min(120, math.floor(value / 2 + 0.5) * 2)))
    end, L["Adjust the bar height without changing its width or text size."])
    U.quickScale, U.quickScaleLabel, U.quickScaleValue = QuickBarSlider(U.barPanel,
        L["Favorite bar scale"], 158, 60, 180, 10, function(_, value)
        if U.refreshingScale then return end
        local percent = math.max(60, math.min(180, math.floor(value / 10 + 0.5) * 10))
        F.SetQuickBarScale(percent / 100)
    end, L["Resize the whole bar, including its buttons and text. You can also use the mouse wheel over its dotted handle."])
    U.quickWidthAuto = Button(U.barPanel, L["Auto width"], 82, 24)
    U.quickWidthAuto:SetPoint("BOTTOMLEFT", 646, 230)
    U.quickWidthAuto.tooltipTitle = L["Auto width"]
    U.quickWidthAuto.tooltipText = L["Restore automatic width based on the number of favorite profiles."]
    U.quickWidthAuto:SetScript("OnClick", function() F.SetQuickBarWidth(nil) end)
    local favoriteHeading = Text(U.barPanel, 13, color.accent, 680, 20)
    favoriteHeading:SetPoint("TOPLEFT", 16, -258)
    favoriteHeading:SetText(L["Favorite shortcuts (up to 3)"])
    U.favoriteSlots = {}
    for index = 1, 3 do
        local button = Button(U.barPanel, "", 712, 28)
        button:SetPoint("TOPLEFT", 16, -286 - (index - 1) * 36)
        button.label:SetJustifyH("LEFT")
        button.slot = index
        button:SetScript("OnClick", function(self)
            local profile = F.Profiles.Favorites()[self.slot]
            U.SelectTab("profiles")
            if profile then
                Select(profile.id)
            else
                U.SetNotice(L["Select a profile and click Favorite to add it to favorites."])
            end
        end)
        U.favoriteSlots[index] = button
    end

    U.tabs = {}
    U.tabs.profiles = Button(window, L["Profiles"], 120, 30)
    U.tabs.profiles:SetPoint("BOTTOMLEFT", 18, 10)
    U.tabs.favorites = Button(window, L["Favorite bar"], 150, 30)
    U.tabs.favorites:SetPoint("LEFT", U.tabs.profiles, "RIGHT", 6, 0)
    U.tabs.profiles:SetScript("OnClick", function() U.SelectTab("profiles") end)
    U.tabs.favorites:SetScript("OnClick", function() U.SelectTab("favorites") end)
    U.activeTab = U.activeTab or "profiles"
    U.profilePanel:SetShown(U.activeTab == "profiles")
    U.barPanel:SetShown(U.activeTab == "favorites")
    for key, button in pairs(U.tabs) do
        button.selected = U.activeTab == key
        PaintButton(button)
    end
    U.notice = Text(window, 12, color.muted, 742, 32)
    U.notice:SetPoint("BOTTOMLEFT", 19, 48)
    U.notice:SetSpacing(2)
    window:SetScript("OnShow", function()
        Fit(window, WIDTH, HEIGHT)
        U.Refresh()
    end)
    window:SetScript("OnHide", function()
        window:StopMovingOrSizing()
        CloseMenu()
        if U.modal then U.modal:Hide() end
        HideTooltip()
    end)
    window:Hide()
    return window
end

function U.SelectTab(tab)
    if tab ~= "profiles" and tab ~= "favorites" then return end
    U.Initialize()
    CloseMenu()
    if U.modal then U.modal:Hide() end
    U.activeTab = tab
    U.profilePanel:SetShown(tab == "profiles")
    U.barPanel:SetShown(tab == "favorites")
    for key, button in pairs(U.tabs) do
        button.selected = key == tab
        PaintButton(button)
    end
    U.Refresh()
end

function U.SetSummaryMode(mode)
    if mode ~= "normal" and mode ~= "raid" then return end
    U.summaryMode = mode
    U.summarySelection = nil
    CloseMenu()
    if U.summaryScroll then RefreshSummary(Selected()) end
end

function U.SetNotice(message, isError)
    U.noticeMessage, U.noticeError = message, isError
    if U.notice then
        U.notice:SetText(message or "")
        U.notice:SetTextColor(unpack(isError and color.warning or color.muted))
    end
end

function U.Refresh()
    U.RefreshQuickBar()
    if not U.window or not U.window:IsShown() or not DB() then return end
    local profiles = F.Profiles.List()
    local profile = Selected()
    if not profile and profiles[1] then
        F.Profiles.SetSelected(profiles[1].id)
        profile = profiles[1]
    end
    local favorites = FavoriteMap()
    if F.busy or (U.menuProfileID and (not profile or U.menuProfileID ~= profile.id)) then CloseMenu() end
    U.listTitle:SetText(L["Profiles"] .. "  (" .. #profiles .. ")")
    for index, item in ipairs(profiles) do
        local row = U.profileRows[index]
        if not row then
            row = ProfileRow(U.listScroll.content, U.listScroll.content:GetWidth())
            U.profileRows[index] = row
        end
        row:SetPoint("TOPLEFT", 0, -(index - 1) * 62)
        row.profile = item
        row.selected = profile and profile.id == item.id
        row.title:SetText(Plain(item.name))
        local status = Status(item.id)
        row.status:SetText(status .. (favorites[item.id] and ("  /  " .. L["Favorite"]) or ""))
        row.status:SetTextColor(unpack(StatusColor(status)))
        row.indicator:SetShown(row.selected)
        row.background:SetColorTexture(unpack(row.selected and { 0.205, 0.165, 0.09, 1 } or { 0.105, 0.095, 0.075, 1 }))
        row:Show()
    end
    for index = #profiles + 1, #U.profileRows do U.profileRows[index]:Hide() end
    U.listEmpty:SetShown(#profiles == 0)
    U.listScroll:SetContentHeight(#profiles * 62)
    if profile and U.listSelection ~= profile.id then
        for index, item in ipairs(profiles) do
            if item.id == profile.id then
                local top = (index - 1) * 62
                local offset = U.listScroll.slider:GetValue()
                if top < offset then
                    U.listScroll.slider:SetValue(top)
                elseif top + 56 > offset + U.listScroll:GetHeight() then
                    U.listScroll.slider:SetValue(math.min(U.listScroll.maximum, top + 56 - U.listScroll:GetHeight()))
                end
                break
            end
        end
    end
    U.listSelection = profile and profile.id
    local canEdit = profile and not F.busy
    Enabled(U.create, not F.busy)
    for _, button in ipairs({ U.rename, U.duplicate, U.update, U.delete, U.apply, U.favorite, U.menuButton }) do
        Enabled(button, canEdit)
    end
    if U.modal then Enabled(U.modal.accept, not F.busy) end
    Enabled(U.restore, not F.busy and F.CanRestore and F.CanRestore())
    U.profileName:SetText(profile and Plain(profile.name) or L["Your first profile"])
    U.favorite.selected = profile and favorites[profile.id] or false
    U.favorite.label:SetText(U.favorite.selected and L["Favorited"] or L["Favorite"])
    U.favorite.tooltipText = U.favorite.selected and L["Click to remove this profile from favorites."]
        or L["Keep up to three favorite profiles in the quick bar."]
    PaintButton(U.favorite)
    local status = profile and Status(profile.id) or L["Save your current configuration to get started."]
    U.status:SetText(F.busy and L["Applying settings..."] or status)
    U.status:SetTextColor(unpack(StatusColor(status)))
    RefreshSummary(profile)
    local db = DB()
    U.quickCheck:SetChecked(db.ui and db.ui.quickBarVisible or false)
    U.quickLock:SetChecked(db.ui and db.ui.quickBarLocked or false)
    local barWidth, barHeight = F.GetQuickBarDimensions()
    U.refreshingDimensions = true
    U.quickWidth:SetValue(barWidth)
    U.quickWidthValue:SetText(string.format("%d px", barWidth))
    U.quickHeight:SetValue(barHeight)
    U.quickHeightValue:SetText(string.format("%d px", barHeight))
    U.refreshingDimensions = nil
    Enabled(U.quickWidthAuto, db.ui and db.ui.quickBarWidth ~= nil)
    local barScale = db.ui and db.ui.quickBarScale or 1
    U.refreshingScale = true
    U.quickScale:SetValue(barScale * 100)
    U.quickScaleValue:SetText(string.format("%.0f%%", barScale * 100))
    U.refreshingScale = nil
    local favoriteProfiles = F.Profiles.Favorites()
    for index, button in ipairs(U.favoriteSlots) do
        local favorite = favoriteProfiles[index]
        button.label:SetText(L["Favorite " .. index] .. ": " .. (favorite and Plain(favorite.name) or L["No favorite"]))
        button.tooltipTitle = favorite and Plain(favorite.name) or L["No favorite"]
        button.tooltipText = favorite and L["Click to view this profile. Selecting it does not apply it."]
            or L["Select a profile and click Favorite to add it to favorites."]
    end
    U.SetNotice(U.noticeMessage or L["Changes made in the game options do not overwrite your saved profiles."], U.noticeError)
end

function U.Show()
    local window = U.Initialize()
    window:Show()
    window:Raise()
    U.Refresh()
end

function U.Toggle()
    if U.window and U.window:IsShown() then U.window:Hide() else U.Show() end
end

local function CreateQuickBar()
    local bar = CreateFrame("Frame", "ForeverProfilesQuickBar", UIParent)
    bar:SetFrameStrata("MEDIUM")
    bar:SetSize(501, 44)
    bar:SetMovable(true)
    bar:SetClampedToScreen(true)
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    Skin(bar, color.background)
    Position(bar, "quickBarPosition", "TOP", "TOP", 0, -125)
    local function StartDrag()
        local db = DB()
        if db and db.ui.quickBarLocked then return end
        HideTooltip()
        bar.moving = true
        bar:StartMoving()
    end
    local function StopDrag()
        if not bar.moving then return end
        SavePosition(bar, "quickBarPosition")
        bar.moving = nil
    end
    bar:SetScript("OnDragStart", StartDrag)
    bar:SetScript("OnDragStop", StopDrag)
    bar:SetScript("OnHide", function()
        if bar.moving then StopDrag() else bar:StopMovingOrSizing() end
        HideTooltip()
    end)
    bar.grip = CreateFrame("Frame", nil, bar)
    bar.grip:SetSize(18, 30)
    bar.grip:SetPoint("LEFT", 7, 0)
    bar.grip:EnableMouse(true)
    bar.grip:EnableMouseWheel(true)
    bar.grip:RegisterForDrag("LeftButton")
    bar.grip:SetScript("OnDragStart", StartDrag)
    bar.grip:SetScript("OnDragStop", StopDrag)
    bar.grip.dots = {}
    for index = 1, 6 do
        local dot = bar.grip:CreateTexture(nil, "ARTWORK")
        dot:SetSize(3, 3)
        dot:SetPoint("TOPLEFT", 4 + ((index - 1) % 2) * 7, -6 - math.floor((index - 1) / 2) * 7)
        dot:SetColorTexture(unpack(color.muted))
        bar.grip.dots[index] = dot
    end
    bar.grip:SetScript("OnEnter", function(self)
        for _, dot in ipairs(self.dots) do dot:SetColorTexture(unpack(color.accent)) end
        Tooltip(self, L["Move favorite bar"], L["Drag this handle to move the bar. Use the mouse wheel to change its size."])
    end)
    bar.grip:SetScript("OnLeave", function(self)
        for _, dot in ipairs(self.dots) do dot:SetColorTexture(unpack(color.muted)) end
        HideTooltip()
    end)
    bar.grip:SetScript("OnMouseWheel", function(_, delta)
        local db = DB()
        if db and db.ui.quickBarLocked then return end
        local scale = db and db.ui and db.ui.quickBarScale or 1
        F.SetQuickBarScale(math.max(0.6, math.min(1.8, scale + delta * 0.1)))
    end)
    bar.handle = Button(bar, "FP", 38, 30)
    bar.handle:SetPoint("LEFT", 31, 0)
    bar.handle.tooltipTitle = "Forever Profiles"
    bar.handle.tooltipText = L["Click to open profiles."]
    bar.handle:SetScript("OnClick", U.Toggle)
    bar.buttons = {}
    for index = 1, 3 do
        local button = Button(bar, "", 136, 30)
        button:SetPoint("LEFT", 75 + (index - 1) * 142, 0)
        button:SetScript("OnClick", function(self)
            if self.profile and not F.busy then F.ApplyProfile(self.profile.id) end
        end)
        bar.buttons[index] = button
    end
    bar.empty = Text(bar, 11, color.muted, 275, 30)
    bar.empty:SetPoint("LEFT", 77, 0)
    bar.empty:SetJustifyV("MIDDLE")
    bar.empty:SetWordWrap(false)
    bar.empty:SetText(L["Choose favorite profiles in the main window."])
    U.quickBar = bar
    return bar
end

function U.RefreshQuickBar()
    local db = DB()
    if not db or not db.ui or not db.ui.quickBarVisible then
        if U.quickBar then U.quickBar:Hide() end
        return
    end
    local bar = U.quickBar or CreateQuickBar()
    local locked = db.ui.quickBarLocked == true
    if locked and bar.moving then
        SavePosition(bar, "quickBarPosition")
        bar.moving = nil
    end
    bar:SetMovable(not locked)
    bar.grip:SetShown(not locked)
    local start = locked and 51 or 75
    bar.handle:ClearAllPoints()
    bar.handle:SetPoint("LEFT", locked and 7 or 31, 0)
    bar.empty:ClearAllPoints()
    bar.empty:SetPoint("LEFT", start + 2, 0)
    local favorites = F.Profiles.Favorites()
    local count = math.min(3, #favorites)
    local width, height = F.GetQuickBarDimensions()
    local requestedScale = db.ui.quickBarScale or 1
    local availableWidth = math.max(1, UIParent:GetWidth() - 32)
    local availableHeight = math.max(1, UIParent:GetHeight() - 32)
    -- Constrain each dimension separately: narrowing a bar to fit the screen
    -- must not shrink its height or change the size of its text.
    width = math.min(width, availableWidth / requestedScale)
    height = math.min(height, availableHeight / requestedScale)
    bar:SetSize(width, height)
    local buttonHeight = math.max(14, height - 14)
    bar.handle:SetSize(38, buttonHeight)
    bar.handle.label:SetSize(26, buttonHeight)
    bar.grip:SetSize(18, buttonHeight)
    local dotSpacing = math.min(7, (buttonHeight - 3) / 2)
    for index, dot in ipairs(bar.grip.dots) do
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", bar.grip, "CENTER", (index - 1) % 2 == 0 and -3.5 or 3.5,
            (1 - math.floor((index - 1) / 2)) * dotSpacing)
    end
    local buttonWidth = (width - start) / math.max(1, count) - 6
    for index, button in ipairs(bar.buttons) do
        button:ClearAllPoints()
        button:SetPoint("LEFT", start + (index - 1) * (buttonWidth + 6), 0)
        button:SetSize(buttonWidth, buttonHeight)
        button.label:SetSize(math.max(1, buttonWidth - 12), buttonHeight)
        local profile = favorites[index]
        if profile and type(profile) ~= "table" then profile = F.Profiles.Get(profile) end
        button.profile = profile
        button:SetShown(profile ~= nil)
        if profile then
            button.label:SetText(Plain(profile.name))
            button.tooltipTitle = Plain(profile.name)
            button.tooltipText = F.busy and L["Applying settings..."] or L["Click to apply this profile."]
            Enabled(button, not F.busy)
            local status = Status(profile.id)
            button.selected = status == L["Active"]
            PaintButton(button)
        end
    end
    bar.empty:SetShown(count == 0)
    bar.empty:SetSize(width - start - 16, buttonHeight)
    bar:SetScale(requestedScale)
    bar:Show()
end
