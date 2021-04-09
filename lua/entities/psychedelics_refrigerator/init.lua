AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function freeSpace(base) -- removes the flasks from inside the refrigerator and fixes counts
	base.space = "0-0-0-0-0" --reset space avaible
	base.count = 5 --reset flask count
	local flasks = ents.FindByClassAndParent("psychedelics_flask", base)
	for k, v in pairs(flasks) do --finds all flasks to remove from refrigerator
		local pos = v:GetPos()
		v:SetParent(nil)
		v:SetSkin(2)
		v:SetPos(pos) -- for some reason, when i unparent this entity, it goes to refrigerator 0 local position
		v:GetPhysicsObject():EnableMotion(true)
		v.level = 9
		v:SetNWString("psychedelicsTipText", "Add to a blotter paper sheet")
	end
end



local function openDoor(base, axis) -- only 1 tick, needs to be called multiple times
	if not (base:IsValid() or axis:IsValid()) then return end

	local angle = base.angle - 5
	axis:SetAngles(base:LocalToWorldAngles(Angle(0, angle, 0)))
	base.angle = angle
end


local function closeDoor(base, axis)
	if not (base:IsValid() or axis:IsValid()) then return end

	local angle = base.angle + 5
	axis:SetAngles(base:LocalToWorldAngles(Angle(0, angle, 0)))
	base.angle = angle
end



local function animateDoor(base)
	local lowDoor = base:GetNWEntity("psychedelicsLowDoor", nil)
	local upperDoor = base:GetNWEntity("psychedelicsUpperDoor", nil)
	local axis = base:GetNWEntity("psychedelicsAxis", nil)

	if not base:IsValid() then return end
	if (not upperDoor:IsValid() or not lowDoor:IsValid() or not axis:IsValid()) then
		return
	end
	local angle = base.angle


	if not base.isOpen and angle == 0 then -- opens the door
		timer.Create("psychedelicsDoorOpen" .. base:EntIndex(), 0.01, 30, function()
			openDoor(base, axis)
		end)
		base.isOpen = true

	elseif base.isOpen and angle == -150 then -- closes the door
		timer.Create("psychedelicsDoorOpen" .. base:EntIndex(), 0.01, 30, function()
			closeDoor(base, axis)
		end)
		base.isOpen = false
	end

end


local function adjustTemp(base) -- function used to adjust the temperature
	if not (base:IsValid()) then return end
	local isOpen = base.isOpen or false
	local temp = base:GetNWInt("psychedelicsTemp", 22)
	local doorAng = base.angle or 0

	if isOpen and temp < 22 then --when opened, increases temperature
		temp = temp + 1
		base:SetNWInt("psychedelicsTemp", temp)
	elseif not (isOpen) and temp > 0 and doorAng == 0 then --when closed, lowers temperature
		temp = temp - 1
		base:SetNWInt("psychedelicsTemp", temp)
	end

	local delay = (22 - temp) / 10 + 1.0
	timer.Simple(delay, function() adjustTemp(base) end) -- the lower the temperature, the more it takes to change
end


local function adjustProgress(base) -- function used to adjust the progress of freezing
	if not (base:IsValid()) then return end
	local isOpen = base.isOpen or false
	local temp = base:GetNWInt("psychedelicsTemp", 22)
	local progress = base:GetNWInt("psychedelicsProgress", 0)
	local doorAng = base.angle or 0
	local count = base.count or 5

	timer.Simple(2.1, function() adjustProgress(base) end) -- debug, return to 2.1 value
	if isOpen or doorAng ~= 0 or count >= 5 then return end -- only adjust progress when the door is closed

	if (temp == 0 and progress < 100) then
		base:SetNWInt("psychedelicsProgress", progress + 1)
		base:SetNWString("psychedelicsTipText", "Wait for it to freeze")
		base.level = 2
	elseif (temp == 0) then -- when the progress goes to 100%
		base:SetNWString("psychedelicsTipText", "Add a flask")
		base.level = 0
		base:SetNWInt("psychedelicsProgress", 0)
		freeSpace(base)
		animateDoor(base)
	else

	end

