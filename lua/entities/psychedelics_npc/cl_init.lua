include("shared.lua")
local lib = include("psychedelics/libs/cl/ents_cl.lua")

function ENT:Draw()
	self:DrawModel()
end

local tipText="Click 'e' on me to sell LSD/mushrooms"
function ENT:DrawTranslucent()
	self:Draw()
	if lib.checkTip(tipText, self) then
		lib.draw3D2DTip(tipText,self)
	end
end

function ENT:Initialize()
	self.AutomaticFrameAdvance = true
end