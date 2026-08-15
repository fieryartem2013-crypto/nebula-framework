--[[
    Nebula Framework — Spawn Point System
    Система точек спавна по фракциям и зонам
]]

Nebula.spawn = Nebula.spawn or {}
Nebula.spawn.points = {}

-- Регистрация точки спавна
function Nebula.spawn:Register(id, data)
    self.points[id] = {
        id = id,
        name = data.name or "Spawn",
        pos = data.pos or Vector(0, 0, 0),
        angle = data.angle or Angle(0, 0, 0),
        faction = data.faction or nil, -- nil = все
        zone = data.zone or nil,
        priority = data.priority or 0,
    }
end

-- Получить точки для игрока
function Nebula.spawn:GetForPlayer(ply)
    if not IsValid(ply) then return nil end
    
    local faction = Nebula.faction:GetPlayerFaction(ply)
    local candidates = {}
    
    for id, point in pairs(self.points) do
        local valid = true
        
        -- Проверка фракции
        if point.faction and point.faction ~= faction then
            valid = false
        end
        
        if valid then
            table.insert(candidates, point)
        end
    end
    
    -- Сортировка по приоритету
    table.sort(candidates, function(a, b) return a.priority > b.priority end)
    
    -- Возвращаем лучшую точку (или рандомную из топ-3)
    if #candidates == 0 then return nil end
    
    local top = math.min(3, #candidates)
    return candidates[math.random(1, top)]
end

-- Получить позицию спавна
function Nebula.spawn:GetSpawnPos(ply)
    local point = self:GetForPlayer(ply)
    if point then
        return point.pos, point.angle
    end
    return nil, nil
end

Nebula.util:Log("Spawn", "Система спавн-поинтов загружена.")
