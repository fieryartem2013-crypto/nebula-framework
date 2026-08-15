--[[
    Nebula Framework - Faction System (Shared)
    Star Wars faction management
]]

Nebula.faction = Nebula.faction or {}
Nebula.faction.stored = Nebula.faction.stored or {}

-- Register a new faction
function Nebula.faction:Register(id, data)
    self.stored[id] = {
        id = id,
        name = data.name or "Unknown",
        description = data.description or "",
        color = data.color or Color(255, 255, 255),
        model = data.model or "models/player/group01/male_01.mdl",
        models = data.models or {}, -- Multiple model options
        weapons = data.weapons or {},
        items = data.items or {}, -- Starting items
        health = data.health or 100,
        armor = data.armor or 0,
        salary = data.salary or 0,
        maxPlayers = data.maxPlayers or 0, -- 0 = unlimited
        whitelist = data.whitelist or false, -- Requires whitelist
        adminOnly = data.adminOnly or false,
        spawn = data.spawn or nil, -- Custom spawn point
        classes = data.classes or {}, -- Sub-classes
        data = data.data or {},
        
        -- Permissions
        canUseRadio = data.canUseRadio or false,
        canUseTerminal = data.canUseTerminal or false,
        canArrest = data.canArrest or false,
        canHeal = data.canHeal or false,
        canHack = data.canHack or false,
    }
    
    return self.stored[id]
end

-- Get faction data
function Nebula.faction:Get(id)
    return self.stored[id]
end

-- Get faction name
function Nebula.faction:GetName(id)
    local faction = self:Get(id)
    return faction and faction.name or "Unknown"
end

-- Get faction color
function Nebula.faction:GetColor(id)
    local faction = self:Get(id)
    return faction and faction.color or Color(255, 255, 255)
end

-- Get all factions
function Nebula.faction:GetAll()
    return self.stored
end

-- Get player's faction
function Nebula.faction:GetPlayerFaction(ply)
    local charData = Nebula.character:GetData(ply)
    if charData then
        return charData.faction
    end
    return "citizen"
end

-- Check if player is in faction
function Nebula.faction:IsInFaction(ply, factionID)
    return self:GetPlayerFaction(ply) == factionID
end

-- Get faction player count
function Nebula.faction:GetPlayerCount(factionID)
    local count = 0
    for _, ply in ipairs(player.GetAll()) do
        if self:IsInFaction(ply, factionID) then
            count = count + 1
        end
    end
    return count
end

-- Check if faction is full
function Nebula.faction:IsFull(factionID)
    local faction = self:Get(factionID)
    if not faction then return true end
    if faction.maxPlayers <= 0 then return false end
    return self:GetPlayerCount(factionID) >= faction.maxPlayers
end

-- Get available classes for faction
function Nebula.faction:GetClasses(factionID)
    local faction = self:Get(factionID)
    return faction and faction.classes or {}
end

-- ==========================================
-- Star Wars Factions
-- ==========================================

-- Galactic Empire
Nebula.faction:Register("empire", {
    name = "Galactic Empire",
    description = "The Galactic Empire rules the galaxy with an iron fist. Led by Emperor Palpatine, the Empire maintains order through military might and fear.",
    color = Color(200, 50, 50),
    model = "models/player/combine_soldier.mdl",
    models = {
        "models/player/combine_soldier.mdl",
        "models/player/combine_super_soldier.mdl",
        "models/player/combine_soldier_prisonguard.mdl",
    },
    weapons = {"weapon_pistol", "weapon_smg1"},
    items = {"empire_id", "bacta_pack"},
    health = 100,
    armor = 50,
    salary = 150,
    maxPlayers = 0,
    whitelist = false,
    canUseRadio = true,
    canUseTerminal = true,
    canArrest = true,
    classes = {
        {id = "stormtrooper", name = "Stormtrooper", salary = 100},
        {id = "officer", name = "Imperial Officer", salary = 200},
        {id = "pilot", name = "TIE Pilot", salary = 150},
        {id = "navy", name = "Imperial Navy", salary = 180},
    },
})

