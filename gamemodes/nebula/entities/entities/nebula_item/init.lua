--[[
    Nebula Framework - World Item Entity (Server)
    Physical items that can be picked up from the ground
]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/garbage_metalcan001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolidity(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    
    -- Default item data
    self:SetNWString("nebula_itemClass", "")
    self:SetNWString("nebula_itemName", "Unknown Item")
    self:SetNWInt("nebula_itemQuantity", 1)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    local itemClass = self:GetNWString("nebula_itemClass", "")
    local quantity = self:GetNWInt("nebula_itemQuantity", 1)
    
    if itemClass == "" then return end
    
    -- Try to add item to player's inventory
    local success = Nebula.inventory:AddItem(activator, itemClass, self.itemData and self.itemData.data or {}, quantity)
    
    if success then
        -- Notify player
        local itemName = self:GetNWString("nebula_itemName", "Unknown")
        Nebula.util:Notify(activator, 0, "Picked up " .. quantity .. "x " .. itemName)
        
        -- Remove the entity
        self:Remove()
    else
        Nebula.util:Notify(activator, 1, "Can't pick up this item!")
    end
end

function ENT:OnTakeDamage(dmginfo)
    -- Items can be destroyed by damage
    self:TakePhysicsDamage(dmginfo)
end

function ENT:Think()
    -- Idle animation/rotation
    local phys = self:GetPhysicsObject()
    if IsValid(phys) and phys:IsAsleep() then
        -- Gentle hover effect
        local pos = self:GetPos()
        pos.z = pos.z + math.sin(CurTime() * 2) * 0.1
        self:SetPos(pos)
    end
end
