AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local default_quantity = 25
local subMaterial="psychedelics/blotters/bycicle_day"
local posx={"0.0","0.1","0.2","0.3","0.4"} --x positions for the 1sheet blotter
local posx2={"0.5","0.6","0.7","0.8","0.9"}

local posy={"0.0","0.1","0.2","0.3","0.4"} --y positions for the 1sheet blotter
local posy2={"0.5","0.6","0.7","0.8","0.9"}

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Quantity" )
	self:NetworkVar( "String", 0, "DataP" )
end
local function SaveData(data_mod,ent) --saves data as networkvar
	ent:SetQuantity(data_mod.quantity)
	ent:SetDataP(data_mod.data)
end
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/blotter/1sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local data = self:GetDataP()
	local quantity = self:GetQuantity()
	if data=="" then data = self:GetNWString("psychedelics_data","psychedelics_blotter_-1-1-1") end
	if quantity==0 then quantity = self:GetNWInt("psychedelics_quantity",default_quantity) end
	self:SetNWString("psychedelics_data", data)
	self:SetNWString("psychedelics_quantity", quantity)
	local data_mod = {}
	data_mod.data = data
	data_mod.quantity = quantity
	SaveData(data_mod,self)
	local dataTab=string.Split(    data,"-"    )
	local subMaterial=dataTab[2]
	local matpos = string.Split(data,"-")
	matpos = tonumber(matpos[#matpos])
	local x=string.Split(data,"-")
    x=tonumber(x[#x-1])
	local i=string.Split(data,"-")
	i=tonumber(i[#i-2])
	local pos1="0.0"
	local pos2="0.0"
	if matpos==1 or matpos==3 then pos1=posx2[x]					-- corrects the x position of the submaterial
	elseif matpos==2 or matpos==4 then pos1=posx[x] end
	if matpos==1 or matpos==2 then pos2=posy2[i]
	else pos2=posy[i] end 		
	local name="psychedelics_sheet_-"..subMaterial.."-"..tostring(i).."-"..tostring(x).."-"..tostring(matpos)
	self:GetPhysicsObject():Wake()
	self:Activate()
	if subMaterial~="" then self:SetSubMaterial(0, "!"..name) end
	self:SetNWBool("psychedelics_initialized",true)
end

function ENT:Use( activator, caller )
	if IsValid(caller) and caller:IsPlayer()	then
		if activator:GetNWBool("psychedelics_usedblotter",false) then return end
		activator:SetNWBool("psychedelics_usedblotter",true)
		timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end)
		local price = GetConVar("psychedelics_lsd_price"):GetInt()
		local quant = self:GetNWInt( "psychedelics_quantity", default_quantity )
		local money = activator:GetNWInt("psychedelics_sell_money",0)
		if activator:KeyDown(IN_SPEED) then
			activator:SetNWInt("psychedelics_sell_money",money + (price*quant)/100 )
			self:Remove()
		return end
		net.Start("LSDmeuStart")
		net.WriteInt(self:GetNWInt("psychedelics_quantity",default_quantity),32)
		net.Send(caller)
		self:Remove()
	end
end

	
function ENT:Think()
end