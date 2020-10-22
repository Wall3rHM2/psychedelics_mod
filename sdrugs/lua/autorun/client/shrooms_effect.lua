local DrugCount=0
local Duration={Onset=0.01,Total=30} --tempo total=horas do efeito na vida real*30    
                                  -- ex:3*30=90     --->3 horas      >30 valor constante
local TimerOnset="SDrugs_shrooms_onset"
local TimerTotal="SDrugs_shrooms_total"
local Mg=0
local senoA=0
local senoB=0
local dsp=0
local FOV=0
local Multi=0.5
local Increase=0.01
local canRemove=0
local cModify={
  [ "$pp_colour_addr" ] = 0.00,
  [ "$pp_colour_addg" ] = 0.00,
  [ "$pp_colour_addb" ] = 0,
  [ "$pp_colour_brightness" ] = 0,
  [ "$pp_colour_contrast" ] = 1,
  [ "$pp_colour_colour" ] = 1,
  [ "$pp_colour_mulr" ] = 0.1,
  [ "$pp_colour_mulg" ] = 0.1,
  [ "$pp_colour_mulb" ] = 0.1
}
local function ClearShrooms(mult)
 local multb=mult
 if mult==nil then mult=1 end
 timer.Remove("ShroomssenoA")
 timer.Remove("ShroomssenoB")
 timer.Remove("SDrugs_Shrooms_dsp")
 timer.Remove("SDrugs_ShroomsEffect")
 timer.Remove("kickin_Shrooms")
 timer.Remove("SDrugs_Shrooms_colour")
 timer.Remove("SDrugs_Shrooms_LerpColor")
 timer.Remove("SDrugs_Shrooms_LerpColor_$pp_colour_mulr")
 timer.Remove("SDrugs_Shrooms_LerpColor_$pp_colour_mulg")
 timer.Remove("SDrugs_Shrooms_LerpColor_$pp_colour_mulb")
 timer.Remove("SDrugs_Shrooms_LerpColor_$pp_colour_colour")
 local function RemoveEffects()
  hook.Remove("RenderScreenspaceEffects","SDrugs_ShroomsEffect")
  hook.Remove("CalcView","SDrugs_ShroomsCalcView")
  cModify["$pp_colour_colour"]=1
  cModify["$pp_colour_mulr"]=0.1
  cModify["$pp_colour_mulg"]=0.1
  cModify["$pp_colour_mulb"]=0.1
  Mg=0
  canRemove=0
  senoA=0
  senoB=0
  dsp=0
  FOV=0
  LocalPlayer():SetDSP(0)
 end
 local function fixMg(mult) --return to default value the dosage variable, responsible for some calculations
  if Mg>=10 then --checks if its higher than a acceptable value
   if (Mg-10*mult>=20)==false then  --checks if the mul is not too much to decrease the variable
    Mg=Mg-10 
    if 10*(mult/2.5)>10 then timer.Create("fixMg",0.01,1,function() fixMg(mult/2.5)  end)
    else timer.Create("fixMg",0.01,1,function() fixMg(mult) end)  end
   else
    Mg=Mg-(10*mult)
    timer.Create("fixMg",0.01,1,function() fixMg(mult) end)
   end
  elseif canRemove==2 then RemoveEffects()
  end 
 end

 local function FixColor(name,default,mult,multb) --
  local sum=0.05
  if name!="$pp_colour_colour" then sum=0.01 end
  if cModify[name]>default+0.2 then   --if its higher than a acceptable value to insta remove
   if (cModify[name]-sum*mult>default-0.2)==false then --checks if the mul is not too much to decrease the variable
    cModify[name]=cModify[name]-sum
    if mult*sum>sum then mult=mult/2.5 end
   else
    cModify[name]=cModify[name]-(sum*mult)
   end
   timer.Create("SDrugs_Shrooms_FixColor_"..name,0.01,1,function() FixColor(name,default,mult,multb) end)
  elseif cModify[name]<default-0.2 then    --if its lower than a acceptable value to insta remove
   if (cModify[name]+sum*mult<default+0.2)==false then --checks if the mul is not too much to add the variable
    cModify[name]=cModify[name]+sum
    if mult*sum>sum then mult=mult/2.5 end
   else
    cModify[name]=cModify[name]+(sum*mult)
   end
   timer.Create("SDrugs_Shrooms_FixColor_"..name,0.01,1,function() FixColor(name,default,mult,multb) end)
 else --if the value is between the acceptable values, than it can be insta removed
   cModify[name]=default
   if cModify["$pp_colour_mulr"]==0.1 and cModify["$pp_colour_mulg"]==0.1
   and cModify["$pp_colour_mulb"]==0.1 and cModify["$pp_colour_colour"]==1 then
    if canRemove==0 then canRemove=1 elseif canRemove==1 then canRemove=2 fixMg(0.5*multb) end
   else
   end
  end
 end
 FixColor("$pp_colour_mulr",0.1,mult,mult)
 FixColor("$pp_colour_mulg",0.1,mult,mult)
 FixColor("$pp_colour_mulb",0.1,mult,mult)
 FixColor("$pp_colour_colour",1,mult,mult)
 --local multb=mult
 local function fixsenoA(mult,multb) --return to default value the senoA variable, responsible for render calculations
  if senoA>=0.002 then --checks if its higher than a acceptable value
   if (senoA-0.001*mult>=0.002)==false then  --checks if the mul is not too much to decrease the variable
    senoA=senoA-0.001 
    if 0.001*(mult/2.5)>0.001 then timer.Create("fixsenoA",0.01,1,function() fixsenoA(mult/2.5,multb)  end)
    else timer.Create("fixsenoA",0.01,1,function() fixsenoA(mult,multb) end)  end
   else
    senoA=senoA-(0.001*mult)
    timer.Create("fixsenoA",0.01,1,function() fixsenoA(mult,multb) end)
   end
  elseif canRemove==0 then canRemove=1 elseif canRemove==1 then canRemove=2 fixMg(0.5*multb)
  end 
 end
 fixsenoA(mult,mult)