-- Rebel Alliance
Nebula.faction:Register("rebel", {
    name = "Rebel Alliance",
    description = "The Alliance to Restore the Republic fights against the tyranny of the Galactic Empire. Freedom fighters and patriots united in their cause.",
    color = Color(50, 150, 255),
    model = "models/player/group03/male_01.mdl",
    models = {
        "models/player/group03/male_01.mdl",
        "models/player/group03/male_02.mdl",
        "models/player/group03/female_01.mdl",
    },
    weapons = {"weapon_pistol", "weapon_smg1"},
    items = {"rebel_id", "bacta_pack"},
    health = 100,
    armor = 30,
    salary = 120,
    maxPlayers = 0,
    whitelist = false,
    canUseRadio = true,
    canHeal = true,
    classes = {
        {id = "trooper", name = "Rebel Trooper", salary = 80},
        {id = "pilot", name = "Starfighter Pilot", salary = 150},
        {id = "medic", name = "Combat Medic", salary = 130},
        {id = "commander", name = "Rebel Commander", salary = 200},
    },
})

-- Citizens
Nebula.faction:Register("citizen", {
    name = "Citizen",
    description = "Ordinary citizens of the galaxy. They may be merchants, farmers, or simply trying to survive under Imperial rule.",
    color = Color(150, 150, 150),
    model = "models/player/group01/male_01.mdl",
    models = {
        "models/player/group01/male_01.mdl",
        "models/player/group01/male_02.mdl",
        "models/player/group01/male_03.mdl",
        "models/player/group01/female_01.mdl",
        "models/player/group01/female_02.mdl",
    },
    weapons = {},
    items = {"citizen_id"},
    health = 100,
    armor = 0,
    salary = 50,
    maxPlayers = 0,
    whitelist = false,
    classes = {
        {id = "merchant", name = "Merchant", salary = 100},
        {id = "medic", name = "Civilian Medic", salary = 80},
        {id = "mechanic", name = "Mechanic", salary = 90},
    },
})

-- Bounty Hunters
Nebula.faction:Register("bounty_hunter", {
    name = "Bounty Hunters' Guild",
    description = "Freelance hunters who track targets for profit. Loyal only to credits, they work for whoever pays the most.",
    color = Color(255, 150, 50),
    model = "models/player/leet.mdl",
    models = {
        "models/player/leet.mdl",
        "models/player/guerilla.mdl",
    },
    weapons = {"weapon_pistol", "weapon_357"},
    items = {"hunter_id", "bacta_pack"},
    health = 120,
    armor = 40,
    salary = 0,
    maxPlayers = 10,
    whitelist = true,
    canHack = true,
    classes = {
        {id = "hunter", name = "Bounty Hunter", salary = 0},
        {id = "assassin", name = "Assassin", salary = 0},
    },
})

-- Smugglers
Nebula.faction:Register("smuggler", {
    name = "Smugglers' Guild",
    description = "Underground traders who move contraband across the galaxy. They operate in the shadows of galactic law.",
    color = Color(100, 200, 100),
    model = "models/player/group02/male_02.mdl",
    models = {
        "models/player/group02/male_02.mdl",
        "models/player/group02/male_04.mdl",
    },
    weapons = {"weapon_pistol"},
    items = {"smuggler_id", "contraband_crate"},
    health = 100,
    armor = 20,
    salary = 0,
    maxPlayers = 8,
    whitelist = true,
    canHack = true,
    classes = {
        {id = "smuggler", name = "Smuggler", salary = 0},
        {id = "dealer", name = "Black Market Dealer", salary = 0},
    },
})

-- Mandalorians
Nebula.faction:Register("mandalorian", {
    name = "Mandalorian Clan",
    description = "Warriors bound by the Creed. The Mandalorians are legendary fighters with a rich cultural heritage spanning millennia.",
    color = Color(180, 180, 200),
    model = "models/player/phoenix.mdl",
    models = {
        "models/player/phoenix.mdl",
    },
    weapons = {"weapon_pistol", "weapon_shotgun"},
    items = {"mandalorian_id", "bacta_pack"},
    health = 150,
    armor = 75,
    salary = 50,
    maxPlayers = 5,
    whitelist = true,
    adminOnly = false,
    classes = {
        {id = "warrior", name = "Warrior", salary = 50},
        {id = "alor", name = "Clan Leader", salary = 100},
    },
})

Nebula.util:Log("Factions", "Faction system initialized with " .. table.Count(Nebula.faction.stored) .. " factions.")
