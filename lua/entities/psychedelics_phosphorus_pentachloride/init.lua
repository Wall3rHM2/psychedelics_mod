AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
  self:SetModel("models/psychedelics/lsd/phosphorus_pentachloride.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:GetPhysicsObject():Wake()
  self:Activate()
end
	
function ENT:Use( activator, caller )

end

function ENT:Touch(entity)
	if (entity:GetClass()=="psychedelics_flask"&&entity:GetNWInt("psychedelics_flask_level",0)==2) then
		entity:SetNWInt("psychedelics_flask_level",3)
		entity:SetNWString("psychedelics_tip_text","Shake it")
		self:Remove()
	end
end
	
function ENT:Think()
end