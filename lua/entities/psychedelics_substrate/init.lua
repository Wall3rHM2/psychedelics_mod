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

function ENT:Use(activator, caller) end

function ENT:Touch(entity)
	local level = entity.level
	if level == nil then level = 0 end

	if not (entity:GetClass() == "psychedelics_box" and level <= 2) then return end
	if entity.substrateTouched then	return end
	entity.substrateTouched = true
	timer.Simple(0.2, function()
		entity.substrateTouched = false
	end) -- delay used to fix bugs related to tick
	
		
	level = level + 1
	entity:SetBodygroup(1, level)
	entity.level = level
	if level ~= 3 then
		entity:SetNWString("psychedelicsTipText", "Add mushroom substrate (" .. tostring(level) .."/3)")
	else
		entity:SetNWString("psychedelicsTipText", "Add mushroom spores")
	end
	self:Remove()

end

function ENT:Think() end
