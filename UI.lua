local _, F = ...
local U = {}
F.UI = U

local L = F.L
local WIDTH, HEIGHT = 780, 540
local color = {
    background = { 0.045, 0.055, 0.070, 0.98 },
    panel = { 0.075, 0.090, 0.115, 1 },
    border = { 0.19, 0.24, 0.30, 1 },
    text = { 0.91, 0.94, 0.97, 1 },
    muted = { 0.64, 0.70, 0.78, 1 },
    accent = { 0.44, 0.77, 0.96, 1 },
    active = { 0.55, 0.83, 0.65, 1 },
    warning = { 0.98, 0.73, 0.39, 1 },
}

local function Plain(value)
    return (tostring(value or ""):gsub("|", "||"))
end

local function ShortName(name)
    -- Stored names have already been validated as UTF-8. Leave room for the
    -- translated copy suffix without cutting an accented character in half.
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

local function Fill(parent, tint, layer)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetAllPoints()
    texture:SetColorTexture(unpack(tint))
    return texture
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
    Fill(panel, tint or color.panel)
    local bottom = panel:CreateTexture(nil, "BORDER")
    bottom:SetColorTexture(unpack(color.border))
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(1)
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

local function Button(parent, label, width, height, primary)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height or 30)
    button.primary = primary
    button.background = Fill(button, primary and { 0.15, 0.37, 0.50, 1 } or { 0.12, 0.15, 0.19, 1 })
    button.label = Text(button, 12, color.text, width - 12, height or 30)
    button.label:SetPoint("CENTER")
    button.label:SetJustifyH("CENTER")
    button.label:SetJustifyV("MIDDLE")
    button.label:SetWordWrap(false)
    button.label:SetText(label)
    button:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            self.background:SetColorTexture(unpack(self.primary and { 0.20, 0.46, 0.60, 1 } or { 0.17, 0.22, 0.28, 1 }))
        end
        if self.tooltipTitle then Tooltip(self, self.tooltipTitle, self.tooltipText) end
    end)
    button:SetScript("OnLeave", function(self)
        self.background:SetColorTexture(unpack(self.primary and { 0.15, 0.37, 0.50, 1 } or { 0.12, 0.15, 0.19, 1 }))
        HideTooltip()
    end)
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
    Fill(holder.slider, { 0.10, 0.13, 0.17, 1 })
    local thumb = holder.slider:CreateTexture(nil, "ARTWORK")
    thumb:SetColorTexture(0.33, 0.43, 0.52, 1)
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

local function Selected()
    local db = DB()
    return db and F.Profiles.Get(db.lastSelectedID)
end

