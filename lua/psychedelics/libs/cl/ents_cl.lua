--hello hello welcome, at first we have draw functions

local w, h -- width of the text and height of the text
local boxHeight = 40
local boxWidth = 200
local boxPosy = 280 -- offset z position of the text box
local function drawCircle(x, y, radius, seg)
    local cir = {}

    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        })
    end

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(cir, {
        x = x + math.sin(a) * radius,
        y = y + math.cos(a) * radius,
        u = math.sin(a) / 2 + 0.5,
        v = math.cos(a) / 2 + 0.5
    })

    surface.DrawPoly(cir)
end


-- lots of math
local function draw3D2DTip(text, ent, op) --op sets height for other tip boxes
    local mins, maxs = ent:GetModelBounds()
    local second = op ~= nil
    local pos = ent:GetPos() + Vector(0, 0, maxs.z)
    if second then pos = pos + Vector(0, 0, op) end
    local yLocal = LocalPlayer():GetRenderAngles().y
    local ang = Angle(0, yLocal - 90, 90)
    cam.Start3D2D(pos, ang, 0.1)
    draw.NoTexture() -- fixes material bugs
    surface.SetFont("DermaLarge")
    w, h = surface.GetTextSize(text)
    surface.SetDrawColor(30, 30, 30)
    surface.DrawRect(-(boxWidth + w) / 2, -(boxHeight + h + boxPosy) / 2, w + boxWidth, h + boxHeight) -- center text and add a box behind the text
    surface.SetDrawColor(255, 255, 0)
    if second == false then
        surface.DrawRect(-1, -(boxPosy - h - boxHeight) / 2, 2, (boxPosy - h - boxHeight) / 2) -- line that connects the text box to the flask
    else
        surface.DrawRect(-1, -(boxPosy - h - boxHeight) / 2, 2, (boxPosy - h - boxHeight) / 2 - 76) -- line that connects the text box to the flask
    end
    surface.DrawRect(-(boxWidth + w) / 2, (-boxPosy + boxHeight + h) / 2, w + boxWidth, 2) -- bottom line used for the box outline
    if (ent:GetNWInt("psychedelicsProgress", 0) > 0) then
        local progress = ent:GetNWInt("psychedelicsProgress", 0)
        local total = w + boxWidth
        local middleOffset = Lerp(progress / 100, 0, total) -- offset used to allign in the middle 
        surface.DrawRect(-middleOffset / 2 - (total - middleOffset) / 2, (-boxPosy + boxHeight + h) / 2 - 16, middleOffset, 16) -- line that connects the text box to the flask
    end
    if second == false then drawCircle(0, 0, 5, 90) end
    surface.SetTextColor(230, 230, 230)
    surface.SetTextPos(-w / 2, -(h + boxPosy) / 2) -- center the text
    surface.DrawText(text)
    cam.End3D2D()
end
local dist = 600*600
local function checkDist(ent) -- used to check if the distance is valid
    return ( LocalPlayer():GetPos():DistToSqr(ent:GetPos()) <= dist )
end
local function checkTip(tipText, ent) --used to check if the 3d2dtip should be rendered
    local bool = false
    if not checkDist(ent) then return false end --returns false in case player is too far
    local enabled = GetConVar("psychedelics_tips"):GetInt()
	local entity = LocalPlayer():GetEyeTrace().Entity
    if (tipText~="" and enabled~=0 and entity==ent) then
        bool = true
    end
    return bool
end

local lib = {}
lib.draw3D2DTip = draw3D2DTip
lib.checkDist = checkDist
lib.checkTip = checkTip
return lib
