--[[
    Nebula Framework - Character System (Client)
    Client-side character management and UI integration
]]

Nebula.character = Nebula.character or {}

-- Receive character sync from server
net.Receive("Nebula:CharacterSync", function()
    local charID = net.ReadUInt(16)
    local name = net.ReadString()
    local description = net.ReadString()
    local model = net.ReadString()
    local faction = net.ReadString()
    local class = net.ReadString()
    local data = net.ReadTable()
    
    Nebula.character.stored[charID] = {
        name = name,
        description = description,
        model = model,
        faction = faction,
        class = class,
        data = data,
    }
    
    -- Update local player reference
    local ply = LocalPlayer()
    if IsValid(ply) then
        ply:SetNWInt("nebula_charID", charID)
        ply:SetNWString("nebula_charName", name)
    end
end)

-- Receive character menu data
net.Receive("Nebula:CharacterMenu", function()
    local chars = net.ReadTable()
    
    -- Open the character creation/selection menu
    Nebula.character:ShowMenu(chars)
end)

-- Show character menu
function Nebula.character:ShowMenu(chars)
    chars = chars or {}
    
    -- Close existing menu
    if IsValid(Nebula.character.menuFrame) then
        Nebula.character.menuFrame:Remove()
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local frameW, frameH = 800, 600
    
    -- Main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:SetBackgroundBlur(true)
    
    frame.Paint = function(self, w, h)
        -- Dark background
        Derma_DrawBackgroundBlur(self, 0.1)
        
        -- Main panel
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 30, 250))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(30, 30, 45, 250))
        
        -- Border
        surface.SetDrawColor(100, 180, 255, 100)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 2)
        
        -- Title
        draw.SimpleText("NEBULA", "Nebula:Font:48", w / 2, 40, Color(100, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Star Wars Roleplay", "Nebula:Font:20", w / 2, 75, Color(180, 180, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    Nebula.character.menuFrame = frame
    
    -- Character slots panel
    local charPanel = vgui.Create("DPanel", frame)
    charPanel:SetPos(20, 100)
    charPanel:SetSize(frameW - 40, frameH - 130)
    charPanel.Paint = function() end
    
    local maxChars = Nebula.config:Get("max_characters", 3)
    local slotH = 120
    local padding = 10
    
    -- Display existing characters
    for i, char in ipairs(chars) do
        if i > maxChars then break end
        
        local slot = vgui.Create("DButton", charPanel)
        slot:SetPos(0, (i - 1) * (slotH + padding))
        slot:SetSize(charPanel:GetWide(), slotH)
        slot:SetText("")
        
        slot.Paint = function(self, w, h)
            local bgColor = Color(35, 35, 50, 200)
            local borderColor = Color(60, 60, 80)
            
            if self:IsHovered() then
                bgColor = Color(45, 45, 65, 220)
                borderColor = Color(100, 180, 255)
            end
            
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            -- Character info
            draw.SimpleText(char.name or "Unknown", "Nebula:Font:24", 70, 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Faction: " .. (char.faction or "Citizen"), "Nebula:Font:16", 70, 45, Color(180, 180, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("Credits: " .. Nebula.util:FormatMoney(char.money or 0), "Nebula:Font:16", 70, 65, Color(255, 200, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            -- Last played
            if char.last_played then
                local timeStr = os.date("%Y-%m-%d %H:%M", char.last_played)
                draw.SimpleText("Last: " .. timeStr, "Nebula:Font:14", w - 10, 20, Color(120, 120, 140), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end
        end
        
        slot.DoClick = function()
            -- Select this character
            net.Start("Nebula:CharacterSelect")
                net.WriteUInt(char.id, 16)
            net.Send()
            
            frame:Close()
        end
        
        -- Delete button
        local delBtn = vgui.Create("DButton", slot)
        delBtn:SetPos(slot:GetWide() - 70, slot:GetTall() - 35)
        delBtn:SetSize(60, 25)
        delBtn:SetText("")
        delBtn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(255, 80, 80, 200) or Color(200, 60, 60, 150)
            draw.RoundedBox(4, 0, 0, w, h, col)
            draw.SimpleText("Delete", "Nebula:Font:14", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        delBtn.DoClick = function()
            Derma_Query(
                "Are you sure you want to delete '" .. (char.name or "Unknown") .. "'?",
                "Delete Character",
                "Yes", function()
                    net.Start("Nebula:CharacterDelete")
                        net.WriteUInt(char.id, 16)
                    net.Send()
                end,
                "No", function() end
            )
        end
    end
    
    -- Create new character slot
    if #chars < maxChars then
        local createSlot = vgui.Create("DButton", charPanel)
        createSlot:SetPos(0, #chars * (slotH + padding))
        createSlot:SetSize(charPanel:GetWide(), slotH)
        createSlot:SetText("")
        
        createSlot.Paint = function(self, w, h)
            local bgColor = Color(30, 50, 40, 150)
            local borderColor = Color(60, 100, 80)
            
            if self:IsHovered() then
                bgColor = Color(40, 70, 50, 180)
                borderColor = Color(80, 200, 120)
            end
            
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            draw.SimpleText("+ Create New Character", "Nebula:Font:24", w / 2, h / 2, Color(80, 200, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        createSlot.DoClick = function()
            frame:Close()
            Nebula.character:ShowCreationMenu()
        end
    end
end

-- Show character creation menu
function Nebula.character:ShowCreationMenu()
    local scrW, scrH = ScrW(), ScrH()
    local frameW, frameH = 700, 550
    
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
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
        
        draw.SimpleText("CREATE CHARACTER", "Nebula:Font:32", w / 2, 30, Color(100, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local startY = 70
    local spacing = 55
    
    -- Name input
    draw.SimpleText("Name:", "Nebula:Font:18", 30, startY, color_white)
    local nameEntry = vgui.Create("DTextEntry", frame)
    nameEntry:SetPos(140, startY - 10)
    nameEntry:SetSize(frameW - 180, 30)
    nameEntry:SetPlaceholderText("First Last (e.g. Luke Skywalker)")
    nameEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 55))
        surface.SetDrawColor(80, 80, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        self:DrawTextEntryText(color_white, Color(100, 180, 255), color_white)
    end
    
    startY = startY + spacing
    
    -- Description input
    draw.SimpleText("Description:", "Nebula:Font:18", 30, startY, color_white)
    local descEntry = vgui.Create("DTextEntry", frame)
    descEntry:SetPos(140, startY - 10)
    descEntry:SetSize(frameW - 180, 60)
    descEntry:SetPlaceholderText("Character background...")
    descEntry:SetMultiline(true)
    descEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 55))
        surface.SetDrawColor(80, 80, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        self:DrawTextEntryText(color_white, Color(100, 180, 255), color_white)
    end
    
    startY = startY + spacing + 30
    
    -- Faction selection
    draw.SimpleText("Faction:", "Nebula:Font:18", 30, startY, color_white)
    local factionCombo = vgui.Create("DComboBox", frame)
    factionCombo:SetPos(140, startY - 10)
    factionCombo:SetSize(frameW - 180, 30)
    factionCombo:SetValue("Select Faction")
    
    -- Populate factions
    for id, factionData in pairs(Nebula.faction.stored) do
        factionCombo:AddChoice(factionData.name, id)
    end
    
    factionCombo.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 55))
        surface.SetDrawColor(80, 80, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    startY = startY + spacing
    
    -- Model selection
    draw.SimpleText("Model:", "Nebula:Font:18", 30, startY, color_white)
    local modelEntry = vgui.Create("DTextEntry", frame)
    modelEntry:SetPos(140, startY - 10)
    modelEntry:SetSize(frameW - 180, 30)
    modelEntry:SetPlaceholderText("models/player/...")
    modelEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 55))
        surface.SetDrawColor(80, 80, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        self:DrawTextEntryText(color_white, Color(100, 180, 255), color_white)
    end
    
    -- Model preset buttons
    local presetModels = {
        {"Rebel Pilot", "models/player/Group03/male_01.mdl"},
        {"Stormtrooper", "models/player/combine_soldier.mdl"},
        {"Civilian", "models/player/group01/male_01.mdl"},
    }
    
    local presetY = startY + 40
    for i, preset in ipairs(presetModels) do
        local btn = vgui.Create("DButton", frame)
        btn:SetPos(30 + (i - 1) * 150, presetY)
        btn:SetSize(140, 25)
        btn:SetText(preset[1])
        btn:SetTextColor(color_white)
        btn.Paint = function(self, w, h)
            local col = self:IsHovered() and Color(60, 60, 80) or Color(40, 40, 55)
            draw.RoundedBox(4, 0, 0, w, h, col)
        end
        btn.DoClick = function()
            modelEntry:SetValue(preset[2])
        end
    end
    
    -- Create button
    local createBtn = vgui.Create("DButton", frame)
    createBtn:SetPos(frameW / 2 - 100, frameH - 70)
    createBtn:SetSize(200, 45)
    createBtn:SetText("")
    createBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 180, 100) or Color(60, 150, 80)
        if self:IsDisabled() then
            col = Color(60, 60, 70)
        end
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("CREATE", "Nebula:Font:24", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    createBtn.DoClick = function()
        local name = nameEntry:GetValue()
        local desc = descEntry:GetValue()
        local _, factionID = factionCombo:GetSelected()
        local model = modelEntry:GetValue()
        
        if not name or name == "" then
            notification.AddLegacy("Please enter a name!", 1, 3)
            return
        end
        
        if not factionID then
            notification.AddLegacy("Please select a faction!", 1, 3)
            return
        end
        
        if not model or model == "" then
            model = "models/player/group01/male_01.mdl"
        end
        
        -- Send to server
        net.Start("Nebula:CharacterCreate")
            net.WriteString(name)
            net.WriteString(desc or "")
            net.WriteString(model)
            net.WriteString(factionID)
        net.Send()
        
        frame:Close()
    end
end
