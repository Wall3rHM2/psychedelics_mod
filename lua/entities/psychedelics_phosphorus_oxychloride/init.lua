AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/phosphorus_oxychloride.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()
end
	
function ENT:Use( activator, caller )

end

function ENT:Touch(entity)
	if entity:GetClass()=="psychedelics_flask" and entity.level==1 then
		entity.level = 2
		entity:SetNWString("psychedelicsTipText","Add phosphorus pentachloride")
		self:Remove()
	end
end
	
function ENT:Think()
end