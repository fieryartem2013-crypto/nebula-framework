--[[
    Nebula Framework — Admin Commands (Server)
    Серверные команды для админ-панели
]]

-- Телепорт к игроку
concommand.Add("nebula_tp", function(ply, cmd, args)
    if not IsValid(ply) or not Nebula.perm:HasAccess(ply, "teleport") then return end
    local target = Nebula.util:FindPlayer(args[1] or "")
    if IsValid(target) then
        ply:SetPos(target:GetPos())
        Nebula.util:Notify(ply, 0, "Телепортирован к " .. target:Name())
    end
end)

-- Телепорт игрока к себе
concommand.Add("nebula_bring", function(ply, cmd, args)
    if not IsValid(ply) or not Nebula.perm:HasAccess(ply, "teleport") then return end
    local target = Nebula.util:FindPlayer(args[1] or "")
    if IsValid(target) then
        target:SetPos(ply:GetPos())
        Nebula.util:Notify(ply, 0, target:Name() .. " телепортирован к тебе.")
    end
end)

-- Кик
concommand.Add("nebula_kick", function(ply, cmd, args)
    if not IsValid(ply) or not Nebula.perm:HasAccess(ply, "kick_player") then return end
    local target = Nebula.util:FindPlayer(args[1] or "")
    local reason = args[2] or "Без причины"
    if IsValid(target) then
        target:Kick(reason)
        Nebula.util:Notify(ply, 0, target:Name() .. " кикнут: " .. reason)
    end
end)

-- Выдать предмет
concommand.Add("nebula_give_item", function(ply, cmd, args)
    if not IsValid(ply) or not Nebula.perm:HasAccess(ply, "give_item") then return end
    local target = Nebula.util:FindPlayer(args[1] or ply:SteamID())
    local itemID = args[2]
    if IsValid(target) and itemID then
        Nebula.inventory:AddItem(target, itemID)
        local itemDef = Nebula.inventory:GetItem(itemID)
        Nebula.util:Notify(ply, 0, "Выдано: " .. (itemDef and itemDef.name or itemID))
    end
end)

-- Установить ранг
concommand.Add("nebula_setrank", function(ply, cmd, args)
    if not IsValid(ply) or not Nebula.perm:HasAccess(ply, "ban_player") then return end
    local steamid = args[1]
    local rank = args[2]
    if steamid and rank then
        Nebula.perm:SetRank(steamid, rank)
        Nebula.perm:Save()
        Nebula.util:Notify(ply, 0, steamid .. " → ранг: " .. rank)
    end
end)

-- Год-мод
concommand.Add("nebula_god", function(ply, cmd, args)
    if not IsValid(ply) or not Nebula.perm:HasAccess(ply, "god_mode") then return end
    ply:GodEnable()
    Nebula.util:Notify(ply, 0, "God mode ВКЛЮЧЕН")
end)

concommand.Add("nebula_ungod", function(ply, cmd, args)
    if not IsValid(ply) then return end
    ply:GodDisable()
    Nebula.util:Notify(ply, 0, "God mode ВЫКЛЮЧЕН")
end)

Nebula.util:Log("Admin", "Админ-команды загружены.")