local function Select(id)
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
    Fill(modal, { 0.015, 0.020, 0.030, 0.88 })
    local panel = Surface(modal, 450, 260, color.background)
    panel:SetPoint("CENTER")
    panel:SetFrameLevel(modal:GetFrameLevel() + 1)
    modal.panel = panel
    modal.title = Text(panel, 18, color.text, 406, 28)
    modal.title:SetPoint("TOPLEFT", 22, -20)
    modal.body = Text(panel, 12, color.muted, 406, 64)
    modal.body:SetPoint("TOPLEFT", 22, -58)
    modal.body:SetSpacing(3)
    modal.editSurface = Surface(panel, 406, 34, { 0.11, 0.14, 0.18, 1 })
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
    local summaries = snapshot and F.Graphics and F.Graphics.GetSummary(snapshot) or {}
    local lastGroup, y, rowIndex = nil, 0, 0
    local groups = {
        normal = L["World graphics"],
        raid = L["Raid and battleground graphics"],
        common = L["Shared options"],
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
    row.background = Fill(row, { 0.085, 0.105, 0.135, 1 })
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
        self.background:SetColorTexture(0.13, 0.19, 0.25, 1)
        if self.profile then Tooltip(self, Plain(self.profile.name), L["Select this profile to view its saved settings."]) end
    end)
    row:SetScript("OnLeave", function(self)
        self.background:SetColorTexture(unpack(self.selected and { 0.11, 0.21, 0.28, 1 } or { 0.085, 0.105, 0.135, 1 }))
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
    Fill(window, color.background)
    Position(window, "windowPosition", "CENTER", "CENTER", 0, 0)
    local drag = CreateFrame("Frame", nil, window)
    drag:SetPoint("TOPLEFT")
    drag:SetPoint("TOPRIGHT", -58, 0)
    drag:SetHeight(50)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() window:StartMoving() end)
    drag:SetScript("OnDragStop", function() SavePosition(window, "windowPosition") end)
    local title = Text(window, 23, color.text, 600, 30)
    title:SetPoint("TOPLEFT", 20, -17)
    title:SetText("Forever Profiles")
    local close = Button(window, "X", 28, 28)
    close:SetPoint("TOPRIGHT", -16, -16)
    close.tooltipTitle = L["Close"]
    close:SetScript("OnClick", function() window:Hide() end)
    UISpecialFrames[#UISpecialFrames + 1] = "ForeverProfilesWindow"

    local listPanel = Surface(window, 232, 352)
    listPanel:SetPoint("TOPLEFT", 18, -64)
    U.listTitle = Text(listPanel, 13, color.muted, 208, 20)
    U.listTitle:SetPoint("TOPLEFT", 12, -12)
    U.listScroll = ScrollArea(listPanel, 208, 245, 12, -43)
    U.profileRows = {}
    U.listEmpty = Text(U.listScroll.content, 12, color.muted, 187, 140)
    U.listEmpty:SetPoint("TOPLEFT", 4, -14)
    U.listEmpty:SetSpacing(4)
    U.listEmpty:SetText(L["No profiles yet. Configure your graphics in the game options, then save your current settings."])
    U.create = Button(listPanel, L["Save current settings"], 208, 32, true)
    U.create:SetPoint("BOTTOMLEFT", 12, 12)
    U.create:SetScript("OnClick", function() NameDialog("create") end)

    local detail = Surface(window, 494, 352)
    detail:SetPoint("TOPLEFT", 268, -64)
    U.detail = detail
    U.profileName = Text(detail, 19, color.text, 316, 29)
    U.profileName:SetPoint("TOPLEFT", 16, -13)
    U.profileName:SetWordWrap(false)
    U.favorite = Button(detail, L["Favorite"], 128, 25)
    U.favorite:SetPoint("TOPRIGHT", -16, -15)
    U.favorite.tooltipTitle = L["Quick access"]
    U.favorite.tooltipText = L["Keep up to three favorite profiles in the quick bar."]
    U.favorite:SetScript("OnClick", function()
        local profile = Selected()
        if profile and not F.busy then F.ToggleFavorite(profile.id) end
    end)
    U.status = Text(detail, 12, color.muted, 462, 22)
    U.status:SetPoint("TOPLEFT", 16, -47)
    U.rename = Button(detail, L["Rename"], 88, 28)
    U.rename:SetPoint("TOPLEFT", 16, -79)
    U.rename:SetScript("OnClick", function() local p = Selected(); if p then NameDialog("rename", p) end end)
    U.duplicate = Button(detail, L["Duplicate"], 92, 28)
    U.duplicate:SetPoint("LEFT", U.rename, "RIGHT", 8, 0)
    U.duplicate:SetScript("OnClick", function() local p = Selected(); if p then NameDialog("duplicate", p) end end)
    U.update = Button(detail, L["Update"], 104, 28)
    U.update:SetPoint("LEFT", U.duplicate, "RIGHT", 8, 0)
    U.update.tooltipTitle = L["Update saved settings"]
    U.update.tooltipText = L["Replace this profile with your current game settings."]
    U.update:SetScript("OnClick", function() local p = Selected(); if p then ConfirmDialog("update", p) end end)
    U.delete = Button(detail, L["Delete"], 82, 28)
    U.delete:SetPoint("LEFT", U.update, "RIGHT", 8, 0)
    U.delete:SetScript("OnClick", function() local p = Selected(); if p then ConfirmDialog("delete", p) end end)
    U.summaryScroll = ScrollArea(detail, 462, 166, 16, -128)
    U.summaryRows = {}
    U.summaryEmpty = Text(U.summaryScroll, 13, color.muted, 405, 95)
    U.summaryEmpty:SetPoint("TOPLEFT", 4, -10)
    U.summaryEmpty:SetSpacing(4)
    U.summaryEmpty:SetText(L["Save a profile to see its graphics settings here."])
    U.apply = Button(detail, L["Apply profile"], 190, 32, true)
    U.apply:SetPoint("BOTTOMRIGHT", -16, 12)
    U.apply:SetScript("OnClick", function()
        local profile = Selected()
        if profile and not F.busy then F.ApplyProfile(profile.id) end
    end)
    local applyHint = Text(detail, 10, color.muted, 235, 31)
    applyHint:SetPoint("BOTTOMLEFT", 16, 12)
    applyHint:SetJustifyV("MIDDLE")
    applyHint:SetText(L["Selecting a profile does not apply it."])

    U.restore = Button(window, L["Restore previous settings"], 255, 32)
    U.restore:SetPoint("BOTTOMLEFT", 18, 80)
    U.restore.tooltipTitle = L["Restore previous settings"]
    U.restore.tooltipText = L["Return to the settings captured just before your last profile application."]
    U.restore:SetScript("OnClick", function() if not F.busy then F.RestorePrevious() end end)
    U.quickCheck = CreateFrame("CheckButton", nil, window, "UICheckButtonTemplate")
    U.quickCheck:SetSize(26, 26)
    U.quickCheck:SetPoint("BOTTOMLEFT", 363, 88)
    U.quickCheck.label = Text(window, 12, color.text, 168, 28)
    U.quickCheck.label:SetPoint("LEFT", U.quickCheck, "RIGHT", 5, 0)
    U.quickCheck.label:SetJustifyV("MIDDLE")
    U.quickCheck.label:SetText(L["Show favorite quick bar"])
    U.quickCheck:SetScript("OnClick", function(self) F.SetQuickBarVisible(self:GetChecked() and true or false) end)
    U.quickCheck:SetScript("OnEnter", function(self)
        Tooltip(self, L["Show favorite quick bar"], L["Apply a favorite profile in one click. Drag the dotted handle to move the bar."])
    end)
    U.quickCheck:SetScript("OnLeave", HideTooltip)
    U.quickLock = CreateFrame("CheckButton", nil, window, "UICheckButtonTemplate")
    U.quickLock:SetSize(26, 26)
    U.quickLock:SetPoint("BOTTOMLEFT", 570, 88)
    U.quickLock.label = Text(window, 12, color.text, 161, 28)
    U.quickLock.label:SetPoint("LEFT", U.quickLock, "RIGHT", 5, 0)
    U.quickLock.label:SetJustifyV("MIDDLE")
    U.quickLock.label:SetText(L["Lock favorite bar"])
    U.quickLock:SetScript("OnClick", function(self) F.SetQuickBarLocked(self:GetChecked() and true or false) end)
    U.quickLock:SetScript("OnEnter", function(self)
        Tooltip(self, L["Lock favorite bar"], L["Keep the bar in place and hide its drag handle."])
    end)
    U.quickLock:SetScript("OnLeave", HideTooltip)
    U.quickScaleLabel = Text(window, 11, color.muted, 141, 20)
    U.quickScaleLabel:SetPoint("BOTTOMLEFT", 363, 60)
    U.quickScaleLabel:SetJustifyV("MIDDLE")
    U.quickScaleLabel:SetText(L["Favorite bar size"])
    U.quickScale = CreateFrame("Slider", nil, window)
    U.quickScale:SetSize(174, 24)
    U.quickScale:SetPoint("BOTTOMLEFT", 512, 58)
    U.quickScale:SetOrientation("HORIZONTAL")
    U.quickScale:SetMinMaxValues(60, 180)
    U.quickScale:SetValueStep(10)
    if U.quickScale.SetObeyStepOnDrag then U.quickScale:SetObeyStepOnDrag(true) end
    local scaleTrack = U.quickScale:CreateTexture(nil, "BACKGROUND")
    scaleTrack:SetPoint("LEFT")
    scaleTrack:SetPoint("RIGHT")
    scaleTrack:SetHeight(4)
    scaleTrack:SetColorTexture(unpack(color.border))
    local scaleThumb = U.quickScale:CreateTexture(nil, "ARTWORK")
    scaleThumb:SetSize(12, 20)
    scaleThumb:SetColorTexture(unpack(color.accent))
    U.quickScale:SetThumbTexture(scaleThumb)
    U.quickScale:SetScript("OnValueChanged", function(_, value)
        if U.refreshingScale then return end
        local percent = math.max(60, math.min(180, math.floor(value / 10 + 0.5) * 10))
        F.SetQuickBarScale(percent / 100)
    end)
    U.quickScale:SetScript("OnEnter", function(self)
        Tooltip(self, L["Favorite bar size"], L["Resize the whole bar, including its buttons and text. You can also use the mouse wheel over its dotted handle."])
    end)
    U.quickScale:SetScript("OnLeave", HideTooltip)
    U.quickScaleValue = Text(window, 12, color.text, 60, 24)
    U.quickScaleValue:SetPoint("BOTTOMLEFT", 702, 58)
    U.quickScaleValue:SetJustifyV("MIDDLE")
    U.quickScaleValue:SetJustifyH("RIGHT")
    U.notice = Text(window, 12, color.muted, 742, 40)
    U.notice:SetPoint("BOTTOMLEFT", 19, 14)
    U.notice:SetSpacing(3)
    window:SetScript("OnShow", function()
        Fit(window, WIDTH, HEIGHT)
        U.Refresh()
    end)
    window:SetScript("OnHide", function()
        if U.modal then U.modal:Hide() end
        HideTooltip()
    end)
    window:Hide()
    return window
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
        row.background:SetColorTexture(unpack(row.selected and { 0.11, 0.21, 0.28, 1 } or { 0.085, 0.105, 0.135, 1 }))
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
    for _, button in ipairs({ U.rename, U.duplicate, U.update, U.delete, U.apply, U.favorite }) do
        Enabled(button, canEdit)
    end
    Enabled(U.restore, not F.busy and F.CanRestore and F.CanRestore())
    U.profileName:SetText(profile and Plain(profile.name) or L["Your first profile"])
    U.favorite.label:SetText(profile and favorites[profile.id] and L["Remove favorite"] or L["Favorite"])
    local status = profile and Status(profile.id) or L["Save your current configuration to get started."]
    U.status:SetText(F.busy and L["Applying settings..."] or status)
    U.status:SetTextColor(unpack(StatusColor(status)))
    RefreshSummary(profile)
    local db = DB()
    U.quickCheck:SetChecked(db.ui and db.ui.quickBarVisible or false)
    U.quickLock:SetChecked(db.ui and db.ui.quickBarLocked or false)
    local barScale = db.ui and db.ui.quickBarScale or 1
    U.refreshingScale = true
    U.quickScale:SetValue(barScale * 100)
    U.quickScaleValue:SetText(string.format("%.0f%%", barScale * 100))
    U.refreshingScale = nil
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
    Fill(bar, color.background)
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
    for index, button in ipairs(bar.buttons) do
        button:ClearAllPoints()
        button:SetPoint("LEFT", start + (index - 1) * 142, 0)
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
            button.label:SetTextColor(unpack(status == L["Active"] and color.accent or color.text))
        end
    end
    bar.empty:SetShown(count == 0)
    bar:SetWidth(count == 0 and start + 293 or start + count * 142)
    local requestedScale = db.ui.quickBarScale or 1
    local availableWidth = math.max(1, UIParent:GetWidth() - 32)
    local availableHeight = math.max(1, UIParent:GetHeight() - 32)
    bar:SetScale(math.min(requestedScale, availableWidth / bar:GetWidth(), availableHeight / 44))
    bar:Show()
end
