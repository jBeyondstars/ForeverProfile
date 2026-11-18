local addonName, F = ...
local L, P, G = F.L, F.Profiles, F.Graphics
F.results = {}

local MONITOR_INTERVAL = 0.25
local MAX_FRAME_STEP = 0.5
local monitorAccumulator = 0
local lowFPSElapsed = 0
local automationTriggered = false
local recoveryElapsed = 0
local recoveryTriggered = false

local function IsSecret(value)
    if type(issecretvalue) == "function" then
        local ok, secret = pcall(issecretvalue, value)
        return not ok or secret
    end
    return false
end

local function Refresh()
    if F.UI then F.UI.Refresh() end
end

function F.ResetAutomationState()
    monitorAccumulator = 0
    lowFPSElapsed = 0
    automationTriggered = false
    recoveryElapsed = 0
    recoveryTriggered = false
end

function F.IsWindowFocused()
    if F.windowFocused ~= nil then return F.windowFocused == true end
    if type(IsWindowFocused) == "function" then
        local ok, focused = pcall(IsWindowFocused)
        if ok and not IsSecret(focused) and type(focused) == "boolean" then
            return focused
        end
    end
    return true
end

function F.SetWindowFocused(focused)
    if IsSecret(focused) then return end
    if focused == nil then
        F.windowFocused = nil
    else
        F.windowFocused = focused == true
    end
    if not F.IsWindowFocused() then
        lowFPSElapsed = 0
        recoveryElapsed = 0
    end
end

function F.GetCurrentFPS()
    if type(GetFramerate) ~= "function" then return nil end
    local ok, fps = pcall(GetFramerate)
    if not ok or IsSecret(fps) then return nil end
    if type(fps) ~= "number" or fps ~= fps or fps <= 0 or fps == math.huge then return nil end
    return fps
end

function F.Notify(message, isError)
    local prefix = isError and "|cffffb38aForever Profiles|r: " or "|cffd7b46bForever Profiles|r: "
    print(prefix .. message)
    if F.UI then F.UI.SetNotice(message, isError); Refresh() end
end

local function Error(message)
    message = L[message or "Settings could not be applied."]
    F.Notify(message, true)
    return nil, message
end

local function CanAct()
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    if F.busy then return Error("Wait for the current switch to finish.") end
    return true
end

local function Changed(profile, message)
    P.SetSelected(profile.id)
    F.Notify(F.Format(message, profile.name))
    return profile
end

function F.CreateProfile(name)
    if not CanAct() then return nil end
    local snapshot, err = G.Capture()
    if not snapshot then return Error(err) end
    local profile, createError = P.Create(name, snapshot)
    if not profile then return Error(createError) end
    return Changed(profile, "Saved profile: %s.")
end

function F.UpdateProfile(id)
    if not CanAct() then return nil end
    local snapshot, err = G.Capture()
    if not snapshot then return Error(err) end
    local profile, updateError = P.Update(id, snapshot)
    if not profile then return Error(updateError) end
    F.results[id] = nil
    F.ResetAutomationState()
    return Changed(profile, "Updated profile: %s.")
end

function F.RenameProfile(id, name)
    if not CanAct() then return nil end
    local profile, err = P.Rename(id, name)
    if not profile then return Error(err) end
    return Changed(profile, "Renamed profile: %s.")
end

function F.DuplicateProfile(id, name)
    if not CanAct() then return nil end
    local profile, err = P.Duplicate(id, name)
    if not profile then return Error(err) end
    return Changed(profile, "Duplicated profile: %s.")
end

function F.ExportProfile(id)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    local payload, err = P.Export(id)
    if not payload then return Error(err) end
    return payload
end

function F.ImportProfile(payload, name)
    if not CanAct() then return nil end
    local profile, err = P.Import(payload, name)
    if not profile then return Error(err) end
    return Changed(profile, "Imported profile: %s.")
end

