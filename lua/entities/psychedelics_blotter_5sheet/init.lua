AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local Ug=100

local posur={"0.0","0.1","0.2","0.3","0.4"} --x position for the 5sheet
local posur2={"0.5","0.6","0.7","0.8","0.9"}  --y positions for the 5sheet

local posx={"0.0","0.1","0.2","0.3","0.4"}
local posx2={"0.5","0.6","0.7","0.8","0.9"}

local posy={"0.0","0.1","0.2","0.3","0.4"}
local posy2={"0.5","0.6","0.7","0.8","0.9"}
function ENT:Initialize()
		self:SetModel("models/psychedelics/lsd/blotter/5sheet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():Wake()
		self:Activate()
		local function update_5blotter(ply,ent,data_mod) --apply modifiers from duplicator data
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
			local sheet5=self
			local pos1="0.0"
			local pos2="0.0"
			if matpos==1 or matpos==3 then pos1=posur2[i]					-- corrects the x position of the submaterial
			elseif matpos==2 or matpos==4 then pos1=posur[i] end
			if matpos==1 or matpos==2 then pos2="0.5" end 
			if subMaterial=="" then return end	
    		net.Start("update_blotter_5sheet")
    		net.WriteString(subMaterial)
    		net.WriteString(pos1)
    		net.WriteString(pos2)
    		net.WriteString("psychedelics_5sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(i))
    		net.WriteEntity(sheet5)
    		net.Broadcast()
    	end
		duplicator.RegisterEntityModifier("psychedelics_data",update_5blotter) --saves data for duplication
	end
	
function ENT:Use( activator, caller )
	if IsValid(caller) and caller:IsPlayer()  then
		if activator:GetNWBool("psychedelics_usedblotter",false) then return end
		activator:SetNWBool("psychedelics_usedblotter",true)
		timer.Simple(0.2,function() activator:SetNWBool("psychedelics_usedblotter",false) end)
		local Count=0
		for k, v in pairs( ents.FindByClass( "psychedelics_blotter_1sheet" ) ) do --counts how many 1sheet entities the player has
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
		local data=self:GetNWString("psychedelics_data","psychedelics_blotter_-psychedelics/blotters/bycicle_day-1")
		local matpos=self:GetNWInt("psychedelics_matpos",1)
		local dataTab=string.Split(	data,"-"	)
		subMaterial=dataTab[2]
		local tmaterial=string.Split(subMaterial,"/")
		local x=string.Split(data,"-")
		x=tonumber(x[#x])
		local sheet5=self
		local angles5=sheet5:LocalToWorldAngles(Angle(0,180,0))
		local Pos=self:GetPos()
		local thetype=self:GetNWString("psychedelics_type","lsd")
		local thequantity=self:GetNWInt("psychedelics_quantity",100)
		self:Remove()
		for i=1,5 do
			local sheet1 = ents.Create("psychedelics_blotter_1sheet")
			sheet1:SetPos( Pos-sheet5:GetForward()*(2*(5-i))+(sheet5:GetForward()*6))
			sheet1:CPPISetOwner(activator)
			sheet1:SetAngles( angles5)
			sheet1:Spawn()
			sheet1:Activate()
			sheet1:SetNWString("psychedelics_data","psychedelics_blotter_".."-"..subMaterial.."-"..tostring(x).."-"..tostring(i))
			sheet1:SetNWInt("psychedelics_matpos",matpos)
			sheet1:SetNWString("psychedelics_type",thetype)
			sheet1:SetNWInt("psychedelics_quantity",thequantity)
			duplicator.StoreEntityModifier( sheet1, "psychedelics_data", {data="psychedelics_blotter_".."-"..subMaterial.."-"..tostring(x).."-"..tostring(i), matpos=matpos,
			type=thetype,quantity=thequantity} ) --saves the data for duplication
			local pos1="0.0"
			local pos2="0.0"
			if matpos==1 or matpos==3 then pos1=posx2[x]					-- corrects the x position of the submaterial
			elseif matpos==2 or matpos==4 then pos1=posx[x] end
			if matpos==1 or matpos==2 then pos2=posy2[i]
			else pos2=posy[i] end 						-- corrects the y position of the submaterial
			if subMaterial!="" then
				net.Start("update_blotter_1sheet")
				net.WriteString(subMaterial)
				net.WriteString(pos1)
				net.WriteString(pos2)
				net.WriteString("psychedelics_1sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(matpos).."-"..tostring(x).."-"..tostring(i))
				net.WriteEntity(sheet1)
				net.Broadcast()
			end
		end
	end
end

	
function ENT:Think()
end
