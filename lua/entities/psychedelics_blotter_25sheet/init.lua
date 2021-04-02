AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local quantity=100
local default_quantity = 25
local type="lsd"
local data="psychedelics_blotter_-psychedelics/blotters/bycicle_day-1"
local matpos=0
local subMaterial="psychedelics/blotters/bycicle_day"
local posx={".5","0",".5","0"} --positions used por the new submaterial used by the 25 blotter sheets
local posy={".5",".5","0","0"}

local posx2={"0.0","0.1","0.2","0.3","0.4"} --positions used for the new submaterial use by the 5 blotter sheets spawned
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
	self:SetModel("models/psychedelics/lsd/blotter/25sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local data = self:GetDataP()
	local quantity = self:GetQuantity()

    if data=="" then data = self:GetNWString("psychedelics_data","psychedelics_blotter_--1") end
    if quantity==0 then quantity = self:GetNWInt("psychedelics_quantity",default_quantity) end
    self:SetNWString("psychedelics_data",data)
    self:SetNWInt("psychedelics_quantity",quantity)
    local dataTab=string.Split(    data,"-"    )
	local subMaterial=dataTab[2]
	local i=string.Split(data,"-")
	i=tonumber(i[#i])
	local data_mod = {}
 	data_mod.quantity = quantity
 	data_mod.data = data
 	SaveData(data_mod,self)
	local name="psychedelics_sheet_-"..subMaterial.."-"..tostring(i)
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
		local price = GetConVar("psychedelics_lsd_price"):GetInt()
		local quant = self:GetNWInt( "psychedelics_quantity", default_quantity )
		local money = activator:GetNWInt("psychedelics_sell_money",0)
		if activator:KeyDown(IN_SPEED) then
			activator:SetNWInt("psychedelics_sell_money",money + (price*quant)/4 )
			self:Remove()
		return end
		local Count=0
		for k, v in pairs( ents.FindByClass( "psychedelics_blotter_5sheet" ) ) do --counts spawned sheets owned by player
			if v:CPPIGetOwner()==activator then
				Count=Count+1
			end
		end
		if Count>=GetConVar("psychedelics_limitspawn_5sheet"):GetInt() then --prevents player from spamming entities
			net.Start("psychedelics_hintmessage")
			net.WriteString("You have hit this entity limit")
			net.WriteInt(1,32)
			net.WriteInt(3,32)
			net.Send(activator)
		return end
		self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
		local quantity=self:GetNWInt("psychedelics_quantity",default_quantity)
  		local type=self:GetNWString("psychedelics_type","lsd")
		local data=self:GetNWString("psychedelics_data","psychedelics_blotter_--1")
		local matpos=string.Split(data,"-")
		matpos=tonumber(matpos[#matpos])
		local dataTab=string.Split(	data,"-"	)
		local subMaterial=dataTab[2]
		local angles25=self:LocalToWorldAngles(Angle(0,-90,0))
		local Pos=self:GetPos()
		local thetype=type
		local thequantity=quantity
		for i=1,5 do
			local sheet5 = ents.Create("psychedelics_blotter_5sheet")
			sheet5:SetPos( Pos-self:GetForward()*(4*(5-i))+(self:GetForward()*10))
			sheet5:CPPISetOwner(activator)
			sheet5:SetAngles( angles25)
			sheet5:SetNWString("psychedelics_data","psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i).."-"..tostring(matpos))
			sheet5:SetNWString("psychedelics_type",thetype)
			sheet5:SetNWInt("psychedelics_quantity",thequantity)
			sheet5:Spawn()
			sheet5:Activate()
		end
		self:Remove()
	end
end

	
function ENT:Think()
end