end


local function initDoors(base)
	local classes = {
		"psychedelics_base_axis", "psychedelics_base_door",
		"psychedelics_base_door"
	}
	local models = {
		"models/hunter/blocks/cube025x025x025.mdl",
		"models/props_interiors/refrigeratorDoor01a.mdl",
		"models/props_interiors/refrigeratorDoor02a.mdl"
	}
	local positions = {
		Vector(16, -15, 35), Vector(16, 0, -7.4), Vector(16, 0, 29.2)
	}
	local entities = {}
	for i = 1, 3 do 
		local class = classes[i]
		entities[i] = ents.Create(class) 
		local ent = entities[i]
		ent:SetModel(models[i])
		ent:SetPos(base:LocalToWorld(positions[i]))
		ent:Spawn()
		ent:GetPhysicsObject():EnableMotion(false)
		ent:SetAngles(base:LocalToWorldAngles(Angle(0, 0, 0)))
		if class == "psychedelics_base_axis" then ent:SetParent(base)
		else
			ent:SetParent(entities[1])
		end
		ent:SetNWEntity("psychedelicsDoorBase", base)
	end
	base:SetNWEntity("psychedelicsAxis", entities[1])
	base:SetNWEntity("psychedelicsUpperDoor", entities[2])
	base:SetNWEntity("psychedelicsLowDoor", entities[3])
end

function ENT:Initialize()
	self:SetModel("models/props_interiors/refrigerator01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetPos(self:LocalToWorld(Vector(0, 0, 40)))
	self:GetPhysicsObject():SetMass(240) -- enables the entity to be picked by gravgun
	self:GetPhysicsObject():Wake()
	self:Activate()
	self.isOpen = false --default door animation
	self.angle = 0	--default door angle
	adjustTemp(self) --debug / print; remove comment pls
	adjustProgress(self)
	initDoors(self)
	self:SetNWInt("psychedelicsTemp", 1)
end

function ENT:Use(activator, caller)
	if activator.usedDoor or self:GetNWBool("psychedelicsProgress", 0) ~= 0 then return end
	activator.usedDoor = true
	self:EmitSound("doors/door1_move.wav", 75, 100, 1)
	timer.Simple(1, function()
		if not activator:IsValid() then return end
		activator.usedDoor = false
	end) -- avoids +use spam
	animateDoor(self)
end


local function sortSpace(ent,flask) --sorts the string in the refrigerator used for space check
	local offsetPos = {
		Vector(0, 0, -33), Vector(0, 0, -18.5), -- offset positions used to setpos in the available spaces
		Vector(0, 0, -5), Vector(0, 0, 8.25), Vector(0, 0, 21.5) 
		}
	local freeTable = ent.space or "0-0-0-0-0"
	freeTable = string.Split(freeTable, "-") -- this is used to know which spaces are occupied or not
	local freeString = ""
	local repeatTable = true

	for i = 1, 5 do
		if (freeTable[i] == "0" and repeatTable) then --alocates space for a flask
			flask:SetPos(ent:LocalToWorld(offsetPos[i]))
			freeTable[i] = "1"
			repeatTable = false
		end

		if (i == 1) then --first element of string
			freeString = freeTable[i]
		else --other elements
			freeString = freeString .. "-" .. freeTable[i]
		end
	end
	return freeString
end


function ENT:Touch(flask)
	local isOpen = self.isOpen
	if not (flask:GetClass() == "psychedelics_flask" and flask.level == 7 and isOpen) then return end
		
	flask:GetPhysicsObject():EnableMotion(false)
	flask:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 0)))

	local count = self.count or 5
	if (count <= 0) then return end -- if there is no space available, it already returns end


	local space = sortSpace(self,flask)
	flask:SetParent(self)
	self.space = space
	self.count = count - 1
	self:SetNWString("psychedelicsTipText", "Close the door and reach 0°")
	self.level = 1
	flask.level = 8
	flask:SetNWString("psychedelicsTipText", "")
	constraint.NoCollide(self, flask, 0, 0)

end
function ENT:Think() end
