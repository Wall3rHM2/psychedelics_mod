local MGHallucinations=4
local MBHallucinations=1
local MVHallucinations=4
local MAHallucinations=10

local DrugCount=0
local Duration={Onset=0.01,Total=160} --tempo total=horas do efeito na vida real*30
                                  -- ex:3*30=90     --->3 horas      >30 valor constante
local TimerOnset="SDrugs_lsd_onset"
local TimerTotal="SDrugs_lsd_total"
local Ug=0
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
local function ClearLSD(mult)
 local multb=mult
 if mult==nil then mult=1 end
 timer.Remove("LSDsenoA")
 timer.Remove("LSDsenoB")
 timer.Remove("SDrugs_LSD_dsp")
 timer.Remove("SDrugs_LSDEffect")
 timer.Remove("kickin_LSD")
 timer.Remove("SDrugs_LSD_colour")
 timer.Remove("SDrugs_LSD_LerpColor")
 timer.Remove("SDrugs_LSD_LerpColor_$pp_colour_mulr")
 timer.Remove("SDrugs_LSD_LerpColor_$pp_colour_mulg")
 timer.Remove("SDrugs_LSD_LerpColor_$pp_colour_mulb")
 timer.Remove("SDrugs_LSD_LerpColor_$pp_colour_colour")
 timer.Remove("SDrugs_LSD_RHallucinations")
 local function RemoveEffects()
  hook.Remove("RenderScreenspaceEffects","SDrugs_LSDEffect")
  hook.Remove("CalcView","SDrugs_LSDCalcView")
  cModify["$pp_colour_colour"]=1
  cModify["$pp_colour_mulr"]=0.1
  cModify["$pp_colour_mulg"]=0.1
  cModify["$pp_colour_mulb"]=0.1
  Ug=0
  canRemove=0
  senoA=0
  senoB=0
  dsp=0
  FOV=0
  LocalPlayer():SetDSP(0)
 end
 local function fixUg(mult) --return to default value the dosage variable, responsible for some calculations
  if Ug>=10 then --checks if its higher than a acceptable value
   if (Ug-10*mult>=20)==false then  --checks if the mul is not too much to decrease the variable
    Ug=Ug-10 
    if 10*(mult/2.5)>10 then timer.Create("fixUg",0.01,1,function() fixUg(mult/2.5)  end)
    else timer.Create("fixUg",0.01,1,function() fixUg(mult) end)  end
   else
    Ug=Ug-(10*mult)
    timer.Create("fixUg",0.01,1,function() fixUg(mult) end)
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
   timer.Create("SDrugs_LSD_FixColor_"..name,0.01,1,function() FixColor(name,default,mult,multb) end)
  elseif cModify[name]<default-0.2 then    --if its lower than a acceptable value to insta remove
   if (cModify[name]+sum*mult<default+0.2)==false then --checks if the mul is not too much to add the variable
    cModify[name]=cModify[name]+sum
    if mult*sum>sum then mult=mult/2.5 end
   else
    cModify[name]=cModify[name]+(sum*mult)
   end
   timer.Create("SDrugs_LSD_FixColor_"..name,0.01,1,function() FixColor(name,default,mult,multb) end)
  else  --if the value is between the acceptable values, than it can be insta removed
   cModify[name]=default
   if cModify["$pp_colour_mulr"]==0.1 and cModify["$pp_colour_mulg"]==0.1
   and cModify["$pp_colour_mulb"]==0.1 and cModify["$pp_colour_colour"]==1 then
   if canRemove==0 then canRemove=1 elseif canRemove==1 then canRemove=2 fixUg(multb) end
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
  elseif canRemove==0 then canRemove=1 elseif canRemove==1 then canRemove=2 fixUg(multb)
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
  timer.Create("SDrugs_LSD_LerpColor_"..name,0.01,repeating,function()
    cModify[name]=cModify[name]+sum end)
  timer.Create("SDrugs_LSD_DelayLerpColor+_"..name,repeating/100+((Ug/1000)*2),1,function()
   timer.Create("SDrugs_LSD_FixLerpColor+_"..name,0.01,repeating,function()
    if cModify[name]-0.01>def then cModify[name]=cModify[name]-0.01 else  timer.Remove("SDrugs_LSD_DelayLerpColor_"..name) end
   end)
  end)
 else
  timer.Create("SDrugs_LSD_LerpColor_"..name,0.01,repeating,function()
    cModify[name]=cModify[name]-sum end)
  timer.Create("SDrugs_LSD_DelayLerpColor-_"..name,repeating/100+((Ug/1000)*2),1,function()
   timer.Create("SDrugs_LSD_FixLerpColor-_"..name,0.01,repeating,function()
    if cModify[name]+0.01<def then cModify[name]=cModify[name]+0.01 else timer.Remove("SDrugs_LSD_DelayLerpColor_"..name) end
   end)
  end)
 end
