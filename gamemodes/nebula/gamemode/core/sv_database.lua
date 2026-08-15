--[[
    Nebula Framework - Database System (Server)
    SQLite-based data persistence with prepared statements
]]

Nebula.database = Nebula.database or {}
Nebula.database.cache = Nebula.database.cache or {}

-- Initialize database tables
function Nebula.database:Init()
    -- Players table
    sql.Query([[
        CREATE TABLE IF NOT EXISTS nebula_players (
            steamid TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            last_join INTEGER NOT NULL
        )
    ]])
    
    -- Characters table
    sql.Query([[
        CREATE TABLE IF NOT EXISTS nebula_characters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT DEFAULT '',
            model TEXT DEFAULT '',
            faction TEXT DEFAULT 'citizen',
            class TEXT DEFAULT '',
            data TEXT NOT NULL,
            inventory TEXT DEFAULT '{}',
            money INTEGER DEFAULT 0,
            salary INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            last_played INTEGER NOT NULL,
            FOREIGN KEY (steamid) REFERENCES nebula_players(steamid)
        )
    ]])
    
    -- Inventory items table
    sql.Query([[
        CREATE TABLE IF NOT EXISTS nebula_inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            item_id TEXT NOT NULL,
            item_class TEXT NOT NULL,
            data TEXT DEFAULT '{}',
            slot INTEGER DEFAULT -1,
            quantity INTEGER DEFAULT 1,
            FOREIGN KEY (character_id) REFERENCES nebula_characters(id)
        )
    ]])
    
    -- Factions table (persistent faction data)
    sql.Query([[
        CREATE TABLE IF NOT EXISTS nebula_factions (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT DEFAULT '',
            data TEXT DEFAULT '{}'
        )
    ]])
    
    -- Server log
    sql.Query([[
        CREATE TABLE IF NOT EXISTS nebula_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            steamid TEXT,
            action TEXT NOT NULL,
            details TEXT DEFAULT ''
        )
    ]])
    
    Nebula.util:Log("Database", "Database tables initialized successfully.")
end

