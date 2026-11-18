local _, F = ...
local U = {}
F.UI = U

local L = F.L
local unpack = unpack or table.unpack
local WIDTH, HEIGHT = 780, 550
local LOGO_PATH = "Interface\\AddOns\\ForeverProfiles\\Media\\Logo"

-- ============================================================================
-- Direction A ("Forge royale") — Centralized Design System & Pixel-Perfect Engine
-- ============================================================================
local THEME = {
    direction = "A",
    name = "Forge royale",
    font = {
        hero = 20,
        title = 18,
        subtitle = 14,
        heading = 13,
        body = 12,
        caption = 11,
        micro = 10,
    },
    color = {
        -- Elevation Level 1: Main Window & Header
        backgroundTop    = { 0.106, 0.098, 0.082, 0.98 }, -- #1b1915
        backgroundBottom = { 0.051, 0.047, 0.039, 0.98 }, -- #0d0c0a
        background       = { 0.106, 0.098, 0.082, 0.98 },
        headerTop        = { 0.141, 0.129, 0.106, 1.00 }, -- #24211b
        headerBottom     = { 0.082, 0.075, 0.059, 1.00 }, -- #15130f

        -- Elevation Level 2: Panels & Recessed Wells
        panelTop         = { 0.086, 0.078, 0.067, 0.98 }, -- #161411
        panelBottom      = { 0.059, 0.055, 0.047, 0.98 }, -- #0f0e0c
        panel            = { 0.086, 0.078, 0.067, 0.98 },
        wellTop          = { 0.027, 0.027, 0.024, 0.98 }, -- #070706
        wellBottom       = { 0.043, 0.039, 0.035, 0.98 }, -- #0b0a09
        well             = { 0.027, 0.027, 0.024, 0.98 },

        -- Borders, Bevels & Shadows
        outer            = { 0.000, 0.000, 0.000, 1.00 }, -- #000000
        border           = { 0.353, 0.310, 0.231, 1.00 }, -- #5a4f3b
        borderSubtle     = { 0.200, 0.180, 0.145, 1.00 }, -- #332e25
        bevel            = { 1.000, 0.925, 0.784, 0.10 }, -- rgba(255,236,200,.10)
        shadow           = { 0.000, 0.000, 0.000, 0.65 },

        -- Typography
        text             = { 0.925, 0.886, 0.804, 1.00 }, -- #ece2cd
        textBright       = { 0.984, 0.961, 0.910, 1.00 }, -- #fbf5e8
        muted            = { 0.639, 0.604, 0.533, 1.00 }, -- #a39a88
        dim              = { 0.435, 0.408, 0.361, 1.00 }, -- #6f685c

        -- Gold Accents (Selection & Identity)
        accent           = { 0.847, 0.710, 0.420, 1.00 }, -- #d8b56b
        accentBright     = { 0.953, 0.839, 0.561, 1.00 }, -- #f3d68f

        -- Elevation Level 3: Profile Cards
        cardTop          = { 0.129, 0.118, 0.098, 1.00 }, -- #211e19
        cardBottom       = { 0.090, 0.082, 0.071, 1.00 }, -- #171512
        cardBorder       = { 0.227, 0.204, 0.165, 1.00 }, -- #3a342a
        cardHoverTop     = { 0.176, 0.161, 0.129, 1.00 }, -- #2d2921
        cardHoverBottom  = { 0.122, 0.110, 0.090, 1.00 }, -- #1f1c17
        cardHoverBorder  = { 0.478, 0.424, 0.322, 1.00 }, -- #7a6c52

        -- Selected Card State (Gold)
        selectedTop      = { 0.227, 0.184, 0.106, 1.00 }, -- #3a2f1b
        selectedBottom   = { 0.145, 0.118, 0.071, 1.00 }, -- #251e12
        selectedBorder   = { 0.890, 0.769, 0.486, 1.00 }, -- #e3c47c

        -- Active Profile State (Emerald)
        active           = { 0.282, 0.820, 0.541, 1.00 }, -- #48d18a
        activeBgTop      = { 0.078, 0.208, 0.141, 1.00 }, -- #143524
        activeBgBottom   = { 0.047, 0.137, 0.094, 1.00 }, -- #0c2318
        activeHoverTop   = { 0.110, 0.275, 0.188, 1.00 },
        activeHoverBottom= { 0.067, 0.184, 0.125, 1.00 },
        activeBorder     = { 0.247, 0.749, 0.486, 1.00 }, -- #3fbf7c

        -- Standard Buttons
        buttonTop        = { 0.165, 0.149, 0.125, 1.00 }, -- #2a2620
        buttonBottom     = { 0.110, 0.098, 0.082, 1.00 }, -- #1c1915
        buttonHoverTop   = { 0.224, 0.200, 0.165, 1.00 },
        buttonHoverBottom= { 0.149, 0.133, 0.110, 1.00 },
        buttonBorder     = { 0.353, 0.310, 0.231, 1.00 }, -- #5a4f3b

        -- Primary CTA (Crimson Ember)
        primaryTop       = { 0.576, 0.188, 0.122, 1.00 }, -- #93301f
        primaryBottom    = { 0.369, 0.102, 0.063, 1.00 }, -- #5e1a10
        primaryHoverTop  = { 0.690, 0.235, 0.157, 1.00 },
        primaryHoverBottom={ 0.455, 0.133, 0.082, 1.00 },
        primaryBorder    = { 0.851, 0.451, 0.310, 1.00 }, -- #d9734f
        primaryText      = { 1.000, 0.965, 0.918, 1.00 }, -- #fff6ea

        -- Danger / Delete (Crimson) & Warning (Amber)
        danger           = { 0.878, 0.322, 0.353, 1.00 }, -- #e0525a
        dangerTop        = { 0.380, 0.102, 0.118, 1.00 },
        dangerBottom     = { 0.235, 0.059, 0.071, 1.00 },
        dangerHoverTop   = { 0.510, 0.145, 0.165, 1.00 },
        dangerHoverBottom= { 0.325, 0.086, 0.102, 1.00 },
        warning          = { 0.980, 0.680, 0.320, 1.00 },

        -- Rows & Overlays
        rowAlt           = { 1.000, 1.000, 1.000, 0.025 },
        rowHover         = { 1.000, 1.000, 1.000, 0.060 },
        backdrop         = { 0.020, 0.018, 0.014, 0.88 },
    },
}

F.THEME = THEME
U.THEME = THEME
local color = THEME.color
THEME._scalables = {}

function THEME.RegisterScalable(item, refreshFn)
    if not item then return item end
    if refreshFn then item._refreshScaleItem = refreshFn end
    THEME._scalables[#THEME._scalables + 1] = item
    return item
end

function THEME.RefreshAllScales()
    for index = 1, #THEME._scalables do
        local item = THEME._scalables[index]
        if item and item._refreshScaleItem then
            item:_refreshScaleItem()
        end
    end
end

function THEME.ApplyPixelSnap(region)
    if not region then return region end
    if region.SetSnapToPixelGrid then region:SetSnapToPixelGrid(false) end
    if region.SetTexelSnappingBias then region:SetTexelSnappingBias(0) end
    return region
end

function THEME.Pixel(frame, pixels)
    local scale = (frame and frame.GetEffectiveScale and frame:GetEffectiveScale())
        or (UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale())
        or 1
    if type(scale) ~= "number" or scale <= 0 or scale ~= scale then scale = 1 end
    return (pixels or 1) / scale
end

function THEME.GetClassColor()
    if type(UnitClass) == "function" then
        local ok, _, classToken = pcall(UnitClass, "player")
        local palette = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
        if ok and classToken and type(palette) == "table" and palette[classToken] then
            local c = palette[classToken]
            if type(c.r) == "number" and type(c.g) == "number" and type(c.b) == "number" then
                return { c.r, c.g, c.b, 1 }
            end
        end
    end
    return color.accent
end

function THEME.CropIcon(texture, texturePath)
    if not texture then return nil end
    if texturePath and texture.SetTexture then texture:SetTexture(texturePath) end
    if texture.SetTexCoord then texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    return THEME.ApplyPixelSnap(texture)
end

local function SetColor(texture, tint)
    local c = tint or color.backgroundTop
    texture:SetColorTexture(c[1] or 0, c[2] or 0, c[3] or 0, c[4] ~= nil and c[4] or 1)
    return THEME.ApplyPixelSnap(texture)
end

function THEME.SetGradient(texture, orientation, startColor, endColor)
    if not texture then return nil end
    local s = startColor or color.backgroundTop
    local e = endColor or s
    local sr, sg, sb, sa = s[1] or 0, s[2] or 0, s[3] or 0, s[4] ~= nil and s[4] or 1
    local er, eg, eb, ea = e[1] or 0, e[2] or 0, e[3] or 0, e[4] ~= nil and e[4] or 1
    texture:SetColorTexture(1, 1, 1, 1)
    -- In WoW's SetGradient("VERTICAL", minColor, maxColor), minColor is at the bottom
    -- and maxColor is at the top. For "HORIZONTAL", minColor is left and maxColor is right.
    local minR, minG, minB, minA = sr, sg, sb, sa
    local maxR, maxG, maxB, maxA = er, eg, eb, ea
    if orientation == "VERTICAL" then
        minR, minG, minB, minA = er, eg, eb, ea
        maxR, maxG, maxB, maxA = sr, sg, sb, sa
    end
    local applied = false
    if type(CreateColor) == "function" and texture.SetGradient then
        local ok = pcall(texture.SetGradient, texture, orientation,
            CreateColor(minR, minG, minB, minA), CreateColor(maxR, maxG, maxB, maxA))
        applied = ok
    end
    if not applied and texture.SetGradientAlpha then
        local ok = pcall(texture.SetGradientAlpha, texture, orientation,
            minR, minG, minB, minA, maxR, maxG, maxB, maxA)
        applied = ok
    end
    if not applied and texture.SetGradient then
        local ok = pcall(texture.SetGradient, texture, orientation,
            minR, minG, minB, maxR, maxG, maxB)
        applied = ok
    end
    if not applied then
        texture:SetColorTexture(sr, sg, sb, sa)
    end
    THEME.ApplyPixelSnap(texture)
    texture._gradientOrientation = orientation
    texture._gradientStart = { sr, sg, sb, sa }
    texture._gradientEnd = { er, eg, eb, ea }
    return texture
end

local function Fill(parent, tint, layer, sublevel)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0)
    texture:SetAllPoints()
    return SetColor(texture, tint)
end

local function FillGradient(parent, topColor, bottomColor, layer, sublevel)
    local texture = parent:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0)
    texture:SetAllPoints()
    return THEME.SetGradient(texture, "VERTICAL", topColor, bottomColor)
end

local function Rim(parent, tint, insetPixels, layer, sublevel)
    local edges = {}
    local px = THEME.Pixel(parent, 1)
    local offset = (insetPixels or 0) * px
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local edge = parent:CreateTexture(nil, layer or "BORDER", nil, sublevel or 0)
        SetColor(edge, tint or color.border)
        if side == "TOP" then
            edge:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, -offset)
            edge:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -offset, -offset)
            edge:SetHeight(px)
        elseif side == "BOTTOM" then
            edge:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", offset, offset)
            edge:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset)
            edge:SetHeight(px)
        elseif side == "LEFT" then
            edge:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, -offset)
            edge:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", offset, offset)
            edge:SetWidth(px)
        else
            edge:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -offset, -offset)
            edge:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset)
            edge:SetWidth(px)
        end
        edges[#edges + 1] = edge
    end
    edges.insetPixels = insetPixels or 0
    function edges:SetColor(newTint)
        for index = 1, 4 do SetColor(self[index], newTint) end
    end
    function edges:RefreshScale()
        local unit = THEME.Pixel(parent, 1)
        local off = (self.insetPixels or 0) * unit
        self[1]:ClearAllPoints()
        self[1]:SetPoint("TOPLEFT", parent, "TOPLEFT", off, -off)
        self[1]:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -off, -off)
        self[1]:SetHeight(unit)
        self[2]:ClearAllPoints()
        self[2]:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", off, off)
        self[2]:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -off, off)
        self[2]:SetHeight(unit)
        self[3]:ClearAllPoints()
        self[3]:SetPoint("TOPLEFT", parent, "TOPLEFT", off, -off)
        self[3]:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", off, off)
        self[3]:SetWidth(unit)
        self[4]:ClearAllPoints()
        self[4]:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -off, -off)
        self[4]:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -off, off)
        self[4]:SetWidth(unit)
    end
    return edges
