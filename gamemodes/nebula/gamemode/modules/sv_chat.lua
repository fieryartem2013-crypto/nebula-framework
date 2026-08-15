--[[
    Nebula Framework - Chat System (Server)
    Server-side chat processing and distribution
]]

Nebula.chat = Nebula.chat or {}

-- Network strings
util.AddNetworkString("Nebula:ChatMessage")

-- Send a chat message
function Nebula.chat:Send(speaker, chatType, text, recipients)
    if not IsValid(speaker) and chatType ~= "event" then return end
    
    local typeData = self:GetType(chatType)
    if not typeData then return end
    
    -- Check permissions
    if typeData.adminOnly and IsValid(speaker) and not speaker:IsAdmin() then
        Nebula.util:Notify(speaker, 1, "You don't have permission to use this chat type!")
        return
    end
    
    -- Run custom callback
    if typeData.onChat then
        local result = typeData.onChat(speaker, text)
        if result == false then return end
        if type(result) == "string" then text = result end
    end
    
    -- Format message
    local formatted = self:Format(chatType, speaker, text)
    
    -- Determine recipients
    local targets = recipients or self:GetRecipients(speaker, chatType, typeData)
    
    -- Send to recipients
    net.Start("Nebula:ChatMessage")
        net.WriteString(chatType)
        net.WriteString(formatted)
        net.WriteBool(IsValid(speaker))
        if IsValid(speaker) then
            net.WriteEntity(speaker)
        end
    net.Send(targets)
    
    -- Log to console
    if IsValid(speaker) then
        Msg("[Chat:" .. chatType .. "] " .. formatted .. "\n")
    else
        Msg("[Chat:" .. chatType .. "] " .. formatted .. "\n")
    end
end

-- Get message recipients based on chat type
function Nebula.chat:GetRecipients(speaker, chatType, typeData)
    local recipients = {}
    
    -- Global chat types
    if typeData.range == 0 then
        if chatType == "radio" then
            -- Radio: same faction only
            for _, ply in ipairs(player.GetAll()) do
                if typeData.canHear and typeData.canHear(speaker, ply) then
                    table.insert(recipients, ply)
                end
            end
        elseif chatType == "admin" then
            -- Admin: admins only
            for _, ply in ipairs(player.GetAll()) do
                if ply:IsAdmin() then
                    table.insert(recipients, ply)
                end
            end
        else
            -- Global
            recipients = player.GetAll()
        end
    else
        -- Range-based
        local range = typeData.range
        local speakerPos = speaker:GetPos()
        
        for _, ply in ipairs(player.GetAll()) do
            -- Dead players can't hear (unless deadCanSee)
            if not ply:Alive() and not typeData.deadCanSee then
                continue
            end
            
            -- Custom hearing check
            if typeData.canHear and not typeData.canHear(speaker, ply) then
                continue
            end
            
            -- Range check
            if ply:GetPos():DistToSqr(speakerPos) <= range * range then
                table.insert(recipients, ply)
            end
        end
    end
    
    return recipients
end

-- ==========================================
-- Chat Command Processing
-- ==========================================

-- Override default chat to handle RP commands
hook.Add("PlayerSay", "Nebula:ChatHandler", function(ply, text, teamChat)
    if not IsValid(ply) then return end
    
    -- Don't process if not in character
    if not Nebula.character:HasCharacter(ply) then
        -- Allow OOC for non-character players
        if string.sub(text, 1, 2) == "//" or string.sub(text, 1, 4) == "((  " then
            Nebula.chat:Send(ply, "ooc", string.sub(text, 3))
            return ""
        end
        return
    end
    
    local lowerText = string.lower(text)
    
    -- OOC chat (// or (( ))
    if string.sub(text, 1, 2) == "//" then
        Nebula.chat:Send(ply, "ooc", string.Trim(string.sub(text, 3)))
        return ""
    end
    
    if string.sub(text, 1, 3) == "(("  then
        local msg = string.Trim(string.sub(text, 4))
        if string.sub(msg, -2) == "))" then
            msg = string.Trim(string.sub(msg, 1, -3))
        end
        Nebula.chat:Send(ply, "looc", msg)
        return ""
    end
    
    -- Me action (/me or *)
    if string.sub(lowerText, 1, 4) == "/me " then
        Nebula.chat:Send(ply, "me", string.Trim(string.sub(text, 5)))
        return ""
    end
    
    if string.sub(text, 1, 1) == "*" and string.sub(text, 2, 2) == " " then
        Nebula.chat:Send(ply, "me", string.Trim(string.sub(text, 3)))
        return ""
    end
    
    -- Yell (/y or !)
    if string.sub(lowerText, 1, 3) == "/y " or string.sub(lowerText, 1, 3) == "/yell " then
        local msg = string.match(text, "/y[ell]* (.+)")
        if msg then
            Nebula.chat:Send(ply, "yell", msg)
        end
        return ""
    end
    
    if string.sub(text, 1, 1) == "!" and #text > 1 then
        Nebula.chat:Send(ply, "yell", string.sub(text, 2))
        return ""
    end
    
    -- Whisper (/w)
    if string.sub(lowerText, 1, 3) == "/w " or string.sub(lowerText, 1, 8) == "/whisper " then
        local msg = string.match(text, "/w[hisper]* (.+)")
        if msg then
            Nebula.chat:Send(ply, "whisper", msg)
        end
        return ""
    end
    
    -- Radio (/r)
    if string.sub(lowerText, 1, 3) == "/r " or string.sub(lowerText, 1, 6) == "/radio " then
        local msg = string.match(text, "/r[adio]* (.+)")
        if msg then
            -- Check if player can use radio
            local factionData = Nebula.faction:Get(Nebula.faction:GetPlayerFaction(ply))
            if factionData and factionData.canUseRadio then
                Nebula.chat:Send(ply, "radio", msg)
            else
                Nebula.util:Notify(ply, 1, "Your faction doesn't have radio access!")
            end
        end
        return ""
    end
    
    -- Admin chat (/a)
    if string.sub(lowerText, 1, 3) == "/a " then
        if ply:IsAdmin() then
            Nebula.chat:Send(ply, "admin", string.Trim(string.sub(text, 4)))
        end
        return ""
    end
    
    -- Default: IC chat
    Nebula.chat:Send(ply, "ic", text)
    return ""
end)

-- Event message (server-wide)
function Nebula.chat:SendEvent(text)
    self:Send(nil, "event", text)
end

Nebula.util:Log("Chat", "Server chat system initialized.")
