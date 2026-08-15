--[[
    Nebula Framework — Quest System (Server)
    Прогресс, выполнение, награды
]]

Nebula.quest = Nebula.quest or {}
Nebula.quest.playerData = Nebula.quest.playerData or {}

util.AddNetworkString("Nebula:QuestSync")
util.AddNetworkString("Nebula:QuestAccept")
util.AddNetworkString("Nebula:QuestComplete")
util.AddNetworkString("Nebula:QuestUpdate")
util.AddNetworkString("Nebula:QuestAbandon")

-- Получить данные квестов игрока
function Nebula.quest:GetPlayerData(ply)
    if not IsValid(ply) then return {} end
    local sid = ply:SteamID()
    if not self.playerData[sid] then
        self.playerData[sid] = {
            active = {},   -- {questID = {progress = {}, startedAt = time}}
            completed = {}, -- {questID = {count, lastCompleted}}
            cooldowns = {}, -- {questID = lastCompletionTime}
        }
    end
    return self.playerData[sid]
end

-- Принять квест
function Nebula.quest:Accept(ply, questID)
    local quest = self:Get(questID)
    if not quest then return false end
    
    local pd = self:GetPlayerData(ply)
    
    -- Уже активен?
    if pd.active[questID] then
        Nebula.util:Notify(ply, 1, "Ты уже выполняешь этот квест!")
        return false
    end
    
    -- Уже выполнен? (если не повторяемый)
    if not quest.repeatable and pd.completed[questID] then
        Nebula.util:Notify(ply, 1, "Ты уже выполнил этот квест!")
        return false
    end
    
    -- Кулдаун?
    if quest.cooldown > 0 and pd.cooldowns[questID] then
        local timeLeft = (pd.cooldowns[questID] + quest.cooldown) - os.time()
        if timeLeft > 0 then
            Nebula.util:Notify(ply, 1, "Квест на кулдауне! Подожди " .. Nebula.util:FormatTime(timeLeft))
            return false
        end
    end
    
    -- Требуется предыдущий квест?
    if quest.requiresQuest and not pd.completed[quest.requiresQuest] then
        local reqQuest = self:Get(quest.requiresQuest)
        Nebula.util:Notify(ply, 1, "Сначала выполни квест: " .. (reqQuest and reqQuest.name or quest.requiresQuest))
        return false
    end
    
    -- Фракция?
    if #quest.requiresFaction > 0 then
        local playerFaction = Nebula.faction:GetPlayerFaction(ply)
        local allowed = false
        for _, f in ipairs(quest.requiresFaction) do
            if playerFaction == f then allowed = true break end
        end
        if not allowed then
            Nebula.util:Notify(ply, 1, "Этот квест не для твоей фракции!")
            return false
        end
    end
    
    -- Инициализируем прогресс
    local progress = {}
    for i, obj in ipairs(quest.objectives) do
        progress[i] = {current = 0, target = obj.amount or 1, done = false}
    end
    
    pd.active[questID] = {
        progress = progress,
        startedAt = os.time(),
    }
    
    Nebula.util:Notify(ply, 0, "Квест принят: " .. quest.name)
    
    if quest.onStart then quest.onStart(ply, quest) end
    
    self:SyncToClient(ply)
    return true
end

-- Обновить прогресс квеста
function Nebula.quest:UpdateProgress(ply, questID, objectiveIndex, amount)
    local pd = self:GetPlayerData(ply)
    local active = pd.active[questID]
    if not active then return end
    
    local quest = self:Get(questID)
    if not quest then return end
    
    local obj = active.progress[objectiveIndex]
    if not obj or obj.done then return end
    
    obj.current = math.min(obj.current + (amount or 1), obj.target)
    if obj.current >= obj.target then
        obj.done = true
    end
    
    -- Уведомление
    local objective = quest.objectives[objectiveIndex]
    if objective then
        Nebula.util:Notify(ply, 0, string.format("[%s] %s: %d/%d", quest.name, objective.text or "Цель", obj.current, obj.target))
    end
    
    -- Проверяем выполнение всех целей
    if self:IsComplete(ply, questID) then
        Nebula.util:Notify(ply, 0, "Квест '" .. quest.name .. "' готов к сдаче!")
    end
    
    if quest.onProgress then quest.onProgress(ply, quest, objectiveIndex, obj) end
    
    self:SyncToClient(ply)