end

function THEME.DoubleRim(parent, innerTint, outerTint)
    local outer = Rim(parent, outerTint or color.outer, 0, "BORDER", 1)
    local inner = Rim(parent, innerTint or color.border, 1, "BORDER", 2)
    local group = { outer = outer, inner = inner }
    for index = 1, 4 do group[index] = inner[index] end
    function group:SetInnerColor(newTint)
        inner:SetColor(newTint)
    end
    function group:RefreshScale()
        outer:RefreshScale()
        inner:RefreshScale()
    end
    return group
end

function THEME.CreateSeparator(parent, orientation, startTint, endTint)
    local line = parent:CreateTexture(nil, "ARTWORK", nil, 1)
    local px = THEME.Pixel(parent, 1)
    if orientation == "VERTICAL" then
        line:SetWidth(px)
        THEME.SetGradient(line, "VERTICAL", startTint or color.border, endTint or { 0, 0, 0, 0 })
    else
        line:SetHeight(px)
        local s = startTint or color.border
        local e = endTint or { s[1], s[2], s[3], 0 }
        THEME.SetGradient(line, "HORIZONTAL", s, e)
    end
    local function RefreshSeparator(self)
        local unit = THEME.Pixel(parent, 1)
        if orientation == "VERTICAL" then
            self:SetWidth(unit)
        else
            self:SetHeight(unit)
        end
    end
    line.RefreshScale = RefreshSeparator
    THEME.RegisterScalable(line, RefreshSeparator)
    return line
end

-- Elevation Level 1: Main Window
function THEME.SkinWindow(frame)
    local px = THEME.Pixel(frame, 1)
    frame.bg = FillGradient(frame, color.backgroundTop, color.backgroundBottom, "BACKGROUND", 0)
    frame.rim = THEME.DoubleRim(frame, color.border, color.outer)
    frame.bevel = frame:CreateTexture(nil, "BORDER", nil, 3)
    frame.bevel:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 * px, -2 * px)
    frame.bevel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2 * px, -2 * px)
    frame.bevel:SetHeight(px)
    SetColor(frame.bevel, color.bevel)
    local function RefreshWindowItem(self)
        local unit = THEME.Pixel(self, 1)
        self.rim:RefreshScale()
        self.bevel:ClearAllPoints()
        self.bevel:SetPoint("TOPLEFT", self, "TOPLEFT", 2 * unit, -2 * unit)
        self.bevel:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2 * unit, -2 * unit)
        self.bevel:SetHeight(unit)
        if self.header then
            self.header:ClearAllPoints()
            self.header:SetPoint("TOPLEFT", self, "TOPLEFT", 2 * unit, -2 * unit)
            self.header:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2 * unit, -2 * unit)
        end
        if self.topStrip then
            self.topStrip:ClearAllPoints()
            self.topStrip:SetPoint("TOPLEFT", self, "TOPLEFT", 2 * unit, -2 * unit)
            self.topStrip:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2 * unit, -2 * unit)
        end
    end
    THEME.RegisterScalable(frame, RefreshWindowItem)
    function frame:RefreshScale()
        RefreshWindowItem(self)
        THEME.RefreshAllScales()
    end
    return frame
end

-- Elevation Level 2a: Section Panel
function THEME.SkinPanel(frame)
    local px = THEME.Pixel(frame, 1)
    frame.bg = FillGradient(frame, color.panelTop, color.panelBottom, "BACKGROUND", 0)
    frame.rim = THEME.DoubleRim(frame, color.borderSubtle, color.outer)
    frame.bevel = frame:CreateTexture(nil, "BORDER", nil, 3)
    frame.bevel:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 * px, -2 * px)
    frame.bevel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2 * px, -2 * px)
    frame.bevel:SetHeight(px)
    SetColor(frame.bevel, color.bevel)
    local function RefreshPanelItem(self)
        local unit = THEME.Pixel(self, 1)
        self.rim:RefreshScale()
        self.bevel:ClearAllPoints()
        self.bevel:SetPoint("TOPLEFT", self, "TOPLEFT", 2 * unit, -2 * unit)
        self.bevel:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2 * unit, -2 * unit)
        self.bevel:SetHeight(unit)
    end
    frame.RefreshScale = RefreshPanelItem
    THEME.RegisterScalable(frame, RefreshPanelItem)
    return frame
end

-- Elevation Level 2b: Recessed Well (Lists, Inputs, Scroll viewports)
function THEME.SkinWell(frame, innerBorderTint)
    local px = THEME.Pixel(frame, 1)
    frame.bg = FillGradient(frame, color.wellTop, color.wellBottom, "BACKGROUND", 0)
    frame.rim = THEME.DoubleRim(frame, innerBorderTint or color.borderSubtle, color.outer)
    frame.innerShadow = frame:CreateTexture(nil, "BORDER", nil, 3)
    frame.innerShadow:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 * px, -2 * px)
    frame.innerShadow:SetPoint("TOPRIGHT", frame, "TOPLEFT", -2 * px, -2 * px)
    frame.innerShadow:ClearAllPoints()
    frame.innerShadow:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 * px, -2 * px)
    frame.innerShadow:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2 * px, -2 * px)
    frame.innerShadow:SetHeight(2 * px)
    SetColor(frame.innerShadow, { 0, 0, 0, 0.50 })
    local function RefreshWellItem(self)
        local unit = THEME.Pixel(self, 1)
        self.rim:RefreshScale()
        self.innerShadow:ClearAllPoints()
        self.innerShadow:SetPoint("TOPLEFT", self, "TOPLEFT", 2 * unit, -2 * unit)
        self.innerShadow:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2 * unit, -2 * unit)
        self.innerShadow:SetHeight(2 * unit)
    end
    frame.RefreshScale = RefreshWellItem
    THEME.RegisterScalable(frame, RefreshWellItem)
    return frame
end

local function Skin(parent, tint)
    if tint == color.panel or tint == color.well then
        return THEME.SkinPanel(parent)
    end
    return THEME.SkinWindow(parent)
end

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

local function Text(parent, size, tint, width, height, singleLine)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local font, _, flags = text:GetFont()
    text:SetFont(font or STANDARD_TEXT_FONT, size or THEME.font.body, flags or "")
    text:SetTextColor(unpack(tint or color.text))
    if text.SetShadowOffset then text:SetShadowOffset(1, -1) end
    if text.SetShadowColor then text:SetShadowColor(0, 0, 0, 0.85) end
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if width then text:SetWidth(width) end
    if height then text:SetHeight(height) end
    if singleLine then
        text:SetWordWrap(false)
        if text.SetMaxLines then text:SetMaxLines(1) end
    end
    return text
end

local function Surface(parent, width, height, tint, isWell)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(width, height)
    if isWell or tint == color.well then
        THEME.SkinWell(panel)
    else
        THEME.SkinPanel(panel)
    end
    return panel
end

local function Tooltip(owner, title, description, extraLines)
    if not GameTooltip then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(title or "", color.accentBright[1], color.accentBright[2], color.accentBright[3])
    if description and description ~= "" then
        GameTooltip:AddLine(description, color.text[1], color.text[2], color.text[3], true)
    end
    if type(extraLines) == "table" then
        for _, line in ipairs(extraLines) do
            if type(line) == "table" then
                local c = line.color or color.muted
                GameTooltip:AddLine(line.text or "", c[1], c[2], c[3], true)
            elseif type(line) == "string" then
                GameTooltip:AddLine(line, color.muted[1], color.muted[2], color.muted[3], true)
            end
        end
    end
    GameTooltip:Show()
end

local function HideTooltip()
    if GameTooltip then GameTooltip:Hide() end
end

local function PaintButton(button, hovered)
    local topTint, bottomTint, borderTint, labelTint
    if button.variant == "active" then
        topTint = hovered and color.activeHoverTop or color.activeBgTop
        bottomTint = hovered and color.activeHoverBottom or color.activeBgBottom
        borderTint = color.activeBorder
        labelTint = color.active
    elseif button.primary then
        topTint = hovered and color.primaryHoverTop or color.primaryTop
        bottomTint = hovered and color.primaryHoverBottom or color.primaryBottom
        borderTint = color.primaryBorder
        labelTint = color.primaryText
    elseif button.variant == "danger" then
        topTint = hovered and color.dangerHoverTop or (button.subtleDanger and color.buttonTop or color.dangerTop)
        bottomTint = hovered and color.dangerHoverBottom or (button.subtleDanger and color.buttonBottom or color.dangerBottom)
        borderTint = color.danger
        labelTint = hovered and color.textBright or color.danger
    elseif button.selected then
        topTint = hovered and color.cardHoverTop or color.selectedTop
        bottomTint = hovered and color.cardHoverBottom or color.selectedBottom
        borderTint = color.accent
        labelTint = color.accentBright
    else
        topTint = hovered and color.buttonHoverTop or color.buttonTop
        bottomTint = hovered and color.buttonHoverBottom or color.buttonBottom
        borderTint = hovered and color.cardHoverBorder or color.buttonBorder
        labelTint = hovered and color.textBright or color.text
    end
    THEME.SetGradient(button.background, "VERTICAL", topTint, bottomTint)
    if button.rim and button.rim.SetInnerColor then
        button.rim:SetInnerColor(borderTint)
    else
        for _, edge in ipairs(button.rim or {}) do
            SetColor(edge, borderTint)
        end
    end
    button.label:SetTextColor(unpack(labelTint))
end

local function Button(parent, label, width, height, primary, variant)
    local button = CreateFrame("Button", nil, parent)
    local h = height or 30
    local px = THEME.Pixel(button, 1)
    button:SetSize(width, h)
    button.primary = primary
    button.variant = variant
    button.background = FillGradient(button, color.buttonTop, color.buttonBottom, "BACKGROUND", 0)
    button.rim = THEME.DoubleRim(button, color.buttonBorder, color.outer)
    local highlight = button:CreateTexture(nil, "BORDER", nil, 3)
    highlight:SetPoint("TOPLEFT", 2 * px, -2 * px)
    highlight:SetPoint("TOPRIGHT", -2 * px, -2 * px)
    highlight:SetHeight(px)
    SetColor(highlight, color.bevel)
    button.highlight = highlight
    local function RefreshButtonItem(self)
        local unit = THEME.Pixel(self, 1)
        self.rim:RefreshScale()
        self.highlight:ClearAllPoints()
        self.highlight:SetPoint("TOPLEFT", self, "TOPLEFT", 2 * unit, -2 * unit)
        self.highlight:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2 * unit, -2 * unit)
        self.highlight:SetHeight(unit)
    end
    button.RefreshScale = RefreshButtonItem
    THEME.RegisterScalable(button, RefreshButtonItem)
    button.label = Text(button, THEME.font.body, color.text, math.max(1, width - 10), h, true)
    button.label:SetPoint("CENTER", 0, 0)
    button.label:SetJustifyH("CENTER")
    button.label:SetJustifyV("MIDDLE")
    button.label:SetText(label or "")
    button:SetScript("OnEnter", function(self)
        self.hovered = true
        if self:IsEnabled() then
            PaintButton(self, true)
        end
        if self.tooltipTitle then
            Tooltip(self, self.tooltipTitle, self.tooltipText, self.tooltipLines)
        end
    end)
    button:SetScript("OnLeave", function(self)
        self.hovered = false
        PaintButton(self, false)
        HideTooltip()
    end)
    button:SetScript("OnMouseDown", function(self)
        if self:IsEnabled() then
            self.pressed = true
            self.label:ClearAllPoints()
            self.label:SetPoint(self.labelAnchor or "CENTER", (self.labelOffsetX or 0) + 1, (self.labelOffsetY or 0) - 1)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.pressed = false
        self.label:ClearAllPoints()
        self.label:SetPoint(self.labelAnchor or "CENTER", self.labelOffsetX or 0, self.labelOffsetY or 0)
    end)
    button:SetScript("OnHide", function(self)
        self.pressed = false
        self.hovered = false
        self.label:ClearAllPoints()
        self.label:SetPoint(self.labelAnchor or "CENTER", self.labelOffsetX or 0, self.labelOffsetY or 0)
    end)
    PaintButton(button, false)
    return button
