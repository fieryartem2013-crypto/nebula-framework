--[[
    Nebula Framework — NPC System (Shared)
    Система NPC: торговцы, квестодатели, диалоги
]]

Nebula.npc = Nebula.npc or {}
Nebula.npc.types = Nebula.npc.types or {}
Nebula.npc.spawned = Nebula.npc.spawned or {}

-- Тип NPC
function Nebula.npc:RegisterType(id, data)
    self.types[id] = {
        id = id,
        name = data.name or "NPC",
        model = data.model or "models/barney.mdl",
        skin = data.skin or 0,
        bodygroups = data.bodygroups or {},
        color = data.color or nil,
        
        -- Поведение
        idleAnim = data.idleAnim or "idle_all_01",
        talkAnim = data.talkAnim or "idle_all_01",
        
        -- Взаимодействие
        useText = data.useText or "Говорить",
        canTrade = data.canTrade or false,
        canHeal = data.canHeal or false,
        canQuest = data.canQuest or false,
        
        -- Диалоги
        greetings = data.greetings or {"Здравствуй."},
        farewells = data.farewells or {"Пока."},
        dialogues = data.dialogues or {},
        
        -- Торговля
        shopItems = data.shopItems or {},
        buybackRate = data.buybackRate or 0.5,
        
        -- Квесты
        quests = data.quests or {},
        
        -- Коллизия
        collisionMins = data.collisionMins or Vector(-16, -16, 0),
        collisionMaxs = data.collisionMaxs or Vector(16, 16, 72),
    }
end

function Nebula.npc:GetType(id)
    return self.types[id]
end

function Nebula.npc:GetAllTypes()
    return self.types
end

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "NPC система загружена.\n")
