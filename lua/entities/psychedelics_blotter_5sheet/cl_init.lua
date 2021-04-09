include("shared.lua")
local lib = include("psychedelics/libs/cl/ents_cl.lua")
local blotter = include("psychedelics/libs/blotter.lua")

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Quantity")
    self:NetworkVar("String", 0, "DataP")
end

function ENT:Draw()
	self:DrawModel()
end

local tipText = "Click 'e' to crop or 'e' +'shift' to add for selling" 
function ENT:DrawTranslucent()
	self:Draw()
	local enabled=GetConVar("psychedelics_tips"):GetInt()
	if lib.checkTip(tipText, self) then
		lib.draw3D2DTip(tipText,self)
	end
end

function ENT:Initialize()
	blotter.tryUpdate(self)
end