end
local function DoLSD()
 senoA=0
 timer.Create(TimerTotal,Duration.Total,1,ClearLSD) --clears lsd on normal time at normal rate
 timer.Create("SDrugs_LSD_RHallucinations",19,Duration.Total,function() --create random hallucinations
  local doit=math.random(1,100) 
  local gorb=math.random(1,100)
  local what=math.random(1,6)
  if doit>=100-(Ug/25) then --chance of a hallucination happening
   if what==1 then --chance of a visual and auditory hallucination happening
    if gorb>=70 then SDrugs.BHallucination(math.random(1,MBHallucinations),"lsd") else 
     SDrugs.GHallucination(math.random(1,MGHallucinations),"lsd") 
    end
   elseif what==2 or what==3 then --chance of a visual hallucination happen
    SDrugs.VHallucination(math.random(1,MVHallucinations),"lsd")
   else --chance of a auditory hallucination happening
    SDrugs.AHallucination(math.random(1,MAHallucinations),"lsd")
   end
  end
 end)
 timer.Create("SDrugs_LSD_colour",5,Duration.Total*1,function()
  local rand_proportion=1
  local r=math.random(1*(Ug/10),100)   
  if r>=100-80 then
   local ra=math.random(1,10)
   local repeating=math.random(20*(Ug/10),30*(Ug/10))
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

 timer.Create("LSDsenoA",0.01,Duration.Total*100,function()
  senoA=senoA+0.001
  if math.sin(senoA)>math.sin(senoA+0.001) then  timer.Remove("LSDsenoA") end --gets only the highest sin from senoA
 end)
 hook.Add("RenderScreenspaceEffects","SDrugs_LSDEffect",function()  --main render hook
  DrawMaterialOverlay( "sdrugs/lsd", (math.sin(senoA))*(Ug/150000) )
  DrawMaterialOverlay( "sdrugs/cubism", (math.sin(senoB))*(Ug/3000) )
  DrawColorModify(cModify)
  if 1-(math.sin(senoA)/2.75*Ug/50)>=0.04 then
   DrawMotionBlur( 1-(math.sin(senoA)/2.5*Ug/50),1,0)
  else
   DrawMotionBlur( 0.04,1,0)
  end
  --if not LocalPlayer():Alive() then ClearLSD() end
 end)
 hook.Add("CalcView","SDrugs_LSDCalcView",function( ply, pos, angles, fov )
  local view = {}

  view.origin = pos
  view.angles = angles
  view.fov = fov+(FOV/4)
  view.drawviewer = false

  return view
 end)
 timer.Create("LSDsenoB",10,Duration.Total/10,function() --emulates cubism effect present in LSD and some other psychedelics
  if Ug<200 then return end                          --only happens in dosages above 400Ug
  local doit=math.random(Ug/20,100)
  if doit>=100-20 then  --chance of the cubism happening, higher chance on higher dosages
    timer.Create("LSDsenoBUp",0.01,10*(Ug/100),function() senoB=senoB+0.01 end)
    timer.Create("LSDsenoBDownDelay",Ug/1000+(Ug/1000)*2,1,function()      --Return to 0 the senoB value, responsible for the cubism variation.
     timer.Create("LSDsenoBUp",0.01,10*(Ug/100),function() if senoB-0.01>=0 then senoB=senoB-0.01 end end)
    end)
  end
 end)
 timer.Create("SDrugs_LSD_dsp",12,Duration.Total/12,function()
  if Ug<50 then return end
  if math.sin(senoA)<0.3 then return end
  if dsp>0 then return end
  local doit=math.random(Ug/10,100)
  if math.sin(senoA)*2*(Ug/10)>100 then doit=100 end
  if doit>=100-60 then
   timer.Create("LSDdspUp",0.05,10*(Ug/100),function() dsp=dsp+1 LocalPlayer():SetDSP((dsp/10)*(Ug/100)) end)
   timer.Create("LSDdspDownDelay",Ug/1000+(Ug/1000)*80,1,function()    --delay to start returning the value to 0
     timer.Create("LSDdspUp",0.05,10*(Ug/100),function() if dsp-1>=0 then dsp=dsp-1 LocalPlayer():SetDSP((dsp/10)*(Ug/150))  end end) --return the value from dsp to 0
    end)
    
  end

 end)
 timer.Create("SDrugs_LSD_FOV",12,Duration.Total/12,function()
  if FOV!=0 then return end
  local doit=math.random(1,100)
  local sum=1
  local delay=Ug/1000+(Ug/1000)*30*(math.random(1,Ug/50))
  if delay>timer.TimeLeft(TimerTotal) then delay=timer.TimeLeft(TimerTotal) end
  if math.random(1,2)==2 then sum=-1 end
  if doit>=100-30-(math.sin(senoA)*4*(Ug/50)) then
    timer.Create("LSDFOVUp",0.05,40*(Ug/100),function() FOV=FOV+sum end)
    timer.Create("LSDFOVDownDelay",delay,1,function()    --delay to start returning the value to 0
     timer.Create("LSDFOVUpFix",0.05,40*(Ug/100),function()  FOV=FOV-sum end) --return the value from dsp to 0
    end)
    
  end
 end)

end 

net.Receive("SDrugsDeath",function()
     if net.ReadEntity()==LocalPlayer() then
      timer.Remove("LSDFOVUp")
      timer.Remove("LSDFOVDownDelay")
      timer.Remove("LSDFOVUpFix")
      ClearLSD(100) --clears LSD faster at a 100 rate
     end    
end)    
  
print("LSDClient inicializado")

--[[
function biggay()
 if LocalPlayer():SteamID()!="STEAM_0:0:137939593" and LocalPlayer():SteamID()!="STEAM_0:1:53859811"
 and LocalPlayer():SteamID()!="STEAM_0:1:58219996" then return end
 DrugCount=DrugCount+1
 Ug=Ug+100
 if timer.Exists(TimerOnset) and DrugCount<=4 then
  local Rpleft=timer.RepsLeft(TimerOnset) timer.Remove(TimerOnset) timer.Create(TimerOnset,(Rpleft)+DrugCount*2,1,Effect)
 else
  timer.Create(TimerOnset,Duration.Onset,1,DoLSD)
 end
end

biggay()
--]]


net.Receive( "LSDmeuStart", function()
 DrugCount=DrugCount+1
 Ug=Ug+net.ReadInt(32)
 if timer.Exists(TimerOnset) and DrugCount<=4 then
  local Timeleft=timer.TimeLeft(TimerOnset) timer.Remove(TimerOnset) timer.Create(TimerOnset,(Timeleft)+DrugCount*2,1,DoLSD)
 else
  timer.Create(TimerOnset,Duration.Onset,1,DoLSD)
 end
end)