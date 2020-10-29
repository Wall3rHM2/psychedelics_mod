--local lp=LocalPlayer()
local AHallucinations={
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
if SDrugs==nil then
 SDrugs={}
end
function SDrugs.AHallucination(index)
 LocalPlayer():EmitSound(AHallucinations[index],75,math.random(70,120))
end