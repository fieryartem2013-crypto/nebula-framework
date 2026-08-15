--[[
    Nebula Framework - Inventory Derma (Client)
    Inventory UI panel (additional panels)
]]

-- Item tooltip panel
function Nebula.inventory:CreateTooltip(itemDef, itemData)
    local tooltip = vgui.Create("DPanel")
    tooltip:SetSize(250, 150)
    tooltip.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(25, 25, 35, 250))
        surface.SetDrawColor(100, 180, 255, 80)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Item name
        draw.SimpleText(itemDef.name, "Nebula:Font:18", 10, 10, Color(100, 180, 255))
        
        -- Category
        draw.SimpleText(itemDef.category, "Nebula:Font:12", 10, 32, Color(150, 150, 170))
        
        -- Divider
        surface.SetDrawColor(60, 60, 80)
        surface.DrawLine(10, 48, w - 10, 48)
        
        -- Description
        draw.DrawText(itemDef.description, "Nebula:Font:14", 10, 55, Color(200, 200, 210), TEXT_ALIGN_LEFT)
        
        -- Weight
        draw.SimpleText("Weight: " .. itemDef.weight .. " kg", "Nebula:Font:12", 10, h - 25, Color(150, 150, 170))
        
        -- Quantity
        if (itemData.quantity or 1) > 1 then
            draw.SimpleText("Qty: " .. itemData.quantity, "Nebula:Font:12", w - 10, h - 25, Color(255, 200, 50), TEXT_ALIGN_RIGHT)
        end
    end
    
    return tooltip
end

-- Trade panel (between players)
function Nebula.inventory:OpenTradeMenu(otherPly)
    if IsValid(Nebula.inventory.tradeFrame) then
        Nebula.inventory.tradeFrame:Remove()
    end
    
    local frameW, frameH = 800, 500
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
        
        draw.SimpleText("TRADE", "Nebula:Font:28", w / 2, 20, Color(100, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Trading with: " .. Nebula.character:GetName(otherPly), "Nebula:Font:16", w / 2, 50, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    Nebula.inventory.tradeFrame = frame
    
    -- Left panel (your items)
    local leftPanel = vgui.Create("DPanel", frame)
    leftPanel:SetPos(10, 70)
    leftPanel:SetSize(frameW / 2 - 15, frameH - 130)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 35))
        draw.SimpleText("Your Offer", "Nebula:Font:16", w / 2, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Right panel (their items)
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:SetPos(frameW / 2 + 5, 70)
    rightPanel:SetSize(frameW / 2 - 15, frameH - 130)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 35))
        draw.SimpleText(Nebula.character:GetName(otherPly) .. "'s Offer", "Nebula:Font:16", w / 2, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Confirm button
    local confirmBtn = vgui.Create("DButton", frame)
    confirmBtn:SetPos(frameW / 2 - 75, frameH - 50)
    confirmBtn:SetSize(150, 35)
    confirmBtn:SetText("")
    confirmBtn.Paint = function(self, w, h)
        local col = self:IsHovered() and Color(80, 180, 100) or Color(60, 150, 80)
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("CONFIRM TRADE", "Nebula:Font:16", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "Inventory Derma loaded.\n")
