--local lp=LocalPlayer()
print("Loaded Hallucinations")
hook.Add("InitPostEntity", "psychedelics_startup",function() --begin of main hook
local Sounds={ --sounds for auditory hallucinations
	"vo/ravenholm/shotgun_overhere.wav",
	"vo/ravenholm/bucket_thereyouarwe.wav",
	"ambient/alarms/train_horn2.wav",
	"ambient/creatures/teddy.wav",
	"ambient/levels/citadel/strange_talk3.wav",
	"ambient/levels/citadel/strange_talk5.wav",
	"ambient/levels/citadel/weaponstrip1_adpcm.wav",
	"ambient/levels/labs/teleport_weird_voices2.wav",
	"ambient/materials/footsteps_wood1.wav",
	"ambient/materials/footsteps_wood2.wav"
}

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
 	end)
	timer.Simple(removetime,function()
		timer.Create(name.."remove",0.01,103,function()
			removeCount=removeCount+1
			local thecolor=ent:GetColor()
			if thecolor.a>0 then
				alpha=alpha-5
				ent:SetColor(Color(thecolor.r,thecolor.g,thecolor.b,alpha)) 
			end
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

local function PlayRandom()
	local id = math.random(1,#Sounds)
	LocalPlayer():EmitSound(Sounds[id],75,math.random(70,120))
end
local Hallucinations={
	function(drug_name) -- hallucination n 1
		local fishes={}
		for i=1,10 do
			fishes[i]=ClientsideModel("models/props/CS_militia/fishriver01.mdl",RENDERGROUP_STATIC)
			if i==1 then
				local theid=LocalPlayer():StartLoopingSound("ambient/water/underwater.wav")
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
 -- hallucination n 2
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
 --hallucination n 3
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
		local fuckgaynewman="vo/npc/male01/hi0"..tostring(math.random(1,2))..".wav"
		timer.Simple(2,function() body:EmitSound(fuckgaynewman) end)
	end,
 --hallucination n 4
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
	end,
	function(drug_name) --hallucination n 5
		local h_name="beware_of_the_dawg"
		local DogSign=ClientsideModel("models/props_lab/bewaredog.mdl",RENDERGROUP_STATIC)
		BasePos(drug_name..h_name,DogSign,8)
		local thex=math.random(-70,70) local they=math.random(-70,70)
		DogSign:SetPos(DogSign:LocalToWorld(Vector(thex,they,0)) )
		DogSign:SetAngles(DogSign:LocalToWorldAngles(Angle(0,180,0)) )
		timer.Simple(2,function()
			DogSign:EmitSound("ambient/dog"..tostring(math.random(1,6))..".wav")
		end)
	end,
	function(drug_name) --hallucination n 6
		local thex=math.random(-70,70)
		local they=math.random(-70,70)
		local theyaw=math.random(-180,180)
		local gman=ClientsideModel("models/player/gman_high.mdl",RENDERGROUP_STATIC)
		BasePos(drug_name.."_gman",gman,math.random(18,22))
		gman:SetPos(gman:LocalToWorld(Vector(thex,they,0)))
		gman:SetAngles(gman:LocalToWorldAngles(Angle(0,theyaw,0)))
	end,
	function(drug_name) --hallucination n 7
		local thex=math.random(-70,70)
		local they=math.random(-70,70)
		local theyaw=math.random(-180,180)
		local headcrab=ClientsideModel("models/headcrabclassic.mdl",RENDERGROUP_STATIC)
		BasePos(drug_name.."_headcrab",headcrab,math.random(16,24))
		headcrab:SetPos(headcrab:LocalToWorld(Vector(thex,they,0)))
		headcrab:SetAngles(headcrab:LocalToWorldAngles(Angle(0,theyaw,0)))
	end,
	function(drug_name) --hallucination n 8
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
	function(drug_name) --hallucination n 9
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
	end,
	PlayRandom, --hallucination n 10
	PlayRandom, --hallucination n 11
	PlayRandom --hallucination n 12

}
if Psychedelics==nil then
	Psychedelics={}
end
function Psychedelics.RandomHallucination(drug_name)
	Hallucinations[math.random(1,#Hallucinations)](drug_name)
end
function Psychedelics.Hallucination(index,drug_name)
	Hallucinations[index](drug_name)
end
hook.Remove("InitPostEntity", "psychedelics_startup")

end) --end of main hook
