--[[
    Nebula Framework
    Star Wars RP Framework for Garry's Mod
    Inspired by Helix & Clockwork
    
    Main shared entry point
]]

Nebula = Nebula or {}
Nebula.version = "1.0.0"
Nebula.author = "Nebula Team"
Nebula.desc = "Star Wars Roleplay Framework"

-- Core tables
Nebula.util = Nebula.util or {}
Nebula.config = Nebula.config or {}
Nebula.hooks = Nebula.hooks or {}
Nebula.modules = Nebula.modules or {}
Nebula.schema = Nebula.schema or {}
Nebula.database = Nebula.database or {}
Nebula.inventory = Nebula.inventory or {}
Nebula.faction = Nebula.faction or {}
Nebula.economy = Nebula.economy or {}
Nebula.chat = Nebula.chat or {}
Nebula.animation = Nebula.animation or {}

-- Character system (inspired by Helix)
Nebula.character = Nebula.character or {}

-- Print initialization
MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Framework v" .. Nebula.version .. " loading...\n")

-- Load utility library first
Nebula.util.Include = function(path, realm)
    realm = realm or "shared"
    
    if realm == "shared" or realm == "sh" then
        if SERVER then AddCSLuaFile(path) end
        include(path)
    elseif realm == "server" or realm == "sv" then
        if SERVER then include(path) end
    elseif realm == "client" or realm == "cl" then
        if SERVER then AddCSLuaFile(path) end
        if CLIENT then include(path) end
    end
end

-- Load core files
Nebula.util.Include("nebula/core/sh_safety.lua", "shared")
Nebula.util.Include("nebula/core/sh_convars.lua", "shared")
Nebula.util.Include("nebula/core/sh_permissions.lua", "shared")
Nebula.util.Include("nebula/core/sh_spawn.lua", "shared")
Nebula.util.Include("nebula/core/sh_util.lua", "shared")
Nebula.util.Include("nebula/core/sh_config.lua", "shared")
Nebula.util.Include("nebula/core/sh_database.lua", "shared")
Nebula.util.Include("nebula/core/sv_database.lua", "server")
Nebula.util.Include("nebula/core/sv_netstrings.lua", "server")
Nebula.util.Include("nebula/core/sv_admin.lua", "server")

-- Load hook system
Nebula.util.Include("nebula/core/sh_hooks.lua", "shared")

-- Load modules
Nebula.util.Include("nebula/modules/sh_inventory.lua", "shared")
Nebula.util.Include("nebula/modules/sv_inventory.lua", "server")
Nebula.util.Include("nebula/modules/cl_inventory.lua", "client")
Nebula.util.Include("nebula/modules/sh_factions.lua", "shared")
Nebula.util.Include("nebula/modules/sh_economy.lua", "shared")
Nebula.util.Include("nebula/modules/sv_economy.lua", "server")
Nebula.util.Include("nebula/modules/sh_chat.lua", "shared")
Nebula.util.Include("nebula/modules/sv_chat.lua", "server")
Nebula.util.Include("nebula/modules/cl_chat.lua", "client")
Nebula.util.Include("nebula/modules/sh_animation.lua", "shared")

-- Load character system
Nebula.util.Include("nebula/core/sh_character.lua", "shared")
Nebula.util.Include("nebula/core/sv_character.lua", "server")
Nebula.util.Include("nebula/core/cl_character.lua", "client")

-- Load schema
Nebula.util.Include("nebula/schema/sh_schema.lua", "shared")

-- Load Derma (UI)
Nebula.util.Include("nebula/derma/cl_fonts.lua", "client")
Nebula.util.Include("nebula/derma/cl_theme.lua", "client")
Nebula.util.Include("nebula/derma/cl_inventory.lua", "client")
Nebula.util.Include("nebula/derma/cl_character.lua", "client")
Nebula.util.Include("nebula/derma/cl_hud.lua", "client")
Nebula.util.Include("nebula/derma/cl_admin.lua", "client")

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Framework loaded successfully!\n")

-- Gamemode info
GM.Name = "Nebula RP"
GM.Author = "Nebula Team"
GM.Website = ""
GM.Email = ""

-- Default team setup
function GM:CreateTeams()
    -- Teams are managed through faction system
end

-- Player spawn setup
function GM:PlayerSpawn(ply)
    -- Let faction system handle loadout
    player_manager.SetPlayerClass(ply, "player_nebula")
    
    -- Default spawn behavior
    self.BaseClass:PlayerSpawn(ply)
end

function GM:PlayerLoadout(ply)
    -- Weapons are given via faction system
    return true
end

function GM:PlayerInitialSpawn(ply)
    self.BaseClass:PlayerInitialSpawn(ply)
    
    -- Initialize player data
    timer.Simple(1, function()
        if IsValid(ply) then
            Nebula.database:InitPlayer(ply)
            Nebula.character:OpenMenu(ply)
        end
    end)
end

function GM:PlayerDisconnected(ply)
    -- Save player data on disconnect
    Nebula.database:SavePlayer(ply)
end

function GM:ShutDown()
    -- Save all players on server shutdown
    for _, ply in ipairs(player.GetAll()) do
        Nebula.database:SavePlayer(ply)
    end
end
