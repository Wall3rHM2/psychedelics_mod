include("shared.lua")
local lib = include("psychedelics/libs/cl/ents_cl.lua")
local blotter = include("psychedelics/libs/blotter.lua")


function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Quantity")
    self:NetworkVar("String", 0, "DataP")
end

function ENT:Draw() self:DrawModel() end

local tipText = ""
function ENT:DrawTranslucent()
    self:Draw(flags)
    local quantity = self:GetQuantity()

    if quantity == 0 then
        tipText = "Press 'e' on me to set a material"
    else
        tipText = tostring(quantity) .. " μg"
    end
    if lib.checkTip(tipText, self) then
        lib.draw3D2DTip(tipText, self)
        lib.draw3D2DTip("Press 'e' to crop or 'e'+'shift' to add for selling", self, 10)
    end
end

function ENT:Initialize() blotter.tryUpdate(self) end
