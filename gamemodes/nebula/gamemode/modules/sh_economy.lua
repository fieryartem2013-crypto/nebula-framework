--[[
    Nebula Framework - Economy System (Shared)
    Currency and economic management
]]

Nebula.economy = Nebula.economy or {}

-- Get currency name
function Nebula.economy:GetCurrencyName()
    return Nebula.config:Get("currency_name", "Credits")
end

-- Get currency symbol
function Nebula.economy:GetCurrencySymbol()
    return Nebula.config:Get("currency_symbol", "CR")
end

-- Format money amount
function Nebula.economy:FormatMoney(amount)
    local symbol = self:GetCurrencySymbol()
    return symbol .. " " .. Nebula.util:FormatMoney(amount)
end

-- Get player's money
function Nebula.economy:GetMoney(ply)
    if not IsValid(ply) then return 0 end
    return ply:GetNWInt("nebula_money", 0)
end

-- Get player's salary
function Nebula.economy:GetSalary(ply)
    if not IsValid(ply) then return 0 end
    return ply:GetNWInt("nebula_salary", 0)
end

-- Check if player can afford amount
function Nebula.economy:CanAfford(ply, amount)
    return self:GetMoney(ply) >= amount
end
