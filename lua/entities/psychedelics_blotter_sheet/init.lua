AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
util.AddNetworkString( "LSDmeuStart" )
local quantity=100
local type="lsd"
local material="psychedelics/blotters/sroad"
local defaultdata="psychedelics_blotter_-"..material.."-1"
local tmaterial=string.Split(material,"/")
local Ded={".5","0",".5","0"}
local Ded2={".5",".5","0","0"}
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/blotter/sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():Wake()
	self:Activate()
	timer.Simple(0.1,function()
		quantity=self:GetNWInt( "psychedelics_quantity", 100 )
		local type=self:GetNWString("psychedelics_type","lsd")
		local data=self:GetNWString("psychedelics_blotter_data",defaultdata)
		local dataTab=string.Split(    data,"-"    )
		subMaterial=dataTab[2]
		local tmaterial=string.Split(subMaterial,"/")
		local sheet25=self

		duplicator.StoreEntityModifier( sheet25, "psychedelics_blotter_data", {data="psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i), matpos=i, --saves the data
 		type=type,quantity=quantity} )  

		net.Start("update_blotter_sheet")
		net.WriteString(subMaterial)
		net.WriteString("0")
		net.WriteString("0")
		net.WriteString("psychedelics_sheet_4".."-"..tmaterial[#tmaterial])
		net.WriteEntity(sheet25)
		net.Broadcast()
	end)
end

function ENT:Use( activator, caller )	
	if IsValid(activator) and activator:IsPlayer()  then
		if activator:GetNWBool("psychedelics_usedblotter",false) then return end
		activator:SetNWBool("psychedelics_usedblotter",true)
		timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end) --delay for the player can use the blotters again
		local Count=0
		for k, v in pairs( ents.FindByClass( "psychedelics_blotter_25sheet" ) ) do
			if v:CPPIGetOwner()==activator then
				Count=Count+1
			end
		end
		if Count>=GetConVar("psychedelics_limitspawn_25sheet"):GetInt() then
			net.Start("psychedelics_hintmessage")
			net.WriteString("You have hit this entity limit")
			net.WriteInt(1,32)
			net.WriteInt(3,32)
			net.Send(activator)
		return end

		self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
		local Pos=self:GetPos()
		local thetype=self:GetNWString("psychedelics_type","lsd")
		local thequantity=self:GetNWInt("psychedelics_quantity",100)
		local data=self:GetNWString("psychedelics_blotter_data",defaultdata)
		local dataTab=string.Split(    data,"-"    )
		subMaterial=dataTab[2]
		local tmaterial=string.Split(subMaterial,"/")
		self:Remove()
		for i=1,4 do
			local sheet25 = ents.Create("psychedelics_blotter_25sheet")
			sheet25:SetPos( Pos+Vector(0,0,2*i))
			sheet25:CPPISetOwner(activator)
			sheet25:SetAngles( Angle( 0, 0, 0 ) )
			sheet25:Spawn()
			sheet25:Activate()
			sheet25:SetNWString("psychedelics_blotter_data","psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i))
			sheet25:SetNWInt("matpos",i)
			sheet25:SetNWString("psychedelics_type",thetype)
			sheet25:SetNWInt("psychedelics_quantity",thequantity)
			duplicator.StoreEntityModifier( sheet25, "psychedelics_blotter_data", {data="psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i), matpos=i, --saves the data
			type=thetype,quantity=thequantity} )  
			timer.Simple(0.1,function()
			net.Start("update_blotter_25sheet")
			net.WriteString(subMaterial)
			net.WriteString(Ded[i])
			net.WriteString(Ded2[i])
			net.WriteString("psychedelics_25sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(i))
    		net.WriteEntity(sheet25)
			net.Broadcast()
			end)
		end
	end
end

	
function ENT:Think()
end