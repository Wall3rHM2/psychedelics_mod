--scripts

if SERVER then
	AddCSLuaFile()
	local sharedScripts = file.Find("lua/psychedelics/*.lua", "THIRDPARTY")
	for k, v in pairs(sharedScripts) do --include shared scripts
		local name = "psychedelics/"..v
		AddCSLuaFile(name)
		include(name)
	end

	local clientScripts = file.Find("lua/psychedelics/client/*.lua", "THIRDPARTY")
	for k, v in pairs(clientScripts) do --include client scripts
		AddCSLuaFile("psychedelics/client/"..v)
	end

	--libraries
	local sharedLibs = file.Find("lua/psychedelics/libs/*.lua", "THIRDPARTY")
	for k, v in pairs(sharedLibs) do --include client libraries
		AddCSLuaFile("psychedelics/libs/"..v)
	end

	local clientLibs = file.Find("lua/psychedelics/libs/cl/*.lua", "THIRDPARTY")
	for k, v in pairs(clientLibs) do --include client libraries
		AddCSLuaFile("psychedelics/libs/cl/"..v)
	end

else
	include("psychedelics/init.lua")
	include("psychedelics/sheet_skin_ui.lua")
	include("psychedelics/update_blotters.lua")
	include("psychedelics/client/init.lua")
	include("psychedelics/client/lsd_effect.lua")
	include("psychedelics/client/shrooms_effect.lua")


end