AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local default_quantity = 25
local posur={"0.0","0.1","0.2","0.3","0.4"} --x position for the 5sheet
local posur2={"0.5","0.6","0.7","0.8","0.9"}  --y positions for the 5sheet

local posx={"0.0","0.1","0.2","0.3","0.4"}
local posx2={"0.5","0.6","0.7","0.8","0.9"}

local posy={"0.0","0.1","0.2","0.3","0.4"}
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
	self:SetModel("models/psychedelics/lsd/blotter/5sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local data = self:GetDataP()
	local quantity = self:GetQuantity()
	if data=="" then data = self:GetNWString("psychedelics_data","psychedelics_blotter_--1-1") end
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
	local i=string.Split(data,"-")
	i=tonumber(i[#i-1])
	local pos1="0.0"
	local pos2="0.0"
	if matpos==1 or matpos==3 then pos1=posy[i]					-- corrects the x position of the submaterial
	elseif matpos==2 or matpos==4 then pos1=posx[i] end
	if matpos==1 or matpos==2 then pos2="0.5" end 						-- corrects the y position of the submaterial
	local name="psychedelics_sheet_-"..subMaterial.."-"..tostring(i).."-"..tostring(matpos)
    self:GetPhysicsObject():Wake()
	self:Activate()
	if subMaterial~="" then self:SetSubMaterial(0, "!"..name) end
	self:SetNWBool("psychedelics_initialized",true)
end
	
function ENT:Use( activator, caller )
	if IsValid(caller) and caller:IsPlayer()  then
		if activator:GetNWBool("psychedelics_usedblotter",false) then return end
		activator:SetNWBool("psychedelics_usedblotter",true)
		timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end)
		local Count=0
		for k, v in pairs( ents.FindByClass( "psychedelics_blotter_1sheet" ) ) do --counts how many 1sheet entities the player have
		local price = GetConVar("psychedelics_lsd_price"):GetInt()
		local quant = self:GetNWInt( "psychedelics_quantity", default_quantity )
		local money = activator:GetNWInt("psychedelics_sell_money",0)
		if activator:KeyDown(IN_SPEED) then 
			activator:SetNWInt("psychedelics_sell_money",money + (price*quant)/20 )
			self:Remove()
		return end

			if v:CPPIGetOwner()==activator then
				Count=Count+1
			end
		end
		if Count>=GetConVar("psychedelics_limitspawn_1sheet"):GetInt() then --limits 1sheet spawn to prevent spam
			net.Start("psychedelics_hintmessage")
			net.WriteString("You have hit this entity limit")
			net.WriteInt(1,32)
			net.WriteInt(3,32)
			net.Send(activator)
		return end
		self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
		local data=self:GetNWString("psychedelics_data","psychedelics_blotter_-psychedelics/blotters/bycicle_day-1-1")
		local matpos = string.Split(data,"-")
		matpos = tonumber(matpos[#matpos])
		local dataTab=string.Split(	data,"-"	)
		local subMaterial=dataTab[2]
		local tmaterial=string.Split(subMaterial,"/")
		local x=string.Split(data,"-")
		x=tonumber(x[#x-1])
		local sheet5=self
		local angles5=sheet5:LocalToWorldAngles(Angle(0,180,0))
		local Pos=self:GetPos()
		local thetype=self:GetNWString("psychedelics_type","lsd")
		local thequantity=self:GetNWInt("psychedelics_quantity",default_quantity)
		self:Remove()
		for i=1,5 do
			local sheet1 = ents.Create("psychedelics_blotter_1sheet")
			sheet1:SetPos( Pos-sheet5:GetForward()*(2*(5-i))+(sheet5:GetForward()*6))
			sheet1:CPPISetOwner(activator)
			sheet1:SetAngles( angles5)
			sheet1:SetNWString("psychedelics_data","psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i).."-"..tostring(x).."-"..tostring(matpos))
			sheet1:SetNWString("psychedelics_type",thetype)
			sheet1:SetNWInt("psychedelics_quantity",thequantity)
			sheet1:Spawn()
			sheet1:Activate()
		end
	end
end

	
function ENT:Think()
end
