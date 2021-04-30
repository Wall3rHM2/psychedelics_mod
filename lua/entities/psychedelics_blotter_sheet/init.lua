if CLIENT then return end
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
local blotter = include("psychedelics/libs/blotter.lua")
--local type = "lsd" -- maybe i will add NBOMe in the future and/or DOB, DOC
local defaultQuantity = 0 -- default quantity of LSD, mainly used for debuging
local material = "" -- default material --psychedelics/blotters/sroad
local defaultData = "psychedelicsSheet-" .. material


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Quantity")
	self:NetworkVar("String", 0, "DataP")
end
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/blotter/sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	--self:SetQuantity(200)
	local data = self:GetDataP()
	local quantity = self:GetQuantity()
	if data == "" then
		data = defaultData
		self:SetDataP( data )
	end
	local dataTab = string.Split(data, "-")
	local subMaterial = dataTab[2]
	if subMaterial ~= "" then self:SetSubMaterial(0, "!" .. data) end
	blotter.saveData(data, quantity, self)
	self:GetPhysicsObject():Wake()
	self:Activate()
	self:SetNWBool("psychedelicsInitialized", true) -- we need it to be networked and we cant use networkvar because it would save the bool
end

function ENT:Use(activator, caller)

	if not (IsValid(caller) and caller:IsPlayer())  then return end
	if activator.usedBlotter then return end --avoid +use spam
	activator.usedBlotter = true
	timer.Simple(0.2,function() 
		if not activator:IsValid() then return end
		activator.usedBlotter = false 
	end)

	local price = GetConVar("psychedelics_lsd_price"):GetInt()
	local quant = self:GetQuantity()
	local money = activator.moneyP
	if money == nil then money = 0 end
	if activator:KeyDown(IN_SPEED) then -- adds the lsd sheet for selling
		activator.moneyP = money + price * quant
		self:Remove()
		return
	end

	if quant == 0 then -- opens menu to choose sheet skin
		self.validCaller = activator -- here we avoid a exploit of setting other players sheet skin by client net message
		net.Start("psychedelicsSheetSkinUI")
		net.WriteEntity(self)
		net.Send(activator)
		return
	end

	local count = 0
	for k, v in pairs(ents.FindByClass("psychedelics_blotter_25sheet")) do -- count function used to limit max spawned blotters
		if v:CPPIGetOwner() == activator then count = count + 1 end
	end
	
	if count >= GetConVar("psychedelics_limitspawn_25sheet"):GetInt() then -- limits the spawn of 25 blotter sheet by a convar
		net.Start("psychedelicsHintMessage")
		net.WriteString("You have hit this entity limit")
		net.WriteInt(1, 32)
		net.WriteInt(3, 32)
		net.Send(activator)
		return
	end

	self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
	local pos = self:GetPos()
	local quantity = self:GetQuantity()
	local data = self:GetDataP()
	local dataTab = string.Split(data, "-")
	local subMaterial = dataTab[2]
	self:Remove()

	for a = 1, 4 do
		local sheet25 = ents.Create("psychedelics_blotter_25sheet")
		sheet25:SetPos(pos + Vector(0, 0, 2 * a))
		sheet25:CPPISetOwner(activator)
		sheet25:SetAngles(Angle(0, 0, 0))
		blotter.saveData(data.."-"..(a), quantity, sheet25)
		sheet25:Spawn()
		sheet25:Activate()
	end
end

function ENT:Touch(flask) -- function for add lsd substance to blotter sheet paper
	if not flask:IsValid() then return end
	if (flask:GetClass() == "psychedelics_flask" and flask.level == 9) == false then
		return
	end
	flask.level = 8 -- since the remove will be done in the next tick,we need
	flask:Remove() -- to change the flask level or otherwise it would call the Touch 2 times

	local quantity = self:GetQuantity()
	quantity = quantity + 25
	self:SetQuantity(quantity)
end

function ENT:Think() end
