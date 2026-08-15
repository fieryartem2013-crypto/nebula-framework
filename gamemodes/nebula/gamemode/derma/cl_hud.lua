--[[
    Nebula Framework - HUD System
    Star Wars themed heads-up display
]]

Nebula.hud = Nebula.hud or {}

-- HUD Configuration
Nebula.hud.config = {
    -- Position offsets from bottom-left
    margin = 20,
    padding = 10,
    
    -- Health bar
    healthBarW = 250,
    healthBarH = 20,
    healthColor = Color(80, 200, 80),
    healthColorLow = Color(255, 100, 50),
    healthColorCrit = Color(255, 50, 50),
    
    -- Armor bar
    armorBarW = 250,
    armorBarH = 12,
    armorColor = Color(100, 150, 255),
    
    -- Money display
    moneyColor = Color(255, 200, 50),
    
    -- Info panel
    infoBg = Color(20, 20, 30, 200),
    infoBorder = Color(60, 60, 80, 150),
}

-- Main HUD drawing
hook.Add("HUDPaint", "Nebula:DrawHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Hide default HUD elements
    -- (handled by HUDShouldDraw hook)
    
    local cfg = Nebula.hud.config
    local margin = cfg.margin
    local scrH = ScrH()
    
    -- Base position (bottom-left)
    local baseX = margin
    local baseY = scrH - margin
    
    -- Draw info panel background
    local panelW = 280
    local panelH = 120
    local panelX = baseX
    local panelY = baseY - panelH
    
    -- Panel background
    draw.RoundedBox(8, panelX, panelY, panelW, panelH, cfg.infoBg)
    surface.SetDrawColor(cfg.infoBorder)
    surface.DrawOutlinedRect(panelX, panelY, panelW, panelH, 1)
    
    -- Health bar
    local health = ply:Health()
    local maxHealth = ply:GetMaxHealth()
    local healthFrac = math.Clamp(health / maxHealth, 0, 1)
    
    local barX = panelX + cfg.padding
    local barY = panelY + cfg.padding
    
    -- Health label
    draw.SimpleText("HP", "Nebula:Font:HUD:Small", barX, barY, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    -- Health bar background
    draw.RoundedBox(3, barX + 25, barY, cfg.healthBarW, cfg.healthBarH, Color(40, 40, 50))
    
    -- Health bar fill
    local healthColor = cfg.healthColor
    if healthFrac < 0.25 then
        healthColor = cfg.healthColorCrit
    elseif healthFrac < 0.5 then
        healthColor = cfg.healthColorLow
    end
    
    if healthFrac > 0 then
        draw.RoundedBox(3, barX + 25, barY, cfg.healthBarW * healthFrac, cfg.healthBarH, healthColor)
    end
    
    -- Health text
    draw.SimpleText(health .. "/" .. maxHealth, "Nebula:Font:HUD:Small", barX + 25 + cfg.healthBarW + 5, barY + 2, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    -- Armor bar
    local armor = ply:Armor()
    if armor > 0 then
        local armorY = barY + cfg.healthBarH + 5
        local armorFrac = math.Clamp(armor / 100, 0, 1)
        
        draw.SimpleText("AP", "Nebula:Font:HUD:Small", barX, armorY, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.RoundedBox(3, barX + 25, armorY, cfg.armorBarW, cfg.armorBarH, Color(40, 40, 50))
        draw.RoundedBox(3, barX + 25, armorY, cfg.armorBarW * armorFrac, cfg.armorBarH, cfg.armorColor)
        draw.SimpleText(tostring(armor), "Nebula:Font:HUD:Small", barX + 25 + cfg.armorBarW + 5, armorY + 1, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    -- Character info
    local infoY = barY + cfg.healthBarH + (armor > 0 and 30 or 10)
    
    -- Character name
    local charName = Nebula.character:GetName(ply)
    draw.SimpleText(charName, "Nebula:Font:HUD", barX, infoY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    
    -- Faction
    local factionID = Nebula.faction:GetPlayerFaction(ply)
    local factionData = Nebula.faction:Get(factionID)
    if factionData then
        draw.SimpleText(factionData.name, "Nebula:Font:HUD:Small", barX, infoY + 22, factionData.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    -- Money (top-right)
    local money = ply:GetNWInt("nebula_money", 0)
    local symbol = Nebula.economy:GetCurrencySymbol()
    local moneyText = symbol .. " " .. Nebula.util:FormatMoney(money)
    
    local moneyX = ScrW() - margin
    local moneyY = margin
    
    draw.SimpleText(moneyText, "Nebula:Font:HUD:Large", moneyX, moneyY, cfg.moneyColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    
    -- Server name (top-center)
    local serverName = Nebula.config:Get("server_name", "Nebula RP")
    draw.SimpleText(serverName, "Nebula:Font:HUD", ScrW() / 2, margin, Color(100, 180, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    
    -- Animation indicator
    if ply:GetNWBool("nebula_animating", false) then
        local animID = ply:GetNWString("nebula_currentAnim", "")
        local anim = Nebula.animation:Get(animID)
        if anim then
            draw.SimpleText("Anim: " .. anim.name, "Nebula:Font:HUD:Small", ScrW() / 2, margin + 25, Color(200, 150, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end
    end
end)

-- Hide default HUD elements
local hideElements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudCrosshair"] = false, -- Keep crosshair
    ["CHudDamageIndicator"] = false, -- Keep damage indicator
}

hook.Add("HUDShouldDraw", "Nebula:HideDefaultHUD", function(name)
    if hideElements[name] then
        return false
    end
end)

-- 3D2D overhead info for other players
hook.Add("PostPlayerDraw", "Nebula:PlayerOverhead", function(ply)
    if ply == LocalPlayer() then return end
    if not ply:Alive() then return end
    
    local myPos = LocalPlayer():GetPos()
    local theirPos = ply:GetPos()
    
    -- Only show if close enough
    if myPos:DistToSqr(theirPos) > 40000 then return end -- 200 units
    
    -- Get character name
    local charName = Nebula.character:GetName(ply)
    local factionID = Nebula.faction:GetPlayerFaction(ply)
    local factionData = Nebula.faction:Get(factionID)
    local factionName = factionData and factionData.name or "Unknown"
    local factionColor = factionData and factionData.color or color_white
    
    -- Calculate position above head
    local headPos = ply:GetPos() + Vector(0, 0, 80)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    -- Draw 3D2D
    local dist = myPos:Distance(theirPos)
    local scale = math.Clamp(dist / 100, 0.5, 2) * 0.05
    
    cam.Start3D2D(headPos, ang, scale)
        -- Name
        draw.SimpleText(charName, "Nebula:Font:24", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Faction
        draw.SimpleText(factionName, "Nebula:Font:16", 0, 25, factionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end)

MsgC(Color(100, 180, 255), "[Nebula] ", color_white, "HUD loaded.\n")
