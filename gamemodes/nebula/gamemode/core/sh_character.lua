--[[
    Nebula Framework - Character System (Shared)
    Inspired by Helix's character system
]]

Nebula.character = Nebula.character or {}
Nebula.character.stored = Nebula.character.stored or {}

-- Character data template
Nebula.character.template = {
    name = "",
    description = "",
    model = "models/player/group01/male_01.mdl",
    faction = "citizen",
    class = "",
    data = {},
}

-- Get character data for player
function Nebula.character:GetData(ply)
    if not IsValid(ply) then return nil end
    
    local charID = ply:GetNWInt("nebula_charID", 0)
    if charID <= 0 then return nil end
    
    return self.stored[charID] or nil
end

-- Set character data
function Nebula.character:SetData(charID, key, value)
    if not self.stored[charID] then return end
    self.stored[charID][key] = value
end

-- Get character ID for player
function Nebula.character:GetID(ply)
    if not IsValid(ply) then return 0 end
    return ply:GetNWInt("nebula_charID", 0)
end

-- Check if player has active character
function Nebula.character:HasCharacter(ply)
    return self:GetID(ply) > 0
end

-- Get character name
function Nebula.character:GetName(ply)
    local data = self:GetData(ply)
    return data and data.name or ply:Name()
end

-- Get character description
function Nebula.character:GetDescription(ply)
    local data = self:GetData(ply)
    return data and data.description or ""
end

-- Get character model
function Nebula.character:GetModel(ply)
    local data = self:GetData(ply)
    return data and data.model or "models/player/group01/male_01.mdl"
end

-- Get character faction
function Nebula.character:GetFaction(ply)
    local data = self:GetData(ply)
    return data and data.faction or "citizen"
end

-- Get character class
function Nebula.character:GetClass(ply)
    local data = self:GetData(ply)
    return data and data.class or ""
end

-- Validate character name
function Nebula.character:ValidateName(name)
    if not name or name == "" then
        return false, "Name cannot be empty"
    end
    
    local minLen = Nebula.config:Get("rpname_min_length", 3)
    local maxLen = Nebula.config:Get("rpname_max_length", 32)
    
    if string.len(name) < minLen then
        return false, "Name must be at least " .. minLen .. " characters"
    end
    
    if string.len(name) > maxLen then
        return false, "Name must be at most " .. maxLen .. " characters"
    end
    
    -- Check for invalid characters
    if string.match(name, "[^%a%s%-%.']") then
        return false, "Name contains invalid characters"
    end
    
    -- Check for excessive spaces
    if string.match(name, "%s%s+") then
        return false, "Name contains excessive spaces"
    end
    
    -- Must contain at least one space (first and last name)
    if not string.find(name, "%s") then
        return false, "Must include first and last name"
    end
    
    return true, "Valid"
end

-- Validate character model
function Nebula.character:ValidateModel(model)
    if not model or model == "" then
        return false, "Model cannot be empty"
    end
    
    -- Check if model file exists
    if not util.IsValidModel(model) then
        return false, "Invalid model"
    end
    
    return true, "Valid"
end

-- Character print functions
function Nebula.character:PrintToChat(ply, text, ...)
    if not IsValid(ply) then return end
    
    local charName = self:GetName(ply)
    local fullText = charName .. ": " .. string.format(text, ...)
    
    -- This is handled by the chat module
    return fullText
end
