AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/psychedelics/mushroom/mushroom_3.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()
	self:SetNWInt("psychedelics_quantity",100)
end
	
function ENT:Use( activator, caller )
	if IsValid(caller) and caller:IsPlayer()  then
    	if activator:GetNWBool("psychedelics_usedshroom",false) then return end
    	activator:SetNWBool("psychedelics_usedshroom",true)
    	timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedshroom",false) end)
    	local price = GetConVar("psychedelics_mushroom_price"):GetInt()
		local quant = self:GetNWInt( "psychedelics_quantity", 100 )
		local money = activator:GetNWInt("psychedelics_sell_money",0)
		if activator:KeyDown(IN_SPEED) then --adds the lsd sheet for selling
			activator:SetNWInt("psychedelics_sell_money",money + price)
			self:Remove()
		return end
		net.Start("ShroommeuStart")
		net.WriteInt(quant,32)
		net.Send(caller)
		self:Remove()
	end
end

function ENT:Touch(entity)


end
	
function ENT:Think()
end