end 
local function LerpColor(repeating,name,mode)  --lerps a color
 local def=0.1
 if name=="$pp_colour_colour" then def=1 end
 if math.floor(repeating)==0 then repeating=1 else repeating=math.floor(repeating) end
 local sum=0.01
 if mode==nil then
  timer.Create("SDrugs_Shrooms_LerpColor_"..name,0.01,repeating,function()
    cModify[name]=cModify[name]+sum end)
  timer.Create("SDrugs_Shrooms_DelayLerpColor+_"..name,repeating/100+((Mg/1000)*2),1,function()
   timer.Create("SDrugs_Shrooms_FixLerpColor+_"..name,0.01,repeating,function()
    if cModify[name]-0.01>def then cModify[name]=cModify[name]-0.01 else  timer.Remove("SDrugs_Shrooms_DelayLerpColor_"..name) end
   end)
  end)
 else
  timer.Create("SDrugs_Shrooms_LerpColor_"..name,0.01,repeating,function()
    cModify[name]=cModify[name]-sum end)
  timer.Create("SDrugs_Shrooms_DelayLerpColor-_"..name,repeating/100+((Mg/1000)*2),1,function()
   timer.Create("SDrugs_Shrooms_FixLerpColor-_"..name,0.01,repeating,function()
    if cModify[name]+0.01<def then cModify[name]=cModify[name]+0.01 else timer.Remove("SDrugs_Shrooms_DelayLerpColor_"..name) end
   end)
  end)
 end
