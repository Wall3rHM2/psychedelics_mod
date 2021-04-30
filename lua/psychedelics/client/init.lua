hook.Add("InitPostEntity","psychedelicsPostEntity",function()
	LocalPlayer().psychedelicsPostEnt = true
	hook.Remove("InitPostEntity","psychedelicsPostEntity")
end)