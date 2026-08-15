--[[
    Nebula Framework — Permission System
    Ранги + кастомные права
]]

Nebula.perm = Nebula.perm or {}
Nebula.perm.ranks = {}
Nebula.perm.permissions = {}
Nebula.perm.playerRanks = {} -- steamid -> rank

-- Стандартные ранги
Nebula.perm:RegisterRank("user", 0, "Обычный игрок", {})
Nebula.perm:RegisterRank("vip", 10, "VIP", {})
Nebula.perm:RegisterRank("moderator", 50, "Модератор", {})
Nebula.perm:RegisterRank("admin", 80, "Администратор", {})
Nebula.perm:RegisterRank("superadmin", 90, "Суперадмин", {})
Nebula.perm:RegisterRank("owner", 100, "Владелец", {})

-- Регистрация ранга
function Nebula.perm:RegisterRank(id, level, name, permissions)
    self.ranks[id] = {
        id = id,
        level = level or 0,
        name = name or id,
        permissions = permissions or {},
    }
end

-- Регистрация права
function Nebula.perm:RegisterPermission(id, data)
    self.permissions[id] = {
        id = id,
        name = data.name or id,
        description = data.description or "",
        minRank = data.minRank or "user",
    }
end

-- Получить ранг игрока
function Nebula.perm:GetRank(ply)
    if not IsValid(ply) then return self.ranks["user"] end
    
    -- SteamID override
    local customRank = self.playerRanks[ply:SteamID()]
    if customRank and self.ranks[customRank] then
        return self.ranks[customRank]
    end
    
    -- GMod fallback
    if ply:IsSuperAdmin() then return self.ranks["superadmin"] or self.ranks["user"] end
    if ply:IsAdmin() then return self.ranks["admin"] or self.ranks["user"] end
    
    return self.ranks["user"]
end

-- Получить уровень ранга
function Nebula.perm:GetLevel(ply)
    local rank = self:GetRank(ply)
    return rank and rank.level or 0
end

-- Проверить право
function Nebula.perm:HasAccess(ply, permission)
    if not IsValid(ply) then return false end
    
    local perm = self.permissions[permission]
    if not perm then return true end -- Неизвестное право = разрешено
    
    local rank = self:GetRank(ply)
    local requiredRank = self.ranks[perm.minRank]
    
    if not rank or not requiredRank then return false end
    
    return rank.level >= requiredRank.level
end

-- Проверить уровень
function Nebula.perm:HasLevel(ply, level)
    return self:GetLevel(ply) >= level
end

-- Установить ранг игроку
function Nebula.perm:SetRank(steamid, rankID)
    if not self.ranks[rankID] then return false end
    self.playerRanks[steamid] = rankID
    return true
end

-- Получить все ранги
function Nebula.perm:GetRanks()
    return self.ranks
end

-- Получить все права
function Nebula.perm:GetPermissions()
    return self.permissions
end

-- ==========================================
-- РЕГИСТРАЦИЯ СТАНДАРТНЫХ ПРАВ
-- ==========================================

Nebula.perm:RegisterPermission("admin_menu", {name = "Админ-панель", minRank = "moderator"})
Nebula.perm:RegisterPermission("kick_player", {name = "Кикнуть игрока", minRank = "moderator"})
Nebula.perm:RegisterPermission("ban_player", {name = "Забанить игрока", minRank = "admin"})
Nebula.perm:RegisterPermission("teleport", {name = "Телепорт", minRank = "moderator"})
Nebula.perm:RegisterPermission("give_item", {name = "Выдать предмет", minRank = "admin"})
Nebula.perm:RegisterPermission("spawn_npc", {name = "Спавнить NPC", minRank = "admin"})
Nebula.perm:RegisterPermission("manage_zones", {name = "Управление зонами", minRank = "admin"})
Nebula.perm:RegisterPermission("manage_kpp", {name = "Управление КПП", minRank = "admin"})
Nebula.perm:RegisterPermission("god_mode", {name = "Бессмертие", minRank = "superadmin"})
Nebula.perm:RegisterPermission("noclip", {name = "Ноуклип", minRank = "moderator"})
Nebula.perm:RegisterPermission("set_money", {name = "Установить деньги", minRank = "admin"})
Nebula.perm:RegisterPermission("view_logs", {name = "Просмотр логов", minRank = "moderator"})

-- ==========================================
-- СОХРАНЕНИЕ/ЗАГРУЗКА РАНГОВ
-- ==========================================

if SERVER then
    function Nebula.perm:Save()
        file.CreateDir("nebula")
        file.Write("nebula/ranks.json", util.TableToJSON(self.playerRanks, true))
    end
    
    function Nebula.perm:Load()
        if not file.Exists("nebula/ranks.json", "DATA") then return end
        local data = util.JSONToTable(file.Read("nebula/ranks.json", "DATA") or "")
        if data then self.playerRanks = data end
    end
    
    hook.Add("Initialize", "Nebula:LoadRanks", function()
        Nebula.perm:Load()
    end)
    
    hook.Add("ShutDown", "Nebula:SaveRanks", function()
        Nebula.perm:Save()
    end)
end

Nebula.util:Log("Permissions", "Система прав загружена: " .. table.Count(Nebula.perm.ranks) .. " рангов, " .. table.Count(Nebula.perm.permissions) .. " прав.")
