--[[
    Nebula Framework - Inventory System (Client)
    Client-side inventory management and UI
]]

Nebula.inventory = Nebula.inventory or {}

-- Receive inventory sync
net.Receive("Nebula:InventorySync", function()
    local inv = net.ReadTable()
    Nebula.inventory.stored[LocalPlayer():SteamID()] = inv
end)

-- Get local player's inventory
function Nebula.inventory:GetLocalInventory()
    return self:GetAll(LocalPlayer())
end

-- Open inventory menu
function Nebula.inventory:OpenMenu()
    if IsValid(Nebula.inventory.panel) then
        Nebula.inventory.panel:Remove()
    end
    
    local inv = self:GetLocalInventory()
    local categories = self:GetCategories()
    
    local frameW, frameH = 700, 500
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
        
        draw.SimpleText("INVENTORY", "Nebula:Font:28", w / 2, 25, Color(100, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    Nebula.inventory.panel = frame
    
    -- Category tabs
    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:SetPos(10, 55)
    sheet:SetSize(frameW - 20, frameH - 70)
    
    -- All items tab
    local allPanel = self:CreateItemList(sheet, inv)
    sheet:AddSheet("All", allPanel, "icon16/box.png")
    
    -- Category tabs
    for _, category in ipairs(categories) do
        local catItems = {}
        for _, item in ipairs(inv) do
            local itemDef = self:GetItem(item.item_class)
            if itemDef and itemDef.category == category then
                table.insert(catItems, item)
            end
        end
        
        if #catItems > 0 then
            local catPanel = self:CreateItemList(sheet, catItems)
            sheet:AddSheet(category, catPanel, "icon16/folder.png")
        end
    end
end

-- Create item list panel
function Nebula.inventory:CreateItemList(parent, items)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(25, 25, 35))
    end
    
    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)
    
    -- Grid layout
    local grid = vgui.Create("DIconLayout", scroll)
    grid:Dock(FILL)
    grid:SetSpaceX(5)
    grid:SetSpaceY(5)
    
    for _, item in ipairs(items) do
        local itemDef = self:GetItem(item.item_class)
        if not itemDef then continue end
        
        local slot = grid:Add("DButton")
        slot:SetSize(100, 100)
        slot:SetText("")
        
        slot.Paint = function(self, w, h)
            local bgColor = Color(35, 35, 50, 200)
            local borderColor = Color(60, 60, 80)
            
            if self:IsHovered() then
                bgColor = Color(50, 50, 70, 220)
                borderColor = Color(100, 180, 255)
            end
            
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            -- Item name
            draw.SimpleText(
                Nebula.util:TrimString(itemDef.name, 12),
                "Nebula:Font:12",
                w / 2, h - 35,
                color_white,
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            
            -- Quantity
            if (item.quantity or 1) > 1 then
                draw.SimpleText(
                    "x" .. item.quantity,
                    "Nebula:Font:14",
                    w - 5, 5,
                    Color(255, 200, 50),
                    TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP
                )
            end
        end
        
        -- Tooltip
        slot:SetTooltip(itemDef.name .. "\n" .. itemDef.description)
        
        -- Right click menu
        slot.DoRightClick = function()
            local menu = DermaMenu()
            
            if itemDef.usable then
                menu:AddOption("Use", function()
                    net.Start("Nebula:InventoryAction")
                        net.WriteString("use")
                        net.WriteUInt(item.id, 16)
                    net.Send()
                end):SetIcon("icon16/tick.png")
            end
            
            if itemDef.droppable then
                menu:AddOption("Drop", function()
                    net.Start("Nebula:InventoryAction")
                        net.WriteString("drop")
                        net.WriteUInt(item.id, 16)
                    net.Send()
                end):SetIcon("icon16/delete.png")
            end
            
            menu:AddSpacer()
            menu:AddOption("Info", function()
                self:ShowItemInfo(item, itemDef)
            end):SetIcon("icon16/information.png")
            
            menu:Open()
        end
    end
    
    -- Empty message
    if #items == 0 then
        local emptyLabel = vgui.Create("DLabel", panel)
        emptyLabel:Dock(FILL)
        emptyLabel:SetText("No items in this category")
        emptyLabel:SetFont("Nebula:Font:20")
        emptyLabel:SetTextColor(Color(120, 120, 140))
        emptyLabel:SetContentAlignment(5)
    end
    
    return panel
end

-- Show item info popup
function Nebula.inventory:ShowItemInfo(item, itemDef)
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 200)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 25, 35, 250))
        surface.SetDrawColor(100, 180, 255, 80)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    -- Item name
    local nameLabel = vgui.Create("DLabel", frame)
    nameLabel:SetPos(10, 10)
    nameLabel:SetSize(280, 25)
    nameLabel:SetText(itemDef.name)
    nameLabel:SetFont("Nebula:Font:20")
    nameLabel:SetTextColor(Color(100, 180, 255))
    
    -- Category
    local catLabel = vgui.Create("DLabel", frame)
    catLabel:SetPos(10, 35)
    catLabel:SetSize(280, 20)
    catLabel:SetText("Category: " .. itemDef.category)
    catLabel:SetFont("Nebula:Font:14")
    catLabel:SetTextColor(Color(180, 180, 200))
    
    -- Description
    local descLabel = vgui.Create("DLabel", frame)
    descLabel:SetPos(10, 60)
    descLabel:SetSize(280, 60)
    descLabel:SetText(itemDef.description)
    descLabel:SetFont("Nebula:Font:14")
    descLabel:SetTextColor(Color(200, 200, 210))
    descLabel:SetWrap(true)
    
    -- Stats
    local statsY = 130
    draw.SimpleText("Weight: " .. itemDef.weight .. " kg", "Nebula:Font:14", 10, statsY, Color(180, 180, 200))
    
    if (item.quantity or 1) > 1 then
        draw.SimpleText("Quantity: " .. item.quantity, "Nebula:Font:14", 10, statsY + 20, Color(255, 200, 50))
    end
end

-- Bind key to open inventory
hook.Add("PlayerBindPress", "Nebula:InventoryBind", function(ply, bind, pressed)
    if pressed and bind == "gm_showspare2" then
        Nebula.inventory:OpenMenu()
        return true
    end
end)

Nebula.util:Log("Inventory", "Client inventory system initialized.")
