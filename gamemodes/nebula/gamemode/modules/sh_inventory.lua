--[[
    Nebula Framework - Inventory System (Shared)
    Item registration and management
]]

Nebula.inventory = Nebula.inventory or {}
Nebula.inventory.items = Nebula.inventory.items or {}
Nebula.inventory.stored = Nebula.inventory.stored or {}

-- ==========================================
-- Item Registration
-- ==========================================

-- Register a new item class
function Nebula.inventory:RegisterItem(id, data)
    self.items[id] = {
        id = id,
        name = data.name or "Unknown Item",
        description = data.description or "No description.",
        model = data.model or "models/props_junk/garbage_metalcan001a.mdl",
        category = data.category or "Miscellaneous",
        weight = data.weight or 1,
        stackable = data.stackable or false,
        maxStack = data.maxStack or 1,
        unique = data.unique or false, -- Can only have one
        droppable = data.droppable or true,
        usable = data.usable or false,
        useText = data.useText or "Use",
        
        -- Callbacks
        onUse = data.onUse,
        onDrop = data.onDrop,
        onPickup = data.onPickup,
        onEquip = data.onEquip,
        onUnequip = data.onUnequip,
        
        -- Custom data
        data = data.data or {},
    }
    
    return self.items[id]
end

-- Get item class
function Nebula.inventory:GetItem(id)
    return self.items[id]
end

-- Get all registered items
function Nebula.inventory:GetAllItems()
    return self.items
end

-- Get items by category
function Nebula.inventory:GetItemsByCategory(category)
    local result = {}
    for id, item in pairs(self.items) do
        if item.category == category then
            result[id] = item
        end
    end
    return result
end

-- Get all categories
function Nebula.inventory:GetCategories()
    local categories = {}
    for id, item in pairs(self.items) do
        if not table.HasValue(categories, item.category) then
            table.insert(categories, item.category)
        end
    end
    table.sort(categories)
    return categories
end

-- ==========================================
-- Player Inventory Access (Shared)
-- ==========================================

-- Get player's inventory table
function Nebula.inventory:GetAll(ply)
    if not IsValid(ply) then return {} end
    return self.stored[ply:SteamID()] or {}
end

-- Get item count in inventory
function Nebula.inventory:GetItemCount(ply, itemClass)
    local inv = self:GetAll(ply)
    local count = 0
    
    for _, item in ipairs(inv) do
        if item.item_class == itemClass then
            count = count + (item.quantity or 1)
        end
    end
    
    return count
end

-- Check if player has item
function Nebula.inventory:HasItem(ply, itemClass, quantity)
    quantity = quantity or 1
    return self:GetItemCount(ply, itemClass) >= quantity
end
