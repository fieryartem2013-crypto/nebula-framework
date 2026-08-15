--[[
    Nebula Framework — Safety & Error Handling
    pcall/xpcall обёртки для стабильности
]]

Nebula.safety = Nebula.safety or {}
Nebula.safety.errors = {}

-- Безопасный вызов функции
function Nebula.safety:Call(func, ...)
    local args = {...}
    local success, err = xpcall(function()
        return func(unpack(args))
    end, debug.traceback)
    
    if not success then
        self:HandleError(err)
    end
    
    return success, err
end

-- Безопасный hook.Run
function Nebula.safety:HookRun(event, ...)
    local success, a, b, c = xpcall(function()
        return hook.Run(event, ...)
    end, debug.traceback)
    
    if not success then
        self:HandleError("Hook '" .. event .. "': " .. tostring(a))
        return nil
    end
    
    return a, b, c
end

-- Безопасный include
function Nebula.safety:Include(path, realm)
    local success, err = pcall(function()
        if realm == "server" or realm == "sv" then
            if SERVER then include(path) end
        elseif realm == "client" or realm == "cl" then
            if SERVER then AddCSLuaFile(path) end
            if CLIENT then include(path) end
        else
            if SERVER then AddCSLuaFile(path) end
            include(path)
        end
    end)
    
    if not success then
        self:HandleError("Include '" .. path .. "': " .. tostring(err))
    end
    
    return success
end

-- Безопасный net.Receive
function Nebula.safety:NetReceive(name, func)
    net.Receive(name, function(len, ply)
        local success, err = xpcall(function()
            func(len, ply)
        end, debug.traceback)
        
        if not success then
            self:HandleError("Net '" .. name .. "': " .. tostring(err))
        end
    end)
end

-- Безопасный timer
function Nebula.safety:Timer(id, delay, reps, func)
    timer.Create(id, delay, reps, function()
        local success, err = xpcall(func, debug.traceback)
        if not success then
            self:HandleError("Timer '" .. id .. "': " .. tostring(err))
            timer.Remove(id)
        end
    end)
end

-- Обработка ошибок
function Nebula.safety:HandleError(err)
    local errStr = tostring(err)
    
    -- Дедупликация
    if self.errors[errStr] then
        self.errors[errStr].count = self.errors[errStr].count + 1
        self.errors[errStr].lastTime = CurTime()
        return
    end
    
    self.errors[errStr] = {count = 1, lastTime = CurTime(), firstTime = CurTime()}
    
    MsgC(Color(255, 80, 80), "[NEBULA:ERROR] ", color_white, errStr .. "\n")
end

-- Получить все ошибки
function Nebula.safety:GetErrors()
    return self.errors
end

-- Очистить ошибки
function Nebula.safety:ClearErrors()
    table.Empty(self.errors)
end

-- Команда для просмотра ошибок
if SERVER then
    concommand.Add("nebula_errors", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        local errors = Nebula.safety:GetErrors()
        if table.Count(errors) == 0 then
            if IsValid(ply) then
                Nebula.util:Notify(ply, 0, "Ошибок нет!")
            else
                print("[Nebula] Ошибок нет!")
            end
            return
        end
        
        for err, data in pairs(errors) do
            local msg = string.format("[%dx] %s (последняя: %.0fс назад)", data.count, err, CurTime() - data.lastTime)
            if IsValid(ply) then
                Nebula.util:Notify(ply, 1, msg)
            else
                print("[Nebula:ERROR] " .. msg)
            end
        end
    end)
end

Nebula.util:Log("Safety", "Система безопасности загружена.")
