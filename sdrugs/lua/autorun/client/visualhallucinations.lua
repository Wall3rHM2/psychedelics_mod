local lp=LocalPlayer()

local function TheSpawn(name,ent,removetime,callback)
 local removeCount=0
 ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
 local alpha=0
 ent:SetColor(Color(ent:GetColor().r,ent:GetColor().g,ent:GetColor().b,0)) 
 timer.Create(name,0.01,102,function()  
  local thecolor=ent:GetColor()
  if alpha<255 then
   alpha=alpha+5
   ent:SetColor(Color(thecolor.r,thecolor.g,thecolor.b,alpha)) 
  end
  --print("add")
 end)
 timer.Simple(removetime,function()
  timer.Create(name.."remove",0.01,103,function()
   removeCount=removeCount+1
   local thecolor=ent:GetColor()
   if thecolor.a>0 then
    alpha=alpha-5
    ent:SetColor(Color(thecolor.r,thecolor.g,thecolor.b,alpha)) 
   end
   --print("remove")
   if removeCount>=103 then if callback~=nil then callback() end ent:Remove() end
  end)
 end)
end
local function BasePos(drug_name,ent,removetime,removecallback)
 local theAIMpos=LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 150
 TheSpawn(drug_name,ent,removetime,removecallback)
 ent:SetPos(Vector(theAIMpos.x,theAIMpos.y,LocalPlayer():GetPos().z) )
 ent:SetAngles(Angle(0,LocalPlayer():GetAngles().y,0))
end

--Thank you sublime 3 for fucking my files and i having to rewrite the entire code that i spend 2 days
local VHallucinations={
 function(drug_name)
  local thex=math.random(-70,70)
  local they=math.random(-70,70)
  local theyaw=math.random(-180,180)
  local gman=ClientsideModel("models/player/gman_high.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_gman",gman,math.random(18,22))
  gman:SetPos(gman:LocalToWorld(Vector(thex,they,0)))
  gman:SetAngles(gman:LocalToWorldAngles(Angle(0,theyaw,0)))
 end,
 function(drug_name)
  local thex=math.random(-70,70)
  local they=math.random(-70,70)
  local theyaw=math.random(-180,180)
  local headcrab=ClientsideModel("models/headcrabclassic.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_headcrab",headcrab,math.random(16,24))
  headcrab:SetPos(headcrab:LocalToWorld(Vector(thex,they,0)))
  headcrab:SetAngles(headcrab:LocalToWorldAngles(Angle(0,theyaw,0)))
 end,
 function(drug_name)
  local thex=math.random(-70,70)
  local they=math.random(-70,70)
  local theyaw=math.random(-45,45)
  local table=ClientsideModel("models/props_interiors/Furniture_Desk01a.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_tcomputer_table",table,25)
  table:SetAngles(table:LocalToWorldAngles(Angle(0,theyaw,0)))
  table:SetPos(table:LocalToWorld(Vector(thex,they,19.8)))
  table:SetAngles(table:LocalToWorldAngles(Angle(0,180,0)))
  local chair=ClientsideModel("models/props_interiors/Furniture_chair03a.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_tcomputer_chair",chair,25)
  chair:SetAngles(chair:LocalToWorldAngles(Angle(0,theyaw,0)))
  chair:SetPos(chair:LocalToWorld(Vector(thex,they,19)))
  chair:SetPos(chair:LocalToWorld(Vector(-26,0,0)))
  local computer=ClientsideModel("models/props_lab/monitor02.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_tcomputer_computer",computer,25)
  computer:SetAngles(computer:LocalToWorldAngles(Angle(0,theyaw,0)))
  computer:SetPos(computer:LocalToWorld(Vector(thex,they,39)))
  computer:SetPos(computer:LocalToWorld(Vector(10,0,0)))
  computer:SetAngles(computer:LocalToWorldAngles(Angle(0,180,0)))
  local morefun=math.random(1,5)
  if morefun>2 then morefun=2 end --better probability of returning the skin 2
  computer:SetSkin(morefun)
 end,
 function(drug_name)
  local thex=math.random(-70,470)
  local they=math.random(-70,70)
  local theyaw=math.random(-180,180)
  bycicle=ClientsideModel("models/props_junk/bicycle01a.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_bycicleh",bycicle,math.random(7,20),function() hook.Remove("Think",drug_name.."_bycicleh_move") end)
  bycicle:SetPos(bycicle:LocalToWorld(Vector(thex,they,21.4)))
  bycicle:SetAngles(bycicle:LocalToWorldAngles(Angle(0,theyaw,0)))
  hook.Add("Think",drug_name.."_bycicleh_move",function()
   bycicle:SetPos(bycicle:LocalToWorld(Vector(0.5,0,0)))
  end)
 end
}

if SDrugs==nil then
 SDrugs={}
end
function SDrugs.VHallucination(index,drug_name)
 VHallucinations[index](drug_name)
end
--SDrugs.VHallucination(4,"lsd")