function F.DeleteProfile(id)
    if not CanAct() then return nil end
    local profile = P.Get(id)
    if not profile then return Error("Profile not found.") end
    local name = profile.name
    local ok, err = P.Delete(id)
    if not ok then return Error(err) end
    F.results[id] = nil
    F.ResetAutomationState()
    F.Notify(F.Format("Deleted profile: %s.", name))
    return true
end

function F.ToggleFavorite(id)
    if not CanAct() then return nil end
    local ok, err = P.ToggleFavorite(id)
    if not ok then return Error(err) end
    Refresh()
    return true
end

function F.GetAutomation()
    if not F.ready then return nil end
    local auto = P.GetAutomation()
    if not auto then return nil end
    auto.elapsed = lowFPSElapsed
    auto.triggered = automationTriggered
    auto.recoveryElapsed = recoveryElapsed
    auto.currentFPS = F.GetCurrentFPS()
    return auto
end

function F.ConfigureAutomation(options)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    local auto, err = P.SetAutomation(options)
    if not auto then return Error(err) end
    F.ResetAutomationState()
    Refresh()
    return auto
end

function F.SetAutomationEnabled(enabled)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    if IsSecret(enabled) then return Error("Invalid automation settings.") end
    local auto, err = P.SetAutomation({ enabled = enabled == true })
    if not auto then return Error(err) end
    F.ResetAutomationState()
    Refresh()
    return auto.enabled
end

function F.SetAutomationCriterion(criterion)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    local auto, err = P.SetAutomation({ criterion = criterion })
    if not auto then return Error(err) end
    F.ResetAutomationState()
    Refresh()
    return auto.criterion
end

function F.SetAutomationFPSThreshold(fps)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    local auto, err = P.SetAutomation({ fpsThreshold = fps })
    if not auto then return Error(err) end
    F.ResetAutomationState()
    Refresh()
    return auto.fpsThreshold
end

function F.SetAutomationDuration(seconds)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    local auto, err = P.SetAutomation({ duration = seconds })
    if not auto then return Error(err) end
    F.ResetAutomationState()
    Refresh()
    return auto.duration
end

function F.SetAutomationProfile(id)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    if IsSecret(id) then return Error("Profile not found.") end
    local auto, err = P.SetAutomation({ profileID = id == nil and false or id })
    if not auto then return Error(err) end
    F.ResetAutomationState()
    Refresh()
    return auto.profileID
end

function F.SetQuickBarVisible(visible)
    if not F.ready then return end
    P.GetDB().ui.quickBarVisible = visible == true
    Refresh()
end

function F.SetQuickBarLocked(locked)
    if not F.ready then return end
    P.GetDB().ui.quickBarLocked = locked == true
    Refresh()
end

function F.SetQuickBarScale(scale)
    if not F.ready or type(scale) ~= "number" or scale ~= scale
        or scale == math.huge or scale == -math.huge then return end
    scale = math.floor(math.max(0.6, math.min(1.8, scale)) * 100 + 0.5) / 100
    P.GetDB().ui.quickBarScale = scale
    Refresh()
    return scale
end

