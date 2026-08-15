--[[
    Nebula Framework — Net Strings Registry (Server)
    ЕДИНЫЙ файл для ВСЕХ network strings.
    НИГДЕ больше не вызывайте util.AddNetworkString!
]]

Nebula.net = Nebula.net or {}
Nebula.net.registered = Nebula.net.registered or {}

function Nebula.net:Register(name)
    local fullName = "Nebula:" .. name
    if self.registered[fullName] then return fullName end
    util.AddNetworkString(fullName)
    self.registered[fullName] = true
    return fullName
end

-- ==========================================
-- ВСЕ NET STRINGS ФРЕЙМВОРКА
-- ==========================================

-- Core
Nebula.net:Register("Notification")
Nebula.net:Register("OpenMenu")
Nebula.net:Register("ConfigSync")

-- Character
Nebula.net:Register("CharacterSync")
Nebula.net:Register("CharacterCreate")
Nebula.net:Register("CharacterSelect")
Nebula.net:Register("CharacterDelete")
Nebula.net:Register("CharacterMenu")

-- Inventory
Nebula.net:Register("InventorySync")
Nebula.net:Register("InventoryAction")
Nebula.net:Register("InventoryUpdate")

-- Economy
Nebula.net:Register("EconomySync")
Nebula.net:Register("EconomyNotification")

-- Chat
Nebula.net:Register("ChatMessage")

-- Factions
Nebula.net:Register("FactionSync")

-- NPC
Nebula.net:Register("NPCInteract")
Nebula.net:Register("NPCDialogue")
Nebula.net:Register("NPCTrade")
Nebula.net:Register("NPCTradeBuy")
Nebula.net:Register("NPCTradeSell")
Nebula.net:Register("NPCClose")

-- Quest
Nebula.net:Register("QuestSync")
Nebula.net:Register("QuestAccept")
Nebula.net:Register("QuestComplete")
Nebula.net:Register("QuestUpdate")
Nebula.net:Register("QuestAbandon")

-- Craft
Nebula.net:Register("CraftStart")
Nebula.net:Register("CraftComplete")
Nebula.net:Register("CraftSync")

-- Build
Nebula.net:Register("BuildPlace")
Nebula.net:Register("BuildRemove")
Nebula.net:Register("BuildSync")

-- Admin
Nebula.net:Register("AdminPanel")
Nebula.net:Register("AdminAction")
Nebula.net:Register("AdminPlayerList")
Nebula.net:Register("AdminKick")
Nebula.net:Register("AdminBan")
Nebula.net:Register("AdminTeleport")
Nebula.net:Register("AdminSpawnNPC")
Nebula.net:Register("AdminGiveItem")
Nebula.net:Register("AdminLogs")

-- Spawn
Nebula.net:Register("SpawnSync")

-- Permissions
Nebula.net:Register("PermSync")

-- Stats (hunger/thirst)
Nebula.net:Register("StatsSync")

-- Events
Nebula.net:Register("EventNotify")
Nebula.net:Register("EventSync")

-- Wanted
Nebula.net:Register("WantedSync")
Nebula.net:Register("WantedUpdate")

-- Phone
Nebula.net:Register("PhoneMessage")
Nebula.net:Register("PhoneCall")
Nebula.net:Register("PhoneDarknet")

Nebula.util:Log("NetStrings", "Зарегистрировано " .. table.Count(Nebula.net.registered) .. " network strings.")
