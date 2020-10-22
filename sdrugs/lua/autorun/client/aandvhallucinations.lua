--local lp=LocalPlayer()


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

--"Good" Hallucinations --> for a normal trip
local GHallucinations={
 function(drug_name) --alucinacao 1  ideia:peixes
  local fishes={}
  for i=1,10 do
   fishes[i]=ClientsideModel("models/props/CS_militia/fishriver01.mdl",RENDERGROUP_STATIC)
   if i==1 then
    local theid=LocalPlayer():StartLoopingSound("ambient/water/underwater.wav")
    print(theid)
    BasePos(drug_name.."_fishes"..tostring(i),fishes[i],20,function() LocalPlayer():StopLoopingSound(theid) hook.Remove("Think",drug_name.."fish_move") end)
   else 
    BasePos(drug_name.."_fishes"..tostring(i),fishes[i],20)
   end
   local thevec=Vector(math.random(-70,70),math.random(-70,70),math.random(10,80))
   fishes[i]:SetPos(fishes[i]:LocalToWorld(thevec))
  end
  hook.Add("Think",drug_name.."fish_move",function()
   for i=1,#fishes do
    fishes[i]:SetPos(fishes[i]:LocalToWorld(Vector(0.01,0,0)))
   end
  end)
 end,
 --alucinacao 2
 function(drug_name)
  local theshitid=0
  local thex=math.random(-70,70)
  local they=math.random(-70,70)
  local theyaw=math.random(-180,180)
  local table=ClientsideModel("models/props_c17/FurnitureTable001a.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_thecall_table",table,20,function() 
    timer.Remove(drug_name.."_thecall_ringringlmao") 
    LocalPlayer():StopLoopingSound(theshitid)
  end)
  table:SetPos(table:LocalToWorld(Vector(thex,they,20)))
  table:SetAngles(table:LocalToWorldAngles(Angle(0,theyaw,0)))
  local phone=ClientsideModel("models/props/cs_office/phone.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_thecall_phone",phone,20)
  phone:SetPos(phone:LocalToWorld(Vector(thex,they,38)))
  phone:SetAngles(phone:LocalToWorldAngles(Angle(0,180,0)))
  phone:SetAngles(phone:LocalToWorldAngles(Angle(0,theyaw,0)))
  local ring=0
  timer.Create(drug_name.."_thecall_ringringlmao",1,30,function()
   if ring<1 then ring=ring+1 else ring=0 end
   if ring==1 then 
    local theshitid=LocalPlayer():StartLoopingSound("ambient/alarms/city_firebell_loop1.wav",75,70)
   else
    LocalPlayer():StopLoopingSound(theshitid)
   end
  end)
 end,
 --alucinacao 3
 function(drug_name)
  local time=6
  local thex=math.random(-70,370) --370
  local they=math.random(-4,4)
  local body=ClientsideModel("models/props/cs_office/Snowman_body.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."snowman_body",body,time,function() hook.Remove("Think",drug_name.."_snowman_move") end)
  body:SetPos(body:LocalToWorld(Vector(thex,they,21)))
  local head=ClientsideModel("models/props/cs_office/Snowman_face.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."snowman_head",head,time)
  head:SetPos(head:LocalToWorld(Vector(thex,they,47)))
  head:SetAngles(head:LocalToWorldAngles(Angle(0,90,0)))
  local larm=ClientsideModel("models/props/cs_office/Snowman_arm.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."snowman_larm",larm,time)
  larm:SetPos(larm:LocalToWorld(Vector(thex,they-16,38)))
  larm:SetAngles(larm:LocalToWorldAngles(Angle(20,-90,0)))
  local rarm=ClientsideModel("models/props/cs_office/Snowman_arm.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."snowman_rarm",rarm,time)
  rarm:SetPos(rarm:LocalToWorld(Vector(thex,they+13,38)))
  rarm:SetAngles(rarm:LocalToWorldAngles(Angle(25,90,0)))
    --another part of my script ruined because gay newman fucking closed facepunch forums
    -- and i have no ideia how to fix this shit.
    -- fucking ruined rust and trow shit updates at gmod that break addons.
    -- 0% support for this shit ass bugged game
  --[[local theAng=rarm:GetAngles()
  local MyShitAng = Angle(10,30,50)*4
  local theothervector = Vector(1,0,0)
  theothervector:Rotate(MyShitAng)
  timer.Simple(0.1,function()
    hook.Add("Think",drug_name.."_snowman_move",function()
     theAng:RotateAroundAxis(theothervector,1)  
     rarm:SetAngles(theAng)
    end)
   end--]]  
  local fuckgaynewman="vo/npc/male01/hi0"..tostring(math.random(1,2))..".wav"
  timer.Simple(2,function() body:EmitSound(fuckgaynewman) end)
 end,
 --alucinacao 4     if it wasant for gay newman being so gay the world would be better
 function(drug_name)
  local thex=math.random(-70,70)
  local they=math.random(-20,20)
  local door=ClientsideModel("models/props_doors/door03_slotted_left.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name.."_thedoorh_door",door,7,function() hook.Remove(drug_name.."_thedoorh_move") end)
  door:SetPos(door:LocalToWorld(Vector(thex,they,53)))
  local theang=door:GetAngles()
  timer.Simple(2,function()
   door:EmitSound("doors/door1_move.wav")
   local count=0
   hook.Add("Think",drug_name.."_thedoorh_move",function()
    if count<180 then
     theang:RotateAroundAxis(door:GetUp(),-0.5)
     door:SetAngles(theang)
     count=count+1
    else
     hook.Remove(drug_name.."_thedoorh_move")
    end
   end)
  end)
 end
}
--Bad hallucinations  --> used for a bad trip
local BHallucinations={
 function(drug_name) --alucinacao 1    primeiro fiz na parte de Good mas quando fui ver fico meio sinistro
  local h_name="beware_of_the_dawg"
  local DogSign=ClientsideModel("models/props_lab/bewaredog.mdl",RENDERGROUP_STATIC)
  BasePos(drug_name..h_name,DogSign,8)
  local thex=math.random(-70,70) local they=math.random(-70,70)
  DogSign:SetPos(DogSign:LocalToWorld(Vector(thex,they,0)) )
  DogSign:SetAngles(DogSign:LocalToWorldAngles(Angle(0,180,0)) )
  timer.Simple(2,function()
   DogSign:EmitSound("ambient/dog"..tostring(math.random(1,6))..".wav")
  end)
 end

}
if SDrugs==nil then
 SDrugs={}
end
function SDrugs.GHallucination(index,drug_name)
 GHallucinations[index](drug_name)
end
function SDrugs.BHallucination(index,drug_name)
 BHallucinations[index](drug_name)
end
--SDrugs.GHallucination(4,"lsd")