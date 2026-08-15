--[[
    Nebula Framework - Economy System (Server)
    Server-side economic management
]]

Nebula.economy = Nebula.economy or {}

-- Network strings
util.AddNetworkString("Nebula:EconomySync")
util.AddNetworkString("Nebula:EconomyNotification")

-- Set player's money
function Nebula.economy:SetMoney(ply, amount)
    if not IsValid(ply) then return end
    
    local maxCredits = Nebula.config:Get("max_credits", 10000000)
    amount = math.Clamp(amount, 0, maxCredits)
    
    local oldAmount = self:GetMoney(ply)
    ply:SetNWInt("nebula_money", amount)
    
    -- Fire hook
    Nebula.hooks:OnMoneyChanged(ply, oldAmount, amount, "set")
    
    -- Notify client
    self:SyncToClient(ply)
end

-- Add money to player
function Nebula.economy:AddMoney(ply, amount, reason)
    if not IsValid(ply) then return end
    
    local current = self:GetMoney(ply)
    local newAmount = current + amount
    
    self:SetMoney(ply, newAmount)
    
    if amount > 0 then
        Nebula.util:Notify(ply, 0, "+" .. self:FormatMoney(amount) .. (reason and (" (" .. reason .. ")") or ""))
    end
    
    -- Log
    Nebula.database:Log(ply:SteamID(), "money_add", tostring(amount) .. " | " .. (reason or ""))
    
    return true
end

-- Remove money from player
function Nebula.economy:TakeMoney(ply, amount, reason)
    if not IsValid(ply) then return end
    
    if not self:CanAfford(ply, amount) then
        Nebula.util:Notify(ply, 1, "You can't afford " .. self:FormatMoney(amount))
        return false
    end
    
    local current = self:GetMoney(ply)
    self:SetMoney(ply, current - amount)
    
    Nebula.util:Notify(ply, 0, "-" .. self:FormatMoney(amount) .. (reason and (" (" .. reason .. ")") or ""))
    
    -- Log
    Nebula.database:Log(ply:SteamID(), "money_take", tostring(amount) .. " | " .. (reason or ""))
    
    return true
end

-- Transfer money between players
function Nebula.economy:TransferMoney(from, to, amount)
    if not IsValid(from) or not IsValid(to) then return false end
    if from == to then return false end
    
    if not self:CanAfford(from, amount) then
        Nebula.util:Notify(from, 1, "You can't afford " .. self:FormatMoney(amount))
        return false
    end
    
    if amount <= 0 then
        Nebula.util:Notify(from, 1, "Invalid amount!")
        return false
    end
    
    self:TakeMoney(from, amount, "Transfer to " .. Nebula.util:GetPlayerName(to))
    self:AddMoney(to, amount, "Transfer from " .. Nebula.util:GetPlayerName(from))
    
    Nebula.util:Notify(from, 0, "Sent " .. self:FormatMoney(amount) .. " to " .. Nebula.util:GetPlayerName(to))
    Nebula.util:Notify(to, 0, "Received " .. self:FormatMoney(amount) .. " from " .. Nebula.util:GetPlayerName(from))
    
    -- Log
    Nebula.database:Log(from:SteamID(), "money_transfer", tostring(amount) .. " to " .. to:SteamID())
    
    return true
end

-- Set player's salary
function Nebula.economy:SetSalary(ply, amount)
    if not IsValid(ply) then return end
    ply:SetNWInt("nebula_salary", amount)
end

-- Give salary to player
function Nebula.economy:PaySalary(ply)
    if not IsValid(ply) then return end
    
    local salary = self:GetSalary(ply)
    
    -- Get faction salary bonus
    local factionID = Nebula.faction:GetPlayerFaction(ply)
    local factionData = Nebula.faction:Get(factionID)
    if factionData then
        salary = salary + (factionData.salary or 0)
    end
    
    if salary > 0 then
        self:AddMoney(ply, salary, "Salary")
    end
end

-- Salary timer
function Nebula.economy:StartSalaryTimer()
    local interval = Nebula.config:Get("salary_interval", 300)
    
    timer.Create("Nebula:Salary", interval, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if Nebula.character:HasCharacter(ply) then
                self:PaySalary(ply)
            end
        end
    end)
    
    Nebula.util:Log("Economy", "Salary timer started (interval: " .. interval .. "s)")
end

-- Sync economy data to client
function Nebula.economy:SyncToClient(ply)
    if not IsValid(ply) then return end
    
    net.Start("Nebula:EconomySync")
        net.WriteUInt(self:GetMoney(ply), 32)
        net.WriteUInt(self:GetSalary(ply), 16)
    net.Send(ply)
end

-- Commands
concommand.Add("nebula_give_money", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local targetName = args[1]
    local amount = tonumber(args[2])
    
    if not targetName or not amount then
        Nebula.util:Notify(ply, 1, "Usage: nebula_give_money <player> <amount>")
        return
    end
    
    local target = Nebula.util:FindPlayer(targetName)
    if not IsValid(target) then
        Nebula.util:Notify(ply, 1, "Player not found!")
        return
    end
    
    Nebula.economy:AddMoney(target, amount, "Admin gift from " .. ply:Name())
    Nebula.util:Notify(ply, 0, "Gave " .. Nebula.economy:FormatMoney(amount) .. " to " .. target:Name())
end)

concommand.Add("nebula_set_money", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    
    local targetName = args[1]
    local amount = tonumber(args[2])
    
    if not targetName or not amount then
        Nebula.util:Notify(ply, 1, "Usage: nebula_set_money <player> <amount>")
        return
    end
    
    local target = Nebula.util:FindPlayer(targetName)
    if not IsValid(target) then
        Nebula.util:Notify(ply, 1, "Player not found!")
        return
    end
    
    Nebula.economy:SetMoney(target, amount)
    Nebula.util:Notify(ply, 0, "Set " .. target:Name() .. "'s money to " .. Nebula.economy:FormatMoney(amount))
end)

-- Start salary timer on load
hook.Add("PostGamemodeLoaded", "Nebula:StartEconomy", function()
    timer.Simple(10, function()
        Nebula.economy:StartSalaryTimer()
    end)
end)

Nebula.util:Log("Economy", "Economy system initialized.")
