--[[
    Nebula Framework - Chat System (Client)
    Client-side chat rendering and UI
]]

Nebula.chat = Nebula.chat or {}

-- Receive chat messages from server
net.Receive("Nebula:ChatMessage", function()
    local chatType = net.ReadString()
    local message = net.ReadString()
    local hasSpeaker = net.ReadBool()
    local speaker = nil
    
    if hasSpeaker then
        speaker = net.ReadEntity()
    end
    
    local typeData = Nebula.chat:GetType(chatType)
    if not typeData then return end
    
    -- Get color
    local color = typeData.color
    
    -- Add to chat
    chat.AddText(color, message)
    
    -- Play sound based on chat type
    if chatType == "ic" or chatType == "yell" then
        surface.PlaySound("buttons/button15.wav")
    elseif chatType == "radio" then
        surface.PlaySound("buttons/button17.wav")
    elseif chatType == "admin" then
        surface.PlaySound("buttons/button10.wav")
    end
end)

-- Chat HUD replacement
hook.Add("ChatText", "Nebula:SuppressDefault", function(index, name, text, messageType)
    -- Suppress default join/leave messages, we'll handle them
    if messageType == "joinleave" or messageType == "namechange" then
        return true
    end
end)

-- Custom chat box (optional, can be disabled)
if GetConVar("nebula_custom_chat") and GetConVar("nebula_custom_chat"):GetBool() then
    -- This would be a full custom chat box implementation
    -- For now, we use the default GMod chat with our formatting
end

-- Chat command suggestions
hook.Add("OnChatTab", "Nebula:ChatTab", function(text)
    -- Tab completion for commands
    local commands = {
        "/me ", "/yell ", "/y ", "/whisper ", "/w ",
        "/radio ", "/r ", "// ", "(( ", "/a ",
    }
    
    local lower = string.lower(text)
    
    for _, cmd in ipairs(commands) do
        if string.sub(string.lower(cmd), 1, #lower) == lower then
            return cmd
        end
    end
    
    -- Player name completion
    local lastWord = string.match(lower, "%s+(%S+)$")
    if lastWord then
        for _, ply in ipairs(player.GetAll()) do
            local name = string.lower(Nebula.character:GetName(ply))
            if string.sub(name, 1, #lastWord) == lastWord then
                local prefix = string.sub(text, 1, #text - #lastWord)
                return prefix .. Nebula.character:GetName(ply) .. " "
            end
        end
    end
    
    return text
end)

Nebula.util:Log("Chat", "Client chat system initialized.")
