if SERVER then
	util.AddNetworkString( "PsychedelicsSheetSkin_UI" ) --for client UI
	util.AddNetworkString( "PsychedelicsSheetSkin_Mat" ) --for server receive material
return end
local function SendMaterial(material,sheet)
	net.Start("PsychedelicsSheetSkin_Mat")
	net.WriteEntity(sheet)
	net.WriteString(material)
	net.SendToServer()
end
local function SetBlotterSkin()
	local sheet=net.ReadEntity()
	local W,H=ScrW(),ScrH()
	local SizeW,SizeH=W/5,W/5
	local OffsetW,OffsetH=W/44,H/44 --makes sure the content dont touch the borders
	local files,directories = file.Find( "materials/psychedelics/blotters/*.vmt", "THIRDPARTY" )
	local buttons={} --saves the buttons spawned in derma
	local Frame = vgui.Create( "DFrame" )
	local closed = false
	Frame:SetPos( W/2-SizeW/2, H/2-SizeH/2 ) --math used to center
	Frame:SetSize( SizeW, SizeH )
	Frame:SetTitle( "Select a blotter texture" )
	Frame:SetVisible( true )
	Frame:SetDraggable( true )
	Frame:ShowCloseButton( true )
	Frame:MakePopup()
	Frame.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color(40,41,35) )
	end
	function Frame:OnClose()
		closed=true
	end
	local DScrollPanel = vgui.Create( "DScrollPanel", Frame )
	DScrollPanel:SetSize(SizeW,SizeH-OffsetH)
	DScrollPanel:SetPos(0,OffsetH)
	local texture_size=SizeW/2-W/270
	local grid = DScrollPanel:Add("DGrid")
	grid:SetPos(0, 0)
	grid:SetCols( 2 )
	grid:SetColWide( texture_size )
	grid:SetRowHeight(texture_size)
	for i = 1, #files do
		local but = vgui.Create( "DImageButton" )
		buttons[i] = but
		but:SetText( i )
		but:SetSize( texture_size, texture_size )
		local material=string.gsub(files[i],".vmt","")
		but:SetMaterial("psychedelics/blotters/"..material)
		grid:AddItem( but )
	end
	local function detect_input() 
		for i=1,#files do
			if closed then hook.Remove("Think","psychedelics_input") return end
			local but=buttons[i]
			local material=but:GetImage()
			if but:IsDown() then
				SendMaterial(material,sheet)
				Frame:Close()
				closed=true
			end
		end
	end
	hook.Add("Think","psychedelics_input",detect_input)
end
net.Receive("PsychedelicsSheetSkin_UI",SetBlotterSkin)