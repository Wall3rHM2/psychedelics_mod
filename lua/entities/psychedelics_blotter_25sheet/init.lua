AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local quantity=100
local type="lsd"
local data="psychedelics_blotter_-psychedelics/blotters/bycicle_day-1"
local matpos=0
local subMaterial="psychedelics/blotters/bycicle_day"
local posx={".5","0",".5","0"} --positions used por the new submaterial used by the 25 blotter sheets
local posy={".5",".5","0","0"}

local posx2={"0.0","0.1","0.2","0.3","0.4"} --positions used for the new submaterial use by the 5 blotter sheets spawned
local posy2={"0.5","0.6","0.7","0.8","0.9"}


function ENT:Initialize()
		self:SetModel("models/psychedelics/lsd/blotter/25sheet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		local function update_25blotter(ply,ent,data_mod) --apply modifiers from duplicator data
			if not SERVER then return end
			quantity=data_mod.quantity
			self:SetNWInt("psychedelics_quantity",quantity)
  			type=data_mod.type
  			self:SetNWString("psychedelics_type",type)
			data=data_mod.data
			self:SetNWString("psychedelics_data",data)
			matpos=data_mod.matpos
			self:SetNWInt("psychedelics_matpos",matpos)
			local dataTab=string.Split(	data,"-"	)
			subMaterial=dataTab[2]
			self:SetNWString("psychedelics_subMaterial",subMaterial)
			local tmaterial=string.Split(subMaterial,"/")
			local i=string.Split(data,"-")
			i=tonumber(i[#i])
			local sheet25=self
			if subMaterial=="" then return end
    		net.Start("update_blotter_25sheet") --updates the upside submaterial of the 25 blotter sheet
    		net.WriteString(subMaterial)
    		net.WriteString(posx[i])
    		net.WriteString(posy[i])
    		net.WriteString("psychedelics_25sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(i))
    		net.WriteEntity(sheet25)
    		net.Broadcast()
    	end
		duplicator.RegisterEntityModifier("psychedelics_data",update_25blotter) --saves data for duplication
		self:GetPhysicsObject():Wake()
		self:Activate()
	end

function ENT:Use( activator, caller )	
	if IsValid(caller) and caller:IsPlayer()  then
		if activator:GetNWBool("psychedelics_usedblotter",false) then return end
		activator:SetNWBool("psychedelics_usedblotter",true)
		timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end)
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
		quantity=self:GetNWInt("psychedelics_quantity",100)
  		type=self:GetNWString("psychedelics_type","lsd")
		data=self:GetNWString("psychedelics_data","psychedelics_blotter_-psychedelics/blotters/bycicle_day-1")
		matpos=self:GetNWInt("psychedelics_matpos",1)
		local dataTab=string.Split(	data,"-"	)
		subMaterial=dataTab[2]
		local tmaterial=string.Split(subMaterial,"/")
		local sheet25=self
		local angles25=sheet25:LocalToWorldAngles(Angle(0,-90,0))
		local Pos=self:GetPos()
		local thetype=type
		local thequantity=quantity
		self:Remove()
		for i=1,5 do
			local sheet5 = ents.Create("psychedelics_blotter_5sheet")
			sheet5:SetPos( Pos-sheet25:GetForward()*(4*(5-i))+(sheet25:GetForward()*10))
			sheet5:CPPISetOwner(activator)
			sheet5:SetAngles( angles25)
			sheet5:Spawn()
			sheet5:Activate()
			sheet5:SetNWString("psychedelics_data","psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i))
			sheet5:SetNWInt("psychedelics_matpos",matpos)
			sheet5:SetNWString("psychedelics_type",thetype)
			sheet5:SetNWInt("psychedelics_quantity",thequantity)
			duplicator.StoreEntityModifier( sheet5, "psychedelics_data", {data="psychedelics_blotter_".."-"..subMaterial.."-"..tostring(i), matpos=matpos,
			type=thetype,quantity=thequantity} ) --saves the data for duplication
			local pos1="0.0"
			local pos2="0.0"
			if matpos==1 or matpos==3 then pos1=posy2[i]					-- corrects the x position of the submaterial
			elseif matpos==2 or matpos==4 then pos1=posx2[i] end
			if matpos==1 or matpos==2 then pos2="0.5" end 						-- corrects the y position of the submaterial
			if subMaterial!="" then
				net.Start("update_blotter_5sheet")
				net.WriteString(subMaterial)
				net.WriteString(pos1)
				net.WriteString(pos2)
				net.WriteString("psychedelics_5sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(matpos).."-"..tostring(i))
				net.WriteEntity(sheet5)
				net.Broadcast()
			end
		end
	end
end

	
function ENT:Think()
end
