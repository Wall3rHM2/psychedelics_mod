AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:GetPhysicsObject():Wake()
	self:Activate()
	self:SetColor(Color(255, 255, 255, 0))
end

function ENT:Use(activator, caller)
	local base = self:GetNWEntity("psychedelicsDoorBase", nil)
	if (base:IsValid() == false) then return end
	base:Use(activator, caller)
end

function ENT:Touch(entity) end

function ENT:Think() end
