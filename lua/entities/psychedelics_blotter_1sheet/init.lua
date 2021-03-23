AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local subMaterial="psychedelics/blotters/bycicle_day"
local posx={"0.0","0.1","0.2","0.3","0.4"} --x positions for the 1sheet blotter
local posx2={"0.5","0.6","0.7","0.8","0.9"}

local posy={"0.0","0.1","0.2","0.3","0.4"} --y positions for the 1sheet blotter
local posy2={"0.5","0.6","0.7","0.8","0.9"}
function ENT:Initialize()
  self:SetModel("models/psychedelics/lsd/blotter/1sheet.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:GetPhysicsObject():Wake()
  self:Activate()
  local function update_1blotter(ply,ent,data_mod) --apply modifiers from duplicator data
    if not SERVER then return end
    quantity=data_mod.quantity
    self:SetNWInt("psychedelics_quantity",quantity)
    type=data_mod.type
    self:SetNWString("psychedelics_type",type)
    data=data_mod.data
    self:SetNWString("psychedelics_data",data)
    matpos=data_mod.matpos
    self:SetNWInt("psychedelics_matpos",matpos)
    local dataTab=string.Split( data,"-"  )
    subMaterial=dataTab[2]
    self:SetNWString("psychedelics_subMaterial",subMaterial)
    local tmaterial=string.Split(subMaterial,"/")
    local x=string.Split(data,"-")
    x=tonumber(x[3])
    local i=string.Split(data,"-")
    i=tonumber(i[#i])
    local sheet1=self
    local pos1="0.0"
    local pos2="0.0"

    if matpos==1 or matpos==3 then pos1=posx2[x]         -- corrects the x position of the submaterial
    elseif matpos==2 or matpos==4 then pos1=posx[x] end
    if matpos==1 or matpos==2 then pos2=posy2[i]
    else pos2=posy[i] end  
    if subMaterial=="" then  return end
    net.Start("update_blotter_1sheet")
    net.WriteString(subMaterial)
    net.WriteString(pos1)
    net.WriteString(pos2)
    net.WriteString("psychedelics_1sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(x).."-"..tostring(i))
    net.WriteEntity(sheet1)
    net.Broadcast()
  end
  duplicator.RegisterEntityModifier("psychedelics_data",update_1blotter)
end
	
function ENT:Use( activator, caller )
  if IsValid(caller) and caller:IsPlayer()  then
    if activator:GetNWBool("psychedelics_usedblotter",false) then return end
    activator:SetNWBool("psychedelics_usedblotter",true)
    timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end)
    net.Start("LSDmeuStart")
    net.WriteInt(self:GetNWInt("psychedelics_quantity",100),32)
    net.Send(caller)
    self:Remove()
  end
end

	
function ENT:Think()
end