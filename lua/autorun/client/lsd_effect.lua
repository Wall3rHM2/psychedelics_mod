local Duration = {Onset=0.01,Total=160} --effect time = hours of the effect irl*30
											-- eg.:3*30=90		 --->3 hours		 >30 constant value
local trip_presets = {Hallucinations=false, FOV=false, Cubism=false, DSP=false} 
--presets used to set which components the random trip will have
local Onset_str = "psychedelics_lsd_onset"
local Total_str = "psychedelics_lsd_total"
local Ug = 0
local O = 0 -- Variable used to lerp the DrawMaterialOverlay
local C = 0 -- Variable used to lerp the cubism
local can_cubism = true
local Max_overlay = 0
local FOV = 75 --75 is the default value
local components= {
	"$pp_colour_colour",
	"$pp_colour_mulr",
	"$pp_colour_mulg",
	"$pp_colour_mulb"
}
local cModify={
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0.1,
	[ "$pp_colour_mulg" ] = 0.1,
	[ "$pp_colour_mulb" ] = 0.1
}
local function TryRemoveAll()
	local do_it = true
	if cModify[ "$pp_colour_colour" ]~=1 then do_it = false end
	for i = 2,#components do
		i = components[i]
		local var = cModify[i]
		if var>=0.11 then do_it = false
		elseif var<=0.09 then do_it = false
		end
	end
	if O>0 then do_it = false end
	if FOV~=75 then do_it = false end
	if do_it then hook.Remove("RenderScreenspaceEffects","psychedelics_LSDEffect") Max_overlay = 0 end
end
local function GoDefaultColors()
	local proceed = false
	local colour = cModify["$pp_colour_colour"]
	--local dif = (math.abs(colour)>=1.1 or math.abs(colour)<=-1.1)
	local dif=true
	if colour>1 and dif then cModify["$pp_colour_colour"]=(colour*100-1)/100 proceed=true 
	elseif colour<1 and dif then cModify["$pp_colour_colour"]=(colour*100+1)/100 proceed=true end
	for i = 2,#components do
		i = components[i]
		local var = cModify[i]
		if var>=0.11 then cModify[i]=(var*100-1)/100 proceed=true var = cModify[i] 
		elseif var<=0.09 then cModify[i]=(var*100+1)/100 proceed=true var = cModify[i]
		end
	end
	if proceed==false then TryRemoveAll() return end
	timer.Simple(0.01,GoDefaultColors)
end
local function ClearLSD(mult)
	for i=1,#components do
		timer.Remove("psychedelics_"..components[i])
	end
	GoDefaultColors()
	trip_presets.Hallucinations = false --return presets to default
	trip_presets.FOV = false
	trip_presets.Cubism = false
	trip_presets.DSP = false
	LocalPlayer():SetDSP(0)
	Ug = 0
	can_cubism = true
end
local function cubism()
	if Ug==0 then return end
	if timer.Exists("psychedelics_cubism")==false and can_cubism then
		can_cubism = false
		timer.Create("psychedelics_cubism",0.01,100,function() 
			C = C + 1
			if C>=100 then 
				timer.Create("psychedelics_cubism",0.01,100,function()
					C = C - 1
					if C<=0 then timer.Simple(math.random(3,6),function() can_cubism = true end) end --wait 3-6 seconds to create the cubism effect again
				end)
			end
		end)
	end
	timer.Simple(0.01,cubism)
end
local function hallucination()
	if Ug==0 then return end
	if trip_presets.Hallucinations==false then return end
	if Ug>=300 then --only works above 300 Ug
		Psychedelics.RandomHallucination("LSD")
	end
	timer.Simple(22,hallucination)
end
local function lerp_component(component,target) --uses the string of the name of the component and the desired value to lerp to
	local value = cModify[component]
	local sum = true
	local repetitions
	if target>value then
		repetitions = target*100-value*100
	elseif target<value then
		repetitions = value*100-target*100
		sum=false
	else return end
	timer.Create("psychedelics_"..component,0.01,repetitions,function()
		local value = cModify[component]
		if sum then
			cModify[component] = (value*100 + 1)/100	--we must transform the float numbers to int to avoid bugs
		else
			cModify[component] = (value*100 - 1)/100
		end
	end)
