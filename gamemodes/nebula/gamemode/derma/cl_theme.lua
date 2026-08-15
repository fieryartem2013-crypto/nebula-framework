--[[
    Nebula Framework - Theme System
    Star Wars inspired dark theme
]]

Nebula.theme = Nebula.theme or {}

-- Theme colors
Nebula.theme.colors = {
    -- Primary colors
    primary = Color(100, 180, 255),
    primaryDark = Color(60, 130, 200),
    primaryLight = Color(150, 210, 255),
    
    -- Background colors
    background = Color(20, 20, 30),
    backgroundLight = Color(30, 30, 45),
    backgroundDark = Color(15, 15, 25),
    
    -- Panel colors
    panel = Color(35, 35, 50),
    panelLight = Color(45, 45, 65),
    panelDark = Color(25, 25, 40),
    
    -- Text colors
    text = Color(240, 240, 240),
    textDark = Color(180, 180, 200),
    textMuted = Color(120, 120, 140),
    textAccent = Color(100, 180, 255),
    
    -- Status colors
    success = Color(80, 200, 80),
    danger = Color(255, 80, 80),
    warning = Color(255, 200, 50),
    info = Color(100, 200, 255),
    
    -- Faction colors (Star Wars)
    empire = Color(200, 50, 50),
    rebel = Color(50, 150, 255),
    citizen = Color(150, 150, 150),
    bountyHunter = Color(255, 150, 50),
    smuggler = Color(100, 200, 100),
    mandalorian = Color(180, 180, 200),
    
    -- Special
    border = Color(60, 60, 80),
    highlight = Color(80, 160, 255, 50),
    shadow = Color(0, 0, 0, 100),
}

-- Get theme color
function Nebula.theme:GetColor(name)
    return self.colors[name] or color_white
end

-- Draw themed panel
function Nebula.theme:DrawPanel(x, y, w, h, color)
    color = color or self.colors.panel
    draw.RoundedBox(6, x, y, w, h, color)
end

-- Draw themed border
function Nebula.theme:DrawBorder(x, y, w, h, color, thickness)
    color = color or self.colors.border
    thickness = thickness or 1
    surface.SetDrawColor(color)
    surface.DrawOutlinedRect(x, y, w, h, thickness)
end

-- Draw themed button
function Nebula.theme:DrawButton(panel, w, h, color, hoverColor)
    color = color or self.colors.panelLight
    hoverColor = hoverColor or self.colors.primaryDark
    
    local bgColor = panel:IsHovered() and hoverColor or color
    
    if panel:IsDisabled() then
        bgColor = Color(40, 40, 50)
    end
    
    draw.RoundedBox(4, 0, 0, w, h, bgColor)
    self:DrawBorder(0, 0, w, h, self.colors.border)
end

-- Draw Star Wars style divider
function Nebula.theme:DrawDivider(y, w, color)
    color = color or self.colors.primary
    
    -- Center glow line
    local lineW = w * 0.6
    local startX = (w - lineW) / 2
    
    surface.SetDrawColor(color.r, color.g, color.b, 50)
    surface.DrawRect(startX, y, lineW, 2)
    
    surface.SetDrawColor(color.r, color.g, color.b, 150)
    surface.DrawRect(startX + lineW * 0.2, y, lineW * 0.6, 2)
    
    -- Diamond accent in center
    local cx = w / 2
    surface.SetDrawColor(color)
    surface.DrawLine(cx - 5, y - 3, cx, y - 8)
    surface.DrawLine(cx, y - 8, cx + 5, y - 3)
    surface.DrawLine(cx + 5, y - 3, cx, y + 2)
    surface.DrawLine(cx, y + 2, cx - 5, y - 3)
end

-- Derma hooks for theme override
hook.Add("VGUIMousePressAllowed", "Nebula:Theme", function()
    -- Allow our themed panels to handle input
end)

-- Override default Derma skin
local SKIN = {}

SKIN.PrintName = "Nebula Theme"
SKIN.Author = "Nebula Team"
SKIN.DermaVersion = 1

SKIN.fontFrame = "Nebula:Font:18"
SKIN.fontTab = "Nebula:Font:16"
SKIN.fontButton = "Nebula:Font:16"

SKIN.colFrameBg = Nebula.theme.colors.background
SKIN.colFrameBorder = Nebula.theme.colors.border
SKIN.colTitleText = Nebula.theme.colors.text

SKIN.colPropertySheet = Nebula.theme.colors.panel
SKIN.colTabTextInactive = Nebula.theme.colors.textDark
SKIN.colTabTextActive = Nebula.theme.colors.text

SKIN.colButton = Nebula.theme.colors.panelLight
SKIN.colButtonText = Nebula.theme.colors.text
SKIN.colButtonBorder = Nebula.theme.colors.border

SKIN.colTextEntryBg = Nebula.theme.colors.panelDark
SKIN.colTextEntryBorder = Nebula.theme.colors.border
SKIN.colTextEntryText = Nebula.theme.colors.text
SKIN.colTextEntryHighlight = Nebula.theme.colors.primary

-- Register the skin
derma.DefineSkin("Nebula", "Nebula Framework Dark Theme", SKIN)

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Theme loaded.\n")
