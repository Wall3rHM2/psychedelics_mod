AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")
local Ug=100

local posur={"0.1","0.2","0.3","0.4","0.5"}
local posur2={"0.6","0.7","0.8","0.9","1.0"}

local posx={"0.0","0.1","0.2","0.3","0.4"}
local posx2={"0.5","0.6","0.7","0.8","0.9"}

local posy={"-0.1","0.0","0.1","0.2","0.3"}
local posy2={"0.4","0.5","0.6","0.7","0.8"}
function ENT:Initialize()
		self:SetModel("models/sdrugs/blotter/5sheet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():Wake()
		self:Activate()
		timer.Simple(0.1,function()
		Ug=self:GetNWInt( "SDrugs_quantity", 100 )
		local sheet5=self
		local matpos=sheet5:GetNWInt("matpos",1)
		local data=sheet5:GetNWString("SDrugs_blotter_data","sdrugs_blotter_-sdrugs/blotters/bycicle_day-1")
		local dataTab=string.Split(	data,"-"	)
		subMaterial=dataTab[2]
		local tmaterial=string.Split(subMaterial,"/")
		local i=string.Split(data,"-")
		i=tonumber(i[#i])
		local pos1="0.1"
   		local pos2="0.0"

   		if matpos==1 or matpos==3 then pos1=posur[i]					-- corrects the x position of the submaterial
   		elseif matpos==2 or matpos==4 then pos1=posur2[i] end

   		if matpos==1 or matpos==2 then pos2="0.5" end 						-- corrects the y position of the submaterial
    	 net.Start("update_blotter_5sheet")
    	 net.WriteString(subMaterial)
    	 net.WriteString(pos1)
    	 net.WriteString(pos2)
    	 net.WriteString("sdrugs_5sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(matpos).."-"..tostring(i))
    	 net.WriteEntity(sheet5)
    	 net.Broadcast()
    	end)

	end
	
function ENT:Use( activator, caller )
if IsValid(caller) and caller:IsPlayer()  then
  if activator:GetNWBool("sdrugs_usedblotter",false) then return end
  activator:SetNWBool("sdrugs_usedblotter",true)
  timer.Simple(0.2,function() activator:SetNWBool("sdrugs_usedblotter",false) end)
  local Count=0
  for k, v in pairs( ents.FindByClass( "sdrugs_blotter_1sheet" ) ) do
   if v:CPPIGetOwner()==activator then
    Count=Count+1
   end
  end
  if Count>=GetConVar("sdrugs_limitspawn_1sheet"):GetInt() then
   net.Start("sdrugs_hintmessage")
   net.WriteString("You have hit this entity limit")
   net.WriteInt(1,32)
   net.WriteInt(3,32)
   net.Send(activator)
  return end
  self:EmitSound("physics/cardboard/cardboard_box_strain1.wav")
  local data=self:GetNWString("SDrugs_blotter_data","sdrugs_blotter_-sdrugs/blotters/bycicle_day-1")
  local matpos=self:GetNWInt("matpos",1)
  local dataTab=string.Split(	data,"-"	)
  subMaterial=dataTab[2]
  local tmaterial=string.Split(subMaterial,"/")
  local x=string.Split(data,"-")
  x=tonumber(x[#x])
  local sheet5=self
  local angles5=sheet5:LocalToWorldAngles(Angle(0,90,0))
  local Pos=self:GetPos()
  local thetype=self:GetNWString("SDrugs_type","lsd")
  local thequantity=self:GetNWInt("SDrugs_quantity",100)
  self:Remove()
  for i=1,5 do
  local sheet1 = ents.Create("sdrugs_blotter_1sheet")
   sheet1:SetPos( Pos-sheet5:GetForward()*(2*i)+(sheet5:GetForward()*6))
   sheet1:CPPISetOwner(activator)
   sheet1:SetAngles( angles5)
   sheet1:Spawn()
   sheet1:Activate()
   sheet1:SetNWString("SDrugs_blotter_data","sdrugs_blotter_".."-"..subMaterial.."-"..tostring(x).."-"..tostring(i))
   sheet1:SetNWInt("matpos",matpos)
   sheet1:SetNWString("SDrugs_type",thetype)
   sheet1:SetNWInt("SDrugs_quantity",thequantity)
   duplicator.StoreEntityModifier( sheet1, "sdrugs_blotter_data", {data="sdrugs_blotter_".."-"..subMaterial.."-"..tostring(x).."-"..tostring(i), matpos=matpos,
   type=thetype,quantity=thequantity} ) --saves the data
   local pos1="0.0"
   local pos2="0.0"

   if matpos==1 or matpos==3 then pos1=posx2[x]					-- corrects the x position of the submaterial
   elseif matpos==2 or matpos==4 then pos1=posx[x] end
   if matpos==1 or matpos==2 then pos2=posy[i]
   else pos2=posy2[i] end 						-- corrects the y position of the submaterial
   timer.Simple(0.1,function()
    net.Start("update_blotter_1sheet")
   	net.WriteString(subMaterial)
    net.WriteString(pos1)
    net.WriteString(pos2)
    net.WriteString("sdrugs_1sheet_".."-"..tmaterial[#tmaterial].."-"..tostring(matpos).."-"..tostring(x).."-"..tostring(i))
    net.WriteEntity(sheet1)
    net.Broadcast()
   end)
  end
 end
end

	
function ENT:Think()
end
