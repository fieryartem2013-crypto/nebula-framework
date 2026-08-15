--[[
    Nebula Framework — Admin Panel (Client)
    F3 — админ-панель для модераторов и выше
]]

Nebula.admin = Nebula.admin or {}

-- Открытие/закрытие по F3
hook.Add("PlayerButtonDown", "Nebula:AdminPanel", function(ply, button)
    if button ~= KEY_F3 then return end
    if not Nebula.perm:HasAccess(ply, "admin_menu") then return end
    
    if IsValid(Nebula.admin.panel) then
        Nebula.admin.panel:Remove()
    else
        Nebula.admin:Open()
    end
end)

function Nebula.admin:Open()
    if IsValid(self.panel) then self.panel:Remove() end
    
    local scrW, scrH = ScrW(), ScrH()
    local frameW, frameH = 800, 600
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0.1)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 15, 25, 250))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(25, 25, 40, 250))
        surface.SetDrawColor(100, 180, 255, 100)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 2)
        
        draw.SimpleText("⚙ NEBULA ADMIN PANEL", "Nebula:Font:24", w / 2, 25, Color(255, 200, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    self.panel = frame
    
    -- Табы
    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:SetPos(10, 55)
    sheet:SetSize(frameW - 20, frameH - 70)
    
    -- Таб: Игроки
    sheet:AddSheet("Игроки", self:CreatePlayerTab(sheet), "icon16/group.png")
    
    -- Таб: Сервер
    sheet:AddSheet("Сервер", self:CreateServerTab(sheet), "icon16/server.png")
    
    -- Таб: КПП/Зоны
    sheet:AddSheet("Зоны", self:CreateZoneTab(sheet), "icon16/map.png")
    
    -- Таб: Выдать предмет
    sheet:AddSheet("Предметы", self:CreateItemTab(sheet), "icon16/box.png")
    
    -- Таб: Логи
    sheet:AddSheet("Логи", self:CreateLogTab(sheet), "icon16/page_white_text.png")
    
    -- Таб: Ошибки
    sheet:AddSheet("Ошибки", self:CreateErrorTab(sheet), "icon16/error.png")
end

function Nebula.admin:CreatePlayerTab(parent)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function() end
    
    local list = vgui.Create("DListView", panel)
    list:Dock(FILL)
    list:AddColumn("Имя")
    list:AddColumn("SteamID")
    list:AddColumn("Фракция")
    list:AddColumn("Деньги")
    list:AddColumn("Здоровье")
    
    for _, ply in ipairs(player.GetAll()) do
        local charName = Nebula.character:GetName(ply)
        local faction = Nebula.faction:GetPlayerFaction(ply)
        local money = ply:GetNWInt("nebula_money", 0)
        
        list:AddLine(charName, ply:SteamID(), faction, Nebula.economy:FormatMoney(money), ply:Health())
    end
    
    -- Кнопки действий
    local btnPanel = vgui.Create("DPanel", panel)
    btnPanel:Dock(BOTTOM)
    btnPanel:SetTall(40)
    btnPanel.Paint = function() end
    
    local actions = {
        {"Телепорт", function()
            local line = list:GetSelectedLine()
            if not line then return end
            local sid = list:GetLine(line):GetValue(2)
            RunConsoleCommand("nebula_tp", sid)
        end},
        {"Кик", function()
            local line = list:GetSelectedLine()
            if not line then return end
            local sid = list:GetLine(line):GetValue(2)
            Derma_StringRequest("Кик", "Причина:", "", function(reason)
                RunConsoleCommand("nebula_kick", sid, reason)
            end)
        end},
        {"Телепорт к себе", function()
            local line = list:GetSelectedLine()
            if not line then return end
            local sid = list:GetLine(line):GetValue(2)
            RunConsoleCommand("nebula_bring", sid)
        end},
        {"Обновить", function()
            self:Open()
        end},
    }
    
    local x = 5
    for _, action in ipairs(actions) do
        local btn = vgui.Create("DButton", btnPanel)
        btn:SetPos(x, 5)
        btn:SetSize(120, 30)
        btn:SetText(action[1])
        btn:SetTextColor(color_white)
        btn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(60, 60, 80) or Color(40, 40, 55)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        btn.DoClick = action[2]
        x = x + 125
    end
    
    return panel
end

function Nebula.admin:CreateServerTab(parent)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 35))
    end
    
    local y = 20
    local info = {
        {"Сервер", Nebula.config:Get("server_name")},
        {"Игроков", #player.GetAll() .. "/" .. game.MaxPlayers()},
        {"Карта", game.GetMap()},
        {"Gamemode", GAMEMODE.Name},
        {"Фреймворк", "Nebula v" .. Nebula.version},
    }
    
    for _, line in ipairs(info) do
        draw.SimpleText(line[1] .. ":", "Nebula:Font:16", 20, y, Color(180, 180, 200))
        draw.SimpleText(line[2], "Nebula:Font:16", 200, y, color_white)
        y = y + 30
    end
    
    -- ConVars
    y = y + 20
    draw.SimpleText("ConVar:", "Nebula:Font:18", 20, y, Color(100, 180, 255))
    y = y + 30
    
    local cvars = {"walk_speed", "run_speed", "starting_money", "salary_interval", "death_penalty_percent"}
    for _, cvarName in ipairs(cvars) do
        local cvar = Nebula.convar[cvarName]
        if cvar then
            draw.SimpleText(cvarName .. ": " .. cvar:GetString(), "Nebula:Font:14", 30, y, Color(200, 200, 210))
            y = y + 22
        end
    end
    
    return panel
end

function Nebula.admin:CreateZoneTab(parent)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function() end
    
    local list = vgui.Create("DListView", panel)
    list:Dock(FILL)
    list:AddColumn("ID")
    list:AddColumn("Название")
    list:AddColumn("Тип")
    list:AddColumn("Статус")
    
    -- Заполняем из серверных данных
    for id, zone in pairs(Nebula.quarantine and Nebula.quarantine.zones or {}) do
        list:AddLine(id, zone.name or "?", zone.type or "?", "Активна")
    end
    
    return panel
end

function Nebula.admin:CreateItemTab(parent)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function() end
    
    local searchBar = vgui.Create("DTextEntry", panel)
    searchBar:Dock(TOP)
    searchBar:SetPlaceholderText("Поиск предмета...")
    searchBar:SetTall(30)
    
    local list = vgui.Create("DListView", panel)
    list:Dock(FILL)
    list:AddColumn("ID")
    list:AddColumn("Название")
    list:AddColumn("Категория")
    
    local function RefreshList(filter)
        list:Clear()
        filter = filter and string.lower(filter) or ""
        for id, item in pairs(Nebula.inventory.items) do
            if filter == "" or string.find(string.lower(item.name), filter, 1, true) then
                list:AddLine(id, item.name, item.category)
            end
        end
    end
    
    RefreshList()
    
    searchBar.OnChange = function(self)
        RefreshList(self:GetValue())
    end
    
    -- Кнопка выдать
    local giveBtn = vgui.Create("DButton", panel)
    giveBtn:Dock(BOTTOM)
    giveBtn:SetTall(35)
    giveBtn:SetText("Выдать выбранный предмет себе")
    giveBtn:SetTextColor(color_white)
    giveBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(60, 100, 60) or Color(40, 70, 40)
        draw.RoundedBox(4, 0, 0, w, h, col)
    end
    giveBtn.DoClick = function()
        local line = list:GetSelectedLine()
        if not line then return end
        local itemID = list:GetLine(line):GetValue(1)
        RunConsoleCommand("nebula_give_item", LocalPlayer():SteamID(), itemID)
    end
    
    return panel
end

function Nebula.admin:CreateLogTab(parent)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function() end
    
    local logList = vgui.Create("DListView", panel)
    logList:Dock(FILL)
    logList:AddColumn("Время")
    logList:AddColumn("Игрок")
    logList:AddColumn("Действие")
    logList:AddColumn("Детали")
    
    -- Загружаем логи (запрос к серверу)
    -- Пока заглушка
    logList:AddLine(os.date("%H:%M"), "Сервер", "Загрузка", "Ожидание...")
    
    local refreshBtn = vgui.Create("DButton", panel)
    refreshBtn:Dock(BOTTOM)
    refreshBtn:SetTall(30)
    refreshBtn:SetText("Обновить логи")
    refreshBtn.DoClick = function()
        logList:Clear()
        logList:AddLine(os.date("%H:%M"), "Сервер", "Логи", "Обновлено")
    end
    
    return panel
end

function Nebula.admin:CreateErrorTab(parent)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function() end
    
    local errList = vgui.Create("DListView", panel)
    errList:Dock(FILL)
    errList:AddColumn("Кол-во")
    errList:AddColumn("Ошибка")
    errList:AddColumn("Последняя")
    
    for err, data in pairs(Nebula.safety and Nebula.safety:GetErrors() or {}) do
        errList:AddLine(data.count, err, string.format("%.0fс назад", CurTime() - data.lastTime))
    end
    
    local clearBtn = vgui.Create("DButton", panel)
    clearBtn:Dock(BOTTOM)
    clearBtn:SetTall(30)
    clearBtn:SetText("Очистить ошибки")
    clearBtn.DoClick = function()
        if Nebula.safety then Nebula.safety:ClearErrors() end
        errList:Clear()
    end
    
    return panel
end

Nebula.util:Log("Admin", "Админ-панель загружена (F3).")