function F.GetQuickBarDimensions()
    if not F.ready then return end
    local ui = P.GetDB().ui
    local count = math.min(3, #P.Favorites())
    local start = ui.quickBarLocked and 51 or 75
    local automaticWidth = count == 0 and start + 293 or start + count * 142
    return ui.quickBarWidth or automaticWidth, ui.quickBarHeight or 44
end

local function SetBarDimension(key, value, minimum, maximum)
    if not F.ready or type(value) ~= "number" or value ~= value
        or value == math.huge or value == -math.huge then return end
    value = math.floor(math.max(minimum, math.min(maximum, value)) + 0.5)
    P.GetDB().ui[key] = value
    Refresh()
    return value
end

function F.SetQuickBarWidth(width)
    if not F.ready then return end
    if width == nil then
        P.GetDB().ui.quickBarWidth = nil
        Refresh()
        local actualWidth = F.GetQuickBarDimensions()
        return actualWidth
    end
    return SetBarDimension("quickBarWidth", width, 160, 1000)
end

function F.SetQuickBarHeight(height)
    return SetBarDimension("quickBarHeight", height, 28, 120)
end

function F.GetProfileStatus(id)
    local profile = P.Get(id)
    if not profile then return L["Profile not found."], false end
    local comparison = G.Compare(profile.modules.graphics)
    if comparison.matches then return L["Active"], true end
    if F.results[id] and not F.results[id].success then return L["Applied partially"], false end
    return L["Modified"], false
end

function F.CanRestore()
    return F.ready and F.previousSnapshot ~= nil and not F.busy
end

-- Recheck after the client and other addons have processed CVar callbacks.
-- An accepted write does not prove that the requested configuration remained active.
local function Apply(snapshot, id, name, restoring, autoMessage)
    local valid, err = G.Validate(snapshot)
    if not valid then return Error(err) end
    local previous
    if not restoring then
        local comparison = G.Compare(snapshot)
        if comparison.matches then
            F.Notify(autoMessage or F.Format("Profile applied: %s.", name))
            return {success = true, total = comparison.total, unchanged = comparison.total, applied = 0, failed = {}, skipped = {}}
        end
        local captureError
        previous, captureError = G.Capture()
        if not previous then return Error(captureError) end
    end
    F.busy = true
    F.Notify(F.Format("Applying %s…", name))
    local ok, result = pcall(G.Apply, snapshot)
    if not ok or type(result) ~= "table" then
        if previous and not G.Compare(previous).matches then F.previousSnapshot = previous end
        F.busy = false
        return Error("Settings could not be applied.")
    end
    local function Finish()
        local comparison = G.Compare(snapshot)
        if previous and not G.Compare(previous).matches then F.previousSnapshot = previous end
        result.success = comparison.matches
        result.matched = comparison.matched
        result.differences = comparison.differences
        F.busy = false
        if id then F.results[id] = result end
        if restoring and comparison.matches then F.previousSnapshot = nil end
        if comparison.matches then
            F.Notify(restoring and L["Previous settings restored."]
                or autoMessage
                or F.Format("Profile applied: %s.", name))
        else
            F.Notify(F.Format("%s: %d of %d settings match. Open the profile for details.",
                name, comparison.matched or 0, comparison.total or 0), true)
        end
    end
    if C_Timer and C_Timer.After then C_Timer.After(0.35, Finish) else Finish() end
    return result
end

local function ApplyAutomaticProfile(rawProfile, threshold, duration, message)
    if G.Compare(rawProfile.modules.graphics).matches then return false end
    local profile = P.Get(rawProfile.id)
    if not profile then return false end
    P.SetSelected(profile.id)
    Apply(profile.modules.graphics, profile.id, profile.name, false,
        F.Format(message, profile.name, threshold, duration))
    return true
end

function F.EvaluateAutomation(elapsed, overrideFPS)
    if not F.ready or F.busy or F.inLoadingScreen then return false end
    if IsSecret(elapsed) or IsSecret(overrideFPS) then return false end
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed <= 0 or elapsed == math.huge then
        return false
    end
    local db = P.GetDB()
    local auto = db and db.automation
    local dropProfile = auto and auto.profileID and db.profiles[auto.profileID]
    if not auto or not auto.enabled or auto.criterion ~= "fps" or not dropProfile then
        lowFPSElapsed = 0
        automationTriggered = false
        recoveryElapsed = 0
        recoveryTriggered = false
        return false
    end
    if not F.IsWindowFocused() then
        lowFPSElapsed = 0
        recoveryElapsed = 0
        return false
    end
    local fps = overrideFPS ~= nil and overrideFPS or F.GetCurrentFPS()
    if type(fps) ~= "number" or fps ~= fps or fps <= 0 or fps == math.huge then
        lowFPSElapsed = 0
        recoveryElapsed = 0
        return false
    end

    if fps < auto.fpsThreshold then
        recoveryElapsed = 0
        recoveryTriggered = false
        if automationTriggered then return false end
        if lowFPSElapsed == 0 and G.Compare(dropProfile.modules.graphics).matches then
            automationTriggered = true
            return false
        end
        lowFPSElapsed = math.min(auto.duration, lowFPSElapsed + elapsed)
        if lowFPSElapsed + 0.000001 >= auto.duration then
            lowFPSElapsed = 0
            automationTriggered = true
            return ApplyAutomaticProfile(dropProfile, auto.fpsThreshold, auto.duration,
                "Auto-applied profile: %s (FPS below %d for %ds).")
        end
        return false
    end
    lowFPSElapsed = 0
    automationTriggered = false

    local recoveryProfile = auto.recoveryProfileID and db.profiles[auto.recoveryProfileID]
    if not recoveryProfile or recoveryProfile == dropProfile
        or auto.recoveryThreshold < auto.fpsThreshold or fps <= auto.recoveryThreshold then
        recoveryElapsed = 0
        recoveryTriggered = false
        return false
    end
    if recoveryTriggered then return false end
    if recoveryElapsed == 0 and not G.Compare(dropProfile.modules.graphics).matches then
        recoveryTriggered = true
        return false
    end
    recoveryElapsed = math.min(auto.recoveryDuration, recoveryElapsed + elapsed)
    if recoveryElapsed + 0.000001 < auto.recoveryDuration then return false end

    recoveryElapsed = 0
    recoveryTriggered = true
    -- Settings can change while the timer runs, including without a CVAR_UPDATE.
    if not G.Compare(dropProfile.modules.graphics).matches then return false end
    return ApplyAutomaticProfile(recoveryProfile, auto.recoveryThreshold, auto.recoveryDuration,
        "Auto-applied profile: %s (FPS above %d for %ds).")
end

function F.ApplyProfile(id)
    if not CanAct() then return nil end
    local profile = P.Get(id)
    if not profile then return Error("Profile not found.") end
    F.ResetAutomationState()
    P.SetSelected(id)
    return Apply(profile.modules.graphics, id, profile.name, false)
end

function F.RestorePrevious()
    if not CanAct() then return nil end
    if not F.previousSnapshot then return Error("No previous settings to restore.") end
    F.ResetAutomationState()
    return Apply(F.previousSnapshot, nil, L["Restore previous settings"], true)
end

function F.ApplyFavorite(slot)
    if not CanAct() then return nil end
    local profile = P.Favorites()[slot]
    if not profile then return Error("No favorite assigned to this slot.") end
    return F.ApplyProfile(profile.id)
end

function ForeverProfiles_Toggle()
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    F.UI.Toggle()
end
function ForeverProfiles_ApplyFavorite(slot) return F.ApplyFavorite(slot) end
function ForeverProfiles_Restore() return F.RestorePrevious() end

local function RegisterSettings()
    if F.settingsCategory or not Settings or not Settings.RegisterCanvasLayoutCategory
        or not Settings.RegisterAddOnCategory then return end
    local panel = CreateFrame("Frame")
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 24, -24)
    title:SetText("Forever Profiles")
    local help = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    help:SetPoint("TOPLEFT", 24, -60)
    help:SetPoint("RIGHT", panel, "RIGHT", -24, 0)
    help:SetJustifyH("LEFT")
    help:SetText(L["Open Forever Profiles to save and apply your graphics configurations."])
    local open = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    open:SetPoint("TOPLEFT", 24, -115)
    open:SetSize(240, 32)
    open:SetText(L["Open profiles"])
    open:SetScript("OnClick", function()
        if SettingsPanel and HideUIPanel then HideUIPanel(SettingsPanel) end
        F.UI.Show()
    end)
    F.settingsCategory = Settings.RegisterCanvasLayoutCategory(panel, "Forever Profiles")
    Settings.RegisterAddOnCategory(F.settingsCategory)
