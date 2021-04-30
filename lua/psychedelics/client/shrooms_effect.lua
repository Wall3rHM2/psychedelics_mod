local lib = include("psychedelics/libs/cl/hallucinations.lua")
local duration = {onset = 15, total = 180} -- effect time = hours of the effect irl*30
-- eg.:3*30=90		 --->3 hours		 >30 constant value
local tripPresets = {hallucinations = false, fov = false}
-- presets used to set which components the random trip will have
local onsetStr = "psychedelicsShroomOnset"
local totalStr = "psychedelicsShroomTotal"
local ug = 0
local o = 0 -- Variable used to lerp the DrawMaterialOverlay
local maxOverlay = 0
local multBlur = 0 -- used to multiply the motion blur
local fov = 75 -- 75 is the default value
local active = false
local components = {
    "$pp_colour_colour", "$pp_colour_mulr", "$pp_colour_mulg", "$pp_colour_mulb"
}
local cModify = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0.1,
    ["$pp_colour_mulg"] = 0.1,
    ["$pp_colour_mulb"] = 0.1
}

local function tryRemoveAll()
    local doIt = true
    if cModify["$pp_colour_colour"] >= 1.01 or cModify["$pp_colour_colour"] < 1 then
        doIt = false
    end
    for i = 2, #components do
        i = components[i]
        local var = cModify[i]
        if var >= 0.11 then
            doIt = false
        elseif var <= 0.09 then
            doIt = false
        end
    end
    if o > 0 then doIt = false end
    if fov ~= 75 then doIt = false end
    if doIt then
        hook.Remove("RenderScreenspaceEffects", "psychedelicsShroomEffect")
        hook.Remove("CalcView", "psychedelicsShroomCalcView")
        maxOverlay = 0
        multBlur = 0
        active = false
    end
end

local function instaRemove() -- called when the player dies to instantly remove the effects
    ug = 0
    o = 0
    maxOverlay = 0
    multBlur = 0
    fov = 75
    active = false
    tripPresets.hallucinations = false -- return presets to default
    tripPresets.fov = false
    cModify["$pp_colour_colour"] = 1
    cModify["$pp_colour_mulr"] = 0.1
    cModify["$pp_colour_mulg"] = 0.1
    cModify["$pp_colour_mulb"] = 0.1
    for i = 1, #components do
        timer.Remove("psychedelics" .. components[i] .. "Shroom")
    end
    hook.Remove("RenderScreenspaceEffects", "psychedelicsShroomEffect")
    hook.Remove("CalcView", "psychedelicsShroomCalcView")
    timer.Remove("psychedelicsAutoCleanShroom")
    timer.Remove("psychedelicsHallucinationShroom")
    timer.Remove("psychedelicsChangeFOVShroom")
    timer.Remove("psychedelicsHoldFOVShroom")
    timer.Remove("psychedelicsWaitFOVShroom")
    timer.Remove(onsetStr)
end

local function goDefaultColors()
    local proceed = false
    local colour = cModify["$pp_colour_colour"]

    if colour >= 1.01 then
        cModify["$pp_colour_colour"] = (colour * 100 - 1) / 100
        proceed = true -- uuuh bugs; so we can only use >=1.01
    elseif colour < 1 then
        cModify["$pp_colour_colour"] = (colour * 100 + 1) / 100
        proceed = true
    end

    for i = 2, #components do
        i = components[i]
        local var = cModify[i]
        if var >= 0.11 then
            cModify[i] = (var * 100 - 1) / 100
            proceed = true
            var = cModify[i]
        elseif var <= 0.09 then
            cModify[i] = (var * 100 + 1) / 100
            proceed = true
            var = cModify[i]
        end
    end

    if proceed == false then
        tryRemoveAll()
        return
    end
    timer.Simple(0.01, goDefaultColors)
end

local function clearShroom(mult)
    timer.Remove("psychedelicsAutoCleanShroom") -- in case if it was called by death
    for i = 1, #components do
        timer.Remove("psychedelics" .. components[i] .. "Shroom")
    end
    goDefaultColors()
    tripPresets.hallucinations = false -- return presets to default
    tripPresets.fov = false
    ug = 0
end

local function hallucination()
    if ug == 0 then return end
    if tripPresets.hallucinations == false then return end

    local o = o / 1000 -- converts to the real value we will use
    if o >= 0.6 then
        lib.randomHallucination("Shroom")
        timer.Create("psychedelicsHallucinationShroom", 22, 1, hallucination)
    else
        timer.Create("psychedelicsHallucinationShroom", 1, 1, hallucination)
    end
end

local function lerpComponent(component, target) -- uses the string of the name of the component and the desired value to lerp to
    local value = cModify[component]
    local sum = true
    local repetitions

    if target > value then
        repetitions = target * 100 - value * 100
    elseif target < value then
        repetitions = value * 100 - target * 100
        sum = false
    else
        return
    end

    timer.Create("psychedelics" .. component .. "Shroom", 0.01, repetitions,
                 function()
        local value = cModify[component]
        if sum then
            cModify[component] = (value * 100 + 1) / 100 -- we must transform the float numbers to int to avoid bugs
        else
            cModify[component] = (value * 100 - 1) / 100
        end
    end)
