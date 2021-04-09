include("shared.lua")
local lib = include("psychedelics/libs/cl/ents_cl.lua")
local function drawPanel(ent)
	-- local pos = ent:LocalToWorld(Vector(18.5,0,28))
	-- local pos = ent:LocalToWorld(Vector(18.5,0,24))
	local base = ent:GetNWEntity("psychedelicsDoorBase", ent)
	local temp = base:GetNWInt("psychedelicsTemp", 22) -- 22C is default room temperature
	local tempString = tostring(temp) .. "°"
	local tempW, tempH -- width and height for the temperature string
	local pos = ent:LocalToWorld(Vector(3, 0, 0))
	local ang = ent:LocalToWorldAngles(Angle(0, 90, 90))

	cam.Start3D2D(pos, ang, 0.2)
	draw.NoTexture() -- fixes material bugs
	surface.SetFont("DermaLarge")
	surface.SetDrawColor(30, 30, 30)
	tempW, tempH = surface.GetTextSize(tempString)
	surface.SetTextColor(HSVToColor(180 - (temp * 2), 1, 1))
	surface.SetTextPos(-tempW / 2, -tempH / 2)
	surface.DrawRect(-20, -15, 40, 30)
	surface.DrawText(tempString)
	cam.End3D2D()
end

function ENT:Draw() self:DrawModel() end

function ENT:DrawTranslucent(flags)
	if (self:GetModel() == "models/props_interiors/refrigeratordoor02a.mdl") and lib.checkDist(self) then
		drawPanel(self)
	end -- only draws a panel for the upper door
end
