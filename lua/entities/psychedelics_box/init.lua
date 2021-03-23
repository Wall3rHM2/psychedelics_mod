AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
local function grow(box)
	local level=box:GetNWInt("psychedelics_box_level",0) --tirar de comentario
	local offset=8
	if	level==5 then 
		for i=1,4 do
			local mushroom1=ents.Create("psychedelics_mushroom1")
			local posx,posy=0 --ifman lmao
			if i==1 then posx=offset posy=offset
			elseif i==2 then posx=-offset posy=offset
			elseif i==3 then posx=offset posy=-offset
			else posx=-offset posy=-offset	end
			mushroom1:Spawn()
			mushroom1:GetPhysicsObject():EnableMotion(false)
			local mins, maxs = mushroom1:GetModelBounds()
			mushroom1:SetPos(box:LocalToWorld(Vector(posx,posy,17.9-mins.z)))
			mushroom1:SetParent(box)
		end
		box:SetNWInt("psychedelics_box_level",5)
	elseif level==6 then 
		for k,mushroom1 in pairs(ents.FindByClassAndParent("psychedelics_mushroom1",box)) do
			local mushroom2=ents.Create("psychedelics_mushroom2")
			mushroom2:Spawn()
			mushroom2:GetPhysicsObject():EnableMotion(false)
			local mins, maxs = mushroom2:GetModelBounds()
			local mushroom1_pos_local=box:WorldToLocal(mushroom1:GetPos())
			local pos=box:LocalToWorld(Vector( mushroom1_pos_local.x,mushroom1_pos_local.y,17.9-mins.z ))
			mushroom2:SetPos(pos)
			mushroom2:SetAngles(mushroom1:GetAngles())
			mushroom2:SetParent(box)
			mushroom1:Remove()
		end
		box:SetNWInt("psychedelics_box_level",6)
	elseif level==7 then 
		for k,mushroom2 in pairs(ents.FindByClassAndParent("psychedelics_mushroom2",box)) do
			local mushroom3=ents.Create("psychedelics_mushroom3")
			mushroom3:Spawn()
			mushroom3:GetPhysicsObject():EnableMotion(false)
			local mins, maxs = mushroom3:GetModelBounds()
			local mushroom2_pos_local=box:WorldToLocal(mushroom2:GetPos())
			local pos=box:LocalToWorld(Vector( mushroom2_pos_local.x,mushroom2_pos_local.y,17.9-mins.z ))
			mushroom3:SetPos(pos)
			mushroom3:SetAngles(mushroom2:GetAngles())
			mushroom3:SetParent(box)
			mushroom2:Remove()
		end
		box:SetNWString("psychedelics_tip_text","Press E to pickup the mushrooms")
		box:SetNWInt("psychedelics_box_level",7)
	end		
end
local function grow_progress(box)
	if !box:IsValid() then return end
	local level=box:GetNWInt("psychedelics_box_level",0)
	if !(level>=3&&level<=6) then return end
	local progress=box:GetNWInt("psychedelics_progress",0)
	local water=box:GetNWInt("psychedelics_water_level",100)
	local minus_water=math.random(1,10)
	local random=math.random(0,1)
	if random==1 then
		progress=progress+1
		if water-minus_water<0 then box:SetNWInt("psychedelics_water_level",0)
		else box:SetNWInt("psychedelics_water_level",water-random) end
	end
	if progress>=100 then 
		level=level+1
		box:SetNWInt("psychedelics_progress",0)
		box:SetNWInt("psychedelics_box_level",level)
		grow(box)
	else box:SetNWInt("psychedelics_progress",progress) end
	timer.Simple(0.1,function() grow_progress(box) end)
end
function ENT:Initialize()
	self:SetModel("models/psychedelics/mushroom/box.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()
	self:SetNWVarProxy("psychedelics_box_level",function() 
		if self:GetNWInt("psychedelics_box_level")==3 then grow_progress(self)  end
	end)
end
	
function ENT:Use( activator, caller )
if (activator:GetNWBool("psychedelics_used_box",false)) then return end
	activator:SetNWBool("psychedelics_used_box",true)
	timer.Simple(0.1,function() activator:SetNWBool("psychedelics_used_box",false) end) --avoids +use spam
	local level=self:GetNWInt("psychedelics_box_level",0)
	if level>3&&level<6 then
		self:EmitSound("ambient/water/water_splash"..tostring(math.random(1,3))..".wav",75,100,1)
		self:SetNWInt("psychedelics_water_level",100)
	end
	if level==7 then
		for k,v in pairs(ents.FindByClassAndParent( "psychedelics_mushroom3", self )) do
			v:SetParent(nil)
			v:GetPhysicsObject():EnableMotion(true)
		end
		self:SetNWInt("psychedelics_box_level",0)
		self:SetBodygroup(1,0)
		self:SetNWString("psychedelics_tip_text","Add mushroom substrate (0/3)")
	end
end

function ENT:Touch(entity)


end
	
function ENT:Think()
end