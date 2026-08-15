--[[
    Nebula Framework - World Item Entity (Client)
    Rendering and UI for world items
]]

include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    -- Draw floating name and info
    local pos = self:GetPos() + Vector(0, 0, 15)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    local dist = LocalPlayer():GetPos():Distance(self:GetPos())
    if dist > 300 then return end
    
    local alpha = math.Clamp(255 - (dist / 300) * 255, 50, 255)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Item name
        local name = self:GetNWString("nebula_itemName", "Unknown")
        draw.SimpleText(name, "Nebula:Font:24", 0, 0, Color(100, 180, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Quantity
        local qty = self:GetNWInt("nebula_itemQuantity", 1)
        if qty > 1 then
            draw.SimpleText("x" .. qty, "Nebula:Font:18", 0, 25, Color(255, 200, 50, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Pickup hint
        draw.SimpleText("[E] Pick Up", "Nebula:Font:16", 0, 45, Color(200, 200, 220, alpha * 0.7), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
