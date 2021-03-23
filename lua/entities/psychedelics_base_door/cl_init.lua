include("shared.lua")

local function DrawPanel(ent)
	--local pos = ent:LocalToWorld(Vector(18.5,0,28))
	--local pos = ent:LocalToWorld(Vector(18.5,0,24))
	local base=ent:GetNWEntity("psychedelics_door_base",ent)
	local temp=base:GetNWInt("psychedelics_temp",22) --22C is default room temperature
	local temp_string=tostring(temp).."°"
	local temp_w,temp_h --width and height for the temperature string
	local pos = ent:LocalToWorld(Vector(3,0,0))
	local ang = ent:LocalToWorldAngles(Angle(0,90,90))
	cam.Start3D2D( pos, ang, 0.2)
	draw.NoTexture() --fixes material bugs
	surface.SetFont( "DermaLarge" )
	surface.SetDrawColor( 30, 30, 30)
	temp_w,temp_h=surface.GetTextSize(temp_string)
	surface.SetTextColor(HSVToColor(180-(temp*2),1,1))
	surface.SetTextPos( -temp_w/2, -temp_h/2 ) 
	surface.DrawRect(-20,-15,40,30)
	surface.DrawText(temp_string)
	cam.End3D2D()
end
function ENT:Draw()
	self:DrawModel()
	if (self:GetModel()=="models/props_interiors/refrigeratordoor02a.mdl") then DrawPanel(self) end --only draws a panel for the upper door
end