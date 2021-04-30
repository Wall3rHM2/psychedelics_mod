-- this file is used to create a submaterial clienstside
if SERVER then
    util.AddNetworkString("psychedelicsHintMessage")
    util.AddNetworkString("updateBlotterSheet")
end

if CLIENT then
    local blotter = include("psychedelics/libs/blotter.lua")
    net.Receive("psychedelicsHintMessage", function(len, ply)
        local text = net.ReadString()
        local type = net.ReadInt(32)
        local length = net.ReadInt(32)
        notification.AddLegacy(text, type, length)
    end)
    net.Receive("updateBlotterSheet", function(len, ply)
        local data = net.ReadString()
        local ent = net.ReadEntity()
        if ent:IsValid() == false then return end
        blotter.updateSkin(ent, data)
    end)
end
