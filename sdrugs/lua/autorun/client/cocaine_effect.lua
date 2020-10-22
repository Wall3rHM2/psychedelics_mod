local Duration={Onset=0.4,Total=30}
local TimerOnset="SDrugs_cocaine_onset"
local TimerTotal="SDrugs_cocaine_total"
local Multi=0.01

local DrugCount=0
local CocaineI=0
local Increase=0.01


local function RemoveEffects(delayb) --delayb:delay beetwen timers to decrease CocaineI value
 if delayb==nil then delayb=0 end
 timer.Remove("SDrugs_CocaineEffect")
 local function Remove()
  timer.Remove(TimerTotal)
  timer.Remove("SDrugs_CocaineEffect")
  hook.Remove("RenderScreenspaceEffects","SDrugs_CocaineEffect")
  hook.Remove("AdjustMouseSensitivity","SDrugs_cocaine_msens")
  hook.Add("AdjustMouseSensitivity","SDrugs_cocaine_fixm",function()
    return 1
  end)
  hook.Remove("AdjustMouseSensitivity","SDrugs_cocaine_fixm")
  CocaineI=0
  DrugCount=0
  toRemove=false
 end

 local function FixCocaineI(ntime)
  if ntime==nil then ntime=0.01 end
  if math.sin(CocaineI)>Increase then
   CocaineI=CocaineI-Increase
   --
   timer.Create("SDrugs_FixCocaineI",ntime,1,FixCocaineI)
  elseif math.sin(CocaineI)<-Increase then
   CocaineI=CocaineI+Increase
   --
   timer.Create("SDrugs_FixCocaineI",ntime,1,FixCocaineI)
  else
  	Remove()
  end
 end
 FixCocaineI()
end

local function Effect()
       timer.Create(TimerTotal,Duration.Total,1,function() RemoveEffects(Multi+(DrugCount/3) ) end)
       timer.Create("SDrugs_CocaineEffect",Multi,(17/(Increase*10)),function()
        CocaineI=CocaineI+Increase
       end)
       hook.Add("RenderScreenspaceEffects","SDrugs_CocaineEffect",function()
       	DrawBloom( math.abs(   1-(math.sin(CocaineI)*0.8*(1+DrugCount/200) )   ), 1, 4, 4, 1, 1, 1, 1, 1 )
       end)
       hook.Add("AdjustMouseSensitivity","SDrugs_cocaine_msens",function(msens)
        local toreturn=math.abs(1+(math.sin(CocaineI)*(DrugCount/4) ))
        return toreturn
       end)
end

net.Receive( "CocainemeuStart", function()
 DrugCount=DrugCount+1
 if timer.Exists(TimerOnset) and DrugCount<=4 then
  local Timeleft=timer.TimeLeft(TimerOnset) timer.Remove(TimerOnset) timer.Create(TimerOnset,(Timeleft)+DrugCount*2,1,Effect)
 else
  timer.Create(TimerOnset,Duration.Onset,1,Effect)
 end
end)

net.Receive("SDrugsDeath",function()
 local plySDDeath=net.ReadEntity()
 if not plySDDeath==LocalPlayer() then return end
 RemoveEffects()
end)

