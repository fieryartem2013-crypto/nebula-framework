--[[
    Nebula Framework - Utility Library
    Shared utility functions
]]

Nebula.util = Nebula.util or {}

-- Color constants
Nebula.util.Colors = {
    primary = Color(100, 180, 255),
    secondary = Color(255, 180, 50),
    success = Color(80, 200, 80),
    danger = Color(255, 80, 80),
    warning = Color(255, 200, 50),
    info = Color(100, 200, 255),
    dark = Color(30, 30, 40),
    darker = Color(20, 20, 30),
    light = Color(220, 220, 230),
    text = Color(240, 240, 240),
    textDark = Color(40, 40, 50),
    accent = Color(0, 150, 255),
    border = Color(60, 60, 70),
}

-- Get a color by name
function Nebula.util:GetColor(name)
    return self.Colors[name] or color_white
end

-- Format money
function Nebula.util:FormatMoney(amount)
    if amount >= 1000000 then
        return string.format("%.1fM", amount / 1000000)
    elseif amount >= 1000 then
        return string.format("%.1fK", amount / 1000)
    end
    return tostring(amount)
end

-- Get player's full name (character name or Steam name)
function Nebula.util:GetPlayerName(ply)
    if not IsValid(ply) then return "Unknown" end
    
    local charData = Nebula.character:GetData(ply)
    if charData and charData.name then
        return charData.name
    end
    
    return ply:Name()
end

-- Find player by name (partial match)
function Nebula.util:FindPlayer(name)
    if not name or name == "" then return nil end
    
    name = string.lower(name)
    
    -- Exact SteamID match
    for _, ply in ipairs(player.GetAll()) do
        if string.lower(ply:SteamID()) == name then
            return ply
        end
    end
    
    -- Exact name match
    for _, ply in ipairs(player.GetAll()) do
        if string.lower(self:GetPlayerName(ply)) == name then
            return ply
        end
    end
    
    -- Partial name match
    local found = {}
    for _, ply in ipairs(player.GetAll()) do
        if string.find(string.lower(self:GetPlayerName(ply)), name, 1, true) then
            table.insert(found, ply)
        end
    end
    
    if #found == 1 then
        return found[1]
    end
    
    return nil
end

-- Safe include for other addons
function Nebula.util:SafeInclude(path)
    local success, err = pcall(function()
        if file.Exists(path, "LUA") then
            include(path)
        end
    end)
    
    if not success then
        MsgC(Color(255, 80, 80), "[Nebula] ", color_white, "Error including " .. path .. ": " .. tostring(err) .. "\n")
    end
end

-- Check if player has access level
function Nebula.util:HasAccess(ply, level)
    if not IsValid(ply) then return false end
    
    -- Superadmin always has access
    if ply:IsSuperAdmin() then return true end
    
    local accessLevels = {
        ["user"] = 0,
        ["moderator"] = 1,
        ["admin"] = 2,
        ["superadmin"] = 3,
        ["owner"] = 4,
    }
    
    local requiredLevel = accessLevels[level] or 0
    local playerLevel = 0
    
    if ply:IsAdmin() then
        playerLevel = 2
    end
    
    -- Check for custom access via NWVar or similar
    local customAccess = ply:GetNWString("nebula_access", "user")
    playerLevel = math.max(playerLevel, accessLevels[customAccess] or 0)
    
    return playerLevel >= requiredLevel
end

-- Log message to console
function Nebula.util:Log(category, message, color)
    color = color or self.Colors.primary
    MsgC(
        color, "[Nebula:" .. category .. "] ",
        color_white, message .. "\n"
    )
end

-- Send notification to player
function Nebula.util:Notify(ply, msgType, message, duration)
    duration = duration or 5
    
    if CLIENT then
        -- Use notification library
        notification.AddLegacy(message, msgType, duration)
        surface.PlaySound("buttons/button15.wav")
        return
    end
    
    -- Server-side: send to client
    net.Start("Nebula:Notification")
        net.WriteUInt(msgType, 3)
        net.WriteString(message)
        net.WriteUInt(duration, 8)
    net.Send(ply)
end

-- Send notification to all players
function Nebula.util:NotifyAll(msgType, message, duration)
    for _, ply in ipairs(player.GetAll()) do
        self:Notify(ply, msgType, message, duration)
    end
end

-- Random chance (percentage)
function Nebula.util:Chance(percent)
    return math.random(100) <= percent
end

-- Clamp a value between min and max
function Nebula.util:Clamp(value, min, max)
    return math.Clamp(value, min, max)
end

-- Generate unique ID
function Nebula.util:GenerateUID()
    return string.format("%s-%s-%s",
        string.format("%06x", math.random(0, 16777215)),
        string.format("%06x", math.random(0, 16777215)),
        string.format("%06x", math.random(0, 16777215))
    )
end

-- Check if string is valid SteamID
function Nebula.util:IsValidSteamID(steamid)
    return string.match(steamid, "STEAM_%d:%d:%d+") ~= nil
end

-- Get distance between two vectors
function Nebula.util:GetDistance(pos1, pos2)
    return pos1:Distance(pos2)
end

-- Check if player is in range of position
function Nebula.util:IsInRange(ply, pos, range)
    if not IsValid(ply) then return false end
    return ply:GetPos():DistToSqr(pos) <= range * range
end

-- Table utilities
function Nebula.util:TableCopy(tbl)
    return table.Copy(tbl)
end

function Nebula.util:TableMerge(base, override)
    local result = table.Copy(base)
    for k, v in pairs(override) do
        if istable(v) and istable(result[k]) then
            result[k] = self:TableMerge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- String utilities
function Nebula.util:TrimString(str, maxLen)
    if string.len(str) > maxLen then
        return string.sub(str, 1, maxLen) .. "..."
    end
    return str
end

function Nebula.util:TitleCase(str)
    return string.gsub(str, "(%a)([%w_']*)", function(first, rest)
        return string.upper(first) .. rest
    end)
end

-- Time formatting
function Nebula.util:FormatTime(seconds)
    if seconds < 60 then
        return seconds .. "s"
    elseif seconds < 3600 then
        return math.floor(seconds / 60) .. "m " .. (seconds % 60) .. "s"
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        return hours .. "h " .. mins .. "m"
    end
end

-- Network string registration
if SERVER then
    util.AddNetworkString("Nebula:Notification")
    util.AddNetworkString("Nebula:OpenMenu")
    util.AddNetworkString("Nebula:CharacterCreate")
    util.AddNetworkString("Nebula:CharacterSelect")
    util.AddNetworkString("Nebula:CharacterDelete")
    util.AddNetworkString("Nebula:InventorySync")
    util.AddNetworkString("Nebula:InventoryAction")
    util.AddNetworkString("Nebula:EconomySync")
    util.AddNetworkString("Nebula:ChatMessage")
    util.AddNetworkString("Nebula:FactionSync")
end

if CLIENT then
    net.Receive("Nebula:Notification", function()
        local msgType = net.ReadUInt(3)
        local message = net.ReadString()
        local duration = net.ReadUInt(8)
        
        notification.AddLegacy(message, msgType, duration)
        surface.PlaySound("buttons/button15.wav")
    end)
end