end

local function Enabled(button, enabled)
    if not button then return end
    button:SetEnabled(not not enabled)
    button:SetAlpha(enabled and 1 or 0.42)
end

local function Fit(frame, width, height)
    local scale = math.min(1, (UIParent:GetWidth() - 32) / width, (UIParent:GetHeight() - 32) / height)
    frame:SetScale(math.max(0.25, scale))
    if frame.RefreshScale then frame:RefreshScale() end
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

-- Custom minimalist scrollbar inside a recessed well
local function ScrollArea(parent, width, height, x, y)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(width, height)
    holder:SetPoint("TOPLEFT", x, y)
    local contentWidth = width - 10
    holder.viewport = CreateFrame("ScrollFrame", nil, holder)
    holder.viewport:SetPoint("TOPLEFT")
    holder.viewport:SetSize(contentWidth, height)
    holder.content = CreateFrame("Frame", nil, holder.viewport)
    holder.content:SetSize(contentWidth, 1)
    holder.viewport:SetScrollChild(holder.content)
    holder.slider = CreateFrame("Slider", nil, holder)
    holder.slider:SetPoint("TOPRIGHT", 0, 0)
    holder.slider:SetSize(5, height)
    holder.slider:SetOrientation("VERTICAL")
    holder.slider:SetValueStep(1)
    holder.slider:SetMinMaxValues(0, 0)
    holder.slider.track = Fill(holder.slider, color.wellTop, "BACKGROUND", 0)
    local thumb = holder.slider:CreateTexture(nil, "ARTWORK")
    SetColor(thumb, color.border)
    thumb:SetSize(5, 34)
    holder.slider.thumb = thumb
    holder.slider:SetThumbTexture(thumb)
    holder.slider:SetScript("OnEnter", function() SetColor(thumb, color.accent) end)
    holder.slider:SetScript("OnLeave", function() SetColor(thumb, color.border) end)
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

-- Custom-skinned CheckButton preserving GetChecked / SetChecked
local function SkinnedCheckButton(parent, labelText, x, y, onClick, tooltipTitle, tooltipText)
    local check = CreateFrame("CheckButton", nil, parent)
    check:SetSize(22, 22)
    check:SetPoint("TOPLEFT", x, y)
    THEME.SkinWell(check, color.border)
    local mark = check:CreateTexture(nil, "ARTWORK")
    mark:SetPoint("TOPLEFT", 5, -5)
    mark:SetPoint("BOTTOMRIGHT", -5, 5)
    THEME.SetGradient(mark, "VERTICAL", color.accentBright, color.accent)
    check.mark = mark
    if check.SetCheckedTexture then check:SetCheckedTexture(mark) end
    local rawSetChecked = check.SetChecked
    function check:SetChecked(checked)
        local state = checked and true or false
        if rawSetChecked then rawSetChecked(self, state) end
        self._checked = state
        self.mark:SetShown(state)
        if self.rim and self.rim.SetInnerColor then
            self.rim:SetInnerColor(state and color.accent or color.border)
        end
    end
    local rawGetChecked = check.GetChecked
    function check:GetChecked()
        if rawGetChecked then
            local val = rawGetChecked(self)
            if val ~= nil then return val end
        end
        return self._checked
    end
    check.label = Text(parent, THEME.font.body, color.text, 270, 22, true)
    check.label:SetPoint("LEFT", check, "RIGHT", 8, 0)
    check.label:SetJustifyV("MIDDLE")
    check.label:SetText(labelText)
    check:SetScript("OnClick", function(self)
        local newState
        if rawGetChecked then
            newState = rawGetChecked(self) and true or false
        else
            newState = not self._checked
        end
        self._checked = newState
        self.mark:SetShown(newState)
        if self.rim and self.rim.SetInnerColor then
            self.rim:SetInnerColor(newState and color.accent or color.border)
        end
        if onClick then onClick(self) end
    end)
    check:SetScript("OnEnter", function(self)
        if self.rim and self.rim.SetInnerColor then self.rim:SetInnerColor(color.accentBright) end
        if tooltipTitle then Tooltip(self, tooltipTitle, tooltipText) end
    end)
    check:SetScript("OnLeave", function(self)
        if self.rim and self.rim.SetInnerColor then
            self.rim:SetInnerColor(self:GetChecked() and color.accent or color.border)
        end
        HideTooltip()
    end)
    check:SetChecked(false)
    return check
end

local function QuickBarSlider(parent, label, bottom, minimum, maximum, step, onChange, help)
    local heading = Text(parent, THEME.font.body, color.text, 184, 24, true)
    heading:SetPoint("BOTTOMLEFT", 16, bottom)
    heading:SetJustifyV("MIDDLE")
    heading:SetText(label)
    local slider = CreateFrame("Slider", nil, parent)
    slider:SetSize(334, 24)
    slider:SetPoint("BOTTOMLEFT", 210, bottom)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minimum, maximum)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    -- Draw the track on the slider so the thumb's draw layer stays above it.
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetHeight(6)
    SetColor(track, color.outer)
    local groove = slider:CreateTexture(nil, "BORDER")
    groove:SetPoint("TOPLEFT", track, "TOPLEFT", 1, -1)
    groove:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", -1, 1)
    THEME.SetGradient(groove, "VERTICAL", color.borderSubtle, color.wellBottom)
    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(12, 18)
    THEME.SetGradient(thumb, "VERTICAL", color.accentBright, color.accent)
    slider:SetThumbTexture(thumb)
    slider:SetScript("OnValueChanged", onChange)
    slider:SetScript("OnEnter", function(self) Tooltip(self, label, help) end)
    slider:SetScript("OnLeave", HideTooltip)
    local value = Text(parent, THEME.font.body, color.accentBright, 80, 24, true)
    value:SetPoint("BOTTOMLEFT", 554, bottom)
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

local function GetProfileQualityBadge(profile)
    local values = profile and profile.modules and profile.modules.graphics and profile.modules.graphics.values
    local raw = values and (values.graphicsQuality or values.RAIDgraphicsQuality)
    local num = tonumber(raw)
    if num and num >= 0 and num <= 9 then
        return string.format("Q%d", math.floor(num + 1.5))
    end
    return "FP"
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
    Fill(modal, color.backdrop)
    local panel = CreateFrame("Frame", nil, modal)
    panel:SetSize(460, 264)
    panel:SetPoint("CENTER")
    panel:SetFrameLevel(modal:GetFrameLevel() + 1)
    THEME.SkinWindow(panel)
    modal.panel = panel
    local px = THEME.Pixel(panel, 1)
    local topStrip = panel:CreateTexture(nil, "ARTWORK")
    topStrip:SetPoint("TOPLEFT", panel, "TOPLEFT", 2 * px, -2 * px)
    topStrip:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2 * px, -2 * px)
    topStrip:SetHeight(2)
    THEME.SetGradient(topStrip, "HORIZONTAL", THEME.GetClassColor(), color.accent)
    panel.topStrip = topStrip
    modal.topStrip = topStrip
    modal.title = Text(panel, THEME.font.title, color.accentBright, 416, 26, true)
    modal.title:SetPoint("TOPLEFT", 22, -18)
    local sep = THEME.CreateSeparator(panel, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    sep:SetPoint("TOPLEFT", 22, -48)
    sep:SetWidth(416)
    modal.body = Text(panel, THEME.font.body, color.muted, 416, 62)
    modal.body:SetPoint("TOPLEFT", 22, -58)
    modal.body:SetSpacing(3)
    modal.editSurface = Surface(panel, 416, 34, color.well, true)
    modal.editSurface:SetPoint("TOPLEFT", 22, -126)
    modal.edit = CreateFrame("EditBox", nil, modal.editSurface)
    modal.edit:SetPoint("TOPLEFT", 10, -5)
    modal.edit:SetPoint("BOTTOMRIGHT", -10, 5)
    modal.edit:SetFontObject(GameFontHighlight)
    modal.edit:SetAutoFocus(false)
    modal.edit:SetMaxLetters(48)
    modal.edit:SetScript("OnEscapePressed", function() modal:Hide() end)
    modal.edit:SetScript("OnEditFocusGained", function()
        if modal.editSurface.rim and modal.editSurface.rim.SetInnerColor then
            modal.editSurface.rim:SetInnerColor(color.accent)
        end
    end)
    modal.edit:SetScript("OnEditFocusLost", function()
        if modal.editSurface.rim and modal.editSurface.rim.SetInnerColor then
            modal.editSurface.rim:SetInnerColor(color.borderSubtle)
        end
    end)
    modal.error = Text(panel, THEME.font.caption, color.warning, 416, 36)
    modal.error:SetPoint("TOPLEFT", 22, -168)
    modal.accept = Button(panel, L["Save"], 170, 32, true)
    modal.accept:SetPoint("BOTTOMRIGHT", -22, 18)
    modal.cancel = Button(panel, L["Cancel"], 104, 32)
    modal.cancel:SetPoint("RIGHT", modal.accept, "LEFT", -10, 0)
    modal.cancel:SetScript("OnClick", function() modal:Hide() end)
    modal.accept:SetScript("OnClick", function(self)
        if not self:IsEnabled() or not modal.callback then return end
        if modal.mode ~= "export" and F.busy then return end
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
    modal.mode = mode
    modal.error:SetText("")
    modal.editSurface:Show()
    modal.edit:SetMaxLetters(48)
    modal.accept.primary = true
    modal.accept.variant = nil
    Enabled(modal.accept, not F.busy)
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
    PaintButton(modal.accept, false)
    modal:Show()
    modal.edit:SetFocus()
    modal.edit:HighlightText()
end

local function ConfirmDialog(mode, profile)
    if F.busy then return end
    local modal = Modal()
    modal.mode = mode
    modal.error:SetText("")
    modal.editSurface:Hide()
    Enabled(modal.accept, not F.busy)
    if mode == "update" then
        modal.title:SetText(L["Update saved settings"])
        modal.body:SetText(string.format(L['Replace the saved settings for "%s" with your current game settings?'], Plain(profile.name)))
        modal.accept.primary = true
        modal.accept.variant = nil
        modal.accept.label:SetText(L["Update profile"])
        modal.callback = function() return F.UpdateProfile(profile.id) end
    else
        modal.title:SetText(L["Delete profile"])
        modal.body:SetText(string.format(L['Delete "%s"? Your current game settings will stay as they are.'], Plain(profile.name)))
        modal.accept.primary = false
        modal.accept.variant = "danger"
        modal.accept.label:SetText(L["Delete"])
        modal.callback = function() return F.DeleteProfile(profile.id) end
    end
    PaintButton(modal.accept, false)
    modal:Show()
end

function U.OpenExportDialog(profile)
    profile = profile or Selected()
    if not profile then return end
    local payload, err = F.ExportProfile and F.ExportProfile(profile.id) or (F.Profiles.Export and F.Profiles.Export(profile.id))
    if not payload then
        U.SetNotice(err or L["Unable to export this profile."], true)
        return
    end
    U.Initialize()
    if not U.window:IsShown() then U.Show() end
    local modal = Modal()
    modal.mode = "export"
    modal.error:SetText("")
    modal.editSurface:Show()
    modal.edit:SetMaxLetters(16384)
    modal.title:SetText(L["Export profile"])
    modal.body:SetText(string.format(L['Copy this string (Ctrl+C) to share or back up "%s".'], Plain(profile.name)))
    modal.edit:SetText(payload)
    modal.accept.primary = true
    modal.accept.variant = nil
    modal.accept.label:SetText(L["Done"])
    modal.callback = function() return true end
    Enabled(modal.accept, true)
    PaintButton(modal.accept, false)
    modal:Show()
    modal.edit:SetFocus()
    modal.edit:HighlightText()
end

function U.OpenImportDialog()
    if F.busy then return end
    U.Initialize()
    if not U.window:IsShown() then U.Show() end
    local modal = Modal()
    modal.mode = "import"
    modal.error:SetText("")
    modal.editSurface:Show()
    modal.edit:SetMaxLetters(16384)
    modal.title:SetText(L["Import profile"])
    modal.body:SetText(L["Paste a Forever Profiles export string (FP1:...) below to create a new profile."])
    modal.edit:SetText("")
    modal.accept.primary = true
    modal.accept.variant = nil
    modal.accept.label:SetText(L["Import profile"])
    modal.callback = function(text)
        local result, err = F.ImportProfile(text)
        if result and type(result) == "table" then F.Profiles.SetSelected(result.id) end
        return result, err
    end
    Enabled(modal.accept, not F.busy)
    PaintButton(modal.accept, false)
    modal:Show()
    modal.edit:SetFocus()
end

local function SummaryRow(parent, width)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width, 24)
    row.stripe = Fill(row, { 0, 0, 0, 0 }, "BACKGROUND", 0)
    row.divider = row:CreateTexture(nil, "BORDER", nil, 1)
    row.divider:SetPoint("BOTTOMLEFT", 4, 0)
    row.divider:SetPoint("BOTTOMRIGHT", -4, 0)
    row.divider:SetHeight(THEME.Pixel(row, 1))
    SetColor(row.divider, color.borderSubtle)
    row.divider:Hide()
    local function RefreshSummaryRowItem(self)
        self.divider:SetHeight(THEME.Pixel(self, 1))
    end
    row.RefreshScale = RefreshSummaryRowItem
    THEME.RegisterScalable(row, RefreshSummaryRowItem)
    row.label = Text(row, THEME.font.body, color.muted, width - 170, 24, true)
    row.label:SetPoint("LEFT", 6, 0)
    row.label:SetJustifyV("MIDDLE")
    row.value = Text(row, THEME.font.body, color.textBright, 155, 24, true)
    row.value:SetPoint("RIGHT", -6, 0)
    row.value:SetJustifyH("RIGHT")
    row.value:SetJustifyV("MIDDLE")
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if not self.isHeading then
            SetColor(self.stripe, color.rowHover)
        end
        if self.tooltipTitle then Tooltip(self, self.tooltipTitle, self.tooltipText) end
    end)
    row:SetScript("OnLeave", function(self)
        if not self.isHeading then
            SetColor(self.stripe, self.alt and color.rowAlt or { 0, 0, 0, 0 })
        end
        HideTooltip()
    end)
    return row