end

local function lerpOverlay()
    local max = 1000

    if ug == 0 and o <= 0 then
        tryRemoveAll()
        return
    end

    if ug ~= 0 then
        if o < max then o = o + 1 end
    elseif ug == 0 then
        if o <= 0 then
            o = 0
        elseif o > 0 then
            o = o - 1
        end
    end

    timer.Simple(0.01, lerpOverlay) -- effects develops quicker than lsd
end


local function shroomColors()
    if ug == 0 then return end -- stops changing colors when the effect is over
    local colour = cModify["$pp_colour_colour"]
    local mulr = cModify["$pp_colour_mulr"]
    local mulg = cModify["$pp_colour_mulg"]
    local mulb = cModify["$pp_colour_mulb"]
    local isChanging = false

    timer.Simple(0.01, shroomColors)
    for i = 1, #components do
        if timer.Exists("psychedelics" .. components[i] .. "Shroom") then
            isChanging = true
        end
    end
    if isChanging then return end

    local x = ug / 10 -- value used 
    local shouldChange = math.random(1, 100) <= x
    local whichComponent = math.random(1, #components)
    local whichValue = (math.random(-30, 30) * (ug / 100)) / 10
    local overValue = false -- gets if the component have a higher or lower value than acceptable
    local currentValue = cModify[components[whichComponent]]

    if currentValue >= 10 and whichValue > 0 then
        overValue = true
    elseif currentValue <= -10 and whichValue < 0 then
        overValue = true
    end

    if shouldChange and overValue == false then
        if whichComponent ~= "$pp_colour_colour" then
            whichValue = whichValue / 10
        end
        lerpComponent(components[whichComponent], whichValue)
    end
end

local function lerpFOV()
    if fov == 75 and ug == 0 then
        tryRemoveAll()
        hook.Remove("CalcView", "psychedelicsShroomCalcView")
        return
    end

    if timer.Exists("psychedelicsChangeFOVShroom") == false and timer.Exists("psychedelicsHoldFOVShroom") == false then
        local o = o / 1000 -- converts to real the value we will use

        if fov == 75 and timer.Exists("psychedelicsWaitFOVShroom") == false and o >= 0.6 then
            local side = math.random(0, 1)
            local mult = math.random(10, 400) -- multiplier of FOV changer
            local duration = math.random(1, 14) -- duration of applied change in FOV
            local wait = math.random(1, 14) -- how much time is needed to wait for another change in FOV
            timer.Create("psychedelicsHoldFOVShroom", mult / 100 + duration, 1, function() end)
            timer.Create("psychedelicsWaitFOVShroom", mult / 100 + duration + wait, 1, function() end)
            if side == 0 then
                timer.Create("psychedelicsChangeFOVShroom", 0.01, mult,
                             function() fov = fov + 0.1 end)
            else
                timer.Create("psychedelicsChangeFOVShroom", 0.01, mult,
                             function() fov = fov - 0.1 end)
            end
        else

            if fov > 75 then
                fov = fov - 0.1
            elseif fov < 75 then
                fov = fov + 0.1
            end

        end
    end
    timer.Simple(0.01, lerpFOV)
end

local function fovHook(ply, pos, angles, fovEdit)
    local view = {origin = pos, angles = angles, fov = fov}
    return view
end

local function shroomHook()
    local min = 0
    local max = maxOverlay
    local o = o / 1000 -- converts to the real value we will use
    DrawColorModify(cModify)
    DrawMaterialOverlay("psychedelics/shrooms", Lerp(o, min, max))
    local blur = Lerp(multBlur / 500, 0, 0.8) * o -- tracers are less consistent on psilocin
    DrawMotionBlur(0.05, blur, 0.01)
end

local function doShroom()
    hook.Add("RenderScreenspaceEffects", "psychedelicsShroomEffect", shroomHook)
    lerpOverlay()
    shroomColors()
    if tripPresets.fov then
        hook.Add("CalcView", "psychedelicsShroomCalcView", fovHook)
        lerpFOV()
    end
    if tripPresets.hallucinations then hallucination() end
    active = true
end

net.Receive("psychedelicsDeathS", function()
    if net.ReadEntity() == LocalPlayer() then
        instaRemove() -- clears Shroom instantly
    end
end)

local function sortPresets()
    local sortH = math.random(ug / 50, 100)
    if sortH > 80 then tripPresets.hallucinations = true end

    local sortF = math.random(ug / 50, 100)
    if sortF > 65 then tripPresets.fov = true end
end




net.Receive("psychedelicsStartShroom", function()
    sortPresets()
    local ugSum = net.ReadInt(20)

    if ug == 0 and active == false then -- makes sure these functions are called only one time
        timer.Create(onsetStr, duration.onset, 1, doShroom)
        timer.Create("psychedelicsAutoCleanShroom", duration.total, 1, clearShroom)
    end

    ug = ug + ugSum
    maxOverlay = ug / 2000
    multBlur = multBlur + ug
end)
