--[[
    Nebula Framework - Font Definitions
    Custom fonts for the UI
]]

local fontName = "Roboto" -- Main font
local fallbackFont = "Arial" -- Fallback

-- Helper function to create font
local function CreateFont(name, size, weight, italic)
    weight = weight or 500
    italic = italic or false
    
    surface.CreateFont("Nebula:Font:" .. size, {
        font = fontName,
        size = size,
        weight = weight,
        antialias = true,
        italic = italic,
    })
    
    -- Bold variant
    surface.CreateFont("Nebula:Font:" .. size .. ":Bold", {
        font = fontName,
        size = size,
        weight = 700,
        antialias = true,
    })
end

-- Create fonts at various sizes
CreateFont("Nebula:Font", 12)
CreateFont("Nebula:Font", 14)
CreateFont("Nebula:Font", 16)
CreateFont("Nebula:Font", 18)
CreateFont("Nebula:Font", 20)
CreateFont("Nebula:Font", 24)
CreateFont("Nebula:Font", 28)
CreateFont("Nebula:Font", 32)
CreateFont("Nebula:Font", 36)
CreateFont("Nebula:Font", 40)
CreateFont("Nebula:Font", 48)
CreateFont("Nebula:Font", 56)
CreateFont("Nebula:Font", 64)

-- Special fonts
surface.CreateFont("Nebula:Font:Title", {
    font = fontName,
    size = 48,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Nebula:Font:Subtitle", {
    font = fontName,
    size = 24,
    weight = 500,
    antialias = true,
})

surface.CreateFont("Nebula:Font:HUD", {
    font = fontName,
    size = 20,
    weight = 600,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Nebula:Font:HUD:Small", {
    font = fontName,
    size = 16,
    weight = 500,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Nebula:Font:HUD:Large", {
    font = fontName,
    size = 28,
    weight = 700,
    antialias = true,
    shadow = true,
})

surface.CreateFont("Nebula:Font:Chat", {
    font = fontName,
    size = 18,
    weight = 500,
    antialias = true,
})

surface.CreateFont("Nebula:Font:Console", {
    font = "Consolas",
    size = 14,
    weight = 500,
    antialias = true,
})

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Fonts loaded.\n")
