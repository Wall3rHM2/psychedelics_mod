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

    self.level = 7 -- debug stuff. 7 for pre cooling and 9 for post cooling
    -- self:SetNWString("psychedelics_tip_text","debug2")
end

function ENT:Use(activator, caller) end
local function task4(ent)
    ent.level = 4
    ent:SetNWInt("psychedelicsProgress", 0)
    ent:SetNWString("psychedelicsTipText", "Let it still for 4 minutes")
    timer.Create("psychedelicsStillTimer" .. ent:EntIndex(), 2.4, 100, function() -- sets a timer for the player wait almost 2 min

        if not ent:IsValid() then
            timer.Remove("psychedelicsStillTimer" .. ent:EntIndex())
            return
        end

        local progress = ent:GetNWInt("psychedelicsProgress", 0)
        ent:SetNWInt("psychedelicsProgress", progress + 1)

        if (progress + 1 >= 100) then --finishes the current task and level
            ent:SetNWInt("psychedelicsProgress", 0)
            ent.level = 5
            ent:SetNWString("psychedelicsTipText", "Add hexane")
        end -- when the timer hits 100%
    end)

end

local function task3(ent)
    local vel = ent:GetVelocity()
    local progress = ent:GetNWInt("psychedelicsProgress", 0)
    local min_vel1 = 20
    local min_vel2 = -20
    if (vel.x >= min_vel1 or vel.y >= min_vel1 or vel.z >= min_vel1) then -- in case velocity is above min_vel1
        progress = progress + 1
    elseif (vel.x <= min_vel2 or vel.y <= min_vel2 or vel.z <= min_vel2) then -- in case velocity is lower than min_vel2
        progress = progress + 1
    end
    ent:SetNWInt("psychedelicsProgress", progress)
    if (progress >= 100) then -- when the progress bar is equal or above 100%
       task4(ent)
    end

end

function ENT:Think()
    if (self.level == 3) then
        task3(self)
    end
end
