if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "psychedelicsDeathL" ) --for lsd
	util.AddNetworkString( "psychedelicsDeathS" ) --for shroom
	util.AddNetworkString( "psychedelicsStartLSD" )
	util.AddNetworkString( "psychedelicsStartShroom" )

	resource.AddWorkshop( "2446913601" ) --content


	local function setSheetSkin(len, ply)
		local sheet = net.ReadEntity()
		if sheet == nil then return end
		if sheet:IsValid() == false then return end

		local plyValid = sheet.validCaller
		if plyValid == nil then return end
		if plyValid:IsValid() == false then return end
		if plyValid ~= ply then return end --avoids exploit

		local materialValid = false
		local validMaterials = file.Find( "materials/psychedelics/blotters/*.vmt", "THIRDPARTY" )
		local material = net.ReadString()
		for i=1,#validMaterials do --only allows for valid materials, so we avoid another exploit
			local formated = "psychedelics/blotters/"..string.gsub(validMaterials[i], ".vmt", "")
			if formated == material then materialValid=true end
		end
		if materialValid == false then return end

		local quantity = sheet:GetNWInt( "psychedelics_quantity", 0)
		local data = "psychedelicsSheet".."-"..material
		if material ~= "" then
			sheet:SetSubMaterial(0, "!"..data)
			sheet:SetDataP(data, quantity)
			net.Start("updateBlotterSheet") --updates the upside submaterial of the 25 blotter sheet
			net.WriteString(data)
			net.WriteEntity(sheet)
			net.Broadcast()
		end
	end
	net.Receive( "psychedelicsSheetSkinMat", setSheetSkin)
	--Hooks
	hook.Add("PlayerDeath", "psychedelicsDeath", function(ply)
		ply:SetNWInt("psychedelicsSellMoney", 0)
		net.Start("psychedelicsDeathL")
		net.WriteEntity(ply)
		net.Send(ply)
		net.Start("psychedelicsDeathS")
		net.WriteEntity(ply)
		net.Send(ply)
	end)
	hook.Add("PlayerSilentDeath","psychedelicsDeathS",function(ply)
		ply:SetNWInt("psychedelicsSellMoney", 0)
		net.Start("psychedelicsDeathL")
		net.WriteEntity(ply)
		net.Send(ply)
		net.Start("psychedelicsDeathS")
		net.WriteEntity(ply)
		net.Send(ply)
	end)
	--ConVars
	CreateConVar("psychedelics_limitspawn_25sheet", 2, FCVAR_ARCHIVE, "Limits how much of the 25sheet entity can be spawn by using the blotter_sheet")
	CreateConVar("psychedelics_limitspawn_5sheet", 8, FCVAR_ARCHIVE, "Limits how much of the 5sheet entity can be spawn by using the blotter_25sheet")
	CreateConVar("psychedelics_limitspawn_1sheet", 5, FCVAR_ARCHIVE, "Limits how much of the 1sheet entity can be spawn by using the blotter_5sheet")
	CreateConVar("psychedelics_lsd_price", 100, FCVAR_ARCHIVE, "Set the price of one lsd blotter for selling")
	CreateConVar("psychedelics_mushroom_price", 1250, FCVAR_ARCHIVE, "Set the price of one single mushroom")
	CreateConVar("psychedelics_mushroom_grow_rate", 1.2, FCVAR_ARCHIVE, "Time in seconds to proccess the growing tick")
end

if CLIENT then
	CreateConVar("psychedelics_tips", 1, FCVAR_ARCHIVE, "Enable or disable the tips in entities")
end