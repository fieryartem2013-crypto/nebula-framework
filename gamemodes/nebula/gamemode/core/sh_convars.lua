--[[
    Nebula Framework — ConVar System
    Настройки через консоль без перезагрузки
]]

Nebula.convar = Nebula.convar or {}

-- Регистрация ConVar
function Nebula.convar:Register(name, default, description, flags)
    flags = flags or FCVAR_ARCHIVE
    local cvar = CreateConVar("nebula_" .. name, default, flags, description or "")
    self[name] = cvar
    return cvar
end

-- Получить значение
function Nebula.convar:Get(name, fallback)
    local cvar = self[name]
    if not cvar then return fallback end
    
    local val = cvar:GetString()
    if val == "" then return fallback end
    
    -- Авто-конвертация типов
    local num = tonumber(val)
    if num then return num end
    if val == "true" then return true end
    if val == "false" then return false end
    return val
end

function Nebula.convar:GetBool(name, fallback)
    local cvar = self[name]
    if not cvar then return fallback or false end
    return cvar:GetBool()
end

function Nebula.convar:GetInt(name, fallback)
    local cvar = self[name]
    if not cvar then return fallback or 0 end
    return cvar:GetInt()
end

function Nebula.convar:GetFloat(name, fallback)
    local cvar = self[name]
    if not cvar then return fallback or 0 end
    return cvar:GetFloat()
end

-- ==========================================
-- РЕГИСТРАЦИЯ ВСЕХ CONVAR
-- ==========================================

-- Общие
Nebula.convar:Register("max_characters", "3", "Максимум персонажей на игрока")
Nebula.convar:Register("starting_money", "500", "Стартовые деньги")
Nebula.convar:Register("auto_save_interval", "300", "Интервал автосейва (сек)")
Nebula.convar:Register("server_name", "Nebula RP", "Название сервера")

-- Геймплей
Nebula.convar:Register("walk_speed", "180", "Скорость ходьбы")
Nebula.convar:Register("run_speed", "280", "Скорость бега")
Nebula.convar:Register("jump_power", "200", "Сила прыжка")
Nebula.convar:Register("spawn_protection", "10", "Защита при спавне (сек)")
Nebula.convar:Register("falldamage_scale", "1.0", "Множитель урона от падения")

-- Чат
Nebula.convar:Register("chat_range", "500", "Дальность IC чата")
Nebula.convar:Register("whisper_range", "150", "Дальность шёпота")
Nebula.convar:Register("yell_range", "1000", "Дальность крика")
Nebula.convar:Register("enable_looc", "1", "Включить LOOC")

-- Экономика
Nebula.convar:Register("salary_interval", "300", "Интервал зарплат (сек)")
Nebula.convar:Register("max_money", "10000000", "Максимум денег")
Nebula.convar:Register("death_penalty_percent", "5", "Штраф при смерти (%)")

-- Debug
Nebula.convar:Register("debug", "0", "Уровень дебага (0=выкл, 1=базовый, 2=подробный)")
Nebula.convar:Register("log_net", "0", "Логировать net сообщения")
Nebula.convar:Register("log_hooks", "0", "Логировать хуки")

-- PvP
Nebula.convar:Register("pvp_enabled", "1", "PvP включено")
Nebula.convar:Register("safezone_damage", "0", "Урон в safe зоне")
Nebula.convar:Register("rdm_protection", "1", "Защита от RDM")

Nebula.util:Log("ConVar", "Зарегистрировано " .. table.Count(Nebula.convar) .. " ConVar.")
