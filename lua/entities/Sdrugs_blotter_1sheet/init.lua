AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local subMaterial="psychedelics_mod/blotters/bycicle_day"
local posx={"0.0","0.1","0.2","0.3","0.4"}
local posx2={"0.5","0.6","0.7","0.8","0.9"}

local posy={"-0.1","0.0","0.1","0.2","0.3"}
local posy2={"0.4","0.5","0.6","0.7","0.8"}
function ENT:Initialize()
  self:SetModel("models/psychedelics_mod/lsd/blotter/1sheet.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:GetPhysicsObject():Wake()
  self:Activate()
  timer.Simple(0.1,function()
    local sheet1=self
    local data=sheet1:GetNWString("psychedelics_mod_blotter_data","psychedelics_mod_blotter_-psychedelics_mod/blotters/bycicle_day-1-1")
    local matpos=sheet1:GetNWInt("matpos",1)
    local dataTab=string.Split(	data,"-"	)
    subMaterial=dataTab[2]
    local tmaterial=string.Split(subMaterial,"/")
    local x=tonumber(dataTab[3])
    local i=tonumber(dataTab[4])
    local pos1="0.0"
    local pos2="0.0"
    if matpos==1 or matpos==3 then pos1=posx2[x]					-- corrects the x position of the submaterial
    elseif matpos==2 or matpos==4 then pos1=posx[x] end
    if matpos==1 or matpos==2 then pos2=posy[i]
    else pos2=posy2[i] end 						-- corrects the y position of the submaterial

    net.Start("update_blotter_1sheet")
    net.WriteString(subMaterial)
    net.WriteString(pos1)
    net.WriteString(pos2)
    net.WriteString("psychedelics_mod_1sheet_10".."-"..tmaterial[#tmaterial].."-"..tostring(matpos).."-"..tostring(x).."-"..tostring(i))
    net.WriteEntity(sheet1)
    net.Broadcast()
  end)
end
	
function ENT:Use( activator, caller )
  if IsValid(caller) and caller:IsPlayer()  then
    if activator:GetNWBool("psychedelics_mod_usedblotter",false) then return end
    activator:SetNWBool("psychedelics_mod_usedblotter",true)
    timer.Simple(0.2,function() activator:SetNWBool("psychedelics_mod_usedblotter",false) end)
    net.Start("LSDmeuStart")
    net.WriteInt(self:GetNWInt("psychedelics_mod_quantity",100),32)
    net.Send(caller)
    self:Remove()
  end
end

	
function ENT:Think()
end