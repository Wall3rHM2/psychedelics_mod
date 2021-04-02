--this file is used to create a submaterial clienstside
if SERVER then
	util.AddNetworkString("psychedelics_hintmessage")
	util.AddNetworkString("update_blotter_sheet")
end

if CLIENT then
	--local debug=""
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
		local matTable = {    
		["$basetexture"] = basematerial,
		["$basetexturetransform"] = "center 0 0 scale " .. (1) .. " " .. (1) .. " rotate 0 translate 0 0",
		["$vertexalpha"] = 0,
		["$vertexcolor"] = 1
		};  
		CreateMaterial(name,"VertexLitGeneric", matTable)
		ent:SetSubMaterial(0,"!"..name)
	end)
	--[[ --below is the old system of updating blotters, dont work very well on dedicated servers
	net.Receive("update_blotter_25sheet",function(len,ply) 
		local basematerial=net.ReadString()
		local pos1=net.ReadString()
		local pos2=net.ReadString()
		local name=net.ReadString()
		local ent=net.ReadEntity()
		local matTable = {		
		["$basetexture"] = basematerial,
		["$basetexturetransform"] = "center 0 0 scale " .. (0.5) .. " " .. (0.5) .. " rotate 0 translate " .. pos1 .. " " .. pos2,
		["$vertexalpha"] = 0,
		["$vertexcolor"] = 1
		};	
		CreateMaterial(name..debug,"VertexLitGeneric", matTable)
		ent:SetSubMaterial(0,"!"..name..debug)
	end)
	net.Receive("update_blotter_5sheet",function(len,ply) 
		local basematerial=net.ReadString()
		local pos1=net.ReadString()
		local pos2=net.ReadString()
		local name=net.ReadString()
		local ent=net.ReadEntity()
		pos1=tostring(tonumber(pos1))
		pos2=tostring(tonumber(pos2))
		local matTable = {    
		["$basetexture"] = basematerial,
		["$basetexturetransform"] = "center 0 0 scale " .. (0.1) .. " " .. (0.5) .. " rotate 0 translate " .. pos1 .. " " .. pos2,
		["$vertexalpha"] = 0,
		["$vertexcolor"] = 1
		};  
		CreateMaterial(name..debug,"VertexLitGeneric", matTable)
		ent:SetSubMaterial(0,"!"..name..debug)
	end)
	net.Receive("update_blotter_1sheet",function(len,ply) 
		local basematerial=net.ReadString()
		local pos1=net.ReadString()
		local pos2=net.ReadString()
		local name=net.ReadString()
		local ent=net.ReadEntity()
		local matTable = {    
		["$basetexture"] = basematerial,
		["$basetexturetransform"] = "center 0 0 scale " .. (0.1) .. " " .. (0.1) .. " rotate 0 translate " .. pos1 .. " " .. pos2,
		["$vertexalpha"] = 0,
		["$vertexcolor"] = 1
		};  
		CreateMaterial(name..debug,"VertexLitGeneric", matTable)
		ent:SetSubMaterial(0,"!"..name..debug)
	end) --]]
end