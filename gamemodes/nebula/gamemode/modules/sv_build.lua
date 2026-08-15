--[[
    Nebula Framework — Build System (Server)
    Строительство, разрушение, управление
]]

Nebula.build = Nebula.build or {}

util.AddNetworkString("Nebula:BuildPlace")
util.AddNetworkString("Nebula:BuildRemove")
util.AddNetworkString("Nebula:BuildSync")

-- Построить объект
function Nebula.build:Place(ply, blueprintID, pos, angle)
    local bp = self:Get(blueprintID)
    if not bp then return false end
    
    local can, reason = self:CanBuild(ply, blueprintID)
    if not can then
        Nebula.util:Notify(ply, 1, reason)
        return false
    end
    
    -- Убираем деньги
    if bp.cost > 0 then
        Nebula.economy:TakeMoney(ply, bp.cost, "Строительство: " .. bp.name)
    end
    
    -- Убираем предметы
    for _, req in ipairs(bp.items) do
        Nebula.inventory:RemoveItemByClass(ply, req.item, req.amount or 1)
    end
    
    -- Создаём энтити
    local ent = ents.Create("nebula_buildable")
    if not IsValid(ent) then return false end
    
    ent:SetPos(pos)
    ent:SetAngles(angle or Angle(0, 0, 0))
    ent:SetModel(bp.model)
    ent:Spawn()
    
    ent:SetNWString("nebula_buildType", blueprintID)
    ent:SetNWString("nebula_buildOwner", ply:SteamID())
    ent:SetNWString("nebula_buildOwnerName", Nebula.character:GetName(ply))
    ent:SetNWFloat("nebula_buildHealth", bp.health)
    ent:SetNWFloat("nebula_buildMaxHealth", bp.health)
    
    -- Физика
    if not bp.solid then
        ent:SetSolid(SOLID_NONE)
    end
    
    if not bp.movable then
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
    
    Nebula.util:Notify(ply, 0, "Построено: " .. bp.name)
    
    -- Авто-удаление через 30 минут (настраивается)
    timer.Simple(1800, function()
        if IsValid(ent) then
            ent:Remove()
        end
    end)
    
    return ent
end

-- Удалить постройку
function Nebula.build:Remove(ply, ent)
    if not IsValid(ent) then return false end
    
    local owner = ent:GetNWString("nebula_buildOwner", "")
    local bpID = ent:GetNWString("nebula_buildType", "")
    
    -- Только владелец или админ
    if owner ~= ply:SteamID() and not ply:IsAdmin() then
        Nebula.util:Notify(ply, 1, "Это не твоя постройка!")
        return false
    end
    
    local bp = self:Get(bpID)
    
    -- Возвращаем часть ресурсов (50%)
    if bp then
        for _, req in ipairs(bp.items) do
            if math.random(100) <= 50 then
                Nebula.inventory:AddItem(ply, req.item, {}, math.ceil((req.amount or 1) * 0.5))
            end
        end
    end
    
    ent:Remove()
    Nebula.util:Notify(ply, 0, "Постройка удалена.")
    
    return true
end

-- Нетворк
net.Receive("Nebula:BuildPlace", function(len, ply)
    local bpID = net.ReadString()
    local pos = net.ReadVector()
    local angle = net.ReadAngle()
    Nebula.build:Place(ply, bpID, pos, angle)
end)

net.Receive("Nebula:BuildRemove", function(len, ply)
    local entIndex = net.ReadUInt(16)
    local ent = Entity(entIndex)
    if IsValid(ent) then
        Nebula.build:Remove(ply, ent)
    end
end)

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Серверная Build система загружена.\n")
