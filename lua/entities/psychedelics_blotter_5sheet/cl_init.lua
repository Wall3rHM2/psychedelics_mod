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
local function Draw3D2DTip(text,ent,op)
	local mins, maxs = ent:GetModelBounds()
	local pos = ent:GetPos() + Vector( 0, 0, maxs.z)
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
	local enabled=GetConVar("psychedelics_tips"):GetInt()
	local entity=LocalPlayer():GetEyeTrace().Entity
	local quantity=self:GetNWInt( "psychedelics_quantity", 0 )
	local tiptext = "Click 'e' to crop or 'e' +'shift' to add for selling" 
	if (tiptext!=""&&enabled!=0&&entity==self) then
		Draw3D2DTip(tiptext,self)
	end
end
local posx={"0.0","0.1","0.2","0.3","0.4"} --positions used for the new submaterial use by the 5 blotter sheets spawned
local posy={"0.5","0.6","0.7","0.8","0.9"}
local function update_skin(ent)
	local data=ent:GetNWString("psychedelics_data","psychedelics_blotter_-1-1")
	local dataTab=string.Split(    data,"-"    )
	local subMaterial=dataTab[2]
	if subMaterial == "" then return end
	local matpos = string.Split(data,"-")
	matpos = tonumber(matpos[#matpos])
	local i=string.Split(data,"-")
	i=tonumber(i[#i-1])
	local pos1="0.0"
	local pos2="0.0"
	if matpos==1 or matpos==3 then pos1=posy[i]					-- corrects the x position of the submaterial
	elseif matpos==2 or matpos==4 then pos1=posx[i] end
	if matpos==1 or matpos==2 then pos2="0.5" end 						-- corrects the y position of the submaterial
	local name="psychedelics_sheet_-"..subMaterial.."-"..tostring(i).."-"..tostring(matpos)
	local matTable = {    
		["$basetexture"] = subMaterial,
		["$basetexturetransform"] = "center 0 0 scale " .. (0.1) .. " " .. (0.5) .. " rotate 0 translate "..(pos1).." "..(pos2),
		["$vertexalpha"] = 0,
		["$vertexcolor"] = 1
		};  
	CreateMaterial(name,"VertexLitGeneric", matTable)
	ent:SetSubMaterial(0,"!"..name)
end
local function try_update(ent)
	if ent:IsValid() == false then return end
	if ent:GetNWBool("psychedelics_initialized",false) and LocalPlayer():GetNWBool("psychedelics_postinit",false) then
		update_skin(ent)
	else
		timer.Simple(0.01,function() try_update(ent) end)
	end
end
function ENT:Initialize()
	try_update(self)
end
