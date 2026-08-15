--[[
    Nebula Framework - Schema (Star Wars RP)
    This is where you customize your server's content.
    Add items, modify factions, create NPCs, etc.
]]

-- ==========================================
-- Custom Items
-- ==========================================

-- Bacta Pack (Healing item)
Nebula.inventory:RegisterItem("bacta_pack", {
    name = "Bacta Pack",
    description = "A portable bacta healing kit. Restores 25 health when used.",
    model = "models/healthvial.mdl",
    category = "Medical",
    weight = 0.5,
    stackable = true,
    maxStack = 5,
    usable = true,
    droppable = true,
    useText = "Apply Bacta",
    onUse = function(ply, item)
        if ply:Health() >= ply:GetMaxHealth() then
            Nebula.util:Notify(ply, 1, "You're already at full health!")
            return false -- Don't consume
        end
        
        ply:SetHealth(math.min(ply:Health() + 25, ply:GetMaxHealth()))
        Nebula.util:Notify(ply, 0, "Applied bacta pack. Health restored.")
        return true -- Consume item
    end,
})

-- Empire ID Card
Nebula.inventory:RegisterItem("empire_id", {
    name = "Imperial ID Card",
    description = "Official identification for Galactic Empire personnel.",
    model = "models/props_lab/clipboard.mdl",
    category = "Documents",
    weight = 0.1,
    unique = true,
    droppable = true,
    usable = false,
})

-- Rebel ID Card
Nebula.inventory:RegisterItem("rebel_id", {
    name = "Rebel Alliance ID",
    description = "Identification for Rebel Alliance members. Keep it hidden from Imperials.",
    model = "models/props_lab/clipboard.mdl",
    category = "Documents",
    weight = 0.1,
    unique = true,
    droppable = true,
    usable = false,
})

-- Citizen ID Card
Nebula.inventory:RegisterItem("citizen_id", {
    name = "Citizen ID Card",
    description = "Standard galactic citizen identification.",
    model = "models/props_lab/clipboard.mdl",
    category = "Documents",
    weight = 0.1,
    unique = true,
    droppable = true,
    usable = false,
})

-- Bounty Hunter License
Nebula.inventory:RegisterItem("hunter_id", {
    name = "Bounty Hunter License",
    description = "Official license to hunt bounties across the galaxy.",
    model = "models/props_lab/clipboard.mdl",
    category = "Documents",
    weight = 0.1,
    unique = true,
    droppable = true,
    usable = false,
})

-- Smuggler ID
Nebula.inventory:RegisterItem("smuggler_id", {
    name = "Smuggler's Mark",
    description = "A discreet mark recognized by the criminal underworld.",
    model = "models/props_lab/clipboard.mdl",
    category = "Documents",
    weight = 0.1,
    unique = true,
    droppable = true,
    usable = false,
})

-- Mandalorian ID
Nebula.inventory:RegisterItem("mandalorian_id", {
    name = "Mandalorian Signet",
    description = "A signet representing your clan and honor.",
    model = "models/props_lab/clipboard.mdl",
    category = "Documents",
    weight = 0.1,
    unique = true,
    droppable = true,
    usable = false,
})

-- Contraband Crate
Nebula.inventory:RegisterItem("contraband_crate", {
    name = "Contraband Crate",
    description = "A sealed crate containing unknown contraband. Could be valuable... or dangerous.",
    model = "models/props_junk/wood_crate001a.mdl",
    category = "Contraband",
    weight = 5.0,
    stackable = false,
    droppable = true,
    usable = true,
    useText = "Open Crate",
    onUse = function(ply, item)
        local lootTable = {
            {item = "bacta_pack", chance = 40, quantity = 2},
            {item = "spice_pack", chance = 30, quantity = 1},
            {item = "blaster_parts", chance = 20, quantity = 1},
            {item = "holocron_fragment", chance = 10, quantity = 1},
        }
        
        local roll = math.random(100)
        local cumulative = 0
        
        for _, loot in ipairs(lootTable) do
            cumulative = cumulative + loot.chance
            if roll <= cumulative then
                Nebula.inventory:AddItem(ply, loot.item, {}, loot.quantity)
                local itemDef = Nebula.inventory:GetItem(loot.item)
                Nebula.util:Notify(ply, 0, "Found " .. loot.quantity .. "x " .. (itemDef and itemDef.name or loot.item) .. "!")
                return true
            end
        end
        
        Nebula.util:Notify(ply, 0, "The crate was empty...")
        return true
    end,
})

