AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/psychedelics/mushroom/spores.mdl")
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
if (entity:GetClass()=="psychedelics_box"&&level==3) then
		if entity:GetNWBool("psychedelics_spores_touched",false) then return end
		entity:SetNWBool("psychedelics_spores_touched",true)
		timer.Simple(0.2,function() if !(entity:IsValid()) then return end 
		entity:SetNWBool("psychedelics_spores_touched",false) end) --delay used to fix bugs related to tick
		level=level+1
		entity:SetNWInt("psychedelics_box_level",level)
		entity:SetNWInt("psychedelics_water_level",100)
		entity:SetNWString("psychedelics_tip_text","Water it regularly and wait for it to grow")
		self:Remove()
	end


end
	
function ENT:Think()
end