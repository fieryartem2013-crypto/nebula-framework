--[[
    Nebula Framework — Crafting System (Server)
    Выполнение крафта
]]

Nebula.craft = Nebula.craft or {}

util.AddNetworkString("Nebula:CraftStart")
util.AddNetworkString("Nebula:CraftComplete")
util.AddNetworkString("Nebula:CraftSync")

-- Выполнить крафт
function Nebula.craft:DoCraft(ply, recipeID)
    local recipe = self:Get(recipeID)
    if not recipe then return false end
    
    local can, reason = self:CanCraft(ply, recipeID)
    if not can then
        Nebula.util:Notify(ply, 1, reason)
        return false
    end
    
    -- Проверяем станцию (если нужна)
    if recipe.requiresStation then
        local trace = ply:GetEyeTrace()
        local nearStation = false
        
        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 200)) do
            if ent:GetNWString("nebula_stationType", "") == recipe.stationType then
                nearStation = true
                break
            end
        end
        
        if not nearStation then
            Nebula.util:Notify(ply, 1, "Нужна станция: " .. (recipe.stationType or "неизвестно"))
            return false
        end
    end
    
    -- Убираем ингредиенты
    for _, ing in ipairs(recipe.ingredients) do
        Nebula.inventory:RemoveItemByClass(ply, ing.item, ing.amount or 1)
    end
    
    -- Шанс успеха
    local success = math.random(100) <= recipe.successChance
    
    if success then
        -- Даём результат
        Nebula.inventory:AddItem(ply, recipe.result.item, {}, recipe.result.amount or 1)
        
        local resultDef = Nebula.inventory:GetItem(recipe.result.item)
        Nebula.util:Notify(ply, 0, "Скрафтил: " .. (resultDef and resultDef.name or recipe.result.item) .. " x" .. (recipe.result.amount or 1))
        
        -- Опыт
        if recipe.xp > 0 then
            -- Можно привязать к системе уровней
        end
    else
        Nebula.util:Notify(ply, 1, "Крафт провалился! Материалы потеряны.")
    end
    
    return success
end

-- Нетворк
net.Receive("Nebula:CraftStart", function(len, ply)
    local recipeID = net.ReadString()
    
    local recipe = Nebula.craft:Get(recipeID)
    if not recipe then return end
    
    -- Таймер крафта
    local duration = recipe.craftTime or 3
    
    Nebula.util:Notify(ply, 0, "Крафт '" .. recipe.name .. "'... (" .. duration .. "с)")
    
    timer.Simple(duration, function()
        if IsValid(ply) then
            Nebula.craft:DoCraft(ply, recipeID)
        end
    end)
end)

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Серверная Crafting система загружена.\n")
