--[[
    Nebula Framework - Animation System (Shared)
    Custom animations and gestures for RP
]]

Nebula.animation = Nebula.animation or {}
Nebula.animation.stored = Nebula.animation.stored or {}

-- Register an animation
function Nebula.animation:Register(id, data)
    self.stored[id] = {
        id = id,
        name = data.name or id,
        description = data.description or "",
        sequence = data.sequence,
        gesture = data.gesture,
        duration = data.duration or 3,
        movement = data.movement or false, -- Can move while animating
        adminOnly = data.adminOnly or false,
        
        -- For sequence-based animations
        sequenceName = data.sequenceName,
        
        -- For gesture-based animations
        gestureName = data.gestureName,
        
        -- Custom callback
        onPlay = data.onPlay,
        onCancel = data.onCancel,
    }
end

-- Get animation data
function Nebula.animation:Get(id)
    return self.stored[id]
end

-- Get all animations
function Nebula.animation:GetAll()
    return self.stored
end

-- Play animation on player
function Nebula.animation:Play(ply, animID)
    if not IsValid(ply) then return false end
    
    local anim = self:Get(animID)
    if not anim then return false end
    
    -- Check permissions
    if anim.adminOnly and not ply:IsAdmin() then
        return false
    end
    
    -- Check if already animating
    if ply:GetNWBool("nebula_animating", false) then
        self:Cancel(ply)
    end
    
    -- Set animating state
    ply:SetNWBool("nebula_animating", true)
    ply:SetNWString("nebula_currentAnim", animID)
    
    -- Play sequence
    if anim.sequenceName then
        local seqID = ply:LookupSequence(anim.sequenceName)
        if seqID and seqID >= 0 then
            ply:SetNWInt("nebula_animSeq", seqID)
            
            if SERVER then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_FLINCH, seqID, 0, true)
            end
        end
    end
    
    -- Play gesture
    if anim.gestureName then
        local actID = ply:LookupActivity(anim.gestureName)
        if actID then
            if SERVER then
                ply:RestartGesture(GESTURE_SLOT_FLINCH)
            end
        end
    end
    
    -- Auto-cancel after duration
    if anim.duration > 0 then
        timer.Create("Nebula:Anim:" .. ply:SteamID(), anim.duration, 1, function()
            if IsValid(ply) then
                self:Cancel(ply)
            end
        end)
    end
    
    -- Custom callback
    if anim.onPlay then
        anim.onPlay(ply)
    end
    
    return true
end

-- Cancel animation
function Nebula.animation:Cancel(ply)
    if not IsValid(ply) then return end
    
    ply:SetNWBool("nebula_animating", false)
    ply:SetNWString("nebula_currentAnim", "")
    ply:SetNWInt("nebula_animSeq", -1)
    
    if SERVER then
        ply:AnimResetGestureSlot(GESTURE_SLOT_FLINCH)
    end
    
    timer.Remove("Nebula:Anim:" .. ply:SteamID())
    
    local animID = ply:GetNWString("nebula_currentAnim", "")
    local anim = self:Get(animID)
    if anim and anim.onCancel then
        anim.onCancel(ply)
    end
end

-- ==========================================
-- Default Animations
-- ==========================================

-- Sitting animations
Nebula.animation:Register("sit", {
    name = "Sit",
    description = "Sit down on the ground",
    sequenceName = "sit_ground",
    duration = 0, -- Infinite until cancelled
    movement = false,
})

Nebula.animation:Register("sit_chair", {
    name = "Sit (Chair)",
    description = "Sit in a chair",
    sequenceName = "sit_zen",
    duration = 0,
    movement = false,
})

-- Standing animations
Nebula.animation:Register("wave", {
    name = "Wave",
    description = "Wave your hand",
    gestureName = "gesture_wave",
    duration = 2,
    movement = true,
})

Nebula.animation:Register("salute", {
    name = "Salute",
    description = "Military salute",
    sequenceName = "menu_combine",
    duration = 3,
    movement = false,
})

Nebula.animation:Register("surrender", {
    name = "Surrender",
    description = "Put your hands up",
    sequenceName = "photo_react_startle",
    duration = 0,
    movement = false,
})

Nebula.animation:Register("arrest", {
    name = "Arrested",
    description = "Hands behind head (arrested)",
    sequenceName = "d1_t03_chess_wonder",
    duration = 0,
    movement = false,
})

-- Interaction animations
Nebula.animation:Register("agree", {
    name = "Agree",
    description = "Nod your head",
    gestureName = "gesture_nod",
    duration = 1.5,
    movement = true,
})

Nebula.animation:Register("disagree", {
    name = "Disagree",
    description = "Shake your head",
    gestureName = "gesture_headshake",
    duration = 1.5,
    movement = true,
})

Nebula.animation:Register("bow", {
    name = "Bow",
    description = "Bow respectfully",
    sequenceName = "photo_react_blind",
    duration = 3,
    movement = false,
})

-- Combat animations
Nebula.animation:Register("kneel", {
    name = "Kneel",
    description = "Kneel down",
    sequenceName = "pose_standing_02",
    duration = 0,
    movement = false,
})

Nebula.animation:Register("lean", {
    name = "Lean",
    description = "Lean against wall",
    sequenceName = "lineidle01",
    duration = 0,
    movement = false,
})

Nebula.animation:Register("dance", {
    name = "Dance",
    description = "Dance!",
    sequenceName = "taunt_muscle",
    duration = 5,
    movement = false,
})

Nebula.animation:Register("laugh", {
    name = "Laugh",
    description = "Laugh out loud",
    gestureName = "gesture_becon",
    duration = 2,
    movement = true,
})

Nebula.animation:Register("point", {
    name = "Point",
    description = "Point forward",
    gestureName = "gesture_point",
    duration = 3,
    movement = true,
})

Nebula.util:Log("Animation", "Animation system initialized with " .. table.Count(Nebula.animation.stored) .. " animations.")
