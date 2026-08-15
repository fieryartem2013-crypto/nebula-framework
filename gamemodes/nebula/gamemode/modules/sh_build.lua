--[[
    Nebula Framework — Build System (Shared)
    Система построек: баррикады, укрепления, ловушки
]]

Nebula.build = Nebula.build or {}
Nebula.build.blueprints = Nebula.build.blueprints or {}

-- Регистрация чертежа
function Nebula.build:Register(id, data)
    self.blueprints[id] = {
        id = id,
        name = data.name or "Постройка",
        description = data.description or "",
        category = data.category or "Общие",
        model = data.model or "models/props_junk/wood_crate001a.mdl",
        
        -- Стоимость
        cost = data.cost or 0, -- Деньги
        items = data.items or {}, -- {{item = "id", amount = 1}}
        
        -- Характеристики
        health = data.health or 100, -- HP постройки
        buildTime = data.buildTime or 5,
        maxPerPlayer = data.maxPerPlayer or 5,
        
        -- Тип
        type = data.type or "barricade", -- barricade, trap, furniture, storage
        
        -- Физика
        solid = data.solid ~= false,
        movable = data.movable or false,
        
        -- Уникальные свойства
        canLock = data.canLock or false,
        canDamage = data.canDamage or true,
        damageOnTouch = data.damageOnTouch or 0,
        
        -- Контейнер
        isContainer = data.isContainer or false,
        containerSlots = data.containerSlots or 10,
    }
end

function Nebula.build:Get(id)
    return self.blueprints[id]
end

function Nebula.build:GetAll()
    return self.blueprints
end

function Nebula.build:GetByCategory(category)
    local result = {}
    for id, bp in pairs(self.blueprints) do
        if bp.category == category then
            table.insert(result, bp)
        end
    end
    return result
end

function Nebula.build:GetCategories()
    local cats = {}
    for _, bp in pairs(self.blueprints) do
        if not table.HasValue(cats, bp.category) then
            table.insert(cats, bp.category)
        end
    end
    table.sort(cats)
    return cats
end

-- Проверить может ли строить
function Nebula.build:CanBuild(ply, blueprintID)
    local bp = self:Get(blueprintID)
    if not bp then return false, "Чертёж не найден" end
    
    -- Деньги
    if bp.cost > 0 and not Nebula.economy:CanAfford(ply, bp.cost) then
        return false, "Нужно " .. Nebula.economy:FormatMoney(bp.cost)
    end
    
    -- Предметы
    for _, req in ipairs(bp.items) do
        if not Nebula.inventory:HasItem(ply, req.item, req.amount or 1) then
            local itemDef = Nebula.inventory:GetItem(req.item)
            return false, "Нужен: " .. (itemDef and itemDef.name or req.item)
        end
    end
    
    -- Лимит
    local count = self:GetPlayerBuildCount(ply, blueprintID)
    if count >= bp.maxPerPlayer then
        return false, "Достигнут лимит (" .. bp.maxPerPlayer .. ")"
    end
    
    return true, "OK"
end

function Nebula.build:GetPlayerBuildCount(ply, blueprintID)
    local count = 0
    for _, ent in ipairs(ents.FindByClass("nebula_buildable")) do
        if ent:GetNWString("nebula_buildOwner", "") == ply:SteamID() and
           ent:GetNWString("nebula_buildType", "") == blueprintID then
            count = count + 1
        end
    end
    return count
end

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Build система загружена.\n")
