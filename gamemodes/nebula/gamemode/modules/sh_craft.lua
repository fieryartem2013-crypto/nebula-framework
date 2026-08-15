--[[
    Nebula Framework — Crafting System (Shared)
    Система крафта: рецепты, ингредиенты, результаты
]]

Nebula.craft = Nebula.craft or {}
Nebula.craft.recipes = Nebula.craft.recipes or {}

-- Регистрация рецепта
function Nebula.craft:Register(id, data)
    self.recipes[id] = {
        id = id,
        name = data.name or "Крафт",
        description = data.description or "",
        category = data.category or "Общие",
        
        -- Ингредиенты: {{item = "id", amount = 1}, ...}
        ingredients = data.ingredients or {},
        
        -- Результат
        result = data.result or {item = "unknown", amount = 1},
        
        -- Требования
        requiresStation = data.requiresStation or false,
        stationType = data.stationType or nil, -- "workbench", "stove", "lab"
        requiresSkill = data.requiresSkill or nil,
        skillLevel = data.skillLevel or 0,
        
        -- Время крафта (секунды)
        craftTime = data.craftTime or 3,
        
        -- Шанс успеха (0-100)
        successChance = data.successChance or 100,
        
        -- Опыт за крафт
        xp = data.xp or 0,
    }
end

function Nebula.craft:Get(id)
    return self.recipes[id]
end

function Nebula.craft:GetAll()
    return self.recipes
end

function Nebula.craft:GetByCategory(category)
    local result = {}
    for id, recipe in pairs(self.recipes) do
        if recipe.category == category then
            table.insert(result, recipe)
        end
    end
    return result
end

function Nebula.craft:GetCategories()
    local cats = {}
    for _, recipe in pairs(self.recipes) do
        if not table.HasValue(cats, recipe.category) then
            table.insert(cats, recipe.category)
        end
    end
    table.sort(cats)
    return cats
end

-- Проверить может ли игрок крафтить
function Nebula.craft:CanCraft(ply, recipeID)
    local recipe = self:Get(recipeID)
    if not recipe then return false, "Рецепт не найден" end
    
    -- Проверяем ингредиенты
    for _, ing in ipairs(recipe.ingredients) do
        local count = Nebula.inventory:GetItemCount(ply, ing.item)
        if count < (ing.amount or 1) then
            local itemDef = Nebula.inventory:GetItem(ing.item)
            return false, "Не хватает: " .. (itemDef and itemDef.name or ing.item) .. " (нужно " .. (ing.amount or 1) .. ", есть " .. count .. ")"
        end
    end
    
    return true, "Можно крафтить"
end

-- Получить список доступных рецептов для игрока
function Nebula.craft:GetAvailable(ply)
    local available = {}
    for id, recipe in pairs(self.recipes) do
        local can, _ = self:CanCraft(ply, id)
        if can then
            table.insert(available, recipe)
        end
    end
    return available
end

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Crafting система загружена.\n")
