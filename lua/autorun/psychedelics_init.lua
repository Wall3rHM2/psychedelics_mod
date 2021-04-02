if SERVER then
	util.AddNetworkString( "PsychedelicsDeath" )
	util.AddNetworkString( "LSDmeuStart" )
	util.AddNetworkString( "ShroommeuStart" )
	util.AddNetworkString( "psychedelics_postentity" )
	--Net messages
	net.Receive("psychedelics_postentity",function(len,ply) 
		ply:SetNWBool("psychedelics_postinit",true)
	end)
	local function SetSheetSkin(len,ply)
		local sheet=net.ReadEntity()
		if sheet==nil then return end
		if !sheet:IsValid() then return end
		local ply_valid=sheet:GetNWEntity("psychedelics_valid_caller",nil)
		if ply_valid==nil then return end
		if !ply_valid:IsValid() then return end
		if ply_valid~=ply then return end --avoids exploit
		local material_valid=false
		local valid_materials = file.Find( "materials/psychedelics/blotters/*.vmt", "THIRDPARTY" )
		local material=net.ReadString()
		local tmaterial=string.Split(material,"/")
		for i=1,#valid_materials do --only allows for valid materials, so we avoid another exploit
			local formated="psychedelics/blotters/"..string.gsub(valid_materials[i],".vmt","")
			if formated == material then material_valid=true end
		end
		if material_valid == false then return end
		local quantity = sheet:GetNWInt( "psychedelics_quantity", 0)
		local type = sheet:GetNWString("psychedelics_type","lsd")
		local data = "psychedelics_blotter_".."-"..material
		local dataTab = string.Split(	data,"-" )
		local name = "psychedelics_blotter_".."-"..material
		duplicator.StoreEntityModifier( sheet, "psychedelics_data", {data=data, matpos=i, --saves the data for duplication
		type=type,quantity=quantity} ) 
		if material~="" then 
			sheet:SetSubMaterial(0, "!"..name)
			sheet:SetNWString("psychedelics_data",data)
			net.Start("update_blotter_sheet") --updates the upside submaterial of the 25 blotter sheet
			net.WriteString(material)
			net.WriteString("0")
			net.WriteString("0")
			net.WriteString(name)
			net.WriteEntity(sheet)
			net.Broadcast()
		end
	end
	net.Receive( "PsychedelicsSheetSkin_Mat", SetSheetSkin)
	--Hooks
	hook.Add("PlayerDeath","PsychedelicsDeath",function(ply)
		net.Start("PsychedelicsDeath")
		net.WriteEntity(ply)
		net.Send(ply)
	end)
	hook.Add("PlayerSilentDeath","PsychedelicsDeath",function(ply)
		net.Start("PsychedelicsDeath")
		net.WriteEntity(ply)
		net.Send(ply)
	end)
	--ConVars
	CreateConVar("psychedelics_limitspawn_25sheet",2,FCVAR_ARCHIVE,"Limits how much of the 25sheet entity can be spawn by using the blotter_sheet")
	CreateConVar("psychedelics_limitspawn_5sheet",8,FCVAR_ARCHIVE,"Limits how much of the 5sheet entity can be spawn by using the blotter_25sheet")
	CreateConVar("psychedelics_limitspawn_1sheet",5,FCVAR_ARCHIVE,"Limits how much of the 1sheet entity can be spawn by using the blotter_5sheet")
	CreateConVar("psychedelics_lsd_price",100,FCVAR_ARCHIVE,"Set the price of one lsd blotter for selling")
	CreateConVar("psychedelics_mushroom_price",2500,FCVAR_ARCHIVE,"Set the price of one single mushroom")
	--Duplicator save
	local function UpdateSavedBlotter( ply, ent, ddata )
		ent:SetNWString("psychedelics_blotter_data",ddata.data)
		ent:SetNWInt("matpos",ddata.matpos)
		ent:SetNWInt("psychedelics_quantity",ddata.quantity)
		ent:SetNWString("psychedelics_type",ddata.type) 
	end
	duplicator.RegisterEntityModifier( "sdrugs_blotter_data", UpdateSavedBlotter  )

end

if CLIENT then
	CreateConVar("psychedelics_tips",1,FCVAR_ARCHIVE,"Enable or disable the tips in entities")
end