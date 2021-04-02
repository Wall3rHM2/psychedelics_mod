AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
if CLIENT then return end
util.AddNetworkString( "LSDmeuStart" )
local type="lsd" --maybe i will add NBOMe in the future and/or DOB, DOC
local default_quantity=0 --default quantity of LSD, mainly used for debuging
local material="" --default material --psychedelics/blotters/sroad
local defaultdata="psychedelics_blotter_-"..material
local tmaterial=string.Split(material,"/")
local posy={".5","0",".5","0"} --positions that the submaterial will use to make 4 different cuts of the base material
local posx={".5",".5","0","0"}
local i=0
function ENT:SetupDataTables() --why darkrp uses this crap?
	self:NetworkVar( "Int", 0, "Quantity" )
	self:NetworkVar( "String", 0, "DataP" )
	self:NetworkVar( "String", 1, "TypeP" )
end
local function SaveData(data_mod,ent) --saves data as networkvar
	ent:SetQuantity(data_mod.quantity)
	ent:SetDataP(data_mod.data)
	ent:SetTypeP(data_mod.type)
end
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/blotter/sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local data = self:GetDataP()
	local type = self:GetTypeP()
	local quantity = self:GetQuantity()
	--self:SetNWString("psychedelics_data","psychedelics_blotter_-psychedelics/blotters/triangles") --debug
	if quantity == 0 then  quantity=self:GetNWInt( "psychedelics_quantity", default_quantity ) end
	if type=="" then type=self:GetNWString("psychedelics_type","lsd") end
	if data=="" then data=self:GetNWString("psychedelics_data",defaultdata) end
	self:SetNWInt( "psychedelics_quantity", quantity )
	self:SetNWString("psychedelics_type",type)
	self:SetNWString("psychedelics_data",data)
	local dataTab=string.Split(    data,"-"    )
	local subMaterial=dataTab[2]
	local tmaterial=string.Split(subMaterial,"/")
	local sheet=self
	local name="psychedelics_sheet_-"..subMaterial 
	if subMaterial~="" then self:SetSubMaterial(0, "!"..name) end
 	local data_mod = {}
 	data_mod.quantity = quantity
 	data_mod.data = data
 	data_mod.type = type
 	data_mod.submaterial = subMaterial
 	SaveData(data_mod,self)
 	self:GetPhysicsObject():Wake()
	self:Activate()
 	self:SetNWBool("psychedelics_initialized",true)
end
if CLIENT then return end
function ENT:Use( activator, caller )	
	if !(IsValid(activator)) or !(activator:IsPlayer())  then return end
	if activator:GetNWBool("psychedelics_usedblotter",false) then return end
	activator:SetNWBool("psychedelics_usedblotter",true)
	timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end) --delay for the player can use the blotters again
	local price = GetConVar("psychedelics_lsd_price"):GetInt()
	local quant = self:GetNWInt( "psychedelics_quantity", default_quantity )
	local money = activator:GetNWInt("psychedelics_sell_money",0)
	if activator:KeyDown(IN_SPEED) then --adds the lsd sheet for selling
		activator:SetNWInt("psychedelics_sell_money",money + price*quant)
		self:Remove()
	return end
	if quant==0 then --opens menu to choose sheet skin
		self:SetNWEntity("psychedelics_valid_caller",activator) --here we avoid a exploit of setting other players sheet skin by client net message
		net.Start("PsychedelicsSheetSkin_UI")
		net.WriteEntity(self)
		net.Send(activator)
	return end
	local Count=0
	for k, v in pairs( ents.FindByClass( "psychedelics_blotter_25sheet" ) ) do --count function used to limit max spawned blotters
		if v:CPPIGetOwner()==activator then
			Count=Count+1
		end
	end
	if Count>=GetConVar("psychedelics_limitspawn_25sheet"):GetInt() then --limits the spawn of 25 blotter sheet by a convar
		net.Start("psychedelics_hintmessage")
		net.WriteString("You have hit this entity limit")
		net.WriteInt(1,32)
		net.WriteInt(3,32)
		net.Send(activator)
	return end
	self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
	local Pos=self:GetPos()
	local thetype=self:GetNWString("psychedelics_type","lsd")
	local thequantity=self:GetNWInt("psychedelics_quantity",default_quantity)
	local data=self:GetNWString("psychedelics_data",defaultdata)
	local dataTab=string.Split(    data,"-"    )
	local subMaterial=dataTab[2]
	local tmaterial=string.Split(subMaterial,"/")
	self:Remove()
	for i=1,4 do
		local sheet25 = ents.Create("psychedelics_blotter_25sheet")
		sheet25:SetPos( Pos+Vector(0,0,2*i))
		sheet25:CPPISetOwner(activator)
		sheet25:SetAngles( Angle( 0, 0, 0 ) )
		sheet25:SetNWString("psychedelics_data","psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i))
		sheet25:SetNWString("psychedelics_type",thetype)
		sheet25:SetNWInt("psychedelics_quantity",thequantity)
		sheet25:Spawn()
		sheet25:Activate()
	end
end
function ENT:Touch(flask) --function for add lsd substance to blotter sheet paper
	if !flask:IsValid() then return end
	if (flask:GetClass()=="psychedelics_flask"&&flask:GetNWInt("psychedelics_flask_level",0)==9)==false then return end
	flask:SetNWInt("psychedelics_flask_level",8) --since the remove will be done in the next tick,we need
	flask:Remove()								--to change the flask level or otherwise it would call the Touch 2 times
	local quantity=self:GetNWInt( "psychedelics_quantity", default_quantity )
	local type=self:GetNWString("psychedelics_type","lsd")
	local data=self:GetNWString("psychedelics_data",defaultdata)
	local dataTab=string.Split(    data,"-"    )
	local subMaterial = dataTab[2]
	local tmaterial = string.Split(subMaterial,"/")
	quantity = quantity + 25
	self:SetNWInt("psychedelics_quantity", quantity)
	self:SetQuantity(quantity)
	duplicator.StoreEntityModifier( self, "psychedelics_data", {data="psychedelics_blotter_".."-"..subMaterial, --saves the data for duplication
 	type=type,quantity=quantity} )  
end
	

function ENT:Think()

end