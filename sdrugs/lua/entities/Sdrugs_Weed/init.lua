AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
util.AddNetworkString( "WeedmeuStart" )
function ENT:Initialize()
		self:SetModel("models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():Wake()
		self:Activate()

		self:SetNWInt("THC",15)
		self:SetNWInt("CBD",2)
	end
	
		function ENT:Use( activator, caller )
	
	if IsValid(caller) and caller:IsPlayer()  then
	net.Start("WeedmeuStart")
	net.WriteInt(self:GetNWInt("THC",15),32)
	net.WriteInt(self:GetNWInt("CBD",2),32)
	net.Send(caller)
	self:Remove()
		end
		end

	
	function ENT:Think()
	end