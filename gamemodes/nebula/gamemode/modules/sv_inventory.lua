--[[
    Nebula Framework - Inventory System (Server)
    Server-side inventory management
]]

Nebula.inventory = Nebula.inventory or {}

-- Network strings
util.AddNetworkString("Nebula:InventorySync")
util.AddNetworkString("Nebula:InventoryAction")
util.AddNetworkString("Nebula:InventoryUpdate")

-- Load inventory from database
function Nebula.inventory:LoadFromDB(ply, charID)
    if not IsValid(ply) then return end
    
    local items = Nebula.database:GetInventoryItems(charID)
    self.stored[ply:SteamID()] = items
    
    -- Sync to client
    self:SyncToClient(ply)
    
    Nebula.util:Log("Inventory", "Loaded " .. #items .. " items for " .. ply:Name())
end

-- Save inventory to database
function Nebula.inventory:SaveToDB(ply, charID)
    if not IsValid(ply) then return end
    
    local inv = self:GetAll(ply)
    
    -- Clear existing items in DB
    sql.Query(string.format(
        "DELETE FROM nebula_inventory WHERE character_id = %d",
        tonumber(charID)
    ))
    
    -- Re-insert all items
    for _, item in ipairs(inv) do
        Nebula.database:AddInventoryItem(charID, item.item_class, item.data, item.quantity)
    end
end

-- Add item to player's inventory
function Nebula.inventory:AddItem(ply, itemClass, data, quantity)
    if not IsValid(ply) then return false end
    
    quantity = quantity or 1
    data = data or {}
    
    local itemDef = self:GetItem(itemClass)
    if not itemDef then
        Nebula.util:Log("Inventory", "Unknown item class: " .. itemClass, Color(255, 80, 80))
        return false
    end
    
    -- Check if unique and already owned
    if itemDef.unique and self:HasItem(ply, itemClass) then
        Nebula.util:Notify(ply, 1, "You already have this unique item!")
        return false
    end
    
    -- Check for stackable
    if itemDef.stackable then
        local inv = self:GetAll(ply)
        for _, item in ipairs(inv) do
            if item.item_class == itemClass and (item.quantity or 1) < itemDef.maxStack then
                local space = itemDef.maxStack - (item.quantity or 1)
                local toAdd = math.min(quantity, space)
                item.quantity = (item.quantity or 1) + toAdd
                quantity = quantity - toAdd
                
                if quantity <= 0 then
                    self:SyncToClient(ply)
                    Nebula.hooks:OnInventoryChanged(ply, "add", item.id, itemDef)
                    return true
                end
            end
        end
    end
    
    -- Add new item
    local steamid = ply:SteamID()
    if not self.stored[steamid] then
        self.stored[steamid] = {}
    end
    
    local newItem = {
        id = #self.stored[steamid] + 1,
        item_class = itemClass,
        data = data,
        quantity = quantity,
        added_at = os.time(),
    }
    
    table.insert(self.stored[steamid], newItem)
    
    -- Sync to client
    self:SyncToClient(ply)
    
    -- Fire hook
    Nebula.hooks:OnInventoryChanged(ply, "add", newItem.id, itemDef)
    
    Nebula.util:Log("Inventory", "Added " .. quantity .. "x " .. itemDef.name .. " to " .. ply:Name())
    
    return true
end

-- Remove item from player's inventory
function Nebula.inventory:RemoveItem(ply, itemID, quantity)
    if not IsValid(ply) then return false end
    
    quantity = quantity or 1
    local steamid = ply:SteamID()
    local inv = self.stored[steamid]
    
    if not inv then return false end
    
    for i, item in ipairs(inv) do
        if item.id == itemID then
            local itemDef = self:GetItem(item.item_class)
            
            if (item.quantity or 1) > quantity then
                item.quantity = item.quantity - quantity
            else
                table.remove(inv, i)
            end
            
            self:SyncToClient(ply)
            Nebula.hooks:OnInventoryChanged(ply, "remove", itemID, itemDef)
            
            return true
        end
    end
    
    return false
end

-- Remove items by class
function Nebula.inventory:RemoveItemByClass(ply, itemClass, quantity)
    if not IsValid(ply) then return false end
    
    quantity = quantity or 1
    local steamid = ply:SteamID()
    local inv = self.stored[steamid]
    
    if not inv then return false end
    
    local remaining = quantity
    
    for i = #inv, 1, -1 do
        local item = inv[i]
        if item.item_class == itemClass then
            if (item.quantity or 1) > remaining then
                item.quantity = item.quantity - remaining
                remaining = 0
            else
                remaining = remaining - (item.quantity or 1)
                table.remove(inv, i)
            end
            
            if remaining <= 0 then
                break
            end
        end
    end
    
    if remaining < quantity then
        self:SyncToClient(ply)
        return true
    end
    
    return false
end

-- Use an item
function Nebula.inventory:UseItem(ply, itemID)
    if not IsValid(ply) then return false end
    
    local steamid = ply:SteamID()
    local inv = self.stored[steamid]
    
    if not inv then return false end
    
    for _, item in ipairs(inv) do
        if item.id == itemID then
            local itemDef = self:GetItem(item.item_class)
            
            if not itemDef then return false end
            if not itemDef.usable then
                Nebula.util:Notify(ply, 1, "This item cannot be used!")
                return false
            end
            
            -- Run use callback
            if itemDef.onUse then
                local result = itemDef.onUse(ply, item)
                
                -- If callback returns true, consume the item
                if result == true then
                    self:RemoveItem(ply, itemID, 1)
                end
            end
            
            return true
        end
    end
    
    return false
end

-- Drop an item
function Nebula.inventory:DropItem(ply, itemID)
    if not IsValid(ply) then return false end
    
    local steamid = ply:SteamID()
    local inv = self.stored[steamid]
    
    if not inv then return false end
    
    for _, item in ipairs(inv) do
        if item.id == itemID then
            local itemDef = self:GetItem(item.item_class)
            
            if not itemDef then return false end
            if not itemDef.droppable then
                Nebula.util:Notify(ply, 1, "This item cannot be dropped!")
                return false
            end
            
            -- Create world item
            self:CreateWorldItem(ply:GetPos() + ply:GetAimVector() * 50 + Vector(0, 0, 30), item)
            
            -- Remove from inventory
            self:RemoveItem(ply, itemID, 1)
            
            -- Run drop callback
            if itemDef.onDrop then
                itemDef.onDrop(ply, item)
            end
            
            return true
        end
    end
    
    return false
end

-- Create a physical item in the world
function Nebula.inventory:CreateWorldItem(pos, itemData)
    local itemDef = self:GetItem(itemData.item_class)
    if not itemDef then return end
    
    local ent = ents.Create("nebula_item")
    if not IsValid(ent) then return end
    
    ent:SetPos(pos)
    ent:SetModel(itemDef.model)
    ent:Spawn()
    
    ent:SetNWString("nebula_itemClass", itemData.item_class)
    ent:SetNWString("nebula_itemName", itemDef.name)
    ent:SetNWInt("nebula_itemQuantity", itemData.quantity or 1)
    ent:SetNWInt("nebula_itemID", itemData.id or 0)
    
    -- Store item data on entity
    ent.itemData = itemData
    ent.itemDef = itemDef
    
    -- Physics
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    
    -- Auto-remove after 5 minutes
    timer.Simple(300, function()
        if IsValid(ent) then
            ent:Remove()
        end
    end)
    
    return ent
end

-- Clear inventory
function Nebula.inventory:Clear(ply)
    if not IsValid(ply) then return end
    self.stored[ply:SteamID()] = {}
    self:SyncToClient(ply)
end

-- Sync inventory to client
function Nebula.inventory:SyncToClient(ply)
    if not IsValid(ply) then return end
    
    local inv = self:GetAll(ply)
    
    net.Start("Nebula:InventorySync")
        net.WriteTable(inv)
    net.Send(ply)
end

-- Give starting items based on faction
function Nebula.inventory:GiveFactionItems(ply, factionID)
    if not IsValid(ply) then return end
    
    local faction = Nebula.faction:Get(factionID)
    if not faction then return end
    
    if faction.items then
        for _, itemClass in ipairs(faction.items) do
            self:AddItem(ply, itemClass)
        end
    end
end

-- Network receivers
net.Receive("Nebula:InventoryAction", function(len, ply)
    local action = net.ReadString()
    local itemID = net.ReadUInt(16)
    
    if action == "use" then
        Nebula.inventory:UseItem(ply, itemID)
    elseif action == "drop" then
        Nebula.inventory:DropItem(ply, itemID)
    end
end)

-- World item entity
if SERVER then
    -- The actual entity is defined in entities/entities/nebula_item
end

Nebula.util:Log("Inventory", "Inventory system initialized.")
