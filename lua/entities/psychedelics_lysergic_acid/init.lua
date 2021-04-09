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
	if entity:GetClass()=="psychedelics_flask" and (entity.level==0 or entity.level==nil) then
		entity:SetSkin(1)
		entity.level = 1
		entity:SetNWString("psychedelicsTipText","Add phosphorous oxychloride")
		self:Remove()
	end
end
	
function ENT:Think()
end