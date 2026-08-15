--[[
    Nebula Framework - Configuration System
    Inspired by Helix's clean config approach
]]

Nebula.config = Nebula.config or {}
Nebula.config.stored = Nebula.config.stored or {}

-- Register a new configuration value
function Nebula.config:Register(key, default, description, options)
    options = options or {}
    
    self.stored[key] = {
        key = key,
        value = default,
        default = default,
        description = description or "",
        type = type(default),
        options = options, -- For dropdown options
        category = options.category or "General",
        min = options.min,
        max = options.max,
    }
    
    return self.stored[key]
end

-- Get a configuration value
function Nebula.config:Get(key, fallback)
    local config = self.stored[key]
    if config then
        return config.value
    end
    return fallback
end

-- Set a configuration value
function Nebula.config:Set(key, value)
    if self.stored[key] then
        local config = self.stored[key]
        
        -- Type checking
        if type(value) ~= config.type then
            Nebula.util:Log("Config", "Type mismatch for '" .. key .. "': expected " .. config.type .. ", got " .. type(value), Color(255, 80, 80))
            return false
        end
        
        -- Min/max clamping for numbers
        if config.type == "number" then
            if config.min then value = math.max(value, config.min) end
            if config.max then value = math.min(value, config.max) end
        end
        
        config.value = value
        return true
    end
    
    return false
end

-- Reset a config to default
function Nebula.config:Reset(key)
    if self.stored[key] then
        self.stored[key].value = self.stored[key].default
        return true
    end
    return false
end

-- Get all configs for a category
function Nebula.config:GetByCategory(category)
    local result = {}
    for k, v in pairs(self.stored) do
        if v.category == category then
            result[k] = v
        end
    end
    return result
end

-- Get all categories
function Nebula.config:GetCategories()
    local categories = {}
    for k, v in pairs(self.stored) do
        if not table.HasValue(categories, v.category) then
            table.insert(categories, v.category)
        end
    end
    return categories
end

-- Save configs to file
if SERVER then
    function Nebula.config:Save()
        local data = {}
        for k, v in pairs(self.stored) do
            data[k] = v.value
        end
        
        file.CreateDir("nebula")
        file.Write("nebula/config.json", util.TableToJSON(data, true))
        Nebula.util:Log("Config", "Configuration saved.")
    end
    
    function Nebula.config:Load()
        if not file.Exists("nebula/config.json", "DATA") then
            Nebula.util:Log("Config", "No config file found, using defaults.")
            return
        end
        
        local raw = file.Read("nebula/config.json", "DATA")
        local data = util.JSONToTable(raw)
        
        if not data then
            Nebula.util:Log("Config", "Failed to parse config file!", Color(255, 80, 80))
            return
        end
        
        for k, v in pairs(data) do
            if self.stored[k] then
                self.stored[k].value = v
            end
        end
        
        Nebula.util:Log("Config", "Configuration loaded.")
    end
    
    -- Auto-load on init
    hook.Add("Initialize", "Nebula:LoadConfig", function()
        Nebula.config:Load()
    end)
    
    -- Auto-save on shutdown
    hook.Add("ShutDown", "Nebula:SaveConfig", function()
        Nebula.config:Save()
    end)
    
    -- Network config sync
    util.AddNetworkString("Nebula:ConfigSync")
    
    function Nebula.config:SyncToClient(ply)
        net.Start("Nebula:ConfigSync")
            net.WriteTable(self.stored)
        net.Send(ply)
    end
    
    function Nebula.config:SyncToAll()
        net.Start("Nebula:ConfigSync")
            net.WriteTable(self.stored)
        net.Broadcast()
    end
end

if CLIENT then
    net.Receive("Nebula:ConfigSync", function()
        local data = net.ReadTable()
        Nebula.config.stored = data
    end)
end

-- ==========================================
-- Default Configuration Values
-- ==========================================

-- General
Nebula.config:Register("server_name", "Nebula Star Wars RP", "Server name shown in menus", {category = "General"})
Nebula.config:Register("server_description", "A Star Wars roleplay server", "Server description", {category = "General"})
Nebula.config:Register("max_characters", 3, "Maximum characters per player", {category = "General", min = 1, max = 10})
Nebula.config:Register("auto_save_interval", 300, "Auto-save interval in seconds", {category = "General", min = 60, max = 3600})

-- Economy
Nebula.config:Register("starting_credits", 500, "Starting credits for new characters", {category = "Economy", min = 0})
Nebula.config:Register("currency_name", "Credits", "Name of the currency", {category = "Economy"})
Nebula.config:Register("currency_symbol", "CR", "Currency symbol", {category = "Economy"})
Nebula.config:Register("salary_interval", 300, "Time between salary payouts (seconds)", {category = "Economy", min = 60})
Nebula.config:Register("max_credits", 10000000, "Maximum credits a player can have", {category = "Economy", min = 0})

-- Chat
Nebula.config:Register("chat_range", 500, "IC chat range in units", {category = "Chat", min = 100, max = 5000})
Nebula.config:Register("whisper_range", 150, "Whisper chat range in units", {category = "Chat", min = 50, max = 1000})
Nebula.config:Register("yell_range", 1000, "Yell chat range in units", {category = "Chat", min = 500, max = 5000})
Nebula.config:Register("enable_looc", true, "Enable LOOC (Local Out Of Character) chat", {category = "Chat"})

-- Gameplay
Nebula.config:Register("spawn_protection", 10, "Spawn protection time in seconds", {category = "Gameplay", min = 0, max = 60})
Nebula.config:Register("allow_self_damage", false, "Allow players to damage themselves", {category = "Gameplay"})
Nebula.config:Register("falldamage_scale", 1.0, "Fall damage multiplier", {category = "Gameplay", min = 0, max = 5})
Nebula.config:Register("walk_speed", 180, "Walk speed", {category = "Gameplay", min = 100, max = 300})
Nebula.config:Register("run_speed", 280, "Run speed", {category = "Gameplay", min = 200, max = 500})
Nebula.config:Register("jump_power", 200, "Jump power", {category = "Gameplay", min = 100, max = 400})

-- Roleplay
Nebula.config:Register("rpname_min_length", 3, "Minimum character name length", {category = "Roleplay", min = 2, max = 10})
Nebula.config:Register("rpname_max_length", 32, "Maximum character name length", {category = "Roleplay", min = 10, max = 64})
Nebula.config:Register("allow_name_change", false, "Allow name change after creation", {category = "Roleplay"})
Nebula.config:Register("character_wipe_time", 0, "Days until inactive characters are wiped (0 = never)", {category = "Roleplay", min = 0})
