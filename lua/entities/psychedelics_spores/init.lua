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

function ENT:Use(activator, caller) end

function ENT:Touch(entity)
	local level = entity.level
	if level == nil then level = 0 end
	if not (entity:GetClass() == "psychedelics_box" and level == 3) then return end

	if entity.sporesTouched then	return end
	entity.sporesTouched = true
	timer.Simple(0.2, function()
		entity.sporesTouched = false
	end) -- delay used to fix bugs related to tick


	level = level + 1
	entity.level = level
	entity:SetNWInt("psychedelicsWaterLevel", 100)
	entity:SetNWString("psychedelicsTipText", "Water it regularly and wait for it to grow")
	self:Remove()

end

function ENT:Think() end
