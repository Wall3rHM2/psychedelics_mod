include("shared.lua")
local lib = include("psychedelics/libs/cl/ents_cl.lua")
function ENT:Draw()
	self:DrawModel()
end
print("psychedelics/libs/cl/ents_cl.lua")
function ENT:DrawTranslucent()
	local tipText=self:GetNWString("psychedelicsTipText","Open the door and add a flask")
	local entity = LocalPlayer():GetEyeTrace().Entity
	local valid = (entity==self or entity:GetNWEntity("psychedelicsDoorBase",nil) == self)
	if lib.checkDist(self) and valid then
		lib.draw3D2DTip(tipText,self)
	end

end