AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
util.AddNetworkString( "CocainemeuStart" )
function ENT:Initialize()
		self:SetModel("models/sprops/rectangles_thin/size_1_5/rect_6x6x1_5.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():Wake()
		self:SetModelScale(0.5,0)
		self:Activate()


	end
	
		function ENT:Use( activator, caller )
	
	if IsValid(caller) and caller:IsPlayer()  then
	net.Start("CocainemeuStart")
	net.Send(caller)
	self:Remove()
		end
		end

	
	function ENT:Think()
	end