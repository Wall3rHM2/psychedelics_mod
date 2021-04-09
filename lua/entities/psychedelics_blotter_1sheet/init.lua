AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")local blotter = include("psychedelics/libs/blotter.lua")
local defaultQuantity = 25

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Quantity")
	self:NetworkVar("String", 0, "DataP")
end
local function SaveData(data_mod, ent) -- saves data as networkvar
	ent:SetQuantity(data_mod.quantity)
	ent:SetDataP(data_mod.data)
end
function ENT:Initialize()
	self:SetModel("models/psychedelics/lsd/blotter/1sheet.mdl")
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

	-- Adds entity for selling
	local price = GetConVar("psychedelics_lsd_price"):GetInt()
	local quant = self:GetQuantity()
	local money = activator.moneyP
	if money == nil then money = 0 end
	if activator:KeyDown(IN_SPEED) then
		activator.moneyP = money + (price * quant) / 100
		self:Remove()
		return
	end

	-- Calls the LSD effect in client
	print(quant)
	net.Start("psychedelicsStartLSD")
	net.WriteInt(quant,20)
	net.Send(caller)
	self:Remove()

end

function ENT:Think() end