end
local function lerp_overlay()
	if Ug==0 and O<=0 then print("2. O = ", O) print("remove overlay") TryRemoveAll() return end
	if Ug~=0 then
		if O<1 then O=O+0.01 end
	elseif Ug==0 then
		if O==0.01 then O = 0 print("3. O = ", O)
		elseif O>0 then O=(O*100-1)/100 print("O = ", O) end
	end
	timer.Simple(0.1,lerp_overlay)
end
local function LSDColors()
	if Ug==0 then return end --stops changing colors when the effect is over
	local colour = cModify[ "$pp_colour_colour" ]
	local mulr = cModify[ "$pp_colour_mulr" ]
	local mulg = cModify[ "$pp_colour_mulg" ]
	local mulb = cModify[ "$pp_colour_mulb" ]
	local ischanging=false
	timer.Simple(0.01,LSDColors)
	for i=1,#components do
		if timer.Exists("psychedelics_"..components[i]) then ischanging=true end
	end
	if ischanging then return end
	local x = Ug/10 --value used 
	local should_change = math.random(1,100)<=x
	local which_component = math.random(1,#components)
	local which_value = (math.random(-100,100)*(Ug/20))/100
	if should_change then
		lerp_component(components[which_component], which_value)
	end
end
local function LerpFOV()
	if FOV==75 and Ug==0 then TryRemoveAll() hook.Remove("CalcView","psychedelics_LSDCalcView") return end
	if timer.Exists("psychedelics_changeFOV")==false and timer.Exists("psychedelics_holdFOV")==false  then
		if FOV==75 and timer.Exists("psychedelics_waitFOV")==false then
			local side = math.random(0,1)
			local mult = math.random(10,400) --multiplier of FOV changer
			local duration = math.random(1,14) --duration of applied change in FOV
			local wait = math.random(1,14) --how much time is needed to wait for another change in FOV
			timer.Create("psychedelics_holdFOV",mult/100 + duration,1,function() end)
			timer.Create("psychedelics_waitFOV",mult/100 + duration+wait,1,function() end)
			if side == 0 then
				timer.Create("psychedelics_changeFOV",0.01,mult,function() FOV=FOV+0.1 end)
			else
				timer.Create("psychedelics_changeFOV",0.01,mult,function() FOV=FOV-0.1 end)
			end
		else
			if FOV>75 then FOV=FOV-0.1
			else FOV=FOV+0.1 end
		end
	end
	timer.Simple(0.01,LerpFOV)
end
local function FOVHook(ply, pos, angles, fov)
	local view = {
		origin = pos,
		angles = angles,
		fov = FOV,
	}
	return view
end
local function LSDHook()
	local Min = 0
	local Max = Max_overlay
	DrawColorModify(cModify)
	DrawMaterialOverlay( "psychedelics/lsd", Lerp(O, Min, Max) )
	DrawMaterialOverlay( "psychedelics/cubism", Lerp(C/100, 0, 0.05) )
end
local function DoLSD()
	hook.Add("RenderScreenspaceEffects","psychedelics_LSDEffect",LSDHook)
	lerp_overlay()
	LSDColors()
	if trip_presets.FOV then 
		hook.Add("CalcView","psychedelics_LSDCalcView",FOVHook) 
		LerpFOV()
	end
	if trip_presets.Cubism then cubism() end
	if trip_presets.Hallucinations then hallucination() end
end

net.Receive("psychedelics_death",function()
		 if net.ReadEntity()==LocalPlayer() then
			ClearLSD(100) --clears LSD faster at a 100 rate
		 end		
end)
	
print("LSDClient inicializado")


net.Receive( "LSDmeuStart", function()
	if Ug==0 then --makes sure these functions are called only one time
		timer.Create(Onset_str,Duration.Onset,1,DoLSD)
		timer.Simple(40,ClearLSD)
	end
	Ug=Ug+net.ReadInt(32)
	Max_overlay = Ug/100000
end)