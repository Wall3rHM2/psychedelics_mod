local DrugCount=0
local Duration={Onset=5,Total=90} --tempo total=horas do efeito na vida real*30    
                                  -- ex:3*30=90     --->3 horas      >30 valor constante
local TimerOnset="SDrugs_weed_onset"
local TimerTotal="SDrugs_weed_total"
local WeedI=0
local Multi=0.5
local Increase=0.01
local THC=0
local CBD=0

local lastreturnm=1
Duration.Total=(Duration.Total/Multi)/2
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

local function RemoveEffects(delayb) --delayb:delay beetwen timers to decrease WeedI value
 if delayb==nil then delayb=0.01 end
 timer.Remove("SDrugs_WeedEffect")
 local function Remove()
  THC=0
  CBD=0
  LocalPlayer():SetDSP(0)
  timer.Remove(TimerTotal)
  timer.Remove("SDrugs_WeedEffect")
  hook.Remove("RenderScreenspaceEffects","SDrugs_WeedEffect")
  hook.Remove("AdjustMouseSensitivity","SDrugs_weed_msens")
  hook.Add("AdjustMouseSensitivity","SDrugs_weed_fixm",function()
  hook.Remove("AdjustMouseSensitivity","SDrugs_weed_fixm")
   return 1
  end)
  WeedI=0
  DrugCount=0
  toRemove=false
 end

 local function FixWeedI()
  if math.sin(WeedI)>Increase then
   WeedI=WeedI-Increase
   cModify["$pp_colour_colour"]=1+(math.abs(math.sin(WeedI/2) ) * (1+(THC)/60) )
   LocalPlayer():SetDSP(math.sin(WeedI)*1.2*(1+THC/20) )
   timer.Create("SDrugs_FixWeedI",delayb,1,FixWeedI)
  elseif math.sin(WeedI)<-Increase then
   WeedI=WeedI+Increase
   cModify["$pp_colour_colour"]=1+(math.abs(math.sin(WeedI/2) ) * (1+(THC)/60) )
   LocalPlayer():SetDSP(math.sin(WeedI)*1.2*(1+THC/20) )
   timer.Create("SDrugs_FixWeedI",delayb,1,FixWeedI)
  else
  	Remove()
  end
 end

 FixWeedI()
end
net.Receive("SDrugsDeath",function()
 local plySDDeath=net.ReadEntity()
 if not plySDDeath==LocalPlayer() then return end
 RemoveEffects()
end)
local function Effect()
       timer.Create(TimerTotal,Duration.Total,1,function() RemoveEffects(0.24) end)
       timer.Create("SDrugs_weed_effect",Multi,17/(Increase*10),function()
        WeedI=WeedI+Increase
        LocalPlayer():SetDSP(math.sin(WeedI)*1.2*(1+THC/20) )
        cModify["$pp_colour_colour"]=1+(math.abs(math.sin(WeedI/2) ) * (1+(THC)/60) )
        --print(math.abs(math.sin(WeedI)*1.5*(DrugCount/2)) )
       end)
       hook.Add("RenderScreenspaceEffects","SDrugs_WeedEffect",function()
        DrawToyTown( math.abs( math.sin(WeedI/1.65)*((1+THC/100)) ), ScrH() )
        DrawColorModify(cModify)
        if THC>50 then
         DrawMaterialOverlay( "psychedelics/lsd",(math.sin(WeedI)/10)*(THC/1500))
        end
       end)
       hook.Add("AdjustMouseSensitivity","SDrugs_weed_msens",function(msens)
        local toreturn=math.abs(1-(math.sin(WeedI)*(CBD/10) ))
        if toreturn>=0.2 then lastreturnm=toreturn else toreturn=lastreturnm end --makes sure the player can fucking move his cursor
       	return toreturn
       end)
end

net.Receive( "WeedmeuStart", function()
 DrugCount=DrugCount+1
 THC=THC+net.ReadInt(32)
 CBD=CBD+net.ReadInt(32)
 if timer.Exists(TimerOnset) and DrugCount<=4 then
  local Timeleft=timer.TimeLeft(TimerOnset) timer.Remove(TimerOnset) timer.Create(TimerOnset,(Timeleft)+DrugCount*2,1,Effect)
 else
  timer.Create(TimerOnset,Duration.Onset,1,Effect)
 end
end)