end

-- Проверить выполнен ли квест
function Nebula.quest:IsComplete(ply, questID)
    local pd = self:GetPlayerData(ply)
    local active = pd.active[questID]
    if not active then return false end
    
    for _, obj in pairs(active.progress) do
        if not obj.done then return false end
    end
    return true
end

-- Сдать квест
function Nebula.quest:Complete(ply, questID)
    local quest = self:Get(questID)
    if not quest then return false end
    
    if not self:IsComplete(ply, questID) then
        Nebula.util:Notify(ply, 1, "Квест ещё не выполнен!")
        return false
    end
    
    local pd = self:GetPlayerData(ply)
    
    -- Награды
    local rewards = quest.rewards
    if rewards.money and rewards.money > 0 then
        Nebula.economy:AddMoney(ply, rewards.money, "Квест: " .. quest.name)
    end
    if rewards.items then
        for _, item in ipairs(rewards.items) do
            Nebula.inventory:AddItem(ply, item.item, {}, item.quantity or 1)
        end
    end
    
    -- Отмечаем как выполненный
    pd.completed[questID] = {count = (pd.completed[questID] and pd.completed[questID].count or 0) + 1, lastCompleted = os.time()}
    pd.active[questID] = nil
    
    if quest.cooldown > 0 then
        pd.cooldowns[questID] = os.time()
    end
    
    Nebula.util:Notify(ply, 0, "Квест '" .. quest.name .. "' выполнен! +" .. Nebula.economy:FormatMoney(rewards.money or 0))
    
    if quest.onComplete then quest.onComplete(ply, quest) end
    
    -- Следующий квест в цепочке
    if quest.nextQuest then
        timer.Simple(2, function()
            if IsValid(ply) then
                Nebula.util:Notify(ply, 0, "Доступен новый квест: " .. (self:Get(quest.nextQuest) and self:Get(quest.nextQuest).name or quest.nextQuest))
            end
        end)
    end
    
    self:SyncToClient(ply)
    return true
end

-- Отменить квест
function Nebula.quest:Abandon(ply, questID)
    local pd = self:GetPlayerData(ply)
    if pd.active[questID] then
        pd.active[questID] = nil
        local quest = self:Get(questID)
        Nebula.util:Notify(ply, 1, "Квест '" .. (quest and quest.name or questID) .. "' отменён.")
        self:SyncToClient(ply)
    end
end

-- Синхронизация
function Nebula.quest:SyncToClient(ply)
    if not IsValid(ply) then return end
    local pd = self:GetPlayerData(ply)
    net.Start("Nebula:QuestSync")
        net.WriteTable(pd)
    net.Send(ply)
end

-- Нетворк приёмники
net.Receive("Nebula:QuestAccept", function(len, ply)
    local questID = net.ReadString()
    Nebula.quest:Accept(ply, questID)
end)

net.Receive("Nebula:QuestComplete", function(len, ply)
    local questID = net.ReadString()
    Nebula.quest:Complete(ply, questID)
end)

net.Receive("Nebula:QuestAbandon", function(len, ply)
    local questID = net.ReadString()
    Nebula.quest:Abandon(ply, questID)
end)

-- Загрузка данных из БД
hook.Add("Nebula:CharacterLoaded", "Quest:LoadData", function(ply, charID)
    local data = Nebula.database:GetCharacter(charID)
    if data and data.data and data.data.quests then
        Nebula.quest.playerData[ply:SteamID()] = data.data.quests
    end
    timer.Simple(1, function()
        if IsValid(ply) then Nebula.quest:SyncToClient(ply) end
    end)
end)

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Серверная Quest система загружена.\n")
