local Duration = {Onset=15,Total=180} --effect time = hours of the effect irl*30
											-- eg.:3*30=90		 --->3 hours		 >30 constant value
local trip_presets = {Hallucinations=false, FOV=false} 
--presets used to set which components the random trip will have
local Onset_str = "psychedelics_shroom_onset"
local Total_str = "psychedelics_shroom_total"
local Ug = 0
local O = 0 -- Variable used to lerp the DrawMaterialOverlay
local Max_overlay = 0
local mult_blur = 0 --used to multiply the motion blur
local FOV = 75 --75 is the default value
local active = false
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
	if cModify[ "$pp_colour_colour" ]>=1.01 or cModify[ "$pp_colour_colour" ]<1 then do_it = false end
	for i = 2,#components do
		i = components[i]
		local var = cModify[i]
		if var>=0.11 then do_it = false
		elseif var<=0.09 then do_it = false
		end
	end
	if O>0 then do_it = false end
	if FOV~=75 then do_it = false end
	if do_it then 
		hook.Remove("RenderScreenspaceEffects","psychedelics_ShroomEffect") 
		hook.Remove("CalcView","psychedelics_ShroomCalcView")
		Max_overlay = 0 
		mult_blur = 0
		active = false
	end
end
local function InstaRemove() --called when the player dies to instantly remove the effects
	Ug = 0
	O = 0
	C = 0
	Max_overlay = 0
	mult_blur = 0
	FOV = 75
	active = false
	trip_presets.Hallucinations = false --return presets to default
	trip_presets.FOV = false
	cModify["$pp_colour_colour"] = 1
	cModify["$pp_colour_mulr"] = 0.1
	cModify["$pp_colour_mulg"] = 0.1
	cModify["$pp_colour_mulb"] = 0.1
	for i=1,#components do
		timer.Remove("psychedelics_"..components[i].."_shroom")
	end
	hook.Remove("RenderScreenspaceEffects","psychedelics_ShroomEffect") 
	hook.Remove("CalcView","psychedelics_ShroomCalcView")
	timer.Remove("psychedelics_autoCleanShroom")
	timer.Remove("psychedelics_hallucination_shroom")
	timer.Remove("psychedelics_changeFOV_shroom")
	timer.Remove("psychedelics_holdFOV_shroom")
	timer.Remove("psychedelics_waitFOV_shroom")
	timer.Remove(Onset_str)
end
local function GoDefaultColors()
	local proceed = false
	local colour = cModify["$pp_colour_colour"]
	--local dif = (math.abs(colour)>=1.1 or math.abs(colour)<=-1.1)
	local dif=true
	if colour>=1.01 and dif then cModify["$pp_colour_colour"]=(colour*100-1)/100 proceed=true --uuuh bugs; so we can only use >=1.01
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
local function ClearShroom(mult)
	timer.Remove("psychedelics_autoCleanShroom") --in case if it was called by death
	for i=1,#components do
		timer.Remove("psychedelics_"..components[i].."_shroom")
	end
	GoDefaultColors()
	trip_presets.Hallucinations = false --return presets to default
	trip_presets.FOV = false
	Ug = 0
end

local function hallucination()
	if Ug==0 then return end
	if trip_presets.Hallucinations==false then return end
	local O = O/1000 --converts to real value we will use
	if O>=0.6 then
		Psychedelics.RandomHallucination("Shroom")
		timer.Create("psychedelics_hallucination_shroom",22,1,hallucination)
	else timer.Create("psychedelics_hallucination_shroom",1,1,hallucination) end
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
	timer.Create("psychedelics_"..component.."_shroom",0.01,repetitions,function()
		local value = cModify[component]
		if sum then
			cModify[component] = (value*100 + 1)/100	--we must transform the float numbers to int to avoid bugs
		else
			cModify[component] = (value*100 - 1)/100
		end
	end)
end
local function lerp_overlay()
	local Max = 1000
	if Ug==0 and O<=0 then TryRemoveAll() return end
	if Ug~=0 then
		if O<Max then O=O+1 end
	elseif Ug==0 then
		if O <= 0 then O = 0
		elseif O>0 then O = O - 1 end
	end
	timer.Simple(0.01,lerp_overlay) --effects develops quicker than lsd
