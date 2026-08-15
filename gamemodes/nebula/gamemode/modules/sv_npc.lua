--[[
    Nebula Framework — NPC System (Server)
    Спавн, взаимодействие, диалоги, торговля
]]

Nebula.npc = Nebula.npc or {}

util.AddNetworkString("Nebula:NPCInteract")
util.AddNetworkString("Nebula:NPCDialogue")
util.AddNetworkString("Nebula:NPCTrade")
util.AddNetworkString("Nebula:NPCTradeBuy")
util.AddNetworkString("Nebula:NPCTradeSell")
util.AddNetworkString("Nebula:NPCClose")

-- Спавн NPC
function Nebula.npc:Spawn(typeID, pos, angle)
    local npcType = self:GetType(typeID)
    if not npcType then return nil end
    
    local ent = ents.Create("nebula_npc")
    if not IsValid(ent) then return nil end
    
    ent:SetPos(pos)
    ent:SetAngles(angle or Angle(0, 0, 0))
    ent:Spawn()
    ent:SetNWString("nebula_npcType", typeID)
    ent:SetNWString("nebula_npcName", npcType.name)
    ent:SetModel(npcType.model)
    
    if npcType.skin then ent:SetSkin(npcType.skin) end
    if npcType.color then ent:SetColor(npcType.color) end
    
    -- Анимация
    local seq = ent:LookupSequence(npcType.idleAnim)
    if seq and seq >= 0 then
        ent:SetSequence(seq)
    end
    
    -- Сохраняем
    table.insert(self.spawned, ent)
    
    return ent
end

-- Взаимодействие с NPC
function Nebula.npc:Interact(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    
    local typeID = ent:GetNWString("nebula_npcType", "")
    local npcType = self:GetType(typeID)
    if not npcType then return end
    
    -- Приветствие
    local greeting = npcType.greetings[math.random(#npcType.greetings)]
    
    -- Отправляем диалог клиенту
    net.Start("Nebula:NPCDialogue")
        net.WriteString(typeID)
        net.WriteString(npcType.name)
        net.WriteString(greeting)
        net.WriteBool(npcType.canTrade)
        net.WriteBool(npcType.canQuest)
        net.WriteBool(npcType.canHeal)
        net.WriteTable(npcType.dialogues)
        net.WriteTable(npcType.quests)
    net.Send(ply)
end

-- Покупка у NPC
function Nebula.npc:Buy(ply, typeID, itemClass, quantity)
    quantity = quantity or 1
    local npcType = self:GetType(typeID)
    if not npcType then return false end
    
    local price = 0
    local found = false
    for _, item in ipairs(npcType.shopItems) do
        if item.item == itemClass then
            price = (item.price or 0) * quantity
            found = true
            break
        end
    end
    
    if not found then
        Nebula.util:Notify(ply, 1, "Этот NPC не продаёт такой предмет.")
        return false
    end
    
    if not Nebula.economy:CanAfford(ply, price) then
        Nebula.util:Notify(ply, 1, "Недостаточно денег! Нужно " .. Nebula.economy:FormatMoney(price))
        return false
    end
    
    Nebula.economy:TakeMoney(ply, price, "Покупка у " .. npcType.name)
    Nebula.inventory:AddItem(ply, itemClass, {}, quantity)
    
    local itemDef = Nebula.inventory:GetItem(itemClass)
    Nebula.util:Notify(ply, 0, "Купил " .. quantity .. "x " .. (itemDef and itemDef.name or itemClass) .. " за " .. Nebula.economy:FormatMoney(price))
    
    return true
end

-- Продажа NPC
function Nebula.npc:Sell(ply, typeID, itemID)
    local npcType = self:GetType(typeID)
    if not npcType then return false end
    
    local inv = Nebula.inventory:GetAll(ply)
    local item = nil
    for _, it in ipairs(inv) do
        if it.id == itemID then
            item = it
            break
        end
    end
    
    if not item then return false end
    
    local itemDef = Nebula.inventory:GetItem(item.item_class)
    if not itemDef then return false end
    
    -- Цена = базовая * buybackRate
    local price = math.floor((itemDef.weight or 1) * 10 * npcType.buybackRate)
    price = math.max(price, 1)
    
    Nebula.inventory:RemoveItem(ply, itemID, 1)
    Nebula.economy:AddMoney(ply, price, "Продажа " .. itemDef.name)
    
    Nebula.util:Notify(ply, 0, "Продал " .. itemDef.name .. " за " .. Nebula.economy:FormatMoney(price))
    
    return true
end

-- Нетворк приёмники
net.Receive("Nebula:NPCTradeBuy", function(len, ply)
    local typeID = net.ReadString()
    local itemClass = net.ReadString()
    local qty = net.ReadUInt(8)
    Nebula.npc:Buy(ply, typeID, itemClass, qty)
end)

net.Receive("Nebula:NPCTradeSell", function(len, ply)
    local typeID = net.ReadString()
    local itemID = net.ReadUInt(16)
    Nebula.npc:Sell(ply, typeID, itemID)
end)

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Серверная NPC система загружена.\n")
