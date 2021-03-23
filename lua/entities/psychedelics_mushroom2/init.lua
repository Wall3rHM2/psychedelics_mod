AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/psychedelics/mushroom/mushroom_2.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:GetPhysicsObject():Wake()
	self:Activate()
end
	
function ENT:Use( activator, caller )

end

function ENT:Touch(entity)


end
	
function ENT:Think()
end