end

local function FindProfile(name)
    for _, profile in ipairs(P.List()) do
        if profile.id == name or string.lower(profile.name) == string.lower(name) then return profile end
    end
end

local function SlashAuto(argument)
    local sub = string.lower((argument or ""):match("^%s*(.-)%s*$"))
    if sub == "" then
        if F.UI then
            F.UI.Show()
            if F.UI.SelectTab then F.UI.SelectTab("automation") end
        end
        return
    elseif sub == "on" or sub == "enable" then
        F.SetAutomationEnabled(true)
        F.Notify(L["Automatic profile activation enabled."])
        return
    elseif sub == "off" or sub == "disable" then
        F.SetAutomationEnabled(false)
        F.Notify(L["Automatic profile activation disabled."])
        return
    elseif sub == "clear" or sub == "none" then
        F.ConfigureAutomation({ enabled = false, clearProfile = true, recoveryProfileID = false })
        F.Notify(L["Automatic profile activation cleared."])
        return
    end
    local rest = (argument or ""):gsub("^%s*[fF][pP][sS]%s+", "")
    local fpsRaw, secRaw, profileName = rest:match("^%s*(%d+)%s*[fF]?[pP]?[sS]?%s+(%d+)%s*[sS]?[eE]?[cC]?%s+(.-)%s*$")
    if fpsRaw and secRaw and profileName and profileName ~= "" then
        local profile = FindProfile(profileName)
        if not profile then return Error("Profile not found.") end
        local auto = F.ConfigureAutomation({
            enabled = true,
            criterion = "fps",
            fpsThreshold = tonumber(fpsRaw),
            duration = tonumber(secRaw),
            profileID = profile.id,
        })
        if auto then
            F.Notify(F.Format("Auto-switch enabled: FPS below %d for %ds -> %s.",
                auto.fpsThreshold, auto.duration, profile.name))
        end
        return
    end
    F.Notify("/fp auto  |  /fp auto on  |  /fp auto off  |  /fp auto <fps> <seconds> <profile>")
