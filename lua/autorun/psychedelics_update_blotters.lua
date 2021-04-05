--this file is used to create a submaterial clienstside
if SERVER then
	util.AddNetworkString("psychedelics_hintmessage")
	util.AddNetworkString("update_blotter_sheet")
end

if CLIENT then
	net.Receive("psychedelics_hintmessage",function(len,ply)
		local text=net.ReadString()
		local type=net.ReadInt(32)
		local length=net.ReadInt(32)
		notification.AddLegacy( text, type, length )
	end)
	net.Receive("update_blotter_sheet",function(len,ply) 
		local basematerial=net.ReadString()
		local pos1=net.ReadString()
		local pos2=net.ReadString()
		local name=net.ReadString()
		local ent=net.ReadEntity()
		if ent:IsValid() == false then return end
		local matTable = {    
		["$basetexture"] = basematerial,
		["$basetexturetransform"] = "center 0 0 scale " .. (1) .. " " .. (1) .. " rotate 0 translate 0 0",
		["$vertexalpha"] = 0,
		["$vertexcolor"] = 1
		};  
		CreateMaterial(name,"VertexLitGeneric", matTable)
		if ent:IsValid() == false then return end
		ent:SetSubMaterial(0,"!"..name)
	end)
end