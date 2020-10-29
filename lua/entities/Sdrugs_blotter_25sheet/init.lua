AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local quantity=100
local type="lsd"
local subMaterial="psychedelics_mod/blotters/bycicle_day"
local Ded={".5","0",".5","0"}
local Ded2={".5",".5","0","0"}

local posur={"0.1","0.2","0.3","0.4","0.5"}
local posur2={"0.6","0.7","0.8","0.9","1.0"}


function ENT:Initialize()
		self:SetModel("models/psychedelics_mod/lsd/blotter/25sheet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():Wake()
		self:Activate()
	    timer.Simple(0.1,function()
		 quantity=self:GetNWInt( "psychedelics_mod_quantity", 100 )
  		 local type=self:GetNWString("psychedelics_mod_type","lsd")
		 local data=self:GetNWString("psychedelics_mod_blotter_data","psychedelics_mod_blotter_-psychedelics_mod/blotters/bycicle_day-1")
		 local dataTab=string.Split(	data,"-"	)
		 subMaterial=dataTab[2]
		 local tmaterial=string.Split(subMaterial,"/")
		 local i=string.Split(data,"-")
		 i=tonumber(i[#i])
		 local sheet25=self
    	 net.Start("update_blotter_25sheet")
    	 net.WriteString(subMaterial)
    	 net.WriteString(Ded[i])
    	 net.WriteString(Ded2[i])
    	 net.WriteString("psychedelics_mod_25sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(i))
    	 net.WriteEntity(sheet25)
    	 net.Broadcast()
    	end)
	end
	
function ENT:Use( activator, caller )	
	if IsValid(caller) and caller:IsPlayer()  then
		if activator:GetNWBool("psychedelics_mod_usedblotter",false) then return end
		activator:SetNWBool("psychedelics_mod_usedblotter",true)
		timer.Simple(0.2,function() activator:SetNWBool("psychedelics_mod_usedblotter",false) end)
		local Count=0
		for k, v in pairs( ents.FindByClass( "psychedelics_mod_blotter_5sheet" ) ) do
			if v:CPPIGetOwner()==activator then
				Count=Count+1
			end
		end
		if Count>=GetConVar("psychedelics_mod_limitspawn_5sheet"):GetInt() then
			net.Start("psychedelics_mod_hintmessage")
			net.WriteString("You have hit this entity limit")
			net.WriteInt(1,32)
			net.WriteInt(3,32)
			net.Send(activator)
		return end
		self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
 		local data=self:GetNWString("psychedelics_mod_blotter_data","psychedelics_mod_blotter_-psychedelics_mod/blotters/bycicle_day-1")
		local matpos=self:GetNWInt("matpos",1)
		local dataTab=string.Split(	data,"-"	)
		subMaterial=dataTab[2]
		local tmaterial=string.Split(subMaterial,"/")
		local sheet25=self
		local angles25=sheet25:LocalToWorldAngles(Angle(0,-90,0))
		local Pos=self:GetPos()
		local thetype=self:GetNWString("psychedelics_mod_type","lsd")
		local thequantity=self:GetNWInt("psychedelics_mod_quantity",100)
		self:Remove()
		for i=1,5 do
			local sheet5 = ents.Create("psychedelics_mod_blotter_5sheet")
			sheet5:SetPos( Pos-sheet25:GetForward()*(4*i)+(sheet25:GetForward()*10))
			sheet5:CPPISetOwner(activator)
			sheet5:SetAngles( angles25)
			sheet5:Spawn()
			sheet5:Activate()
			sheet5:SetNWString("psychedelics_mod_blotter_data","psychedelics_mod_blotter_".."-"..subMaterial.."-"..tostring(i))
			sheet5:SetNWInt("matpos",matpos)
			sheet5:SetNWString("psychedelics_mod_type",thetype)
			sheet5:SetNWInt("psychedelics_mod_quantity",thequantity)
			duplicator.StoreEntityModifier( sheet5, "psychedelics_mod_blotter_data", {data="psychedelics_mod_blotter_".."-"..subMaterial.."-"..tostring(i), matpos=matpos,
			type=thetype,quantity=thequantity} ) --saves the data
			local pos1="0.1"
			local pos2="0.0"

			if matpos==1 or matpos==3 then pos1=posur[i]					-- corrects the x position of the submaterial
			elseif matpos==2 or matpos==4 then pos1=posur2[i] end

			if matpos==1 or matpos==2 then pos2="0.5" end 						-- corrects the y position of the submaterial
			timer.Simple(0.1,function()
				net.Start("update_blotter_5sheet")
				net.WriteString(subMaterial)
				net.WriteString(pos1)
				net.WriteString(pos2)
				net.WriteString("psychedelics_mod_5sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(matpos).."-"..tostring(i))
				net.WriteEntity(sheet5)
				net.Broadcast()
			end)
		end
	end
end

	
function ENT:Think()
end
