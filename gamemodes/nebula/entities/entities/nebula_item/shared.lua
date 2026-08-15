--[[
    Nebula Framework - World Item Entity (Shared)
]]

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Nebula Item"
ENT.Author = "Nebula Team"
ENT.Category = "Nebula"
ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "ItemClass")
    self:NetworkVar("String", 1, "ItemName")
    self:NetworkVar("Int", 0, "ItemQuantity")
    self:NetworkVar("Int", 1, "ItemID")
end
