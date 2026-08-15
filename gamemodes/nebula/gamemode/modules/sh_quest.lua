--[[
    Nebula Framework — Quest System (Shared)
    Система квестов: цепочки, награды, отслеживание
]]

Nebula.quest = Nebula.quest or {}
Nebula.quest.stored = Nebula.quest.stored or {}

-- Регистрация квеста
function Nebula.quest:Register(id, data)
    self.stored[id] = {
        id = id,
        name = data.name or "Квест",
        description = data.description or "",
        category = data.category or "Общие",
        difficulty = data.difficulty or 1, -- 1-5
        level = data.level or 0,
        
        -- Тип квеста
        type = data.type or "talk", -- talk, fetch, kill, explore, craft, escort
        
        -- Цели
        objectives = data.objectives or {},
        
        -- Награды
        rewards = data.rewards or {money = 0, items = {}, xp = 0},
        
        -- Прогресс
        startNPC = data.startNPC or nil,
        endNPC = data.endNPC or nil,
        
        -- Условия
        requiresQuest = data.requiresQuest or nil,
        requiresFaction = data.requiresFaction or {},
        requiresLevel = data.requiresLevel or 0,
        repeatable = data.repeatable or false,
        cooldown = data.cooldown or 0, -- секунды
        
        -- Цепочка
        nextQuest = data.nextQuest or nil,
        
        -- Коллбэки
        onStart = data.onStart,
        onComplete = data.onComplete,
        onFail = data.onFail,
        onProgress = data.onProgress,
    }
end

function Nebula.quest:Get(id)
    return self.stored[id]
end

function Nebula.quest:GetAll()
    return self.stored
end

function Nebula.quest:GetByNPC(npcType)
    local result = {}
    for id, quest in pairs(self.stored) do
        if quest.startNPC == npcType then
            table.insert(result, quest)
        end
    end
    return result
end

function Nebula.quest:GetByCategory(category)
    local result = {}
    for id, quest in pairs(self.stored) do
        if quest.category == category then
            table.insert(result, quest)
        end
    end
    return result
end

function Nebula.quest:GetCategories()
    local cats = {}
    for _, quest in pairs(self.stored) do
        if not table.HasValue(cats, quest.category) then
            table.insert(cats, quest.category)
        end
    end
    table.sort(cats)
    return cats
end

function Nebula.quest:DifficultyText(level)
    local texts = {"", "Легко", "Средне", "Сложно", "Очень сложно", "ЭПИЧНО"}
    return texts[level] or "?"
end

function Nebula.quest:DifficultyColor(level)
    local colors = {
        Color(200,200,200),
        Color(80,200,80),
        Color(255,200,50),
        Color(255,150,50),
        Color(255,80,80),
        Color(200,50,255),
    }
    return colors[level] or Color(200,200,200)
end

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Quest система загружена.\n")
