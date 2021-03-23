AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
util.AddNetworkString( "LSDmeuStart" )
local type="lsd" --maybe i will add NBOMe in the future and/or DOB, DOC
local default_quantity=0 --default quantity of lSD, mainly used for debuging
local material="" --default material --psychedelics/blotters/sroad
local defaultdata="psychedelics_blotter_-"..material.."-1"
local tmaterial=string.Split(material,"/")
local posy={".5","0",".5","0"} --positions that the submaterial will use to make 4 different cuts of the base material
local posx={".5",".5","0","0"}
local i=0
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/blotter/sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()
	local function update_sheet(ply,ent,data_mod) 
			local quantity=data_mod.quantity
			self:SetNWInt("psychedelics_quantity",quantity)
  			local type=data_mod.type
  			self:SetNWString("psychedelics_type",type)
			local data=data_mod.data
			self:SetNWString("psychedelics_data",data)
			local matpos=data_mod.matpos
			self:SetNWInt("psychedelics_matpos",matpos)
			local dataTab=string.Split(	data,"-"	)
			local subMaterial=dataTab[2]
			self:SetNWString("psychedelics_subMaterial",subMaterial)
			local tmaterial=string.Split(subMaterial,"/")
			local i=string.Split(data,"-")
			i=tonumber(i[#i])
			local sheet=self
			if subMaterial=="" then return end
    		net.Start("update_blotter_sheet") --updates the upside submaterial of the 25 blotter sheet
    		net.WriteString(subMaterial)
    		net.WriteString("0")
    		net.WriteString("0")
    		net.WriteString("psychedelics_sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(i))
    		net.WriteEntity(sheet)
    		net.Broadcast()
	end
	duplicator.RegisterEntityModifier("psychedelics_data",update_sheet)
	local quantity=self:GetNWInt( "psychedelics_quantity", default_quantity )
	local type=self:GetNWString("psychedelics_type","lsd")
	local data=self:GetNWString("psychedelics_data",defaultdata)
	local dataTab=string.Split(    data,"-"    )
	local subMaterial=dataTab[2]
	local tmaterial=string.Split(subMaterial,"/")
	local sheet=self
	duplicator.StoreEntityModifier( sheet, "psychedelics_data", {data="psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i), matpos=i, --saves the data for duplication
 	type=type,quantity=quantity} ) 
 	if subMaterial=="" then return end 
	net.Start("update_blotter_sheet") --sets the upside submaterial
	net.WriteString(subMaterial)
	net.WriteString("0")
	net.WriteString("0")
	net.WriteString("psychedelics_sheet_4".."-"..tmaterial[#tmaterial])
	net.WriteEntity(sheet)
	net.Broadcast()

end
if CLIENT then return end
function ENT:Use( activator, caller )	
	if !(IsValid(activator)) or !(activator:IsPlayer())  then return end
	if activator:GetNWBool("psychedelics_usedblotter",false) then return end
	activator:SetNWBool("psychedelics_usedblotter",true)
	timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end) --delay for the player can use the blotters again
	if self:GetNWInt( "psychedelics_quantity", default_quantity )==0 then 
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
	subMaterial=dataTab[2]
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
		sheet25:SetNWInt("psychedelics_matpos",i)
		duplicator.StoreEntityModifier( sheet25, "psychedelics_data", {data="psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i), matpos=i, --saves the data
		type=thetype,quantity=thequantity,pos1=posx[i],pos2=posy[i]} )  --saves data in the spawned 25 blotters for duplication
		if subMaterial!="" then 
			net.Start("update_blotter_25sheet") --updates the 4 spawned 25 blotter sheet submaterial
			net.WriteString(subMaterial)
			net.WriteString(posx[i])
			net.WriteString(posy[i])
			net.WriteString("psychedelics_25sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(i))
    		net.WriteEntity(sheet25)
			net.Broadcast()
		end
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
	local subMaterial=dataTab[2]
	local tmaterial=string.Split(subMaterial,"/")
	quantity=quantity+25
	self:SetNWInt("psychedelics_quantity", quantity)
	duplicator.StoreEntityModifier( self, "psychedelics_data", {data="psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i), matpos=i, --saves the data for duplication
 	type=type,quantity=quantity} )  
end
	
local function SetSheetSkin(len,ply)
	local sheet=net.ReadEntity()
	if sheet==nil then return end
	if !sheet:IsValid() then return end
	local ply_valid=sheet:GetNWEntity("psychedelics_valid_caller",nil)
	if ply_valid==nil then return end
	if !ply_valid:IsValid() then return end
	if ply_valid!=ply then return end --avoids exploit
	local material_valid=false
	local valid_materials = file.Find( "materials/psychedelics/blotters/*.vmt", "THIRDPARTY" )
	local material=net.ReadString()
	local tmaterial=string.Split(material,"/")
	for i=1,#valid_materials do --only allows for valid materials, so we avoid another exploit
		local formated="psychedelics/blotters/"..string.gsub(valid_materials[i],".vmt","")
		if formated==material then material_valid=true end
	end
	if material_valid==false then return end
	local quantity=sheet:GetNWInt( "psychedelics_quantity", default_quantity )
	local type=sheet:GetNWString("psychedelics_type","lsd")
	local data="psychedelics_blotter_".."-"..material.."-"..tostring(i)
	local dataTab=string.Split(    data,"-"    )
	duplicator.StoreEntityModifier( sheet, "psychedelics_data", {data="psychedelics_blotter_".."-"..material.."-"..tostring(i), matpos=i, --saves the data for duplication
	type=type,quantity=quantity} ) 
	sheet:SetNWString("psychedelics_data",data)
	net.Start("update_blotter_sheet") --updates the upside submaterial of the 25 blotter sheet
	net.WriteString(material)
	net.WriteString("0")
	net.WriteString("0")
	net.WriteString("psychedelics_sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(i))
	net.WriteEntity(sheet)
	net.Broadcast()
end
net.Receive( "PsychedelicsSheetSkin_Mat", SetSheetSkin)

function ENT:Think()

end