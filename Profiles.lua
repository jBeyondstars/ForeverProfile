local _, F = ...

local P = {}
F.Profiles = P

local MAX_PROFILES = 40
local MAX_FAVORITES = 3
local MAX_ID = 1000000000
local MAX_SCAN = 200
local db

local function L(message)
    return F.L and F.L[message] or message
end

local function IsFinite(value)
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function IsInteger(value)
    return IsFinite(value) and value == math.floor(value)
end

local function Timestamp()
    if type(time) == "function" then
        local ok, value = pcall(time)
        if ok and IsFinite(value) then return value end
    end
    return 0
end

-- SavedVariables should be plain data. Bound recursive copies so corrupt data
-- cannot create unbounded allocations or carry executable values into profiles.
local function CopyData(value, state, depth)
    state = state or { count = 0, seen = {} }
    depth = depth or 0
    local kind = type(value)
    if kind == "number" then
        if not IsFinite(value) then return nil, false end
        return value, true
    elseif kind == "string" then
        if #value > 8192 then return nil, false end
        return value, true
    elseif kind == "boolean" or kind == "nil" then
        return value, true
    elseif kind ~= "table" or depth > 8 or state.seen[value] then
        return nil, false
    end

    state.seen[value] = true
    local result = {}
    for key, item in pairs(value) do
        state.count = state.count + 1
        if state.count > (state.limit or 2048) then return nil, false end
        local keyKind = type(key)
        if not ((keyKind == "string" and #key <= 128) or (keyKind == "number" and IsFinite(key))) then
            return nil, false
        end
        local copy, ok = CopyData(item, state, depth + 1)
        if not ok then return nil, false end
        result[key] = copy
    end
    state.seen[value] = nil
    return result, true
end

local function UTF8Length(value)
    local count, index = 0, 1
    while index <= #value do
        local first = string.byte(value, index)
        local width
        if first < 128 then width = 1
        elseif first >= 194 and first <= 223 then width = 2
        elseif first >= 224 and first <= 239 then width = 3
        elseif first >= 240 and first <= 244 then width = 4
        else return nil end

        if index + width - 1 > #value then return nil end
        for offset = 1, width - 1 do
            local continuation = string.byte(value, index + offset)
            if continuation < 128 or continuation > 191 then return nil end
        end
        local second = string.byte(value, index + 1)
        if (first == 224 and second < 160) or (first == 237 and second > 159)
            or (first == 240 and second < 144) or (first == 244 and second > 143) then
            return nil
        end
        count = count + 1
        index = index + width
    end
    return count
end

local function NormalizeName(name)
    if type(name) ~= "string" then return nil, L("Enter a profile name.") end
    if #name > 1024 then return nil, L("Profile names must be 100 bytes or fewer.") end
    if string.find(name, "[%z\1-\31\127|]") then
        return nil, L("Profile names cannot contain control characters or |.")
    end
    name = string.gsub(string.gsub(name, "^%s+", ""), "%s+$", "")
    if name == "" then return nil, L("Enter a profile name.") end
    if #name > 100 then return nil, L("Profile names must be 100 bytes or fewer.") end
    local length = UTF8Length(name)
    if not length then return nil, L("Profile names must use valid UTF-8.") end
    if length > 48 then return nil, L("Profile names must be 48 characters or fewer.") end
    return name
end

local function IDNumber(id)
    if type(id) ~= "string" or #id > 11 or not string.match(id, "^p%d+$") then return nil end
    local number = tonumber(string.sub(id, 2))
    if not IsInteger(number) or number < 1 or number > MAX_ID or id ~= "p" .. tostring(number) then return nil end
    return number
end

local function ValidateSnapshot(snapshot)
    if type(snapshot) ~= "table" then return nil, L("Invalid graphics snapshot.") end
    local copy, copied = CopyData({ values = snapshot.values })
    if not copied then return nil, L("Profile data is too large or invalid.") end
    if not F.Graphics or type(F.Graphics.Validate) ~= "function" then
        return nil, L("Graphics settings are unavailable.")
    end
    local ok, valid, err = pcall(F.Graphics.Validate, copy)
    if not ok or not valid then return nil, err or L("Invalid graphics snapshot.") end
    return copy
end

local function HasName(name, exceptID)
    local lowered = string.lower(name)
    for _, id in ipairs(db.order) do
        local profile = db.profiles[id]
        if profile and id ~= exceptID and string.lower(profile.name) == lowered then return true end
    end
    return false
end

local function RequireDB()
    if not db then return nil, L("Profile storage is unavailable.") end
    return true
end

local function FindProfile(id)
    if not db then return nil, L("Profile storage is unavailable.") end
    if type(id) ~= "string" or not db.profiles[id] then return nil, L("Profile not found.") end
    return db.profiles[id]
end

local function SanitizeTime(value)
    if IsFinite(value) and value >= 0 and value < 1000000000000 then return value end
    return 0
end

local POINTS = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true,
    LEFT = true, CENTER = true, RIGHT = true,
    BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}

local function SanitizePosition(position)
    if type(position) ~= "table" or not POINTS[position.point] or not POINTS[position.relativePoint]
        or not IsFinite(position.x) or not IsFinite(position.y)
        or math.abs(position.x) > 10000 or math.abs(position.y) > 10000 then return nil end
    return { point = position.point, relativePoint = position.relativePoint, x = position.x, y = position.y }
end

local function SanitizeProfile(id, raw)
    if not IDNumber(id) or type(raw) ~= "table" or (raw.id ~= nil and raw.id ~= id) then return nil end
    local name = NormalizeName(raw.name)
    if not name or type(raw.modules) ~= "table" then return nil end
    local snapshot = ValidateSnapshot(raw.modules.graphics)
    if not snapshot then return nil end
    local modules = { graphics = snapshot }
    local scanned, retained = 0, 0
    local budget = { count = 0, seen = {}, limit = 1900 }
    local _, graphicsFits = CopyData(snapshot, budget, 2)
    if not graphicsFits then return nil end
    -- Preserve valid future modules without invoking their code. Malformed
    -- optional modules do not invalidate an otherwise usable graphics profile.
    for key, value in pairs(raw.modules) do
        scanned = scanned + 1
        if scanned > 32 then break end
        if key ~= "graphics" and type(key) == "string" and #key <= 64 and string.match(key, "^[%w_]+$") then
            local before = budget.count
            -- A module lives two levels below the complete profile. Validate
            -- using that depth so a retained module remains readable later.
            local copy, ok = CopyData(value, budget, 2)
            if ok and copy ~= nil then
                modules[key] = copy
                retained = retained + 1
                if retained >= 16 then break end
            else
                budget.count = before
                budget.seen = {}
            end
        end
    end
    local profile = {
        id = id, name = name,
        createdAt = SanitizeTime(raw.createdAt), updatedAt = SanitizeTime(raw.updatedAt),
        modules = modules,
    }
    local _, complete = CopyData(profile)
    if complete then return profile end
end

function P.Initialize(saved)
    if type(saved) == "table" and saved.schemaVersion ~= nil and saved.schemaVersion ~= 1 then
        db = nil
        if type(saved.schemaVersion) == "number" and saved.schemaVersion > 1 then
            return nil, L("This saved data version is newer than the addon.")
        end
        return nil, L("Unsupported saved data version.")
    end

    local result = {
        schemaVersion = 1, nextID = 1, profiles = {}, order = {}, favorites = {},
        ui = { quickBarVisible = false, quickBarScale = 1, quickBarLocked = false }, lastSelectedID = nil,
    }
    if type(saved) ~= "table" then db = result; return result end

    local rawProfiles = type(saved.profiles) == "table" and saved.profiles or {}
    local names, maxID = {}, 0
    local function Retain(id)
        if #result.order >= MAX_PROFILES or result.profiles[id] then return end
        local profile = SanitizeProfile(id, rawProfiles[id])
        if not profile or names[string.lower(profile.name)] then return end
        names[string.lower(profile.name)] = true
        result.profiles[id] = profile
        result.order[#result.order + 1] = id
        maxID = math.max(maxID, IDNumber(id))
    end

    if type(saved.order) == "table" then
        for index = 1, MAX_SCAN do
            local id = saved.order[index]
            if IDNumber(id) then Retain(id) end
        end
    end
    local candidateIDs, scanned = {}, 0
    for id in pairs(rawProfiles) do
        scanned = scanned + 1
        if scanned > MAX_SCAN then break end
        if IDNumber(id) and not result.profiles[id] then candidateIDs[#candidateIDs + 1] = id end
    end
    table.sort(candidateIDs, function(left, right) return IDNumber(left) < IDNumber(right) end)
    for _, id in ipairs(candidateIDs) do Retain(id) end

    if IsInteger(saved.nextID) and saved.nextID >= 1 and saved.nextID <= MAX_ID + 1 then
        result.nextID = saved.nextID
    end
    result.nextID = math.max(result.nextID, maxID + 1)
    if type(saved.favorites) == "table" then
        local seen = {}
        for index = 1, MAX_SCAN do
            local id = saved.favorites[index]
            if type(id) == "string" and result.profiles[id] and not seen[id] then
                seen[id] = true
                result.favorites[#result.favorites + 1] = id
                if #result.favorites >= MAX_FAVORITES then break end
            end
        end
    end
    if type(saved.lastSelectedID) == "string" and result.profiles[saved.lastSelectedID] then
        result.lastSelectedID = saved.lastSelectedID
    end
    if type(saved.ui) == "table" then
        result.ui.quickBarVisible = saved.ui.quickBarVisible == true
        result.ui.quickBarLocked = saved.ui.quickBarLocked == true
        if IsFinite(saved.ui.quickBarScale) then
            result.ui.quickBarScale = math.max(0.6, math.min(1.8, saved.ui.quickBarScale))
        end
        result.ui.windowPosition = SanitizePosition(saved.ui.windowPosition)
        result.ui.quickBarPosition = SanitizePosition(saved.ui.quickBarPosition)
    end
    db = result
    return result
end

local function AddProfile(name, modules)
    if #db.order >= MAX_PROFILES then return nil, L("Maximum of 40 profiles reached.") end
    local number = db.nextID
    while number <= MAX_ID and db.profiles["p" .. tostring(number)] do number = number + 1 end
    if number > MAX_ID then return nil, L("No more profile IDs are available.") end
    local id = "p" .. tostring(number)
    local now = Timestamp()
    local profile = { id = id, name = name, createdAt = now, updatedAt = now, modules = modules }
    local copy, copied = CopyData(profile)
    if not copied then return nil, L("Profile data is too large or invalid.") end
    db.nextID = number + 1
    db.profiles[id] = profile
    db.order[#db.order + 1] = id
    db.lastSelectedID = id
    return copy
end

function P.Create(name, snapshot)
    local ready, err = RequireDB()
    if not ready then return nil, err end
    name, err = NormalizeName(name)
    if not name then return nil, err end
    if HasName(name) then return nil, L("That profile name already exists.") end
    local copy
    copy, err = ValidateSnapshot(snapshot)
    if not copy then return nil, err end
    return AddProfile(name, { graphics = copy })
end

function P.Update(id, snapshot)
    local profile, err = FindProfile(id)
    if not profile then return nil, err end
    local copy
    copy, err = ValidateSnapshot(snapshot)
    if not copy then return nil, err end
    local candidate, copied = CopyData(profile)
    if not copied then return nil, L("Profile data is too large or invalid.") end
    candidate.modules.graphics = copy
    candidate.updatedAt = Timestamp()
    local copyProfile, complete = CopyData(candidate)
    if not complete then return nil, L("Profile data is too large or invalid.") end
    db.profiles[id] = candidate
    return copyProfile
end

function P.Rename(id, name)
    local profile, err = FindProfile(id)
    if not profile then return nil, err end
    name, err = NormalizeName(name)
    if not name then return nil, err end
    if HasName(name, id) then return nil, L("That profile name already exists.") end
    local candidate, copied = CopyData(profile)
    if not copied then return nil, L("Profile data is too large or invalid.") end
    candidate.name = name
    candidate.updatedAt = Timestamp()
    local copy, complete = CopyData(candidate)
    if not complete then return nil, L("Profile data is too large or invalid.") end
    db.profiles[id] = candidate
    return copy
end

local function ShortName(name, maxCharacters, maxBytes)
    local index, characters, finish = 1, 0, 0
    while index <= #name and characters < maxCharacters do
        local byte = string.byte(name, index)
        local width = byte < 128 and 1 or (byte < 224 and 2 or (byte < 240 and 3 or 4))
        if index + width - 1 > maxBytes then break end
        finish = index + width - 1
        index, characters = index + width, characters + 1
    end
    return string.sub(name, 1, finish)
end

function P.Duplicate(id, name)
    local profile, err = FindProfile(id)
    if not profile then return nil, err end
    if name == nil then
        for number = 2, MAX_PROFILES + 2 do
            local suffix = " (" .. tostring(number) .. ")"
            local candidate = ShortName(profile.name, 48 - #suffix, 100 - #suffix) .. suffix
            if not HasName(candidate) then name = candidate; break end
        end
    end
    name, err = NormalizeName(name)
    if not name then return nil, err end
    if HasName(name) then return nil, L("That profile name already exists.") end
    local modules, copied = CopyData(profile.modules)
    if not copied then return nil, L("Profile data is too large or invalid.") end
    return AddProfile(name, modules)
end

function P.Delete(id)
    local profile, err = FindProfile(id)
    if not profile then return nil, err end
    db.profiles[id] = nil
    for index = #db.order, 1, -1 do
        if db.order[index] == id then table.remove(db.order, index) end
    end
    for index = #db.favorites, 1, -1 do
        if db.favorites[index] == id then table.remove(db.favorites, index) end
    end
    if db.lastSelectedID == id then db.lastSelectedID = db.order[1] end
    return true
end

function P.ToggleFavorite(id)
    local profile, err = FindProfile(id)
    if not profile then return nil, err end
    for index, favoriteID in ipairs(db.favorites) do
        if favoriteID == id then table.remove(db.favorites, index); return true end
    end
    if #db.favorites >= MAX_FAVORITES then return nil, L("Maximum of 3 favorites reached.") end
    db.favorites[#db.favorites + 1] = id
    return true
end

function P.List()
    local result = {}
    if not db then return result end
    for _, id in ipairs(db.order) do
        local profile = db.profiles[id]
        if profile then result[#result + 1] = CopyData(profile) end
    end
    return result
end

function P.Get(id)
    local profile = FindProfile(id)
    if profile then
        local copy = CopyData(profile)
        return copy
    end
end

function P.Favorites()
    local result = {}
    if not db then return result end
    for _, id in ipairs(db.favorites) do
        local profile = db.profiles[id]
        if profile then result[#result + 1] = CopyData(profile) end
    end
    return result
end

function P.GetDB()
    return db
end

function P.SetSelected(id)
    local ready, err = RequireDB()
    if not ready then return nil, err end
    if id ~= nil then
        local profile
        profile, err = FindProfile(id)
        if not profile then return nil, err end
    end
    db.lastSelectedID = id
    return true
end

P.MAX_PROFILES = MAX_PROFILES
P.MAX_FAVORITES = MAX_FAVORITES
