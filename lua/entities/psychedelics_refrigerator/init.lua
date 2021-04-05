AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
local function free_space(base) --removes the flasks from inside the refrigerator and fixes counts
	base:SetNWString("psychedelics_refrigerator_space","0-0-0-0-0")
	base:SetNWInt("psychedelics_refrigerator_count",5)
	local flasks=ents.FindByClassAndParent("psychedelics_flask",base)
	for k,v in pairs(flasks) do
		local pos = v:GetPos()
		v:SetParent(nil)
		v:SetSkin(2)
		v:SetPos(pos) --for some reason, when i unparent this entity, it goes to refrigerator 0 local position
		v:GetPhysicsObject():EnableMotion(true)
		v:SetNWInt("psychedelics_flask_level",9)
		v:SetNWString("psychedelics_tip_text","Add to a blotter paper sheet")
		--v:SetCollisionGroup(COLLISION_GROUP_NONE)
		--v:GetPhysicsObject():SetCollisionGroup(true)
	end
end
local function AnimateDoor(base)
	local low_door=base:GetNWEntity("psychedelics_low_door",nil)
	local upper_door=base:GetNWEntity("psychedelics_upper_door",nil)
	local axis=base:GetNWEntity("psychedelics_axis",nil)
	if (!base:IsValid()) then  return end
	if (!upper_door:IsValid() or !low_door:IsValid() or !axis:IsValid()) then return end
	--local angle=base:GetNWInt("psychedelics_door_angle",0)
	local local_y=base:GetNWInt("psychedelics_door_angle",0)
	if (base:GetNWBool("psychedelics_door_isopen",false)==false&&local_y==0) then --open the door
		timer.Create("psychedelics_door_open_"..base:EntIndex(),0.01,30,function()
			if !(base:IsValid() or axis:IsValid()) then return end
			local local_y=base:GetNWInt("psychedelics_door_angle",0)
			axis:SetAngles(base:LocalToWorldAngles(Angle(0,local_y-5,0)))
			base:SetNWInt("psychedelics_door_angle",local_y-5)
		end)
		base:SetNWBool("psychedelics_door_isopen",true)
	elseif(base:GetNWBool("psychedelics_door_isopen",false)==true&&local_y==-150) then --close the door
		timer.Create("psychedelics_door_open_"..base:EntIndex(),0.01,30,function()
			if !(base:IsValid() or axis:IsValid()) then return end
			local local_y=base:GetNWInt("psychedelics_door_angle",0)
			axis:SetAngles(base:LocalToWorldAngles(Angle(0,local_y+5,0)))
			base:SetNWInt("psychedelics_door_angle",local_y+5)
		end)
		base:SetNWBool("psychedelics_door_isopen",false)
	end
end
local function adjust_temp(base) --function used to adjust the temperature
	if !(base:IsValid()) then return end
	local isopen=base:GetNWBool("psychedelics_door_isopen",false)
	local temp=base:GetNWInt("psychedelics_temp",22)
	local door_ang=base:GetNWInt("psychedelics_door_angle",0)
	if isopen&&temp<22 then
		temp=temp+1
		base:SetNWInt("psychedelics_temp",temp)
	elseif !(isopen)&&temp>0&&door_ang==0 then
		temp=temp-1
		base:SetNWInt("psychedelics_temp",temp)
	else
	end
	timer.Simple((22-temp)/10+1.0,function() adjust_temp(base) end) --the lower the temperature, the more it takes to change
end
local function adjust_progress(base) --function used to adjust the progress of freezing
	if !(base:IsValid()) then return end
	local isopen=base:GetNWBool("psychedelics_door_isopen",false)
	local temp=base:GetNWInt("psychedelics_temp",22)
	local progress=base:GetNWInt("psychedelics_progress",0)
	local door_ang=base:GetNWInt("psychedelics_door_angle",-10)
	local free_count=base:GetNWInt("psychedelics_refrigerator_count",5) --gets the count of available free spaces
	timer.Simple(2.1,function() adjust_progress(base) end) --debug, return to 2.1 value
	if isopen or door_ang!=0 or free_count>=5 then return end --only adjust progress when the door is closed

	if (temp==0&&progress<100) then 
		base:SetNWInt("psychedelics_progress",progress+1)
		base:SetNWString("psychedelics_tip_text","Wait for it to freeze")
		base:SetNWInt("psychedelics_level",2)
	elseif (temp==0) then	--when the progress goes to 100%
		base:SetNWString("psychedelics_tip_text","Add a flask")
		base:SetNWInt("psychedelics_level",0)
		base:SetNWInt("psychedelics_progress",0)
		free_space(base)
		AnimateDoor(base)
	else

	end