end
local function ShroomColors()
	if Ug==0 then return end --stops changing colors when the effect is over
	local colour = cModify[ "$pp_colour_colour" ]
	local mulr = cModify[ "$pp_colour_mulr" ]
	local mulg = cModify[ "$pp_colour_mulg" ]
	local mulb = cModify[ "$pp_colour_mulb" ]
	local ischanging=false
	timer.Simple(0.01,ShroomColors)
	for i=1,#components do
		if timer.Exists("psychedelics_"..components[i].."_shroom") then ischanging=true end
	end
	if ischanging then return end
	local x = Ug/10 --value used 
	local should_change = math.random(1,100)<=x
	local which_component = math.random(1,#components)
	local which_value = (math.random(-30,30)*(Ug/100))/10
	local over_value = false--gets if the component have a higher or lower value than acceptable
	local current_value = cModify[components[which_component]]
	if current_value>=10 and which_value>0 then over_value = true
	elseif current_value<=-10 and which_value<0 then over_value = true end
	if should_change and over_value == false then
		if which_component~="$pp_colour_colour" then which_value = which_value/10 end
		lerp_component(components[which_component], which_value)
	end
end
local function LerpFOV()
	if FOV==75 and Ug==0 then TryRemoveAll() hook.Remove("CalcView","psychedelics_ShroomCalcView") return end
	if timer.Exists("psychedelics_changeFOV_shroom")==false and timer.Exists("psychedelics_holdFOV_shroom")==false	then
		local O = O/1000 --converts to real value we will use
		if FOV==75 and timer.Exists("psychedelics_waitFOV_shroom")==false and O>=0.6  then
			local side = math.random(0,1)
			local mult = math.random(10,400) --multiplier of FOV changer
			local duration = math.random(1,14) --duration of applied change in FOV
			local wait = math.random(1,14) --how much time is needed to wait for another change in FOV
			timer.Create("psychedelics_holdFOV_shroom",mult/100 + duration,1,function() end)
			timer.Create("psychedelics_waitFOV_shroom",mult/100 + duration+wait,1,function() end)
			if side == 0 then
				timer.Create("psychedelics_changeFOV_shroom",0.01,mult,function() FOV=FOV+0.1 end)
			else
				timer.Create("psychedelics_changeFOV_shroom",0.01,mult,function() FOV=FOV-0.1 end)
			end
		else
			if FOV>75 then FOV=FOV-0.1
			elseif FOV<75 then FOV=FOV+0.1 end
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
local function ShroomHook()
	local Min = 0
	local Max = Max_overlay
	local O = O/1000 --converts to the real value we will use
	DrawColorModify(cModify)
	DrawMaterialOverlay( "psychedelics/shrooms", Lerp(O, Min, Max) )
	local blur = Lerp(mult_blur/500,0,0.8)*O --tracers are less consistent on psilocin
	DrawMotionBlur(0.05,blur,0.01)
end
local function DoShroom()
	hook.Add("RenderScreenspaceEffects","psychedelics_ShroomEffect",ShroomHook)
	lerp_overlay()
	ShroomColors()
	if trip_presets.FOV then 
		hook.Add("CalcView","psychedelics_ShroomCalcView",FOVHook) 
		LerpFOV()
	end
	if trip_presets.Hallucinations then hallucination() end
	active=true
end

net.Receive("PsychedelicsDeathS",function()
		 if net.ReadEntity()==LocalPlayer() then
			InstaRemove() --clears Shroom instantly
		 end		
end)
local function SortPresets()
	local sort_h = math.random(Ug/50,100) 
	if sort_h>80 then
		trip_presets.Hallucinations = true
	end
	local sort_f = math.random(Ug/50,100)
	if sort_f>65 then
		trip_presets.FOV = true
	end

end
net.Receive( "ShroommeuStart", function()
	SortPresets()
	if Ug==0 and active==false then --makes sure these functions are called only one time
		timer.Create(Onset_str,Duration.Onset,1,DoShroom)
		timer.Create("psychedelics_autoCleanShroom",Duration.Total,1,ClearShroom)
		Ug=Ug+net.ReadInt(32)
		Max_overlay = Ug/2000 --1000
		mult_blur = mult_blur + Ug
	elseif Ug~=0 and active then
		if active then
			Ug=Ug+net.ReadInt(32)
			ShroomColors() 
			Max_overlay = Ug/2000
			mult_blur = mult_blur + Ug
		else
			local delay = timer.TimeLeft(Onset_str)
			local sum = net.ReadInt(32)
			timer.Simple(delay, function()
				if Ug==0 then return end --avoids executing the function if the player died
				Ug=Ug+sum
				ShroomColors()
				Max_overlay = Ug/2000
				mult_blur = mult_blur + Ug
			end)
		end
	end
end)