end
local function DoShrooms()
 senoA=0
 timer.Create(TimerTotal,Duration.Total,1,ClearShrooms) --clears shrooms on normal time at normal rate
 timer.Create("SDrugs_Shrooms_colour",5,Duration.Total*1,function()
  local rand_proportion=1
  local r=math.random(1*(Mg/10),100)   
  if r>=100-80 then
   --local lul=(((Mg*4)*Mg/100)*Mg/100)*Mg/100
   local ra=math.random(1,10)
   local repeating=math.random(20*(Mg/10),30*(Mg/10))
   if ra==1 then LerpColor(repeating,"$pp_colour_mulr") elseif
   ra==2 then LerpColor(repeating,"$pp_colour_mulg" ) elseif
   ra==3 then LerpColor(repeating,"$pp_colour_mulb" ) elseif
   ra==4 then LerpColor(repeating,"$pp_colour_mulr",1 ) elseif
   ra==5 then LerpColor(repeating,"$pp_colour_mulg",1 ) elseif
   ra==6 then LerpColor(repeating,"$pp_colour_mulb",1 ) elseif
   ra>=7 and ra<9 then LerpColor(repeating,"$pp_colour_colour") else
   LerpColor(repeating,"$pp_colour_colour",1) end
  end
 end)

 timer.Create("ShroomssenoA",0.01,Duration.Total*100,function()
  senoA=senoA+0.001
  if math.sin(senoA)>math.sin(senoA+0.001) then  timer.Remove("ShroomssenoA") end --gets only the highest sin from senoA
 end)
 hook.Add("RenderScreenspaceEffects","SDrugs_ShroomsEffect",function()  --main render hook
  DrawMaterialOverlay( "sdrugs/shrooms", (math.sin(senoA))*(Mg/3000) )
  DrawMaterialOverlay( "sdrugs/cubism", (math.sin(senoB))*(Mg/3000) )
  DrawColorModify(cModify)
  if 1-(math.sin(senoA)/2.75*Mg/50)>=0.2 then
   DrawMotionBlur( 1-(math.sin(senoA)/2.5*Mg/50),1,0)
  else
   DrawMotionBlur( 0.2,1,0)
  end
 end)
 hook.Add("CalcView","SDrugs_ShroomsCalcView",function( ply, pos, angles, fov )
  local view = {}

  view.origin = pos
  view.angles = angles
  view.fov = fov+(FOV/4)
  view.drawviewer = false

  return view
 end)
 timer.Create("ShroomssenoB",10,Duration.Total/10,function() --emulates cubism effect present in Shrooms and some other psychedelics
  if Mg<200 then return end                          --only happends in dosages above or equal to 200Mg
  local doit=math.random(Mg/10,100)
  if doit>=100-20 then  --chance of the cubism happening, higher chance on higher dosages
    timer.Create("ShroomssenoBUp",0.01,10*(Mg/100),function() senoB=senoB+0.01 end)
    timer.Create("ShroomssenoBDownDelay",Mg/1000+(Mg/1000)*4,1,function()      --Return to 0 the senoB value, responsible for the cubism variation.
     timer.Create("ShroomssenoBUpFix",0.01,10*(Mg/100),function() if senoB-0.01>=0 then senoB=senoB-0.01 end end)
    end)
  end
 end)
 timer.Create("SDrugs_Shrooms_dsp",12,Duration.Total/12,function()
  if Mg<50 then return end
  if math.sin(senoA)<0.3 then return end
  if dsp>0 then return end
  local doit=math.random(Mg/10,100)
  local repeating=(20*math.sin(senoA))*(Mg/200)
  if math.sin(senoA)*2*(Mg/10)>100 then doit=100 end
  if doit>=100-60 then
   timer.Create("ShroomsdspUp",0.05,repeating,function() dsp=dsp+1 LocalPlayer():SetDSP((dsp/10)*(Mg/100)) end)
   timer.Create("ShroomsdspDownDelay",Mg/1000+(Mg/1000)*80,1,function()    --delay to start returning the value to 0
     timer.Create("ShroomsdspUpFix",0.05,repeating,function() if dsp-1>=0 then dsp=dsp-1 LocalPlayer():SetDSP((dsp/10)*(Mg/150))  end end) --return the value from dsp to 0
    end)
    
  end

 end)
 timer.Create("SDrugs_Shrooms_FOV",12,Duration.Total/12,function()
  if FOV!=0 then return end
  local doit=math.random(1,100)
  local sum=1
  local delay=Mg/1000+(Mg/1000)*30*(math.random(1,Mg/50))
  if delay>timer.TimeLeft(TimerTotal) then delay=timer.TimeLeft(TimerTotal) end
  if math.random(1,2)==2 then sum=-1 end
  multisum=Mg
  if multisum>=240 then if math.random(1,100)>=10 then multisum=120  end end
  if multisum<=-240 then if math.random(1,100)>=10 then multisum=-120  end end
  print(0+(math.sin(senoA)*4*(Mg/25)))
  if doit>=100-( 0+(math.sin(senoA)*8*(Mg/50)) )
    then
    timer.Create("ShroomsFOVUp",0.05,40*(multisum/100),function() FOV=FOV+sum end)
    timer.Create("ShroomsFOVDownDelay",delay,1,function()    --delay to start returning the value to 0
     timer.Create("ShroomsFOVUpFix",0.05,40*(multisum/100),function()  FOV=FOV-sum end) --return the value from dsp to 0
    end)
    
  end
 end)
end 
net.Receive("SDrugsDeath",function()
     if net.ReadEntity()==LocalPlayer() then
      timer.Remove("ShroomsFOVUp")
      timer.Remove("ShroomsFOVDownDelay")
      timer.Remove("ShroomsFOVUpFix")
      ClearShrooms(100) --clears Shrooms effect faster at a 100 rate
     end    
end)    
  
print("ShroomsClient inicializado")

--[[
function biggay()
 if LocalPlayer():SteamID()!="STEAM_0:0:137939593" and LocalPlayer():SteamID()!="STEAM_0:1:53859811"
 and LocalPlayer():SteamID()!="STEAM_0:1:58219996" then return end
 DrugCount=DrugCount+1
 Ug=Ug+100
 if timer.Exists(TimerOnset) and DrugCount<=4 then
  local Rpleft=timer.RepsLeft(TimerOnset) timer.Remove(TimerOnset) timer.Create(TimerOnset,(Rpleft)+DrugCount*2,1,DoShrooms)
 else
  timer.Create(TimerOnset,Duration.Onset,1,DoShrooms)
 end
end

biggay()
--]]


net.Receive( "ShroomsmeuStart", function()
 DrugCount=DrugCount+1
 Mg=Mg+net.ReadInt(32)*4
 if timer.Exists(TimerOnset) and DrugCount<=4 then
  local Timeleft=timer.TimeLeft(TimerOnset) timer.Remove(TimerOnset) timer.Create(TimerOnset,(Timeleft)+DrugCount*2,1,DoShrooms)
 else
  timer.Create(TimerOnset,Duration.Onset,1,DoShrooms)
 end
end)