end

local function RefreshSummary(profile)
    local scroll = U.summaryScroll
    for _, row in ipairs(U.summaryRows) do row:Hide() end
    local snapshot = profile and profile.modules and profile.modules.graphics
    local mode, summaries = U.summaryMode or "normal", {}
    if snapshot then
        if mode == "saved" then
            summaries = F.Graphics.GetSavedSettings(snapshot)
        else
            for _, setting in ipairs(F.Graphics.GetSummary(snapshot)) do
                if setting.group == mode or setting.group == "common" then
                    summaries[#summaries + 1] = setting
                end
            end
        end
    end
    for key, button in pairs(U.summaryTabs or {}) do
        button.selected = key == mode
        PaintButton(button, button.hovered)
    end
    local lastGroup, y, rowIndex, groupItemIndex = nil, 0, 0, 0
    local groups = {
        normal = L["General"],
        raid = L["Raid / instance"],
        common = L["Shared"],
    }
    local function NextRow(isHeading)
        rowIndex = rowIndex + 1
        local row = U.summaryRows[rowIndex]
        if not row then
            row = SummaryRow(scroll.content, scroll.content:GetWidth())
            U.summaryRows[rowIndex] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, -y)
        row.isHeading = isHeading and true or false
        row.divider:SetShown(isHeading and true or false)
        if isHeading then
            row.alt = false
            SetColor(row.stripe, { 0, 0, 0, 0 })
        else
            groupItemIndex = groupItemIndex + 1
            row.alt = (groupItemIndex % 2 == 0)
            SetColor(row.stripe, row.alt and color.rowAlt or { 0, 0, 0, 0 })
        end
        row:Show()
        return row
    end
    local application = profile and F.results and F.results[profile.id]
    if snapshot and application and not application.success and not F.busy then
        local comparison = F.Graphics.Compare(snapshot)
        if #comparison.differences > 0 then
            local heading = NextRow(true)
            heading.label:SetWidth(scroll.content:GetWidth() - 170)
            heading.label:SetTextColor(unpack(color.warning))
            heading.label:SetText(L["Settings that differ"])
            heading.value:SetTextColor(unpack(color.muted))
            heading.value:SetText(L["Saved / current"])
            heading.tooltipTitle = nil
            y = y + 26
            groupItemIndex = 0
            local settings = {}
            for _, entry in ipairs(F.Graphics.catalog or {}) do settings[entry.name] = entry end
            local reasons = {}
            for _, entry in ipairs(application.failed or {}) do reasons[entry.name] = entry.reason end
            for _, entry in ipairs(application.skipped or {}) do reasons[entry.name] = entry.reason end
            for _, difference in ipairs(comparison.differences) do
                local entry = settings[difference.name]
                local row = NextRow(false)
                row.label:SetWidth(scroll.content:GetWidth() - 170)
                row.label:SetTextColor(unpack(color.warning))
                local label = entry and L[entry.label] or difference.name
                row.label:SetText(label)
                local current = difference.actual or L["Unavailable"]
                local expected = difference.expected or L["Unavailable"]
                row.value:SetTextColor(unpack(color.warning))
                row.value:SetText(Plain(expected) .. " / " .. Plain(current))
                row.tooltipTitle = label
                row.tooltipText = (entry and ((groups[entry.group] or entry.group) .. "\n") or "")
                    .. L["Saved"] .. ": " .. Plain(expected) .. "\n"
                    .. L["Current"] .. ": " .. Plain(current) .. "\n"
                    .. L[reasons[difference.name] or difference.reason or "Value differs"]
                y = y + 24
            end
            y = y + 10
        end
    end
    for _, setting in ipairs(summaries) do
        if setting.group ~= lastGroup then
            if rowIndex > 0 then y = y + 6 end
            local heading = NextRow(true)
            heading.label:SetWidth(scroll.content:GetWidth() - 12)
            heading.label:SetTextColor(unpack(color.accent))
            heading.label:SetText(groups[setting.group] or L[setting.group or "Graphics settings"])
            heading.value:SetText("")
            heading.tooltipTitle = nil
            y = y + 24
            lastGroup = setting.group
            groupItemIndex = 0
        end
        local row = NextRow(false)
        local value = Plain(L[tostring(setting.value)] or setting.value)
        row.label:SetWidth(scroll.content:GetWidth() - 170)
        row.label:SetTextColor(unpack(color.muted))
        row.label:SetText(L[setting.label] or setting.label)
        row.value:SetTextColor(unpack(color.textBright))
        row.value:SetText(value)
        row.tooltipTitle = L[setting.label] or setting.label
        row.tooltipText = setting.description and (setting.description .. "\n" .. value) or value
        y = y + 24
    end
    U.summaryEmpty:SetShown(#summaries == 0)
    scroll:SetContentHeight(y, U.summarySelection ~= (profile and profile.id))
    U.summarySelection = profile and profile.id
end

local function PaintProfileRow(row, hovered)
    local topTint, bottomTint, borderTint, barTint
    local badgeBorder, badgeText, titleTint
    if row.active and row.selected then
        topTint = hovered and color.activeHoverTop or color.activeBgTop
        bottomTint = hovered and color.activeHoverBottom or color.activeBgBottom
        borderTint = color.selectedBorder
        barTint = color.active
        badgeBorder = color.active
        badgeText = color.active
        titleTint = color.accentBright
    elseif row.active then
        topTint = hovered and color.activeHoverTop or color.activeBgTop
        bottomTint = hovered and color.activeHoverBottom or color.activeBgBottom
        borderTint = color.activeBorder
        barTint = color.active
        badgeBorder = color.active
        badgeText = color.active
        titleTint = color.textBright
    elseif row.selected then
        topTint = hovered and color.cardHoverTop or color.selectedTop
        bottomTint = hovered and color.cardHoverBottom or color.selectedBottom
        borderTint = color.selectedBorder
        barTint = color.accentBright
        badgeBorder = color.selectedBorder
        badgeText = color.accentBright
        titleTint = color.accentBright
    else
        topTint = hovered and color.cardHoverTop or color.cardTop
        bottomTint = hovered and color.cardHoverBottom or color.cardBottom
        borderTint = hovered and color.cardHoverBorder or color.cardBorder
        barTint = nil
        badgeBorder = hovered and color.border or color.borderSubtle
        badgeText = hovered and color.text or color.muted
        titleTint = hovered and color.textBright or color.text
    end
    THEME.SetGradient(row.background, "VERTICAL", topTint, bottomTint)
    if row.rim and row.rim.SetInnerColor then
        row.rim:SetInnerColor(borderTint)
    end
    if barTint then
        SetColor(row.indicator, barTint)
        row.indicator:Show()
    else
        row.indicator:Hide()
    end
    if row.badge and row.badge.rim and row.badge.rim.SetInnerColor then
        row.badge.rim:SetInnerColor(badgeBorder)
    end
    if row.badge and row.badge.text then
        row.badge.text:SetTextColor(unpack(badgeText))
    end
    row.title:SetTextColor(unpack(titleTint))
end

local function ProfileRow(parent, width)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, 56)
    local px = THEME.Pixel(row, 1)
    row.background = FillGradient(row, color.cardTop, color.cardBottom, "BACKGROUND", 0)
    row.rim = THEME.DoubleRim(row, color.cardBorder, color.outer)
    row.indicator = row:CreateTexture(nil, "ARTWORK", nil, 2)
    SetColor(row.indicator, color.accentBright)
    row.indicator:SetPoint("TOPLEFT", 2 * px, -2 * px)
    row.indicator:SetPoint("BOTTOMLEFT", 2 * px, 2 * px)
    row.indicator:SetWidth(3)

    -- Recessed Quality Badge (Q1..Q10) with cropped icon backdrop
    local badge = CreateFrame("Frame", nil, row)
    badge:SetSize(28, 28)
    badge:SetPoint("LEFT", 10, 0)
    THEME.SkinWell(badge, color.borderSubtle)
    badge.icon = badge:CreateTexture(nil, "BACKGROUND", nil, 2)
    badge.icon:SetPoint("TOPLEFT", 3, -3)
    badge.icon:SetPoint("BOTTOMRIGHT", -3, 3)
    THEME.CropIcon(badge.icon, LOGO_PATH)
    badge.icon:SetAlpha(0.16)
    badge.text = Text(badge, THEME.font.caption, color.muted, 26, 26, true)
    badge.text:SetPoint("CENTER", 0, 0)
    badge.text:SetJustifyH("CENTER")
    badge.text:SetJustifyV("MIDDLE")
    badge.text:SetText("FP")
    row.badge = badge

    local textWidth = math.max(60, width - 108)
    row.title = Text(row, THEME.font.heading, color.text, textWidth, 18, true)
    row.title:SetPoint("TOPLEFT", 44, -9)
    row.title:SetJustifyV("MIDDLE")

    row.statusDot = row:CreateTexture(nil, "ARTWORK", nil, 2)
    row.statusDot:SetSize(6, 6)
    row.statusDot:SetPoint("TOPLEFT", 44, -35)
    SetColor(row.statusDot, color.muted)

    row.status = Text(row, THEME.font.caption, color.muted, math.max(50, textWidth - 11), 16, true)
    row.status:SetPoint("TOPLEFT", 55, -30)
    row.status:SetJustifyV("MIDDLE")

    -- One-click Quick Apply CTA directly on each card (<= 2 clicks requirement)
    row.quickApply = Button(row, L["Apply"], 52, 22)
    row.quickApply:SetPoint("RIGHT", -7, 0)
    row.quickApply.label:SetFont(row.quickApply.label:GetFont(), THEME.font.caption, "")
    row.quickApply:SetScript("OnClick", function()
        if row.profile and not F.busy then
            F.ApplyProfile(row.profile.id)
        end
    end)
    row.quickApply:SetScript("OnEnter", function(self)
        self.hovered = true
        if self:IsEnabled() then PaintButton(self, true) end
        if row.profile then
            Tooltip(self, Plain(row.profile.name),
                row.active and L["This profile is currently active."]
                or L["Click to apply this profile immediately."])
        end
    end)

    local function RefreshProfileRowItem(self)
        local unit = THEME.Pixel(self, 1)
        self.rim:RefreshScale()
        self.indicator:ClearAllPoints()
        self.indicator:SetPoint("TOPLEFT", self, "TOPLEFT", 2 * unit, -2 * unit)
        self.indicator:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 2 * unit, 2 * unit)
        if self.badge and self.badge.RefreshScale then self.badge:RefreshScale() end
        if self.quickApply and self.quickApply.RefreshScale then self.quickApply:RefreshScale() end
    end
    row.RefreshScale = RefreshProfileRowItem
    THEME.RegisterScalable(row, RefreshProfileRowItem)

    row:SetScript("OnClick", function(self)
        if self.profile then Select(self.profile.id) end
    end)
    row:SetScript("OnMouseDown", function(self)
        self.title:SetPoint("TOPLEFT", 45, -10)
    end)
    row:SetScript("OnMouseUp", function(self)
        self.title:SetPoint("TOPLEFT", 44, -9)
    end)
    row:SetScript("OnEnter", function(self)
        self.hovered = true
        PaintProfileRow(self, true)
        if self.profile then
            local statusText = Status(self.profile.id)
            local quality = GetProfileQualityBadge(self.profile)
            Tooltip(self, Plain(self.profile.name), L["Select this profile to view its saved settings."], {
                { text = L["Status"] .. ": " .. statusText, color = StatusColor(statusText) },
                { text = L["Graphics quality"] .. ": " .. quality, color = color.accent },
                { text = L["Tip: Click Apply on the card for instant 1-click switching."], color = color.muted },
            })
        end
    end)
    row:SetScript("OnLeave", function(self)
        self.hovered = false
        self.title:SetPoint("TOPLEFT", 44, -9)
        PaintProfileRow(self, false)
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
    THEME.SkinWindow(window)
    Position(window, "windowPosition", "CENTER", "CENTER", 0, 0)

    -- ========================================================================
    -- Structured Header Bar (Elevation Level 1)
    -- ========================================================================
    local winPx = THEME.Pixel(window, 1)
    local header = CreateFrame("Frame", nil, window)
    header:SetPoint("TOPLEFT", window, "TOPLEFT", 2 * winPx, -2 * winPx)
    header:SetPoint("TOPRIGHT", window, "TOPRIGHT", -2 * winPx, -2 * winPx)
    header:SetHeight(50)
    header.bg = FillGradient(header, color.headerTop, color.headerBottom, "BACKGROUND", 1)
    header.classStrip = header:CreateTexture(nil, "ARTWORK", nil, 2)
    header.classStrip:SetPoint("TOPLEFT", 0, 0)
    header.classStrip:SetPoint("TOPRIGHT", 0, 0)
    header.classStrip:SetHeight(2)
    THEME.SetGradient(header.classStrip, "HORIZONTAL", THEME.GetClassColor(), color.accent)
    header.bottomSep = THEME.CreateSeparator(header, "HORIZONTAL", color.accent, { color.accent[1], color.accent[2], color.accent[3], 0 })
    header.bottomSep:SetPoint("BOTTOMLEFT", 0, 0)
    header.bottomSep:SetPoint("BOTTOMRIGHT", 0, 0)
    window.header = header

    local drag = CreateFrame("Frame", nil, header)
    drag:SetPoint("TOPLEFT")
    drag:SetPoint("BOTTOMRIGHT", -352, 0)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")
    drag:SetScript("OnDragStart", function() window:StartMoving() end)
    drag:SetScript("OnDragStop", function() SavePosition(window, "windowPosition") end)

    -- Header Left: Cropped Logo Well + Title + Version Badge + Active Profile Pill
    local logoWell = CreateFrame("Frame", nil, header)
    logoWell:SetSize(28, 28)
    logoWell:SetPoint("LEFT", 14, 0)
    THEME.SkinWell(logoWell, color.accent)
    local logoIcon = logoWell:CreateTexture(nil, "ARTWORK")
    logoIcon:SetSize(22, 22)
    logoIcon:SetPoint("CENTER")
    THEME.CropIcon(logoIcon, LOGO_PATH)
    window.logoIcon = logoIcon

    local title = Text(header, THEME.font.hero, color.accent, 158, 28, true)
    title:SetPoint("LEFT", 50, 0)
    title:SetJustifyV("MIDDLE")
    title:SetText("Forever Profiles")
    window.title = title

    local versionBadge = CreateFrame("Frame", nil, header)
    versionBadge:SetSize(50, 20)
    versionBadge:SetPoint("LEFT", 210, 0)
    THEME.SkinWell(versionBadge, color.borderSubtle)
    local versionText = Text(versionBadge, THEME.font.caption, color.muted, 46, 20, true)
    versionText:SetPoint("CENTER")
    versionText:SetJustifyH("CENTER")
    versionText:SetJustifyV("MIDDLE")
    versionText:SetText("v" .. tostring(F.version or "0.2.1"))
    window.versionBadge = versionBadge

    -- Active Profile Header Pill (Identify active profile at first glance + jump to it)
    U.activePill = Button(header, L["No active profile"], 162, 24, false, "active")
    U.activePill:SetPoint("LEFT", 266, 0)
    U.activePill.dot = U.activePill:CreateTexture(nil, "OVERLAY")
    U.activePill.dot:SetSize(6, 6)
    U.activePill.dot:SetPoint("LEFT", 9, 0)
    SetColor(U.activePill.dot, color.active)
    U.activePill.labelAnchor = "LEFT"
    U.activePill.labelOffsetX = 21
    U.activePill.labelOffsetY = 0
    U.activePill.label:ClearAllPoints()
    U.activePill.label:SetPoint("LEFT", 21, 0)
    U.activePill.label:SetWidth(133)
    U.activePill.label:SetJustifyH("LEFT")
    U.activePill.tooltipTitle = L["Active profile"]
    U.activePill:SetScript("OnClick", function(self)
        if self.activeProfileID then
            U.SelectTab("profiles")
            Select(self.activeProfileID)
        end
    end)

    -- Header Right: Navigation Tabs + Close Button
    U.tabs = {}
    U.tabs.profiles = Button(header, L["Profiles"], 86, 28)
    U.tabs.profiles:SetPoint("RIGHT", -254, 0)
    U.tabs.favorites = Button(header, L["Favorite bar"], 104, 28)
    U.tabs.favorites:SetPoint("RIGHT", -146, 0)
    U.tabs.automation = Button(header, L["Automation"], 96, 28)
    U.tabs.automation:SetPoint("RIGHT", -46, 0)
    U.tabs.profiles:SetScript("OnClick", function() U.SelectTab("profiles") end)
    U.tabs.favorites:SetScript("OnClick", function() U.SelectTab("favorites") end)
    U.tabs.automation:SetScript("OnClick", function() U.SelectTab("automation") end)

    local close = Button(header, "X", 28, 28, false, "danger")
    close.subtleDanger = true
    PaintButton(close, false)
    close:SetPoint("RIGHT", -12, 0)
    close.tooltipTitle = L["Close"]
    close:SetScript("OnClick", function() window:Hide() end)
    window.closeButton = close
    UISpecialFrames[#UISpecialFrames + 1] = "ForeverProfilesWindow"

    -- ========================================================================
    -- Profiles Tab Panel (744 x 430)
    -- ========================================================================
    U.profilePanel = CreateFrame("Frame", nil, window)
    U.profilePanel:SetSize(744, 430)
    U.profilePanel:SetPoint("TOPLEFT", 18, -62)

    -- Left Column: Profile List Panel (248 x 430)
    local listPanel = Surface(U.profilePanel, 248, 430)
    listPanel:SetPoint("TOPLEFT", 0, 0)
    U.listPanel = listPanel
    U.listTitle = Text(listPanel, THEME.font.heading, color.accent, 162, 22, true)
    U.listTitle:SetPoint("TOPLEFT", 10, -10)
    U.listTitle:SetJustifyV("MIDDLE")

    U.importButton = Button(listPanel, L["Import"], 58, 20)
    U.importButton:SetPoint("TOPRIGHT", -10, -11)
    U.importButton.label:SetFont(U.importButton.label:GetFont(), THEME.font.caption, "")
    U.importButton.tooltipTitle = L["Import profile"]
    U.importButton.tooltipText = L["Create a profile from a shared export string."]
    U.importButton:SetScript("OnClick", function() U.OpenImportDialog() end)

    local listSep = THEME.CreateSeparator(listPanel, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    listSep:SetPoint("TOPLEFT", 10, -36)
    listSep:SetWidth(228)

    local listWell = Surface(listPanel, 228, 336, color.well, true)
    listWell:SetPoint("TOPLEFT", 10, -43)
    U.listWell = listWell
    U.listScroll = ScrollArea(listWell, 220, 328, 4, -4)
    U.profileRows = {}

    -- Aesthetic Empty State (0 Profiles)
    local emptyFrame = CreateFrame("Frame", nil, U.listScroll.content)
    emptyFrame:SetSize(202, 220)
    emptyFrame:SetPoint("TOP", 0, -32)
    local emptyIconWell = CreateFrame("Frame", nil, emptyFrame)
    emptyIconWell:SetSize(44, 44)
    emptyIconWell:SetPoint("TOP", 0, -6)
    THEME.SkinWell(emptyIconWell, color.border)
    local emptyIcon = emptyIconWell:CreateTexture(nil, "ARTWORK")
    emptyIcon:SetSize(34, 34)
    emptyIcon:SetPoint("CENTER")
    THEME.CropIcon(emptyIcon, LOGO_PATH)
    emptyIcon:SetAlpha(0.65)
    local emptyHeading = Text(emptyFrame, THEME.font.heading, color.accentBright, 190, 20, true)
    emptyHeading:SetPoint("TOP", 0, -60)
    emptyHeading:SetJustifyH("CENTER")
    emptyHeading:SetText(L["No profiles yet"])
    U.listEmptyFrame = emptyFrame

    U.listEmpty = Text(emptyFrame, THEME.font.body, color.muted, 190, 120)
    U.listEmpty:SetPoint("TOP", 0, -84)
    U.listEmpty:SetJustifyH("CENTER")
    U.listEmpty:SetSpacing(4)
    U.listEmpty:SetText(L["No profiles yet. Configure your graphics in the game options, then save your current settings."])

    U.create = Button(listPanel, L["Save current settings"], 228, 32)
    U.create.selected = true
    PaintButton(U.create, false)
    U.create:SetPoint("BOTTOMLEFT", 10, 10)
    U.create.tooltipTitle = L["Save current settings"]
    U.create.tooltipText = L["Capture your active graphics CVars into a new named profile."]
    U.create:SetScript("OnClick", function() NameDialog("create") end)

    -- Right Column: Profile Detail Panel (482 x 430)
    local detail = Surface(U.profilePanel, 482, 430)
    detail:SetPoint("TOPLEFT", 262, 0)
    U.detail = detail

    U.detailBadge = CreateFrame("Frame", nil, detail)
    U.detailBadge:SetSize(36, 36)
    U.detailBadge:SetPoint("TOPLEFT", 14, -14)
    THEME.SkinWell(U.detailBadge, color.selectedBorder)
    U.detailBadge.icon = U.detailBadge:CreateTexture(nil, "BACKGROUND", nil, 2)
    U.detailBadge.icon:SetPoint("TOPLEFT", 4, -4)
    U.detailBadge.icon:SetPoint("BOTTOMRIGHT", -4, 4)
    THEME.CropIcon(U.detailBadge.icon, LOGO_PATH)
    U.detailBadge.icon:SetAlpha(0.18)
    U.detailBadge.text = Text(U.detailBadge, THEME.font.heading, color.accentBright, 34, 34, true)
    U.detailBadge.text:SetPoint("CENTER")
    U.detailBadge.text:SetJustifyH("CENTER")
    U.detailBadge.text:SetJustifyV("MIDDLE")
    U.detailBadge.text:SetText("FP")

    U.profileName = Text(detail, THEME.font.title, color.textBright, 268, 22, true)
    U.profileName:SetPoint("TOPLEFT", 60, -13)
    local nameTooltip = CreateFrame("Frame", nil, detail)
    nameTooltip:SetSize(268, 22)
    nameTooltip:SetPoint("TOPLEFT", 60, -13)
    nameTooltip:EnableMouse(true)
    nameTooltip:SetScript("OnEnter", function(self)
        local profile = Selected()
        if profile then Tooltip(self, Plain(profile.name)) end
    end)
    nameTooltip:SetScript("OnLeave", HideTooltip)

    U.statusDot = detail:CreateTexture(nil, "ARTWORK")
    U.statusDot:SetSize(6, 6)
    U.statusDot:SetPoint("TOPLEFT", 60, -40)
    SetColor(U.statusDot, color.muted)

    U.status = Text(detail, THEME.font.body, color.muted, 260, 18, true)
    U.status:SetPoint("TOPLEFT", 71, -36)
    U.status:SetJustifyV("MIDDLE")

    U.favorite = Button(detail, L["Favorite"], 86, 26)
    U.favorite:SetPoint("TOPRIGHT", -52, -14)
    U.favorite.tooltipTitle = L["Quick access"]
    U.favorite.tooltipText = L["Keep up to three favorite profiles in the quick bar."]
    U.favorite:SetScript("OnClick", function()
        local profile = Selected()
        if profile and not F.busy then F.ToggleFavorite(profile.id) end
    end)

    U.menuButton = Button(detail, "...", 32, 26)
    U.menuButton:SetPoint("TOPRIGHT", -14, -14)
    U.menuButton.tooltipTitle = L["Profile actions"]
    U.menuButton.tooltipText = L["Rename, duplicate, export, or delete this profile."]

    local detailTopSep = THEME.CreateSeparator(detail, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    detailTopSep:SetPoint("TOPLEFT", 14, -60)
    detailTopSep:SetWidth(454)

    U.summaryTabs = {}
    U.summaryTabs.normal = Button(detail, L["General"], 110, 25)
    U.summaryTabs.normal:SetPoint("TOPLEFT", 14, -69)
    U.summaryTabs.raid = Button(detail, L["Raid / instance"], 140, 25)
    U.summaryTabs.raid:SetPoint("LEFT", U.summaryTabs.normal, "RIGHT", 6, 0)
    U.summaryTabs.saved = Button(detail, L["Saved settings"], 134, 25)
    U.summaryTabs.saved:SetPoint("LEFT", U.summaryTabs.raid, "RIGHT", 6, 0)
    U.summaryTabs.normal:SetScript("OnClick", function() U.SetSummaryMode("normal") end)
    U.summaryTabs.raid:SetScript("OnClick", function() U.SetSummaryMode("raid") end)
    U.summaryTabs.saved:SetScript("OnClick", function() U.SetSummaryMode("saved") end)

    local summaryWell = Surface(detail, 454, 262, color.well, true)
    summaryWell:SetPoint("TOPLEFT", 14, -102)
    U.summaryWell = summaryWell
    U.summaryScroll = ScrollArea(summaryWell, 446, 254, 4, -4)
    U.summaryRows = {}
    U.summaryEmpty = Text(U.summaryScroll, THEME.font.heading, color.muted, 405, 95)
    U.summaryEmpty:SetPoint("TOPLEFT", 12, -16)
    U.summaryEmpty:SetSpacing(4)
    U.summaryEmpty:SetText(L["Save a profile to see its graphics settings here."])

    local detailBottomSep = THEME.CreateSeparator(detail, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    detailBottomSep:SetPoint("BOTTOMLEFT", 14, 52)
    detailBottomSep:SetWidth(454)

    U.update = Button(detail, L["Update"], 128, 32)
    U.update:SetPoint("BOTTOMLEFT", 14, 12)
    U.update.tooltipTitle = L["Update saved settings"]
    U.update.tooltipText = L["Replace this profile with your current game settings."]
    U.update:SetScript("OnClick", function()
        local profile = Selected()
        if profile then ConfirmDialog("update", profile) end
    end)

    U.apply = Button(detail, L["Apply profile"], 178, 32, true)
    U.apply:SetPoint("BOTTOMRIGHT", -14, 12)
    U.apply.tooltipTitle = L["Apply profile"]
    U.apply.tooltipText = L["Apply all graphics settings saved in this profile."]
    U.apply:SetScript("OnClick", function()
        local profile = Selected()
        if profile and not F.busy then F.ApplyProfile(profile.id) end
    end)

    -- ========================================================================
    -- Unified Window Footer (Restore + Status / Notice)
    -- ========================================================================
    local footerSep = THEME.CreateSeparator(window, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    footerSep:SetPoint("BOTTOMLEFT", 18, 46)
    footerSep:SetWidth(744)

    U.restore = Button(window, L["Restore previous settings"], 240, 28)
    U.restore:SetPoint("BOTTOMLEFT", 18, 12)
    U.restore.tooltipTitle = L["Restore previous settings"]
    U.restore.tooltipText = L["Return to the settings captured just before your last profile application."]
    U.restore:SetScript("OnClick", function()
        if not F.busy then F.RestorePrevious() end
    end)

    U.notice = Text(window, THEME.font.body, color.muted, 480, 28, true)
    U.notice:SetPoint("BOTTOMRIGHT", -18, 12)
    U.notice:SetJustifyH("RIGHT")
    U.notice:SetJustifyV("MIDDLE")

    -- ========================================================================
    -- Owned Context Menu (Rename / Duplicate / Export / Delete)
    -- ========================================================================
    U.menuBlocker = CreateFrame("Frame", nil, window)
    U.menuBlocker:SetAllPoints(UIParent)
    U.menuBlocker:SetFrameLevel(window:GetFrameLevel() + 15)
    U.menuBlocker:EnableMouse(true)
    U.menuBlocker:SetScript("OnMouseDown", CloseMenu)
    U.menuBlocker:Hide()

    U.menu = CreateFrame("Frame", "ForeverProfilesMenu", window)
    U.menu:SetSize(156, 144)
    U.menu:SetPoint("TOPRIGHT", U.menuButton, "BOTTOMRIGHT", 0, -4)
    U.menu:SetFrameLevel(window:GetFrameLevel() + 16)
    U.menu:EnableMouse(true)
    THEME.SkinWindow(U.menu)
    U.menu:SetScript("OnHide", function()
        U.menuBlocker:Hide()
        U.menuProfileID = nil
    end)
    U.menu:Hide()
    UISpecialFrames[#UISpecialFrames + 1] = "ForeverProfilesMenu"

    U.rename = Button(U.menu, L["Rename"], 140, 26)
    U.rename:SetPoint("TOPLEFT", 8, -8)
    U.duplicate = Button(U.menu, L["Duplicate"], 140, 26)
    U.duplicate:SetPoint("TOPLEFT", 8, -38)
    U.export = Button(U.menu, L["Export"], 140, 26)
    U.export:SetPoint("TOPLEFT", 8, -68)
    local menuSep = THEME.CreateSeparator(U.menu, "HORIZONTAL", color.borderSubtle, { 0, 0, 0, 0 })
    menuSep:SetPoint("TOPLEFT", 8, -100)
    menuSep:SetWidth(140)
    U.delete = Button(U.menu, L["Delete"], 140, 26, false, "danger")
    U.delete:SetPoint("TOPLEFT", 8, -106)

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
    U.export:SetScript("OnClick", function()
        local profile = MenuProfile()
        CloseMenu()
        if profile then U.OpenExportDialog(profile) end
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

    -- ========================================================================
    -- Favorite Bar Tab Panel (744 x 430)
    -- ========================================================================
    U.barPanel = Surface(window, 744, 430)
    U.barPanel:SetPoint("TOPLEFT", 18, -62)
    local barTitle = Text(U.barPanel, THEME.font.title, color.accent, 680, 26, true)
    barTitle:SetPoint("TOPLEFT", 16, -14)
    barTitle:SetText(L["Favorite bar"])
    local barHelp = Text(U.barPanel, THEME.font.body, color.muted, 700, 34)
    barHelp:SetPoint("TOPLEFT", 16, -42)
    barHelp:SetSpacing(2)
    barHelp:SetText(L["Choose up to three profiles for one-click access. Add or remove them with Favorite in the Profiles tab."])

    local barTopSep = THEME.CreateSeparator(U.barPanel, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    barTopSep:SetPoint("TOPLEFT", 16, -80)
    barTopSep:SetWidth(712)

    U.quickCheck = SkinnedCheckButton(U.barPanel, L["Show favorite quick bar"], 16, -94,
        function(self) F.SetQuickBarVisible(self:GetChecked() and true or false) end,
        L["Show favorite quick bar"],
        L["Apply a favorite profile in one click. Drag the dotted handle to move the bar."])

    U.quickLock = SkinnedCheckButton(U.barPanel, L["Lock favorite bar"], 330, -94,
        function(self) F.SetQuickBarLocked(self:GetChecked() and true or false) end,
        L["Lock favorite bar"],
        L["Keep the bar in place and hide its drag handle."])

    U.quickWidth, U.quickWidthLabel, U.quickWidthValue = QuickBarSlider(U.barPanel,
        L["Favorite bar width"], 250, 160, 1000, 10, function(_, value)
        if U.refreshingDimensions then return end
        F.SetQuickBarWidth(math.max(160, math.min(1000, math.floor(value / 10 + 0.5) * 10)))
    end, L["Adjust the bar width without changing its height or text size."])
    U.quickHeight, U.quickHeightLabel, U.quickHeightValue = QuickBarSlider(U.barPanel,
        L["Favorite bar height"], 214, 28, 120, 2, function(_, value)
        if U.refreshingDimensions then return end
        F.SetQuickBarHeight(math.max(28, math.min(120, math.floor(value / 2 + 0.5) * 2)))
    end, L["Adjust the bar height without changing its width or text size."])
    U.quickScale, U.quickScaleLabel, U.quickScaleValue = QuickBarSlider(U.barPanel,
        L["Favorite bar scale"], 178, 60, 180, 10, function(_, value)
        if U.refreshingScale then return end
        local percent = math.max(60, math.min(180, math.floor(value / 10 + 0.5) * 10))
        F.SetQuickBarScale(percent / 100)
    end, L["Resize the whole bar, including its buttons and text. You can also use the mouse wheel over its dotted handle."])

    U.quickWidthAuto = Button(U.barPanel, L["Auto width"], 82, 24)
    U.quickWidthAuto:SetPoint("BOTTOMLEFT", 646, 250)
    U.quickWidthAuto.tooltipTitle = L["Auto width"]
    U.quickWidthAuto.tooltipText = L["Restore automatic width based on the number of favorite profiles."]
    U.quickWidthAuto:SetScript("OnClick", function() F.SetQuickBarWidth(nil) end)

    local favSep = THEME.CreateSeparator(U.barPanel, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    favSep:SetPoint("TOPLEFT", 16, -264)
    favSep:SetWidth(712)

    local favoriteHeading = Text(U.barPanel, THEME.font.heading, color.accent, 680, 20, true)
    favoriteHeading:SetPoint("TOPLEFT", 16, -274)
    favoriteHeading:SetText(L["Favorite shortcuts (up to 3)"])
    U.favoriteSlots = {}
    for index = 1, 3 do
        local button = Button(U.barPanel, "", 712, 30)
        button:SetPoint("TOPLEFT", 16, -302 - (index - 1) * 36)
        button.labelAnchor = "LEFT"
        button.labelOffsetX = 12
        button.labelOffsetY = 0
        button.label:ClearAllPoints()
        button.label:SetPoint("LEFT", 12, 0)
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

    -- ========================================================================
    -- Automation Tab Panel (744 x 430)
    -- ========================================================================
    U.autoPanel = Surface(window, 744, 430)
    U.autoPanel:SetPoint("TOPLEFT", 18, -62)
    local autoTitle = Text(U.autoPanel, THEME.font.title, color.accent, 680, 26, true)
    autoTitle:SetPoint("TOPLEFT", 16, -14)
    autoTitle:SetText(L["Automatic activation"])
    local autoTopSep = THEME.CreateSeparator(U.autoPanel, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    autoTopSep:SetPoint("TOPLEFT", 16, -80)
    autoTopSep:SetWidth(712)

    U.autoCheck = SkinnedCheckButton(U.autoPanel, L["Enable automatic profile activation"], 16, -46,
        function(self) F.SetAutomationEnabled(self:GetChecked() and true or false) end,
        L["Enable automatic profile activation"],
        L["Monitor FPS and apply the configured drop and recovery rules."])

    U.autoMode = "drop"
    U.autoTabs = {
        drop = Button(U.autoPanel, L["FPS drop"], 110, 24),
        recovery = Button(U.autoPanel, L["FPS recovery"], 128, 24),
    }
    U.autoTabs.drop:SetPoint("TOPLEFT", 16, -94)
    U.autoTabs.recovery:SetPoint("LEFT", U.autoTabs.drop, "RIGHT", 6, 0)
    local function ShowAutomationRule(mode)
        U.autoMode = mode
        U.autoProfileScroll.slider:SetValue(0)
        U.Refresh()
    end
    U.autoTabs.drop:SetScript("OnClick", function() ShowAutomationRule("drop") end)
    U.autoTabs.recovery:SetScript("OnClick", function() ShowAutomationRule("recovery") end)
    U.autoClearRecovery = Button(U.autoPanel, L["Clear recovery target"], 160, 24)
    U.autoClearRecovery:SetPoint("TOPRIGHT", -16, -94)
    U.autoClearRecovery:SetScript("OnClick", function() F.ConfigureAutomation({ recoveryProfileID = false }) end)
    U.autoClearRecovery:Hide()

    local profileRules = F.Profiles
    U.autoStatusWell = Surface(U.autoPanel, 250, 24, color.well, true)
    U.autoStatusWell:SetPoint("TOPRIGHT", -16, -45)
    U.autoStatusDot = U.autoStatusWell:CreateTexture(nil, "ARTWORK")
    U.autoStatusDot:SetSize(6, 6)
    U.autoStatusDot:SetPoint("LEFT", 8, 0)
    SetColor(U.autoStatusDot, color.muted)
    U.autoStatusText = Text(U.autoStatusWell, THEME.font.caption, color.muted, 224, 24, true)
    U.autoStatusText:SetPoint("LEFT", 20, 0)
    U.autoStatusText:SetJustifyV("MIDDLE")

    U.autoThreshold, U.autoThresholdLabel, U.autoThresholdValue = QuickBarSlider(U.autoPanel,
        L["FPS threshold"], 268, profileRules.MIN_FPS_THRESHOLD, profileRules.MAX_FPS_THRESHOLD, 1, function(_, value)
        if U.refreshingAutomation then return end
        local field = U.autoMode == "recovery" and "recoveryThreshold" or "fpsThreshold"
        F.ConfigureAutomation({ [field] = value })
    end, L["The drop rule uses FPS below its threshold. The recovery rule uses FPS above its threshold."])

    U.autoThresholdReset = Button(U.autoPanel, L["80 FPS"], 82, 24)
    U.autoThresholdReset:SetPoint("BOTTOMLEFT", 646, 268)
    U.autoThresholdReset.tooltipTitle = L["Default FPS threshold"]
    U.autoThresholdReset.tooltipText = L["Restore the default FPS threshold for this rule."]
    U.autoThresholdReset:SetScript("OnClick", function()
        if U.autoMode == "recovery" then
            F.ConfigureAutomation({ recoveryThreshold = profileRules.DEFAULT_RECOVERY_THRESHOLD })
        else
            F.SetAutomationFPSThreshold(profileRules.DEFAULT_FPS_THRESHOLD)
        end
    end)

    U.autoDuration, U.autoDurationLabel, U.autoDurationValue = QuickBarSlider(U.autoPanel,
        L["Duration (seconds)"], 232, profileRules.MIN_DURATION, profileRules.MAX_DURATION, 1, function(_, value)
        if U.refreshingAutomation then return end
        local field = U.autoMode == "recovery" and "recoveryDuration" or "duration"
        F.ConfigureAutomation({ [field] = value })
    end, L["Number of consecutive seconds the FPS condition must hold before applying the profile."])

    U.autoDurationReset = Button(U.autoPanel, L["5 s"], 82, 24)
    U.autoDurationReset:SetPoint("BOTTOMLEFT", 646, 232)
    U.autoDurationReset.tooltipTitle = L["Default duration"]
    U.autoDurationReset.tooltipText = L["Restore the default duration for this rule."]
    U.autoDurationReset:SetScript("OnClick", function()
        if U.autoMode == "recovery" then
            F.ConfigureAutomation({ recoveryDuration = profileRules.DEFAULT_RECOVERY_DURATION })
        else
            F.SetAutomationDuration(profileRules.DEFAULT_DURATION)
        end
    end)

    U.autoRuleSummary = Text(U.autoPanel, THEME.font.body, color.accentBright, 712, 20, true)
    U.autoRuleSummary:SetPoint("TOPLEFT", 16, -210)
    U.autoRuleSummary:SetJustifyV("MIDDLE")

    local autoMidSep = THEME.CreateSeparator(U.autoPanel, "HORIZONTAL", color.border, { color.border[1], color.border[2], color.border[3], 0 })
    autoMidSep:SetPoint("TOPLEFT", 16, -238)
    autoMidSep:SetWidth(712)

    local autoTargetHeading = Text(U.autoPanel, THEME.font.heading, color.accent, 680, 20, true)
    autoTargetHeading:SetPoint("TOPLEFT", 16, -248)
    autoTargetHeading:SetText(L["Target profile to apply"])

    local autoTargetWell = Surface(U.autoPanel, 712, 144, color.well, true)
    autoTargetWell:SetPoint("TOPLEFT", 16, -272)
    U.autoTargetWell = autoTargetWell
    U.autoProfileScroll = ScrollArea(autoTargetWell, 704, 136, 4, -4)
    U.autoProfileRows = {}
    U.autoProfileEmpty = Text(U.autoProfileScroll.content, THEME.font.body, color.muted, 660, 40)
    U.autoProfileEmpty:SetPoint("TOPLEFT", 12, -14)
    U.autoProfileEmpty:SetText(L["No profiles yet. Save a profile in the Profiles tab to select it here."])

    U.activeTab = U.activeTab or "profiles"
    U.profilePanel:SetShown(U.activeTab == "profiles")
    U.barPanel:SetShown(U.activeTab == "favorites")
    U.autoPanel:SetShown(U.activeTab == "automation")
    for key, button in pairs(U.tabs) do
        button.selected = U.activeTab == key
        PaintButton(button, false)
    end

    window:SetScript("OnShow", function()
        Fit(window, WIDTH, HEIGHT)
        THEME.SetGradient(header.classStrip, "HORIZONTAL", THEME.GetClassColor(), color.accent)
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
    if tab ~= "profiles" and tab ~= "favorites" and tab ~= "automation" then return end
    U.Initialize()
    CloseMenu()
    if U.modal then U.modal:Hide() end
    U.activeTab = tab
    U.profilePanel:SetShown(tab == "profiles")
    U.barPanel:SetShown(tab == "favorites")
    if U.autoPanel then U.autoPanel:SetShown(tab == "automation") end
    for key, button in pairs(U.tabs) do
        button.selected = key == tab
        PaintButton(button, button.hovered)
    end
    U.Refresh()
end

function U.SetSummaryMode(mode)
    if mode ~= "normal" and mode ~= "raid" and mode ~= "saved" then return end
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

function U.RefreshAutomationStatus()
    if not U.window or not U.window:IsShown() or not U.autoPanel then return end
    local auto = F.GetAutomation and F.GetAutomation()
    if not auto then return end
    local profiles = DB().profiles
    local dropTarget = profiles[auto.profileID]
    local recoveryTarget = profiles[auto.recoveryProfileID]
    local editingRecovery = U.autoMode == "recovery"
    local target = profiles[auto[editingRecovery and "recoveryProfileID" or "profileID"]]
    local fps = auto.currentFPS
    local fpsLabel = fps and string.format("%.0f FPS", fps) or L["FPS N/A"]

    if not auto.enabled then
        SetColor(U.autoStatusDot, color.dim)
        U.autoStatusText:SetText(fpsLabel .. " · " .. L["Disabled"])
        U.autoStatusText:SetTextColor(unpack(color.muted))
    elseif not dropTarget then
        SetColor(U.autoStatusDot, color.warning)
        U.autoStatusText:SetText(fpsLabel .. " · " .. L["No drop target"])
        U.autoStatusText:SetTextColor(unpack(color.warning))
    elseif F.IsWindowFocused and not F.IsWindowFocused() then
        SetColor(U.autoStatusDot, color.dim)
        U.autoStatusText:SetText(fpsLabel .. " · " .. L["Paused (background)"])
        U.autoStatusText:SetTextColor(unpack(color.muted))
    elseif auto.recoveryElapsed > 0 then
        SetColor(U.autoStatusDot, color.accent)
        U.autoStatusText:SetText(string.format(L["%s · Recovery %.1f/%d s"], fpsLabel, auto.recoveryElapsed, auto.recoveryDuration))
        U.autoStatusText:SetTextColor(unpack(color.accentBright))
    elseif auto.elapsed > 0 then
        SetColor(U.autoStatusDot, color.warning)
        U.autoStatusText:SetText(string.format(L["%s · Drop %.1f/%d s"], fpsLabel, auto.elapsed, auto.duration))
        U.autoStatusText:SetTextColor(unpack(color.warning))
    elseif target and Status(target.id) == L["Active"] then
        SetColor(U.autoStatusDot, color.active)
        U.autoStatusText:SetText(fpsLabel .. " · " .. L["Target active"])
        U.autoStatusText:SetTextColor(unpack(color.active))
    else
        SetColor(U.autoStatusDot, color.active)
        U.autoStatusText:SetText(fpsLabel .. " · " .. L["Monitoring"])
        U.autoStatusText:SetTextColor(unpack(color.text))
    end

    local summary, tint
    if editingRecovery then
        if not recoveryTarget then
            summary, tint = L["Select a target profile to enable FPS recovery."], color.muted
        elseif not dropTarget then
            summary, tint = L["Select a target under FPS drop to use FPS recovery."], color.warning
        elseif recoveryTarget == dropTarget then
            summary, tint = L["Choose different targets for FPS drop and FPS recovery."], color.warning
        elseif auto.recoveryThreshold < auto.fpsThreshold then
            summary, tint = F.Format("Set the recovery threshold to at least %d FPS.", auto.fpsThreshold), color.warning
        else
            summary = F.Format("After %ds above %d FPS, switch from %s to %s.",
                auto.recoveryDuration, auto.recoveryThreshold, Plain(dropTarget.name), Plain(recoveryTarget.name))
        end
    elseif dropTarget then
        summary = F.Format('Apply "%s" after %ds below %d FPS.',
            Plain(dropTarget.name), auto.duration, auto.fpsThreshold)
    else
        summary, tint = L["Select a target profile for FPS drop."], color.warning
    end
    U.autoRuleSummary:SetText(summary)
    U.autoRuleSummary:SetTextColor(unpack(tint or (auto.enabled and color.accentBright or color.muted)))
end

function U.RefreshScale()
    if U.window then Fit(U.window, WIDTH, HEIGHT) end
    if U.quickBar and U.quickBar.RefreshScale then U.quickBar:RefreshScale() end
    THEME.RefreshAllScales()
end

function U.Refresh()
    U.RefreshQuickBar()
    if U.modal then
        Enabled(U.modal.accept, U.modal.mode == "export" or not F.busy)
    end
    if not U.window or not U.window:IsShown() or not DB() then return end
    local profiles = F.Profiles.List()
    local profile = Selected()
    if not profile and profiles[1] then
        F.Profiles.SetSelected(profiles[1].id)
        profile = profiles[1]
    end
    local favorites = FavoriteMap()
    local auto = F.GetAutomation and F.GetAutomation()
    if F.busy or (U.menuProfileID and (not profile or U.menuProfileID ~= profile.id)) then
        CloseMenu()
    end

    U.listTitle:SetText(L["Profiles"] .. " (" .. #profiles .. ")")
    local activeProfile
    for index, item in ipairs(profiles) do
        local row = U.profileRows[index]
        if not row then
            row = ProfileRow(U.listScroll.content, U.listScroll.content:GetWidth())
            U.profileRows[index] = row
        end
        row:SetPoint("TOPLEFT", 0, -(index - 1) * 62)
        row.profile = item
        row.selected = profile and profile.id == item.id or false
        local status = Status(item.id)
        row.active = status == L["Active"]
        if row.active and not activeProfile then activeProfile = item end
        row.badge.text:SetText(GetProfileQualityBadge(item))
        row.title:SetText(Plain(item.name))
        local tags = status
        if favorites[item.id] then tags = tags .. " · " .. L["Fav"] end
        if auto and (auto.profileID == item.id or auto.recoveryProfileID == item.id) then
            tags = tags .. " · " .. L["Auto"]
        end
        row.status:SetText(tags)
        local sColor = StatusColor(status)
        row.status:SetTextColor(unpack(sColor))
        SetColor(row.statusDot, sColor)
        row.quickApply.variant = row.active and "active" or nil
        row.quickApply.label:SetText(row.active and L["Active"] or L["Apply"])
        PaintButton(row.quickApply, row.quickApply.hovered)
        Enabled(row.quickApply, not F.busy)
        PaintProfileRow(row, row.hovered)
        row:Show()
    end
    for index = #profiles + 1, #U.profileRows do U.profileRows[index]:Hide() end
    local isEmpty = #profiles == 0
    if U.listEmptyFrame then U.listEmptyFrame:SetShown(isEmpty) end
    U.listEmpty:SetShown(isEmpty)
    U.listScroll:SetContentHeight(#profiles * 62)

    -- Update Header Active Profile Pill
    if U.activePill then
        U.activePill:SetSize(162, 24)
        U.activePill.label:SetWidth(133)
        if activeProfile then
            U.activePill.activeProfileID = activeProfile.id
            U.activePill.variant = "active"
            U.activePill.label:SetText(Plain(activeProfile.name))
            SetColor(U.activePill.dot, color.active)
            U.activePill.tooltipText = L["Click to select the currently active profile."]
        else
            U.activePill.activeProfileID = nil
            U.activePill.variant = nil
            U.activePill.label:SetText(L["No active profile"])
            SetColor(U.activePill.dot, color.dim)
            U.activePill.tooltipText = L["No saved profile currently matches all active game settings."]
        end
        PaintButton(U.activePill, U.activePill.hovered)
    end

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
    Enabled(U.importButton, not F.busy)
    for _, button in ipairs({ U.rename, U.duplicate, U.update, U.delete, U.apply, U.favorite, U.menuButton }) do
        Enabled(button, canEdit)
    end
    Enabled(U.export, profile ~= nil)
    if U.modal then
        Enabled(U.modal.accept, U.modal.mode == "export" or not F.busy)
    end
    Enabled(U.restore, not F.busy and F.CanRestore and F.CanRestore())

    U.profileName:SetText(profile and Plain(profile.name) or L["Your first profile"])
    U.favorite.selected = profile and favorites[profile.id] or false
    U.favorite.label:SetText(U.favorite.selected and L["Favorited"] or L["Favorite"])
    U.favorite.tooltipText = U.favorite.selected and L["Click to remove this profile from favorites."]
        or L["Keep up to three favorite profiles in the quick bar."]
    PaintButton(U.favorite, U.favorite.hovered)

    local status = profile and Status(profile.id) or L["Save your current configuration to get started."]
    local isSelectedActive = profile and status == L["Active"]
    if U.detailBadge then
        U.detailBadge.text:SetText(profile and GetProfileQualityBadge(profile) or "FP")
        local badgeTextColor = not profile and color.muted or (isSelectedActive and color.active or color.accentBright)
        local badgeBorderColor = not profile and color.borderSubtle or (isSelectedActive and color.active or color.selectedBorder)
        U.detailBadge.text:SetTextColor(unpack(badgeTextColor))
        if U.detailBadge.rim and U.detailBadge.rim.SetInnerColor then
            U.detailBadge.rim:SetInnerColor(badgeBorderColor)
        end
    end
    local displayStatus = status
    if profile and status == L["Modified"] then
        displayStatus = L["Modified"] .. " · " .. L["not applied"]
    end
    U.status:SetText(F.busy and L["Applying settings..."] or displayStatus)
    local stColor = StatusColor(status)
    U.status:SetTextColor(unpack(stColor))
    SetColor(U.statusDot, stColor)
    U.apply.variant = isSelectedActive and "active" or nil
    U.apply.primary = not isSelectedActive
    U.apply.label:SetText(isSelectedActive and L["Active"] or L["Apply profile"])
    PaintButton(U.apply, U.apply.hovered)

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
        local isFavActive = favorite ~= nil and Status(favorite.id) == L["Active"]
        button.selected = isFavActive
        button.variant = isFavActive and "active" or nil
        button.label:SetText(L["Favorite " .. index] .. ": " .. (favorite and Plain(favorite.name) or L["No favorite"]))
        button.tooltipTitle = favorite and Plain(favorite.name) or L["No favorite"]
        button.tooltipText = favorite and L["Click to view this profile. Selecting it does not apply it."]
            or L["Select a profile and click Favorite to add it to favorites."]
        PaintButton(button, button.hovered)
    end

    if U.autoPanel and auto then
        local recovering = U.autoMode == "recovery"
        local threshold = recovering and auto.recoveryThreshold or auto.fpsThreshold
        local duration = recovering and auto.recoveryDuration or auto.duration
        local targetID = auto[recovering and "recoveryProfileID" or "profileID"]
        local defaultThreshold = recovering and F.Profiles.DEFAULT_RECOVERY_THRESHOLD or F.Profiles.DEFAULT_FPS_THRESHOLD
        local defaultDuration = recovering and F.Profiles.DEFAULT_RECOVERY_DURATION or F.Profiles.DEFAULT_DURATION
        U.autoCheck:SetChecked(auto.enabled == true)
        for mode, button in pairs(U.autoTabs) do
            button.selected = U.autoMode == mode
            PaintButton(button, button.hovered)
        end
        U.autoClearRecovery:SetShown(recovering)
        Enabled(U.autoClearRecovery, recovering and targetID ~= nil)
        U.refreshingAutomation = true
        U.autoThreshold:SetValue(threshold)
        U.autoThresholdValue:SetText(string.format(recovering and "> %d FPS" or "< %d FPS", threshold))
        U.autoDuration:SetValue(duration)
        U.autoDurationValue:SetText(string.format("%d s", duration))
        U.refreshingAutomation = nil
        U.autoThresholdReset.label:SetText(string.format("%d FPS", defaultThreshold))
        U.autoDurationReset.label:SetText(string.format("%d s", defaultDuration))
        Enabled(U.autoThresholdReset, threshold ~= defaultThreshold)
        Enabled(U.autoDurationReset, duration ~= defaultDuration)

        local rowWidth = U.autoProfileScroll.content:GetWidth()
        for index, item in ipairs(profiles) do
            local button = U.autoProfileRows[index]
            if not button then
                button = Button(U.autoProfileScroll.content, "", rowWidth, 30)
                button.labelAnchor = "LEFT"
                button.labelOffsetX = 12
                button.labelOffsetY = 0
                button.label:ClearAllPoints()
                button.label:SetPoint("LEFT", 12, 0)
                button.label:SetWidth(math.max(1, rowWidth - 24))
                button.label:SetJustifyH("LEFT")
                button:SetScript("OnClick", function(self)
                    if not self.profileID then return end
                    if U.autoMode == "recovery" then
                        F.ConfigureAutomation({ recoveryProfileID = self.profileID })
                    else
                        F.SetAutomationProfile(self.profileID)
                    end
                end)
                U.autoProfileRows[index] = button
            end
            button:SetPoint("TOPLEFT", 0, -(index - 1) * 34)
            button.profileID = item.id
            local isTarget = targetID == item.id
            button.selected = isTarget
            local itemStatus = Status(item.id)
            local suffix = isTarget and ("  [" .. L["Selected target"] .. "]") or ("  (" .. itemStatus .. ")")
            button.label:SetText(Plain(item.name) .. suffix)
            button.tooltipTitle = Plain(item.name)
            button.tooltipText = isTarget and L["This profile will be applied automatically when the criterion is met."]
                or L["Click to choose this profile for automatic activation."]
            PaintButton(button, button.hovered)
            button:Show()
        end
        for index = #profiles + 1, #U.autoProfileRows do U.autoProfileRows[index]:Hide() end
        U.autoProfileEmpty:SetShown(#profiles == 0)
        U.autoProfileScroll:SetContentHeight(#profiles * 34)
        U.RefreshAutomationStatus()
    end

    U.SetNotice(U.noticeMessage or L["Selecting a profile does not apply it."], U.noticeError)
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
    THEME.SkinWindow(bar)
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
        SetColor(dot, color.muted)
        bar.grip.dots[index] = dot
    end
    bar.grip:SetScript("OnEnter", function(self)
        for _, dot in ipairs(self.dots) do SetColor(dot, color.accentBright) end
        Tooltip(self, L["Move favorite bar"], L["Drag this handle to move the bar. Use the mouse wheel to change its size."])
    end)
    bar.grip:SetScript("OnLeave", function(self)
        for _, dot in ipairs(self.dots) do SetColor(dot, color.muted) end
        HideTooltip()
    end)
    bar.grip:SetScript("OnMouseWheel", function(_, delta)
        local db = DB()
        if db and db.ui.quickBarLocked then return end
        local scale = db and db.ui and db.ui.quickBarScale or 1
        F.SetQuickBarScale(math.max(0.6, math.min(1.8, scale + delta * 0.1)))
    end)
    bar.handle = Button(bar, "FP", 38, 30)
    bar.handle.selected = true
    PaintButton(bar.handle, false)
    bar.handle:SetPoint("LEFT", 31, 0)
    bar.handle.tooltipTitle = "Forever Profiles"
    bar.handle.tooltipText = L["Click to open profiles."]
    bar.handle:SetScript("OnClick", U.Toggle)
    bar.buttons = {}
    for index = 1, 3 do
        local button = Button(bar, "", 136, 30)
        button:SetPoint("LEFT", 75 + (index - 1) * 142, 0)
        button:SetScript("OnClick", function(self)
            if self.profile and not F.busy then
                F.ApplyProfile(self.profile.id)
            end
        end)
        bar.buttons[index] = button
    end
    bar.empty = Text(bar, THEME.font.caption, color.muted, 275, 30, true)
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
    local width, height = F.GetQuickBarDimensions()
    local requestedScale = db.ui.quickBarScale or 1
    local availableWidth = math.max(1, UIParent:GetWidth() - 32)
    local availableHeight = math.max(1, UIParent:GetHeight() - 32)
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
            local isActive = status == L["Active"]
            button.selected = isActive
            button.variant = isActive and "active" or nil
            PaintButton(button, button.hovered)
        end
    end
    bar.empty:SetShown(count == 0)
    bar.empty:SetSize(width - start - 16, buttonHeight)
    bar:SetScale(requestedScale)
    if bar.RefreshScale then bar:RefreshScale() end
    bar:Show()
end
