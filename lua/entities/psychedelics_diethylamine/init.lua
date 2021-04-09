AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/diethylamine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()
end

function ENT:Use(activator, caller) end

function ENT:Touch(entity)
	if entity:GetClass() == "psychedelics_flask" and 
	entity.level == 6 then
		entity.level = 7
		entity:SetNWString("psychedelicsTipText", "Let it cool to 0°")
		self:Remove()
	end
end

function ENT:Think() end
