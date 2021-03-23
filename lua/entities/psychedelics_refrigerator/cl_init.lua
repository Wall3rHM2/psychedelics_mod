include("shared.lua")
local w,h --width of the text and height of the text
local box_height=40
local box_width=200
local box_posy=280 -- offset z position of the text box
local function drawCircle( x, y, radius, seg )
	local cir = {}
	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end
	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	surface.DrawPoly( cir )
end

--lots of math
local function Draw3D2DTip(text,ent)
	local mins, maxs = ent:GetModelBounds()
	local pos = ent:GetPos() + Vector( 0, 0, maxs.z )
	local y_local = LocalPlayer():GetRenderAngles().y
	local ang = Angle(0,y_local-90,90)
	cam.Start3D2D( pos, ang, 0.1)
		draw.NoTexture() --fixes material bugs
		surface.SetFont( "DermaLarge" )
		w,h = surface.GetTextSize(text)
		surface.SetDrawColor( 30, 30, 30)
		surface.DrawRect( -(box_width+w)/2, -(box_height+h+box_posy)/2, w+box_width,h+box_height ) --center text and add a box behind the text
		surface.SetDrawColor( 255, 255, 0)
		surface.DrawRect(-1,-(box_posy-h-box_height)/2 ,2,(box_posy-h-box_height)/2 ) --line that connects the text box to the flask
		surface.DrawRect(-(box_width+w)/2,(-box_posy+box_height+h)/2 ,w+box_width,2)	--bottom line used for the box outline
		if (ent:GetNWInt("psychedelics_progress",0)>0) then
			local progress=ent:GetNWInt("psychedelics_progress",0)
			--local middle_offset=Lerp(progress/100,0,(w+box_width))/2 --offset used to allign in the middle 
			local total=w+box_width
			local middle_offset=Lerp(progress/100,0,total) --offset used to allign in the middle 
			surface.DrawRect( -middle_offset/2-(total-middle_offset)/2 ,(-box_posy+box_height+h)/2-16 ,middle_offset,16) --line that connects the text box to the flask
		end
		drawCircle(0,0,5,90)
		surface.SetTextColor( 230, 230, 230 )
		surface.SetTextPos( -w/2, -(h+box_posy)/2 ) --center the text
		surface.DrawText( text )
	cam.End3D2D()
end

function ENT:Draw()
	self:DrawModel()


end
function ENT:DrawTranslucent()
	local entity=LocalPlayer():GetEyeTrace().Entity
	local enabled=GetConVar("psychedelics_tips"):GetInt()
	local tiptext=self:GetNWString("psychedelics_tip_text","Open the door and add a flask")
	if (tiptext!=""&&enabled!=0&&entity==self) then
		Draw3D2DTip(tiptext,self)
	end
end