--[[
    Nebula Framework - Chat System (Shared)
    Roleplay chat with multiple chat types
]]

Nebula.chat = Nebula.chat or {}
Nebula.chat.types = Nebula.chat.types or {}

-- Register a chat type
function Nebula.chat:RegisterType(id, data)
    self.types[id] = {
        id = id,
        name = data.name or id,
        color = data.color or color_white,
        range = data.range or Nebula.config:Get("chat_range", 500),
        format = data.format or "%s: \"%s\"",
        adminOnly = data.adminOnly or false,
        deadCanSee = data.deadCanSee or false,
        canHear = data.canHear, -- Custom function(ply, listener)
        onChat = data.onChat, -- Custom callback
    }
end

-- Get chat type
function Nebula.chat:GetType(id)
    return self.types[id]
end

-- Format a chat message
function Nebula.chat:Format(chatType, speaker, text)
    local typeData = self:GetType(chatType)
    if not typeData then return text end
    
    local name = Nebula.character:GetName(speaker)
    return string.format(typeData.format, name, text)
end

-- Get message color for chat type
function Nebula.chat:GetColor(chatType)
    local typeData = self:GetType(chatType)
    return typeData and typeData.color or color_white
end

-- ==========================================
-- Default Chat Types
-- ==========================================

-- IC (In Character) - Normal speech
Nebula.chat:RegisterType("ic", {
    name = "Say",
    color = Color(255, 255, 255),
    range = Nebula.config:Get("chat_range", 500),
    format = "%s says: \"%s\"",
})

-- Yell
Nebula.chat:RegisterType("yell", {
    name = "Yell",
    color = Color(255, 200, 100),
    range = Nebula.config:Get("yell_range", 1000),
    format = "%s yells: \"%s\"",
})

-- Whisper
Nebula.chat:RegisterType("whisper", {
    name = "Whisper",
    color = Color(180, 180, 200),
    range = Nebula.config:Get("whisper_range", 150),
    format = "%s whispers: \"%s\"",
})

-- Me (Action)
Nebula.chat:RegisterType("me", {
    name = "Me",
    color = Color(200, 150, 255),
    range = Nebula.config:Get("chat_range", 500),
    format = "%s %s",
})

-- LOOC (Local Out Of Character)
Nebula.chat:RegisterType("looc", {
    name = "LOOC",
    color = Color(180, 220, 180),
    range = Nebula.config:Get("chat_range", 500),
    format = "(( LOOC %s: %s ))",
})

-- OOC (Out Of Character) - Global
Nebula.chat:RegisterType("ooc", {
    name = "OOC",
    color = Color(180, 200, 255),
    range = 0, -- 0 = global
    format = "(( OOC %s: %s ))",
})

-- Radio
Nebula.chat:RegisterType("radio", {
    name = "Radio",
    color = Color(255, 150, 50),
    range = 0, -- Faction-based
    format = "[Radio] %s: %s",
    canHear = function(ply, listener)
        -- Same faction can hear radio
        return Nebula.faction:GetPlayerFaction(ply) == Nebula.faction:GetPlayerFaction(listener)
    end,
})

-- Admin chat
Nebula.chat:RegisterType("admin", {
    name = "Admin",
    color = Color(255, 100, 100),
    range = 0,
    format = "[Admin] %s: %s",
    adminOnly = true,
})

-- Console/Event
Nebula.chat:RegisterType("event", {
    name = "Event",
    color = Color(255, 200, 50),
    range = 0,
    format = "[Event] %s",
})

Nebula.util:Log("Chat", "Chat system initialized.")