-- Spice Pack
Nebula.inventory:RegisterItem("spice_pack", {
    name = "Spice Pack",
    description = "A small package of refined spice. Illegal in most systems.",
    model = "models/props_junk/garbage_bag001a.mdl",
    category = "Contraband",
    weight = 0.3,
    stackable = true,
    maxStack = 10,
    droppable = true,
    usable = true,
    useText = "Use Spice",
    onUse = function(ply, item)
        ply:SetHealth(math.min(ply:Health() + 10, ply:GetMaxHealth() + 50))
        ply:ViewPunch(Angle(math.random(-10, 10), math.random(-10, 10), 0))
        Nebula.util:Notify(ply, 0, "You feel a rush of energy...")
        return true
    end,
})

-- Blaster Parts
Nebula.inventory:RegisterItem("blaster_parts", {
    name = "Blaster Parts",
    description = "Assorted parts for blaster repair and modification.",
    model = "models/props_c17/tools_wrench01a.mdl",
    category = "Components",
    weight = 1.0,
    stackable = true,
    maxStack = 5,
    droppable = true,
    usable = false,
})

-- Holocron Fragment
Nebula.inventory:RegisterItem("holocron_fragment", {
    name = "Holocron Fragment",
    description = "A fragment of an ancient Jedi or Sith holocron. Radiates with the Force.",
    model = "models/props_lab/box01a.mdl",
    category = "Artifacts",
    weight = 0.5,
    unique = true,
    droppable = true,
    usable = true,
    useText = "Study Fragment",
    onUse = function(ply, item)
        Nebula.util:Notify(ply, 0, "You study the fragment and feel the Force flowing through you...")
        -- Could add Force powers or XP here
        return false -- Don't consume
    end,
})

-- Datapad
Nebula.inventory:RegisterItem("datapad", {
    name = "Datapad",
    description = "A standard galactic datapad for storing information.",
    model = "models/props_lab/box01a.mdl",
    category = "Electronics",
    weight = 0.3,
    stackable = false,
    droppable = true,
    usable = false,
})

-- Ration Pack
Nebula.inventory:RegisterItem("ration_pack", {
    name = "Ration Pack",
    description = "Standard military rations. Not tasty, but keeps you alive.",
    model = "models/props_junk/garbage_metalcan001a.mdl",
    category = "Food",
    weight = 0.5,
    stackable = true,
    maxStack = 10,
    droppable = true,
    usable = true,
    useText = "Eat Ration",
    onUse = function(ply, item)
        ply:SetHealth(math.min(ply:Health() + 10, ply:GetMaxHealth()))
        Nebula.util:Notify(ply, 0, "You eat the ration. Not bad.")
        return true
    end,
})

-- Comlink
Nebula.inventory:RegisterItem("comlink", {
    name = "Comlink",
    description = "A wrist-mounted comlink for long-range communication.",
    model = "models/props_lab/box01a.mdl",
    category = "Electronics",
    weight = 0.2,
    unique = true,
    droppable = true,
    usable = false,
})

-- ==========================================
-- Schema Configuration Overrides
-- ==========================================

-- Override default configs for this schema
Nebula.config:Set("server_name", "Nebula Star Wars RP")
Nebula.config:Set("server_description", "A galaxy far, far away...")
Nebula.config:Set("starting_credits", 500)
Nebula.config:Set("currency_name", "Credits")
Nebula.config:Set("currency_symbol", "CR")

-- ==========================================
-- Schema Hooks
-- ==========================================

-- Player spawn customization
hook.Add("Nebula:CharacterLoaded", "Schema:CharacterLoaded", function(ply, charID)
    -- Custom logic when character loads
    local charData = Nebula.character:GetData(ply)
    if not charData then return end
    
    -- Set player speed based on faction
    local factionData = Nebula.faction:Get(charData.faction)
    if factionData then
        ply:SetWalkSpeed(Nebula.config:Get("walk_speed", 180))
        ply:SetRunSpeed(Nebula.config:Get("run_speed", 280))
        ply:SetJumpPower(Nebula.config:Get("jump_power", 200))
    end
end)

-- Custom death handling
hook.Add("PlayerDeath", "Schema:PlayerDeath", function(ply, inflictor, attacker)
    -- Drop some credits on death
    local money = Nebula.economy:GetMoney(ply)
    local dropAmount = math.floor(money * 0.1) -- Drop 10%
    
    if dropAmount > 0 then
        Nebula.economy:TakeMoney(ply, dropAmount, "Death penalty")
    end
    
    -- Respawn timer
    local respawnTime = 10
    ply:SetNWInt("nebula_respawnTime", CurTime() + respawnTime)
end)

-- Prevent default GMod respawn
hook.Add("PlayerDeathThink", "Schema:DeathThink", function(ply)
    local respawnTime = ply:GetNWInt("nebula_respawnTime", 0)
    
    if CurTime() >= respawnTime then
        ply:Spawn()
        return true
    end
    
    return false
end)

MsgC(Color(100, 180, 255), "[Nebula:Schema] ", color_white, "Star Wars schema loaded.\n")
