local sounds = { -- sounds for auditory hallucinations
    "vo/ravenholm/shotgun_overhere.wav", "vo/ravenholm/madlaugh03.wav",
    "ambient/alarms/train_horn2.wav", "ambient/creatures/teddy.wav",
    "ambient/levels/citadel/strange_talk3.wav",
    "ambient/levels/citadel/strange_talk5.wav",
    "ambient/levels/citadel/weaponstrip1_adpcm.wav",
    "ambient/levels/labs/teleport_weird_voices2.wav",
    "ambient/materials/footsteps_wood1.wav",
    "ambient/materials/footsteps_wood2.wav"
}
-- functions used to create the hallucination functions
local function theSpawn(name, ent, removeTime, callback)
    local removeCount = 0
    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    local alpha = 0
    ent:SetColor(Color(ent:GetColor().r, ent:GetColor().g, ent:GetColor().b, 0))
    timer.Create(name, 0.01, 102, function()
        local color = ent:GetColor()
        if alpha < 255 then
            alpha = alpha + 5
            ent:SetColor(Color(color.r, color.g, color.b, alpha))
        end
    end)
    timer.Simple(removeTime, function()
        timer.Create(name .. "remove", 0.01, 103, function()
            removeCount = removeCount + 1
            local color = ent:GetColor()
            if color.a > 0 then
                alpha = alpha - 5
                ent:SetColor(Color(color.r, color.g, color.b, alpha))
            end
            if removeCount >= 103 then
                if callback ~= nil then callback() end
                ent:Remove()
            end
        end)
    end)
end

local function basePos(drugName, ent, removeTime, removeCallback)
    local aimPos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 150
    theSpawn(drugName, ent, removeTime, removeCallback)
    ent:SetPos(Vector(aimPos.x, aimPos.y, LocalPlayer():GetPos().z))
    ent:SetAngles(Angle(0, LocalPlayer():GetAngles().y, 0))
end