end
function ENT:Initialize()
	self:SetModel("models/props_interiors/refrigerator01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetPos(self:LocalToWorld(Vector( 	0, 0, 40 )) )
	self:GetPhysicsObject():SetMass(240) --enables the entity to be picked by gravgun
	self:GetPhysicsObject():Wake()
	self:Activate()
	adjust_temp(self)
	adjust_progress(self)
	local axis = ents.Create( "psychedelics_base_axis" )	--doors used for the open and close animation
	axis:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	axis:SetPos(self:LocalToWorld(Vector( 16, -15,  35)) )
	axis:Spawn()
	axis:GetPhysicsObject():EnableMotion(false)
	axis:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
	axis:SetParent(self)
	axis:SetNWEntity("psychedelics_door_base",self) --this makes possible for the player to +use the doors to trigger the open/close
	local low_door = ents.Create( "psychedelics_base_door" )	--doors used for the open and close animation
	low_door:SetModel( "models/props_interiors/refrigeratorDoor01a.mdl" )
	low_door:SetPos(self:LocalToWorld(Vector( 16, 0, -7.4 )) )
	low_door:Spawn()
	low_door:GetPhysicsObject():EnableMotion(false)
	low_door:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
	low_door:SetParent(axis)
	low_door:SetNWEntity("psychedelics_door_base",self) --this makes possible for the player to +use the doors to trigger the open/close
	local upper_door = ents.Create( "psychedelics_base_door" )
	upper_door:SetModel( "models/props_interiors/refrigeratorDoor02a.mdl" )
	upper_door:SetPos(self:LocalToWorld(Vector( 16, 0,  29.2)) )
	upper_door:Spawn()
	upper_door:GetPhysicsObject():EnableMotion(false)
	upper_door:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
	upper_door:SetParent(axis)
	upper_door:SetNWEntity("psychedelics_door_base",self)
	self:SetNWEntity("psychedelics_low_door",low_door)
	self:SetNWEntity("psychedelics_upper_door",upper_door)
	self:SetNWEntity("psychedelics_axis",axis)
	axis:SetAngles(self:LocalToWorldAngles( Angle(0,0,0)))
--[[	--this part was made to get the axis position of the doors
	local debug = ents.Create( "psychedelics_base_door" )
	debug:SetModel( "models/hunter/plates/plate.mdl" )
	debug:SetPos(self:LocalToWorld(Vector( 16, -15,  35)) )
	debug:Spawn()
	debug:GetPhysicsObject():EnableMotion(false)
	debug:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
	debug:SetParent(self)
	debug:SetNWEntity("psychedelics_door_base",self)
	-]]
	self:SetNWInt("psychedelics_temp",1)
end

function ENT:Use( activator, caller )
	if (activator:GetNWBool("psychedelics_used_door",false) or self:GetNWBool("psychedelics_progress",0)!=0) then return end
	activator:SetNWBool("psychedelics_used_door",true)
	self:EmitSound("doors/door1_move.wav",75,100,1)
	timer.Simple(1,function() activator:SetNWBool("psychedelics_used_door",false) end) --avoids +use spam
	AnimateDoor(self)
end

function ENT:Touch(entity)
	local isopen=self:GetNWBool("psychedelics_door_isopen",false)
	if (entity:GetClass()=="psychedelics_flask"&&entity:GetNWInt("psychedelics_flask_level",0)==7&&isopen) then
		local free_count=self:GetNWInt("psychedelics_refrigerator_count",5)
		if (free_count<=0) then return end --if there is no space available, it already returns end
		local offset_pos={Vector(0,0,-33),Vector(0,0,-18.5), --offset positions used to setpos in the available spaces
		Vector(0,0,-5),Vector(0,0,8.25),Vector(0,0,21.5)}
		local free_table=self:GetNWString("psychedelics_refrigerator_space","0-0-0-0-0") -- since there is no NWTable, we can improvise with strings
		free_table=string.Split(free_table,"-")						--this is used to know which spaces are occupied or not
		entity:GetPhysicsObject():EnableMotion(false)
		entity:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
		local free_string=""
		local repeat_table=true
		for i=1,5 do
			if (free_table[i]=="0"&&repeat_table) then
				entity:SetPos(self:LocalToWorld(offset_pos[i]))
				free_table[i]="1"
				repeat_table=false
			else
			end
			if (i==1) then free_string=free_table[i] else
				free_string=free_string.."-"..free_table[i]
			end
		end
		entity:SetParent(self)
		self:SetNWString("psychedelics_refrigerator_space",free_string)
		self:SetNWInt("psychedelics_refrigerator_count",free_count-1)
		self:SetNWString("psychedelics_tip_text","Close the door and reach 0°")
		self:SetNWInt("psychedelics_level",1)
		entity:SetNWInt("psychedelics_flask_level",8)
		entity:SetNWString("psychedelics_tip_text","")
		constraint.NoCollide( self, entity, 0, 0 )

	end

end
function ENT:Think()
end