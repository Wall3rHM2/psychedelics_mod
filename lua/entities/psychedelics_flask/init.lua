AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/flask.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()

	self:SetNWInt("psychedelics_flask_level",7) --debug stuff. 7 for pre cooling and 9 for post cooling
	--self:SetNWString("psychedelics_tip_text","debug2")
 end
	
function ENT:Use( activator, caller )

end

	
function ENT:Think()
	if (self:GetNWInt("psychedelics_flask_level",0)==3) then
		local vel=self:GetVelocity()
		local progress=self:GetNWInt("psychedelics_progress",0)
		local min_vel1=20
		local min_vel2=-20
		if (vel.x>=min_vel1 or vel.y>=min_vel1 or vel.z>=min_vel1)  then
			self:SetNWInt("psychedelics_progress",progress+1)
		elseif (vel.x<=min_vel2 or vel.y<=min_vel2 or vel.z<=min_vel2) then
			self:SetNWInt("psychedelics_progress",progress+1)
		end
		if (self:GetNWInt("psychedelics_progress",0)>=100) then --when the progress bar is equal or above 100%
			self:SetNWInt("psychedelics_flask_level",4)
			self:SetNWInt("psychedelics_progress",0)
			self:SetNWString("psychedelics_tip_text","Let it still for 4 minutes")
			timer.Create( "psychedelics_still_timer"..self:EntIndex(), 2.4, 100, function()  --sets a timer for the player wait almost 2 min
				if (!self:IsValid()) then timer.Remove("psychedelics_still_timer"..self:EntIndex()) return end
				local progress=self:GetNWInt("psychedelics_progress",0)
				self:SetNWInt("psychedelics_progress",progress+1)
				if (progress+1>=100) then  
					self:SetNWInt("psychedelics_progress",0)
					self:SetNWInt("psychedelics_flask_level",5)
					self:SetNWString("psychedelics_tip_text","Add hexane")
				end --when the timer hits 100%
			end )
		end
	end



end