-- Initialize a player (called on join)
function Nebula.database:InitPlayer(ply)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    local now = os.time()
    
    -- Check if player exists
    local exists = sql.QueryValue(string.format(
        "SELECT steamid FROM nebula_players WHERE steamid = %s",
        sql.SQLStr(steamid)
    ))
    
    if not exists then
        -- New player
        sql.Query(string.format(
            "INSERT INTO nebula_players (steamid, data, created_at, last_join) VALUES (%s, '{}', %d, %d)",
            sql.SQLStr(steamid),
            now,
            now
        ))
        
        Nebula.util:Log("Database", "New player registered: " .. steamid)
    else
        -- Existing player - update last join
        sql.Query(string.format(
            "UPDATE nebula_players SET last_join = %d WHERE steamid = %s",
            now,
            sql.SQLStr(steamid)
        ))
    end
    
    -- Cache player data
    self.cache[steamid] = self:GetPlayerData(steamid) or {}
    
    -- Load characters
    local chars = self:GetCharacters(steamid)
    ply:SetNWInt("nebula_charCount", #chars)
    
    Nebula.util:Log("Database", "Player initialized: " .. steamid)
end

-- Save player data
function Nebula.database:SavePlayer(ply)
    if not IsValid(ply) then return end
    
    local steamid = ply:SteamID()
    local charID = ply:GetNWInt("nebula_charID", 0)
    
    -- Save character data if active
    if charID > 0 then
        self:SaveCharacter(charID, ply)
    end
    
    -- Save player data
    local data = self.cache[steamid] or {}
    sql.Query(string.format(
        "UPDATE nebula_players SET data = %s WHERE steamid = %s",
        sql.SQLStr(util.TableToJSON(data)),
        sql.SQLStr(steamid)
    ))
end

-- Get player data
function Nebula.database:GetPlayerData(steamid)
    if self.cache[steamid] then
        return self.cache[steamid]
    end
    
    local result = sql.QueryValue(string.format(
        "SELECT data FROM nebula_players WHERE steamid = %s",
        sql.SQLStr(steamid)
    ))
    
    if result then
        local data = util.JSONToTable(result) or {}
        self.cache[steamid] = data
        return data
    end
    
    return {}
end

-- Set player data
function Nebula.database:SetPlayerData(steamid, key, value)
    local data = self:GetPlayerData(steamid)
    data[key] = value
    self.cache[steamid] = data
end

-- ==========================================
-- Character Operations
-- ==========================================

-- Create a new character
function Nebula.database:CreateCharacter(steamid, charData)
    local now = os.time()
    local name = sql.SQLStr(charData.name or "Unknown")
    local description = sql.SQLStr(charData.description or "")
    local model = sql.SQLStr(charData.model or "models/player/group01/male_01.mdl")
    local faction = sql.SQLStr(charData.faction or "citizen")
    local data = sql.SQLStr(util.TableToJSON(charData.data or {}))
    local money = charData.money or Nebula.config:Get("starting_credits", 500)
    
    local result = sql.Query(string.format(
        "INSERT INTO nebula_characters (steamid, name, description, model, faction, data, money, created_at, last_played) VALUES (%s, %s, %s, %s, %s, %s, %d, %d, %d)",
        sql.SQLStr(steamid),
        name,
        description,
        model,
        faction,
        data,
        money,
        now,
        now
    ))
    
    if result == false then
        Nebula.util:Log("Database", "Failed to create character for " .. steamid, Color(255, 80, 80))
        return nil
    end
    
    -- Get the inserted ID
    local charID = sql.QueryValue("SELECT last_insert_rowid()")
    charID = tonumber(charID)
    
    Nebula.util:Log("Database", "Character created: " .. charData.name .. " (ID: " .. charID .. ") for " .. steamid)
    
    return charID
end

-- Get all characters for a player
function Nebula.database:GetCharacters(steamid)
    local result = sql.Query(string.format(
        "SELECT * FROM nebula_characters WHERE steamid = %s ORDER BY last_played DESC",
        sql.SQLStr(steamid)
    ))
    
    return result or {}
end

-- Get a specific character
function Nebula.database:GetCharacter(charID)
    local result = sql.QueryRow(string.format(
        "SELECT * FROM nebula_characters WHERE id = %d",
        tonumber(charID)
    ))
    
    if result then
        -- Parse JSON fields
        result.data = util.JSONToTable(result.data or "{}") or {}
        result.inventory = util.JSONToTable(result.inventory or "{}") or {}
        return result
    end
    
    return nil
end

-- Save character data
function Nebula.database:SaveCharacter(charID, ply)
    if not IsValid(ply) then return end
    
    local charData = Nebula.character:GetData(ply)
    if not charData then return end
    
    local now = os.time()
    local name = sql.SQLStr(charData.name or "Unknown")
    local description = sql.SQLStr(charData.description or "")
    local model = sql.SQLStr(charData.model or "")
    local faction = sql.SQLStr(charData.faction or "citizen")
    local class = sql.SQLStr(charData.class or "")
    local data = sql.SQLStr(util.TableToJSON(charData.data or {}))
    local money = ply:GetNWInt("nebula_money", 0)
    local salary = ply:GetNWInt("nebula_salary", 0)
    
    sql.Query(string.format(
        "UPDATE nebula_characters SET name = %s, description = %s, model = %s, faction = %s, class = %s, data = %s, money = %d, salary = %d, last_played = %d WHERE id = %d",
        name,
        description,
        model,
        faction,
        class,
        data,
        money,
        salary,
        now,
        tonumber(charID)
    ))
    
    -- Save inventory
    local inventory = Nebula.inventory:GetAll(ply)
    sql.Query(string.format(
        "UPDATE nebula_characters SET inventory = %s WHERE id = %d",
        sql.SQLStr(util.TableToJSON(inventory)),
        tonumber(charID)
    ))
end

-- Delete a character
function Nebula.database:DeleteCharacter(charID)
    -- Delete associated inventory items first
    sql.Query(string.format(
        "DELETE FROM nebula_inventory WHERE character_id = %d",
        tonumber(charID)
    ))
    
    -- Delete character
    sql.Query(string.format(
        "DELETE FROM nebula_characters WHERE id = %d",
        tonumber(charID)
    ))
    
    Nebula.util:Log("Database", "Character deleted: ID " .. charID)
end

-- Get character count for player
function Nebula.database:GetCharacterCount(steamid)
    local result = sql.QueryValue(string.format(
        "SELECT COUNT(*) FROM nebula_characters WHERE steamid = %s",
        sql.SQLStr(steamid)
    ))
    
    return tonumber(result) or 0
end

-- ==========================================
-- Inventory Operations
-- ==========================================

-- Add item to inventory
function Nebula.database:AddInventoryItem(charID, itemClass, data, quantity)
    quantity = quantity or 1
    data = data or {}
    
    local result = sql.Query(string.format(
        "INSERT INTO nebula_inventory (character_id, item_class, data, quantity) VALUES (%d, %s, %s, %d)",
        tonumber(charID),
        sql.SQLStr(itemClass),
        sql.SQLStr(util.TableToJSON(data)),
        quantity
    ))
    
    if result == false then
        return nil
    end
    
    local itemID = sql.QueryValue("SELECT last_insert_rowid()")
    return tonumber(itemID)
end

-- Remove item from inventory
function Nebula.database:RemoveInventoryItem(itemID)
    sql.Query(string.format(
        "DELETE FROM nebula_inventory WHERE id = %d",
        tonumber(itemID)
    ))
end

-- Get all inventory items for a character
function Nebula.database:GetInventoryItems(charID)
    local result = sql.Query(string.format(
        "SELECT * FROM nebula_inventory WHERE character_id = %d",
        tonumber(charID)
    ))
    
    if result then
        for _, item in ipairs(result) do
            item.data = util.JSONToTable(item.data or "{}") or {}
        end
    end
    
    return result or {}
end

-- Update item data
function Nebula.database:UpdateInventoryItem(itemID, data, quantity)
    local updates = {}
    
    if data then
        table.insert(updates, "data = " .. sql.SQLStr(util.TableToJSON(data)))
    end
    
    if quantity then
        table.insert(updates, "quantity = " .. tonumber(quantity))
    end
    
    if #updates > 0 then
        sql.Query(string.format(
            "UPDATE nebula_inventory SET %s WHERE id = %d",
            table.concat(updates, ", "),
            tonumber(itemID)
        ))
    end
end

-- ==========================================
-- Logging
-- ==========================================

function Nebula.database:Log(steamid, action, details)
    sql.Query(string.format(
        "INSERT INTO nebula_log (timestamp, steamid, action, details) VALUES (%d, %s, %s, %s)",
        os.time(),
        sql.SQLStr(steamid or ""),
        sql.SQLStr(action),
        sql.SQLStr(details or "")
    ))
end

-- Get recent logs
function Nebula.database:GetLogs(limit, offset)
    limit = limit or 50
    offset = offset or 0
    
    return sql.Query(string.format(
        "SELECT * FROM nebula_log ORDER BY id DESC LIMIT %d OFFSET %d",
        limit,
        offset
    )) or {}
end

-- ==========================================
-- Auto-save system
-- ==========================================

function Nebula.database:StartAutoSave()
    local interval = Nebula.config:Get("auto_save_interval", 300)
    
    timer.Create("Nebula:AutoSave", interval, 0, function()
        self:SaveAllPlayers()
    end)
    
    Nebula.util:Log("Database", "Auto-save started (interval: " .. interval .. "s)")
end

function Nebula.database:SaveAllPlayers()
    local count = 0
    for _, ply in ipairs(player.GetAll()) do
        self:SavePlayer(ply)
        count = count + 1
    end
    
    Nebula.util:Log("Database", "Auto-saved " .. count .. " players.")
end

-- Initialize on server start
hook.Add("Initialize", "Nebula:InitDatabase", function()
    Nebula.database:Init()
end)

hook.Add("PostGamemodeLoaded", "Nebula:StartAutoSave", function()
    timer.Simple(5, function()
        Nebula.database:StartAutoSave()
    end)
end)
