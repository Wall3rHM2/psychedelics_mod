--This library is used for functions used in the 
--psychedelics_blotter_* entities
local lib = {}
--hey now we have submaterial related functions ooo


if CLIENT then
    local scalesX = {"1","0.5","0.1","0.1"} --tables used to scale the texture right
    local scalesY = {"1","0.5","0.5","0.1"}
    local positionsX = {        --tables used for texture positions
        {".5", "0", ".5", "0"},
        {"0.0", "0.1", "0.2", "0.3", "0.4"}
    }
    local positionsY = {
        {".5", ".5", "0", "0"},
        {"0.5", "0.6", "0.7", "0.8", "0.9"}
    }
    
    local function updateSkin(ent,datap)
        local data = datap or ent:GetDataP()
        if data=="" then data = "psychedelicsSheet--1" end
        local tab = string.Split(data, "-")
        local subMaterial = tab[2]
        if subMaterial == "" then return end
        local type  = #tab - 2 --1=sheet, 2=25sheet, 3=5sheet, 4=1sheet
        local a, b, c = tonumber(tab[3]), tonumber(tab[4]), tonumber(tab[5])--example: psychedelicsSheet-material-1-2-3;    a = 1, b = 2, c = 3
        local scaleX = scalesX[type+1]
        local scaleY = scalesY[type+1]
        local posX, posY = "0","0"--default values that already work for sheet
        if type == 1 then   --generates the 25sheet positions
            posX = positionsX[1][ a ]
            posY = positionsY[1][ a ]
    

        elseif type == 2 then --algorithm to generate the 5sheet positions
            if a == 1 or a == 3 then posX = positionsY[2][ b ] --generate X positions
            elseif a == 2 or a == 4 then posX = positionsX[2][ b ] end
    
            if a == 1 or a == 2 then posY = "0.5" end --generate Y positions
    
            
        elseif type == 3 then --algorithm to generate the 1sheet positions
            if a == 1 or a == 3 then posX = positionsY[2][ b ] --generate X positions
            elseif a == 2 or a == 4 then posX = positionsX[2][ b ] end
    
            if a == 1 or a == 2 then posY = positionsY[2][ c ] else -- generate Y positions
            posY = positionsX[2][ c ] end
            
        end

        local matTable = {
            ["$basetexture"] = subMaterial,
            ["$basetexturetransform"] = "center 0 0 scale " .. scaleX .. " " .. scaleY .." rotate 0 translate "..posX.." "..posY,
            ["$vertexalpha"] = 0,
            ["$vertexcolor"] = 1
        };
        CreateMaterial(data, "VertexLitGeneric", matTable)
        ent:SetSubMaterial(0, "!" .. data)
    end

    
    local function tryUpdate(ent)
        if ent:IsValid() == false then return end
        if ent:GetNWBool("psychedelicsInitialized", false) and
            LocalPlayer().psychedelicsPostEnt then
            updateSkin(ent)
        else
            timer.Simple(0.01, function() tryUpdate(ent) end)
        end
    end
    
lib.updateSkin = updateSkin
lib.tryUpdate = tryUpdate


else --serverside
    local function saveData(data, quantity, ent) -- saves data as networkvar
        ent:SetQuantity(quantity)
        ent:SetDataP(data)
    end
    lib.saveData = saveData

end
return lib