end

local function Slash(text)
    if not F.ready then return Error(F.startupError or "Addon is not ready.") end
    local command, argument = (text or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")
    if command == "" then F.UI.Toggle()
    elseif command == "save" then F.CreateProfile(argument)
    elseif command == "apply" then
        local profile = FindProfile(argument)
        if profile then F.ApplyProfile(profile.id) else Error("Profile not found.") end
    elseif command == "auto" then SlashAuto(argument)
    elseif command == "export" then
        local profile = (argument ~= "" and FindProfile(argument)) or (P.GetDB() and P.Get(P.GetDB().lastSelectedID))
        if profile then
            if F.UI and F.UI.OpenExportDialog then
                F.UI.Show()
                F.UI.OpenExportDialog(profile)
            else
                local payload = F.ExportProfile(profile.id)
                if payload then F.Notify(payload) end
            end
        else
            Error("Profile not found.")
        end
    elseif command == "import" then
        if argument ~= "" then
            F.ImportProfile(argument)
        elseif F.UI and F.UI.OpenImportDialog then
            F.UI.Show()
            F.UI.OpenImportDialog()
        else
            Error("Paste an export string to import.")
        end
    elseif command == "restore" then F.RestorePrevious()
    elseif command == "quick" then F.SetQuickBarVisible(not P.GetDB().ui.quickBarVisible)
    elseif command == "list" then
        for _, profile in ipairs(P.List()) do
            print("|cffd7b46bFP|r: " .. profile.name .. " (" .. F.GetProfileStatus(profile.id) .. ")")
        end
        if #P.List() == 0 then F.Notify(L["No profiles yet"]) end
    elseif command == "diagnostics" then
        local snapshot = G.Capture()
        local count = 0
        for _ in pairs(snapshot and snapshot.values or {}) do count = count + 1 end
        F.Notify(string.format("v%s | WoW %s (%s) | Interface %s | %d CVars | %d profiles",
            F.version, F.clientVersion or "?", F.clientBuild or "?", tostring(F.interfaceVersion or "?"), count, #P.List()))
    else
        F.Notify("/fp  |  /fp save <name>  |  /fp apply <name>  |  /fp auto  |  /fp export <name>  |  /fp import <string>  |  /fp restore  |  /fp quick  |  /fp list  |  /fp diagnostics")
    end
end

SLASH_FOREVERPROFILES1 = "/fp"
SLASH_FOREVERPROFILES2 = "/foreverprofiles"
SlashCmdList.FOREVERPROFILES = Slash

local catalogNames = {}
for _, entry in ipairs(G.catalog) do catalogNames[string.lower(entry.name)] = true end
local refreshPending
local events = CreateFrame("Frame")
F.events = events
events:SetScript("OnEvent", function(_, event, arg)
    if IsSecret(arg) then return end
    if event == "ADDON_LOADED" and arg == addonName then
        local version, build, date, tocVersion = GetBuildInfo()
        F.clientVersion, F.clientBuild, F.interfaceVersion = version, build, tocVersion
        local toc = tonumber(F.interfaceVersion)
        if not toc or toc < 16000 or toc >= 20000 then
            F.startupError = "This addon requires the WoW Forever client."
            F.Notify(L[F.startupError], true)
            return
        end
        local db, err = P.Initialize(ForeverProfilesDB)
        if not db then
            F.startupError = err
            F.Notify(L[err], true)
            return
        end
        ForeverProfilesDB = db
        F.ready = true
    elseif event == "PLAYER_LOGIN" and F.ready then
        pcall(RegisterSettings)
        F.UI.RefreshQuickBar()
    elseif event == "LOADING_SCREEN_ENABLED" then
        F.inLoadingScreen = true
        F.ResetAutomationState()
    elseif event == "LOADING_SCREEN_DISABLED" or event == "PLAYER_ENTERING_WORLD" then
        F.inLoadingScreen = false
        F.ResetAutomationState()
    elseif (event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED") and F.ready then
        if F.UI and F.UI.RefreshScale then F.UI.RefreshScale() end
        Refresh()
    elseif event == "CVAR_UPDATE" and F.ready and not F.busy then
        if type(arg) ~= "string" or not catalogNames[string.lower(arg)] then return end
        automationTriggered = false
        recoveryElapsed = 0
        recoveryTriggered = false
        if refreshPending then return end
        refreshPending = true
        local function Update()
            refreshPending = nil
            if not F.busy then Refresh() end
        end
        if C_Timer and C_Timer.After then C_Timer.After(0.2, Update) else Update() end
    end
end)
events:SetScript("OnUpdate", function(_, elapsed)
    if not F.ready or F.inLoadingScreen then return end
    if IsSecret(elapsed) then return end
    if type(elapsed) ~= "number" or elapsed ~= elapsed or elapsed <= 0 or elapsed == math.huge then return end
    local step = math.min(elapsed, MAX_FRAME_STEP)
    local triggered = F.EvaluateAutomation(step)
    monitorAccumulator = monitorAccumulator + step
    if triggered or monitorAccumulator >= MONITOR_INTERVAL then
        monitorAccumulator = 0
        if F.UI and F.UI.RefreshAutomationStatus
            and (triggered or (F.UI.window and F.UI.window:IsShown() and F.UI.autoPanel and F.UI.autoPanel:IsShown())) then
            F.UI.RefreshAutomationStatus()
        end
    end
end)
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("CVAR_UPDATE")
pcall(events.RegisterEvent, events, "UI_SCALE_CHANGED")
pcall(events.RegisterEvent, events, "DISPLAY_SIZE_CHANGED")
pcall(events.RegisterEvent, events, "LOADING_SCREEN_ENABLED")
pcall(events.RegisterEvent, events, "LOADING_SCREEN_DISABLED")
pcall(events.RegisterEvent, events, "PLAYER_ENTERING_WORLD")
