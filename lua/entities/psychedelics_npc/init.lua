AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize( ) --This function is run when the entity is created so it's a good place to setup our entity.
 
	self:SetModel( "models/Humans/Group02/male_06.mdl" ) -- Sets the model of the NPC.
	self:SetHullType( HULL_HUMAN ) -- Sets the hull type, used for movement calculations amongst other things.
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX ) -- This entity uses a solid bounding box for collisions.
	self:CapabilitiesAdd( CAP_ANIMATEDFACE) -- Adds what the NPC is allowed to do ( It cannot move in this case ). --CAP_TURN_HEAD )
	self:CapabilitiesAdd(CAP_TURN_HEAD)
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
	--self:SetMaxYawSpeed( 90 ) --Sets the angle by which an NPC can rotate at once.
 
end
function ENT:AcceptInput(name, activator, caller )
	if name == "Use" and activator:IsPlayer() then
		local money = activator:GetNWInt("psychedelics_sell_money",0)
		if money <= 0 then return end
		activator:addMoney(money)
    	activator:SetNWInt("psychedelics_sell_money",0)
    	activator:SendLua("chat.AddText('You got "..tostring(money).."$ from selling')")
	end
end