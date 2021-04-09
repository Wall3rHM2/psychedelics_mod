if SERVER then
    util.AddNetworkString("psychedelicsSheetSkinUI") -- for client UI
    util.AddNetworkString("psychedelicsSheetSkinMat") -- for server to receive the material
    return
end
local function sendMaterial(material, sheet)
    net.Start("psychedelicsSheetSkinMat")
    net.WriteEntity(sheet)
    net.WriteString(material)
    net.SendToServer()
end
local function setBlotterSkin()
    local sheet = net.ReadEntity()
    local w, h = ScrW(), ScrH()
    local sizeW, sizeH = w / 5, w / 5
    local offsetW, offsetH = w / 44, h / 44 -- makes sure the content dont touch the borders
    local files, directories = file.Find(
                                   "materials/psychedelics/blotters/*.vmt",
                                   "THIRDPARTY")
    local buttons = {} -- saves the buttons spawned in derma
    local frame = vgui.Create("DFrame")
    local closed = false

    frame:SetPos(w / 2 - sizeW / 2, h / 2 - sizeH / 2) -- math used to center
    frame:SetSize(sizeW, sizeH)
    frame:SetTitle("Select a blotter texture")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(40, 41, 35))
    end
    function frame:OnClose() closed = true end

    local dScrollPanel = vgui.Create("DScrollPanel", frame)
    dScrollPanel:SetSize(sizeW, sizeH - offsetH)
    dScrollPanel:SetPos(0, offsetH)

    local textureSize = sizeW / 2 - w / 270
    local grid = dScrollPanel:Add("DGrid")
    grid:SetPos(0, 0)
    grid:SetCols(2)
    grid:SetColWide(textureSize)
    grid:SetRowHeight(textureSize)

    for i = 1, #files do
        local but = vgui.Create("DImageButton")
        buttons[i] = but
        but:SetText(i)
        but:SetSize(textureSize, textureSize)
        local material = string.gsub(files[i], ".vmt", "")
        but:SetMaterial("psychedelics/blotters/" .. material)
        grid:AddItem(but)
    end
    
    local function detectInput()
        for i = 1, #files do
            if closed then
                hook.Remove("Think", "psychedelicsInput")
                return
            end
            local but = buttons[i]
            local material = but:GetImage()
            if but:IsDown() then
                sendMaterial(material, sheet)
                frame:Close()
                closed = true
            end
        end
    end

    hook.Add("Think", "psychedelicsInput", detectInput)
end

net.Receive("psychedelicsSheetSkinUI", setBlotterSkin)
