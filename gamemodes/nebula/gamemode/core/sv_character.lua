--[[
    Nebula Framework - Character System (Server)
    Server-side character management
]]

Nebula.character = Nebula.character or {}

-- Network strings
util.AddNetworkString("Nebula:CharacterSync")
util.AddNetworkString("Nebula:CharacterCreate")
util.AddNetworkString("Nebula:CharacterSelect")
util.AddNetworkString("Nebula:CharacterDelete")
util.AddNetworkString("Nebula:CharacterMenu")

-- Load a character for a player
function Nebula.character:Load(ply, charID)
    if not IsValid(ply) then return false end
    
    local charData = Nebula.database:GetCharacter(charID)
    if not charData then
        Nebula.util:Notify(ply, 1, "Character not found!")
        return false
    end
    
    -- Verify ownership
    if charData.steamid ~= ply:SteamID() then
        Nebula.util:Notify(ply, 1, "This character doesn't belong to you!")
        return false
    end
    
    -- Store character data
    self.stored[charID] = {
        name = charData.name,
        description = charData.description,
        model = charData.model,
        faction = charData.faction,
        class = charData.class or "",
        data = charData.data or {},
        steamid = ply:SteamID(),
    }
    
    -- Set player properties
    ply:SetNWInt("nebula_charID", charID)
    ply:SetNWString("nebula_charName", charData.name)
    ply:SetNWString("nebula_charFaction", charData.faction)
    ply:SetNWInt("nebula_money", charData.money or 0)
    ply:SetNWInt("nebula_salary", charData.salary or 0)
    
    -- Set model
    ply:SetModel(charData.model)
    
    -- Load inventory
    Nebula.inventory:LoadFromDB(ply, charID)
    
    -- Apply faction loadout
    local factionData = Nebula.faction:Get(charData.faction)
    if factionData then
        if factionData.model and factionData.model ~= "" then
            ply:SetModel(factionData.model)
        end
        if factionData.weapons then
            for _, weapon in ipairs(factionData.weapons) do
                ply:Give(weapon)
            end
        end
        if factionData.health then
            ply:SetHealth(factionData.health)
        end
        if factionData.armor then
            ply:SetArmor(factionData.armor)
        end
    end
    
    -- Sync to client
    self:SyncToClient(ply)
    
    -- Fire hook
    Nebula.hooks:OnCharacterLoaded(ply, charID)
    
    -- Log
    Nebula.database:Log(ply:SteamID(), "character_loaded", charData.name)
    Nebula.util:Log("Character", "Loaded character '" .. charData.name .. "' for " .. ply:Name())
    
    return true
end

-- Unload character (switch or disconnect)
function Nebula.character:Unload(ply)
    if not IsValid(ply) then return end
    
    local charID = self:GetID(ply)
    if charID <= 0 then return end
    
    -- Save before unloading
    Nebula.database:SaveCharacter(charID, ply)
    
    -- Clear stored data
    self.stored[charID] = nil
    
    -- Clear player NWVars
    ply:SetNWInt("nebula_charID", 0)
    ply:SetNWString("nebula_charName", "")
    ply:SetNWString("nebula_charFaction", "")
    
    -- Strip weapons
    ply:StripWeapons()
    
    -- Clear inventory
    Nebula.inventory:Clear(ply)
end

-- Create a new character
function Nebula.character:Create(ply, charData)
    if not IsValid(ply) then return false end
    
    -- Validate name
    local valid, err = self:ValidateName(charData.name)
    if not valid then
        Nebula.util:Notify(ply, 1, "Invalid name: " .. err)
        return false
    end
    
    -- Check character limit
    local maxChars = Nebula.config:Get("max_characters", 3)
    local currentChars = Nebula.database:GetCharacterCount(ply:SteamID())
    
    if currentChars >= maxChars then
        Nebula.util:Notify(ply, 1, "You've reached the maximum number of characters (" .. maxChars .. ")")
        return false
    end
    
    -- Validate faction
    if not Nebula.faction:Get(charData.faction) then
        Nebula.util:Notify(ply, 1, "Invalid faction!")
        return false
    end
    
    -- Validate model
    local validModel, modelErr = self:ValidateModel(charData.model)
    if not validModel then
        -- Use faction default model
        local factionData = Nebula.faction:Get(charData.faction)
        charData.model = factionData and factionData.model or "models/player/group01/male_01.mdl"
    end
    
    -- Set defaults
    charData.money = charData.money or Nebula.config:Get("starting_credits", 500)
    charData.data = charData.data or {}
    
    -- Create in database
    local charID = Nebula.database:CreateCharacter(ply:SteamID(), charData)
    if not charID then
        Nebula.util:Notify(ply, 1, "Failed to create character!")
        return false
    end
    
    -- Fire hook
    Nebula.hooks:OnCharacterCreated(ply, charID, charData)
    
    -- Notify
    Nebula.util:Notify(ply, 0, "Character '" .. charData.name .. "' created!")
    
    -- Auto-load the new character
    self:Load(ply, charID)
    
    return true
