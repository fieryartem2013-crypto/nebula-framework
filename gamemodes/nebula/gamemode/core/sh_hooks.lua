--[[
    Nebula Framework - Hook System
    Custom hook management for plugin-like modularity
]]

Nebula.hooks = Nebula.hooks or {}
Nebula.hooks.stored = Nebula.hooks.stored or {}

-- Register a hook
function Nebula.hooks:Register(event, id, callback, priority)
    priority = priority or 0
    
    if not self.stored[event] then
        self.stored[event] = {}
    end
    
    self.stored[event][id] = {
        callback = callback,
        priority = priority,
        id = id,
    }
    
    -- Register with GMod hook system
    hook.Add(event, "Nebula:Hook:" .. id, function(...)
        local args = {...}
        
        -- Run callback
        local result = callback(unpack(args))
        
        return result
    end)
end

-- Remove a hook
function Nebula.hooks:Remove(event, id)
    if self.stored[event] then
        self.stored[event][id] = nil
    end
    
    hook.Remove(event, "Nebula:Hook:" .. id)
end

-- Check if hook exists
function Nebula.hooks:Exists(event, id)
    return self.stored[event] and self.stored[event][id] ~= nil
end

-- Get all hooks for an event
function Nebula.hooks:GetByEvent(event)
    return self.stored[event] or {}
end

-- ==========================================
-- Built-in Hooks
-- ==========================================

-- Player data loaded hook
Nebula.hooks:Register("PlayerInitialSpawn", "Nebula:PlayerInit", function(ply)
    timer.Simple(2, function()
        if IsValid(ply) then
            hook.Run("Nebula:PlayerDataLoaded", ply)
        end
    end)
end, -10)

-- Character loaded hook
function Nebula.hooks:OnCharacterLoaded(ply, charID)
    hook.Run("Nebula:CharacterLoaded", ply, charID)
end

-- Character created hook
function Nebula.hooks:OnCharacterCreated(ply, charID, charData)
    hook.Run("Nebula:CharacterCreated", ply, charID, charData)
end

-- Character deleted hook
function Nebula.hooks:OnCharacterDeleted(ply, charID)
    hook.Run("Nebula:CharacterDeleted", ply, charID)
end

-- Inventory changed hook
function Nebula.hooks:OnInventoryChanged(ply, action, itemID, itemData)
    hook.Run("Nebula:InventoryChanged", ply, action, itemID, itemData)
end

-- Money changed hook
function Nebula.hooks:OnMoneyChanged(ply, oldAmount, newAmount, reason)
    hook.Run("Nebula:MoneyChanged", ply, oldAmount, newAmount, reason)
end

-- Faction changed hook
function Nebula.hooks:OnFactionChanged(ply, oldFaction, newFaction)
    hook.Run("Nebula:FactionChanged", ply, oldFaction, newFaction)
end

Nebula.util:Log("Hooks", "Hook system initialized.")
