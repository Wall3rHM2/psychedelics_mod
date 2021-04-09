AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local blotter = include("psychedelics/libs/blotter.lua")
local defaultQuantity = 25

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Quantity")
	self:NetworkVar("String", 0, "DataP")
end

function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/blotter/5sheet.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local data = self:GetDataP()
	local quantity = self:GetQuantity()

	if data == "" then
		data = "psychedelicsSheet--1"
		self:SetDataP(data)
	end
	if quantity == 0 then
		quantity = defaultQuantity
		self:SetQuantity(quantity)
	end

	blotter.saveData(data, quantity, self)
	local tab = string.Split(data, "-")
	local subMaterial = tab[2]
	self:GetPhysicsObject():Wake()
	self:Activate()
	if subMaterial ~= "" then self:SetSubMaterial(0, "!" .. data) end
	self:SetNWBool("psychedelicsInitialized", true)
end
function ENT:Use(activator, caller)
	if not (IsValid(caller) and caller:IsPlayer()) then return end
	if activator.usedBlotter then return end -- avoid +use spam
	activator.usedBlotter = true
	timer.Simple(0.2, function()
		if not activator:IsValid() then return end
		activator.usedBlotter = false
	end)

	-- avoids entity spam by cropping sheets
	local count = 0
	for k, v in pairs(ents.FindByClass("psychedelics_blotter_5sheet")) do -- counts how many 5sheets belongs to the player
		if v:CPPIGetOwner() == activator then count = count + 1 end
	end
	if count >= GetConVar("psychedelics_limitspawn_1sheet"):GetInt() then -- limits 5sheet spawn to prevent spam
		net.Start("psychedelicsHintMessage")
		net.WriteString("You have hit this entity limit")
		net.WriteInt(1, 32)
		net.WriteInt(3, 32)
		net.Send(activator)
		return
	end

	-- for when the player add the entity for selling
	local price = GetConVar("psychedelics_lsd_price"):GetInt()
	local quant = self:GetQuantity()
	local money = activator.moneyP
	if money == nil then money = 0 end
	if activator:KeyDown(IN_SPEED) then
		activator.moneyP = money + (price * quant) / 20
		self:Remove()
		return
	end

	-- for when the player crops the 5sheet
	self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
	local data = self:GetDataP()
	local tab = string.Split(data, "-")
	local subMaterial = tab[2]
	local angles5 = self:LocalToWorldAngles(Angle(0, 180, 0))
	local pos = self:GetPos()
	local quantity = self:GetQuantity()
	for c = 1, 5 do
		local sheet1 = ents.Create("psychedelics_blotter_1sheet")
		sheet1:SetPos(pos - self:GetForward() * (2 * (5 - c)) +
						  (self:GetForward() * 6))
		sheet1:CPPISetOwner(activator)
		sheet1:SetAngles(angles5)
		blotter.saveData(data .. "-" .. (c), quantity, sheet1)
		sheet1:Spawn()
		sheet1:Activate()
	end
	self:Remove()
end

function ENT:Think() end
