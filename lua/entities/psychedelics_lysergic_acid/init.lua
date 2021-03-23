AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
  self:SetModel("models/psychedelics/lsd/lysergic_acid.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:GetPhysicsObject():Wake()
  self:Activate()
end
	
function ENT:Use( activator, caller )

end

function ENT:Touch(entity)
	if (entity:GetClass()=="psychedelics_flask"&&entity:GetNWInt("psychedelics_flask_level",0)==0) then
		entity:SetSkin(1)
		entity:SetNWInt("psychedelics_flask_level",1)
		entity:SetNWString("psychedelics_tip_text","Add phosphorous oxychloride")
		self:Remove()
	end
end
	
function ENT:Think()
end