--[[
    Nebula Framework - Player Class
    Custom player class for Nebula RP
]]

local CLASS = {}

CLASS.DisplayName = "Nebula Player"
CLASS.WalkSpeed = 180
CLASS.RunSpeed = 280
CLASS.CrouchedWalkSpeed = 0.3
CLASS.DuckSpeed = 0.3
CLASS.UnDuckSpeed = 0.3
CLASS.JumpPower = 200
CLASS.CanUseFlashlight = true
CLASS.MaxHealth = 100
CLASS.StartArmor = 0
CLASS.StartHealth = 100
CLASS.RespawnTime = 10
CLASS.DropWeaponOnDie = true
CLASS.TeammateNoCollide = false
CLASS.AvoidPlayers = true
CLASS.UseVMHands = true

function CLASS:Init(ply)
    -- Set default speeds
    ply:SetWalkSpeed(self.WalkSpeed)
    ply:SetRunSpeed(self.RunSpeed)
    ply:SetCrouchedWalkSpeed(self.CrouchedWalkSpeed)
    ply:SetDuckSpeed(self.DuckSpeed)
    ply:SetUnDuckSpeed(self.UnDuckSpeed)
    ply:SetJumpPower(self.JumpPower)
    ply:SetMaxHealth(self.MaxHealth)
    ply:SetHealth(self.StartHealth)
    ply:SetArmor(self.StartArmor)
    
    -- Flashlight
    ply:AllowFlashlight(self.CanUseFlashlight)
end

function CLASS:Loadout(ply)
    -- Default loadout (override via faction system)
    ply:Give("gmod_tool")
    ply:Give("gmod_camera")
    ply:Give("weapon_physgun")
    
    -- Don't give weapons if character has faction weapons
    local charData = Nebula.character:GetData(ply)
    if charData then
        local factionData = Nebula.faction:Get(charData.faction)
        if factionData and #factionData.weapons > 0 then
            -- Faction handles weapons
            return
        end
    end
    
    -- Default weapon
    ply:Give("weapon_physcannon")
end

function CLASS:SetModel(ply)
    -- Model is set by character system
    local charData = Nebula.character:GetData(ply)
    if charData and charData.model then
        ply:SetModel(charData.model)
        return
    end
    
    -- Default model
    ply:SetModel("models/player/group01/male_01.mdl")
end

player_manager.RegisterClass("player_nebula", CLASS, "player_default")
