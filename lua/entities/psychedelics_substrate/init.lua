AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/psychedelics/mushroom/substrate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()
end
	
function ENT:Use( activator, caller )

end

function ENT:Touch(entity)
local level=entity:GetNWInt("psychedelics_box_level",0)

if (entity:GetClass()=="psychedelics_box"&&



	level<=2) then
		if entity:GetNWBool("psychedelics_substrate_touched",false) then return end
		entity:SetNWBool("psychedelics_substrate_touched",true)
		timer.Simple(0.2,function() entity:SetNWBool("psychedelics_substrate_touched",false) end) --delay used to fix bugs related to tick
		level=level+1
		entity:SetBodygroup(1,level)
		entity:SetNWInt("psychedelics_box_level",level)
		if level!=3 then
			entity:SetNWString("psychedelics_tip_text","Add mushroom substrate ("..tostring(level).."/3)")
		else entity:SetNWString("psychedelics_tip_text","Add mushroom spores") end
		self:Remove()
	end

end
	
function ENT:Think()
end