local function playRandom()
    local id = math.random(1, #sounds)
    LocalPlayer():EmitSound(sounds[id], 75, math.random(70, 120))
end


local hallucinations = {

	-- hallucination n 1
    function(drugName)
        local fishes = {}
        for i = 1, 10 do
            fishes[i] = ClientsideModel("models/props/CS_militia/fishriver01.mdl", RENDERGROUP_STATIC)
            if i == 1 then
                local sound = LocalPlayer():StartLoopingSound("ambient/water/underwater.wav")
                basePos(drugName .. "fishes" .. tostring(i), fishes[i], 20, function()
                    LocalPlayer():StopLoopingSound(sound)
                    hook.Remove("Think", drugName .. "fishesMove")
                end)
            else
                basePos(drugName .. "fishes" .. tostring(i), fishes[i], 20)
            end
            local thevec = Vector(math.random(-70, 70), math.random(-70, 70), math.random(10, 80))
            fishes[i]:SetPos(fishes[i]:LocalToWorld(thevec))
        end
        hook.Add("Think", drugName .. "fishesMove", function()
            for i = 1, #fishes do
                if fishes[i]:IsValid() then
                    fishes[i]:SetPos(fishes[i]:LocalToWorld(Vector(0.01, 0, 0)))
                end
            end
        end)
    end, 

	-- hallucination n 2
    function(drugName)
        local id = 0
        local x = math.random(-70, 70)
        local y = math.random(-70, 70)
        local yaw = math.random(-180, 180)
        local table = ClientsideModel("models/props_c17/FurnitureTable001a.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "theCallTable", table, 20, function()
            timer.Remove(drugName .. "theCallRing")
            LocalPlayer():StopLoopingSound(id)
        end)
        table:SetPos(table:LocalToWorld(Vector(x, y, 20)))
        table:SetAngles(table:LocalToWorldAngles(Angle(0, yaw, 0)))
        local phone = ClientsideModel("models/props/cs_office/phone.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "theCallPhone", phone, 20)
        phone:SetPos(phone:LocalToWorld(Vector(x, y, 38)))
        phone:SetAngles(phone:LocalToWorldAngles(Angle(0, 180, 0)))
        phone:SetAngles(phone:LocalToWorldAngles(Angle(0, yaw, 0)))
        local ring = 0
        timer.Create(drugName .. "theCallRing", 1, 30, function()
            if ring < 1 then
                ring = ring + 1
            else
                ring = 0
            end
            if ring == 1 then
                id = LocalPlayer():StartLoopingSound("ambient/alarms/city_firebell_loop1.wav", 75, 70)
            else
                LocalPlayer():StopLoopingSound(id)
            end
        end)
    end, 
	
	-- hallucination n 3
    function(drugName)
        local time = 6
        local x = math.random(-70, 370) -- 370
        local y = math.random(-4, 4)

        local body = ClientsideModel("models/props/cs_office/Snowman_body.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "snowmanBody", body, time, function()
            hook.Remove("Think", drugName .. "snowmanMove")
        end)
        body:SetPos(body:LocalToWorld(Vector(x, y, 21)))

        local head = ClientsideModel("models/props/cs_office/Snowman_face.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "snowmanHead", head, time)
        head:SetPos(head:LocalToWorld(Vector(x, y, 47)))
        head:SetAngles(head:LocalToWorldAngles(Angle(0, 90, 0)))

        local lArm = ClientsideModel("models/props/cs_office/Snowman_arm.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "snowmanLArm", lArm, time)
        lArm:SetPos(lArm:LocalToWorld(Vector(x, y - 16, 38)))
        lArm:SetAngles(lArm:LocalToWorldAngles(Angle(20, -90, 0)))

        local rArm = ClientsideModel("models/props/cs_office/Snowman_arm.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "snowmanRArm", rArm, time)
        rArm:SetPos(rArm:LocalToWorld(Vector(x, y + 13, 38)))
        rArm:SetAngles(rArm:LocalToWorldAngles(Angle(25, 90, 0)))

        local sound = "vo/npc/male01/hi0" .. tostring(math.random(1, 2)) .. ".wav"
        timer.Simple(2, function() body:EmitSound(sound) end)
    end, 
	
	-- hallucination n 4
    function(drugName)
        local x = math.random(-70, 70)
        local y = math.random(-20, 20)

        local door = ClientsideModel( "models/props_doors/door03_slotted_left.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "doorEntity", door, 7, function() 
			hook.Remove(drugName .. "doorMove") 
		end)
        door:SetPos(door:LocalToWorld(Vector(x, y, 53)))

        local ang = door:GetAngles() --rotate the door
        timer.Simple(2, function()
            if not door:IsValid() then return end
            door:EmitSound("doors/door1_move.wav")
            local count = 0
            hook.Add("Think", drugName .. "doorMove", function()
                if count < 180 and door:IsValid() then
                    ang:RotateAroundAxis(door:GetUp(), -0.5)
                    door:SetAngles(ang)
                    count = count + 1
                else
                    hook.Remove(drugName .. "doorMove")
                end
            end)
        end)
    end, 
	
	-- hallucination n 5
	function(drugName)
        local hName = "dogSign" --hallucination name
        local dogSign = ClientsideModel("models/props_lab/bewaredog.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. hName, dogSign, 8)
        local x = math.random(-70, 70)
        local y = math.random(-70, 70)
        dogSign:SetPos(dogSign:LocalToWorld(Vector(x, y, 0)))
        dogSign:SetAngles(dogSign:LocalToWorldAngles(Angle(0, 180, 0)))
        timer.Simple(2, function() if not dogSign:IsValid() then return end
            dogSign:EmitSound("ambient/animal/dog" .. tostring(math.random(1, 6)) .. ".wav")
        end)
    end, 

	-- hallucination n 6
	function(drugName)
        local x = math.random(-70, 70)
        local y = math.random(-70, 70)
        local yaw = math.random(-180, 180)
        local gman = ClientsideModel("models/player/gman_high.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "gman", gman, math.random(18, 22))
        gman:SetPos(gman:LocalToWorld(Vector(x, y, 0)))
        gman:SetAngles(gman:LocalToWorldAngles(Angle(0, yaw, 0)))
    end, 
	
	-- hallucination n 7
	function(drugName)
        local x = math.random(-70, 70)
        local y = math.random(-70, 70)
        local yaw = math.random(-180, 180)
        local headcrab = ClientsideModel("models/headcrabclassic.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "headcrab", headcrab, math.random(16, 24))
        headcrab:SetPos(headcrab:LocalToWorld(Vector(x, y, 0)))
        headcrab:SetAngles(headcrab:LocalToWorldAngles(Angle(0, yaw, 0)))
    end, 
	
	-- hallucination n 8
	function(drugName)
        local x = math.random(-70, 70)
        local y = math.random(-70, 70)
        local yaw = math.random(-45, 45)
        local table = ClientsideModel("models/props_interiors/Furniture_Desk01a.mdl", RENDERGROUP_STATIC)

        basePos(drugName .. "computerTable", table, 18)
        table:SetAngles(table:LocalToWorldAngles(Angle(0, yaw, 0)))
        table:SetPos(table:LocalToWorld(Vector(x, y, 19.8)))
        table:SetAngles(table:LocalToWorldAngles(Angle(0, 180, 0)))

        local chair = ClientsideModel("models/props_interiors/Furniture_chair03a.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "computerChair", chair, 18)
        chair:SetAngles(chair:LocalToWorldAngles(Angle(0, yaw, 0)))
        chair:SetPos(chair:LocalToWorld(Vector(x, y, 19)))
        chair:SetPos(chair:LocalToWorld(Vector(-26, 0, 0)))

        local computer = ClientsideModel("models/props_lab/monitor02.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "computerEntity", computer, 18)
        computer:SetAngles(computer:LocalToWorldAngles(Angle(0, yaw, 0)))
        computer:SetPos(computer:LocalToWorld(Vector(x, y, 39)))
        computer:SetPos(computer:LocalToWorld(Vector(10, 0, 0)))
        computer:SetAngles(computer:LocalToWorldAngles(Angle(0, 180, 0)))
        computer:SetSkin(1)
    end, 
	
	-- hallucination n 9
	function(drugName)
        local x = math.random(-70, 470)
        local y = math.random(-70, 70)
        local yaw = math.random(-180, 180)
        local bicycle = ClientsideModel("models/props_junk/bicycle01a.mdl", RENDERGROUP_STATIC)
        basePos(drugName .. "bicycle", bicycle, math.random(7, 20), function()
            hook.Remove("Think", drugName .. "bicycleMove")
        end)
        bicycle:SetPos(bicycle:LocalToWorld(Vector(x, y, 21.4)))
        bicycle:SetAngles(bicycle:LocalToWorldAngles(Angle(0, yaw, 0)))
        hook.Add("Think", drugName .. "bicycleMove", function()
            if bicycle:IsValid() then
                bicycle:SetPos(bicycle:LocalToWorld(Vector(0.5, 0, 0)))
            end
        end)
    end, 

	playRandom, -- hallucination n 10
    playRandom, -- hallucination n 11
    playRandom -- hallucination n 12

}
local api = {}
function api.randomHallucination(drugName)
    hallucinations[math.random(1, #hallucinations)](drugName)
end
function api.hallucination(index, drugName) 
	hallucinations[index](drugName) 
end
return api
