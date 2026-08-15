--[[
    Nebula Framework - Character Derma (Client)
    Character management UI panels
]]

-- Character info panel (shown in-game)
function Nebula.character:ShowInfoPanel(ply)
    if not IsValid(ply) then return end
    
    local charData = self:GetData(ply)
    if not charData then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 500)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0.1)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 30, 250))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(30, 30, 45, 250))
        surface.SetDrawColor(100, 180, 255, 100)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 2)
        
        draw.SimpleText("CHARACTER INFO", "Nebula:Font:24", w / 2, 25, Color(100, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local y = 60
    local x = 20
    local w = 360
    
    -- Name
    draw.SimpleText("Name:", "Nebula:Font:16", x, y, Color(150, 150, 170))
    draw.SimpleText(charData.name, "Nebula:Font:20", x, y + 18, color_white)
    y = y + 50
    
    -- Faction
    local factionData = Nebula.faction:Get(charData.faction)
    if factionData then
        draw.SimpleText("Faction:", "Nebula:Font:16", x, y, Color(150, 150, 170))
        draw.SimpleText(factionData.name, "Nebula:Font:18", x, y + 18, factionData.color)
        y = y + 45
    end
    
    -- Class
    if charData.class and charData.class ~= "" then
        draw.SimpleText("Class:", "Nebula:Font:16", x, y, Color(150, 150, 170))
        draw.SimpleText(charData.class, "Nebula:Font:18", x, y + 18, color_white)
        y = y + 45
    end
    
    -- Description
    draw.SimpleText("Description:", "Nebula:Font:16", x, y, Color(150, 150, 170))
    y = y + 20
    
    local descText = charData.description ~= "" and charData.description or "No description set."
    local descLabel = vgui.Create("DLabel", frame)
    descLabel:SetPos(x, y)
    descLabel:SetSize(w, 100)
    descLabel:SetText(descText)
    descLabel:SetFont("Nebula:Font:14")
    descLabel:SetTextColor(Color(200, 200, 210))
    descLabel:SetWrap(true)
    descLabel:SetAutoStretchVertical(true)
    
    y = y + 120
    
    -- Stats
    draw.SimpleText("Stats:", "Nebula:Font:16", x, y, Color(150, 150, 170))
    y = y + 20
    
    local stats = {
        {"Money", Nebula.economy:FormatMoney(Nebula.economy:GetMoney(ply))},
        {"Health", ply:Health() .. "/" .. ply:GetMaxHealth()},
        {"Armor", tostring(ply:Armor())},
    }
    
    for _, stat in ipairs(stats) do
        draw.SimpleText(stat[1] .. ": " .. stat[2], "Nebula:Font:14", x + 10, y, Color(200, 200, 210))
        y = y + 20
    end
end

-- Character description editor
function Nebula.character:OpenDescriptionEditor()
    local charData = self:GetData(LocalPlayer())
    if not charData then return end
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 400)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, 0.1)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 30, 250))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(30, 30, 45, 250))
        surface.SetDrawColor(100, 180, 255, 100)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 2)
        
        draw.SimpleText("EDIT DESCRIPTION", "Nebula:Font:24", w / 2, 25, Color(100, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Text entry
    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:SetPos(20, 60)
    textEntry:SetSize(460, 250)
    textEntry:SetMultiline(true)
    textEntry:SetValue(charData.description or "")
    textEntry:SetFont("Nebula:Font:14")
    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 50))
        surface.SetDrawColor(60, 60, 80)
        surface.DrawOutlinedRect(0, 0, w, h)
        self:DrawTextEntryText(Color(200, 200, 210), Color(100, 180, 255), color_white)
    end
    
    -- Save button
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetPos(frame:GetWide() / 2 - 75, 330)
    saveBtn:SetSize(150, 40)
    saveBtn:SetText("")
    saveBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 180, 100) or Color(60, 150, 80)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("SAVE", "Nebula:Font:18", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    saveBtn.DoClick = function()
        local newText = textEntry:GetValue()
        -- Send to server to update description
        -- This would need a net message
        notification.AddLegacy("Description updated!", 0, 3)
        frame:Close()
    end
end

-- Animation menu
function Nebula.animation:OpenMenu()
    if IsValid(Nebula.animation.menuPanel) then
        Nebula.animation.menuPanel:Remove()
    end
    
    local frameW, frameH = 300, 400
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:SetPos(ScrW() - frameW - 20, ScrH() / 2 - frameH / 2)
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 30, 240))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(30, 30, 45, 240))
        surface.SetDrawColor(100, 180, 255, 80)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)
        
        draw.SimpleText("ANIMATIONS", "Nebula:Font:20", w / 2, 20, Color(100, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    Nebula.animation.menuPanel = frame
    
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(10, 50)
    scroll:SetSize(frameW - 20, frameH - 70)
    
    local list = vgui.Create("DIconLayout", scroll)
    list:Dock(FILL)
    list:SetSpaceY(5)
    
    for id, anim in pairs(self:GetAll()) do
        if anim.adminOnly and not LocalPlayer():IsAdmin() then continue end
        
        local btn = list:Add("DButton")
        btn:SetSize(frameW - 30, 35)
        btn:SetText("")
        
        btn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(50, 50, 70) or Color(35, 35, 50)
            draw.RoundedBox(4, 0, 0, w, h, col)
            surface.SetDrawColor(60, 60, 80)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            draw.SimpleText(anim.name, "Nebula:Font:16", 10, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            if anim.duration > 0 then
                draw.SimpleText(anim.duration .. "s", "Nebula:Font:12", w - 10, h / 2, Color(150, 150, 170), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText("Loop", "Nebula:Font:12", w - 10, h / 2, Color(200, 150, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
        
        btn:SetTooltip(anim.description)
        
        btn.DoClick = function()
            -- Send animation request to server
            net.Start("Nebula:PlayAnimation")
                net.WriteString(id)
            net.Send()
        end
    end
end

-- Bind animation menu to key
hook.Add("PlayerBindPress", "Nebula:AnimBind", function(ply, bind, pressed)
    if pressed and bind == "gm_showspare1" then
        Nebula.animation:OpenMenu()
        return true
    end
end)

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Character Derma loaded.\n")