end

-- Delete a character
function Nebula.character:Delete(ply, charID)
    if not IsValid(ply) then return false end
    
    -- Verify ownership
    local charData = Nebula.database:GetCharacter(charID)
    if not charData then
        Nebula.util:Notify(ply, 1, "Character not found!")
        return false
    end
    
    if charData.steamid ~= ply:SteamID() then
        Nebula.util:Notify(ply, 1, "This character doesn't belong to you!")
        return false
    end
    
    -- Unload if currently active
    if self:GetID(ply) == charID then
        self:Unload(ply)
    end
    
    -- Delete from database
    Nebula.database:DeleteCharacter(charID)
    
    -- Fire hook
    Nebula.hooks:OnCharacterDeleted(ply, charID)
    
    -- Notify
    Nebula.util:Notify(ply, 0, "Character '" .. charData.name .. "' deleted.")
    
    -- Open character menu
    self:OpenMenu(ply)
    
    return true
end

-- Sync character data to client
function Nebula.character:SyncToClient(ply)
    if not IsValid(ply) then return end
    
    local charID = self:GetID(ply)
    if charID <= 0 then return end
    
    local charData = self.stored[charID]
    if not charData then return end
    
    net.Start("Nebula:CharacterSync")
        net.WriteUInt(charID, 16)
        net.WriteString(charData.name or "")
        net.WriteString(charData.description or "")
        net.WriteString(charData.model or "")
        net.WriteString(charData.faction or "")
        net.WriteString(charData.class or "")
        net.WriteTable(charData.data or {})
    net.Send(ply)
end

-- Open character menu for player
function Nebula.character:OpenMenu(ply)
    if not IsValid(ply) then return end
    
    -- Send character list
    local chars = Nebula.database:GetCharacters(ply:SteamID())
    
    net.Start("Nebula:CharacterMenu")
        net.WriteTable(chars)
    net.Send(ply)
end

-- ==========================================
-- Network Receivers
-- ==========================================

-- Character creation request
net.Receive("Nebula:CharacterCreate", function(len, ply)
    local name = net.ReadString()
    local description = net.ReadString()
    local model = net.ReadString()
    local faction = net.ReadString()
    
    local charData = {
        name = name,
        description = description,
        model = model,
        faction = faction,
    }
    
    Nebula.character:Create(ply, charData)
end)

-- Character selection request
net.Receive("Nebula:CharacterSelect", function(len, ply)
    local charID = net.ReadUInt(16)
    
    -- Unload current character if any
    if Nebula.character:HasCharacter(ply) then
        Nebula.character:Unload(ply)
    end
    
    -- Load selected character
    Nebula.character:Load(ply, charID)
end)

-- Character deletion request
net.Receive("Nebula:CharacterDelete", function(len, ply)
    local charID = net.ReadUInt(16)
    
    -- Confirmation is handled client-side
    Nebula.character:Delete(ply, charID)
end)

-- Admin commands
concommand.Add("nebula_char_reload", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local target = ply
    if args[1] then
        target = Nebula.util:FindPlayer(args[1])
    end
    
    if IsValid(target) then
        local charID = Nebula.character:GetID(target)
        if charID > 0 then
            Nebula.character:Unload(target)
            Nebula.character:Load(target, charID)
            Nebula.util:Notify(ply, 0, "Character reloaded for " .. target:Name())
        end
    end
end)

concommand.Add("nebula_char_saveall", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    Nebula.database:SaveAllPlayers()
    Nebula.util:Notify(ply, 0, "All characters saved!")
end)
