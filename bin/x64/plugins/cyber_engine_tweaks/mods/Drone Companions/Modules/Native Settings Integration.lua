DCO = { 
    description = "DCO"
}
local config = require("modules/utils/config")

curSettings = config.loadFile("Data/config.json")
FlyingHP = curSettings.FlyingHP
FlyingDPS = curSettings.FlyingDPS
AndroidHP = curSettings.AndroidHP
AndroidDPS = curSettings.AndroidDPS
MechHP = curSettings.MechHP
MechDPS = curSettings.MechDPS
Drone_Core_Price = curSettings.Drone_Core_Price
Disable_Android_Voices = curSettings.Disable_Android_Voices
Permanent_Mechs = curSettings.Permanent_Mechs
SystemExSlot = curSettings.SystemExSlot

MeleeAndroidAppearance = curSettings.MeleeAndroidAppearance
RangedAndroidAppearance = curSettings.RangedAndroidAppearance
ShotgunnerAndroidAppearance = curSettings.ShotgunnerAndroidAppearance
NetrunnerAndroidAppearance = curSettings.NetrunnerAndroidAppearance
TechieAndroidAppearance = curSettings.TechieAndroidAppearance
SniperAndroidAppearance = curSettings.SniperAndroidAppearance

BombusAppearance = curSettings.BombusAppearance

function DCO:new()


    defaultSettings = {
	FlyingHP = 1,
	FlyingDPS = 1,
	AndroidHP = 1,
	AndroidDPS = 1,
	MechHP = 1,
	MechDPS = 1,
	
	Drone_Core_Price = 30,

	Disable_Android_Voices = false,
	Permanent_Mechs = false,
	SystemExSlot = 1,
	
	MeleeAndroidAppearance = "Maelstrom 1",
	RangedAndroidAppearance = "Scavengers 3",
	ShotgunnerAndroidAppearance = "Sixth Street 6",
	NetrunnerAndroidAppearance = "Maelstrom 3",
	TechieAndroidAppearance = "Wraiths 5",
	SniperAndroidAppearance = "Badlands 2",
	
	BombusAppearance = "Beam"

	}

	local nativeSettings = GetMod("nativeSettings")
    if not nativeSettings then
        print("[Drone Companions] Error: NativeSettings lib not found!")
        return
    end
    nativeSettings.addTab("/DCO", Tab_Name)
	nativeSettings.addSubcategory("/DCO/Stats", Subtab_1)
	nativeSettings.addSubcategory("/DCO/Pricing", Subtab_2)
	nativeSettings.addSubcategory("/DCO/Misc", Subtab_3)
	nativeSettings.addSubcategory("/DCO/Appearances", Subtab_4)


	
	--Enable reloading mods on exit (courtesy of keanuWheeze)
	local fromMods = false

	Observe("PauseMenuGameController", "OnMenuItemActivated", function (_, _, target)
		fromMods = target:GetData().label == "Mods"
	end)

	Observe("gameuiMenuItemListGameController", "OnMenuItemActivated", function (_, _, target)
		fromMods = target:GetData().label == "Mods"
	end)

	Observe("SettingsMainGameController", "RequestClose", function () -- Handle mod settings close
		if fromMods then
			reloadDCOMods()
			fromMods = false
		end
	end)

	--Stats
	
	nui_limit = 10
	
	nativeSettings.addRangeFloat("/DCO/Stats", FlyingHP_String, HP_Desc, 0.3, nui_limit, 0.1, "%.1f", curSettings.FlyingHP, defaultSettings.FlyingHP, function(value)
		curSettings.FlyingHP = value
		config.saveFile("Data/config.json", curSettings)
	 end)
	nativeSettings.addRangeFloat("/DCO/Stats", FlyingDPS_String, DPS_Desc, 0.3, nui_limit, 0.1, "%.1f", curSettings.FlyingDPS, defaultSettings.FlyingDPS, function(value)
		curSettings.FlyingDPS = value
		config.saveFile("Data/config.json", curSettings)
	 end)

	nativeSettings.addRangeFloat("/DCO/Stats", AndroidHP_String, HP_Desc, 0.3, nui_limit, 0.1, "%.1f", curSettings.AndroidHP, defaultSettings.AndroidHP, function(value)
		curSettings.AndroidHP = value
		config.saveFile("Data/config.json", curSettings)
	 end)
	nativeSettings.addRangeFloat("/DCO/Stats", AndroidDPS_String, DPS_Desc, 0.3, nui_limit, 0.1, "%.1f", curSettings.AndroidDPS, defaultSettings.AndroidDPS, function(value)
		curSettings.AndroidDPS = value
		config.saveFile("Data/config.json", curSettings)
	 end)
	 
	nativeSettings.addRangeFloat("/DCO/Stats", MechHP_String, HP_Desc, 0.3, nui_limit, 0.1, "%.1f", curSettings.MechHP, defaultSettings.MechHP, function(value)
		curSettings.MechHP = value
		config.saveFile("Data/config.json", curSettings)
	 end)
	nativeSettings.addRangeFloat("/DCO/Stats", MechDPS_String, DPS_Desc, 0.3, nui_limit, 0.1, "%.1f", curSettings.MechDPS, defaultSettings.MechDPS, function(value)
		curSettings.MechDPS = value
		config.saveFile("Data/config.json", curSettings)
	 end)
	 
	
	 --Pricing
	 nativeSettings.addRangeInt("/DCO/Pricing", Drone_Core_Price_String, Drone_Core_Price_Desc, 10, 200, 10, curSettings.Drone_Core_Price, defaultSettings.Drone_Core_Price, function(value)
		curSettings.Drone_Core_Price = value
		config.saveFile("Data/config.json", curSettings)
	 end)

	--Miscellaneous
	 nativeSettings.addSwitch("/DCO/Misc", Permanent_Mechs_String, Permanent_Mechs_Description, curSettings.Permanent_Mechs, defaultSettings.Permanent_Mechs, function(state)
		curSettings.Permanent_Mechs = state
		config.saveFile("Data/config.json", curSettings)
	 end)
	 
	 --Appearances
	

	 nativeSettings.addSelectorString("/DCO/Appearances", MeleeAndroidAppearance_String, SelectAppearance_Description, android_app_list, findAppearanceInt(android_app_list, curSettings.MeleeAndroidAppearance), findAppearanceInt(android_app_list, defaultSettings.MeleeAndroidAppearance), function(value)
		curSettings.MeleeAndroidAppearance = android_app_list[value]
		config.saveFile("Data/config.json", curSettings)
	end)
	
	 nativeSettings.addSelectorString("/DCO/Appearances", RangedAndroidAppearance_String, SelectAppearance_Description, android_app_list, findAppearanceInt(android_app_list, curSettings.RangedAndroidAppearance), findAppearanceInt(android_app_list, defaultSettings.RangedAndroidAppearance), function(value)
		curSettings.RangedAndroidAppearance = android_app_list[value]
		config.saveFile("Data/config.json", curSettings)
	end)
	
	 nativeSettings.addSelectorString("/DCO/Appearances", ShotgunnerAndroidAppearance_String, SelectAppearance_Description, android_app_list, findAppearanceInt(android_app_list, curSettings.ShotgunnerAndroidAppearance), findAppearanceInt(android_app_list, defaultSettings.ShotgunnerAndroidAppearance), function(value)
		curSettings.ShotgunnerAndroidAppearance = android_app_list[value]
		config.saveFile("Data/config.json", curSettings)
	end)
	
	 nativeSettings.addSelectorString("/DCO/Appearances", TechieAndroidAppearance_String, SelectAppearance_Description, android_app_list, findAppearanceInt(android_app_list, curSettings.TechieAndroidAppearance), findAppearanceInt(android_app_list, defaultSettings.TechieAndroidAppearance), function(value)
		curSettings.TechieAndroidAppearance = android_app_list[value]
		config.saveFile("Data/config.json", curSettings)
	end)
	
	 nativeSettings.addSelectorString("/DCO/Appearances", NetrunnerAndroidAppearance_String, SelectAppearance_Description, android_app_list, findAppearanceInt(android_app_list, curSettings.NetrunnerAndroidAppearance), findAppearanceInt(android_app_list, defaultSettings.NetrunnerAndroidAppearance), function(value)
		curSettings.NetrunnerAndroidAppearance = android_app_list[value]
		config.saveFile("Data/config.json", curSettings)
	end)
	
	 nativeSettings.addSelectorString("/DCO/Appearances", SniperAndroidAppearance_String, SelectAppearance_Description, android_app_list, findAppearanceInt(android_app_list, curSettings.SniperAndroidAppearance), findAppearanceInt(android_app_list, defaultSettings.SniperAndroidAppearance), function(value)
		curSettings.SniperAndroidAppearance = android_app_list[value]
		config.saveFile("Data/config.json", curSettings)
	end)
	
	
	 nativeSettings.addSelectorString("/DCO/Appearances", BombusAppearance_String, SelectAppearance_Description, bombus_app_list, findAppearanceInt(bombus_app_list, curSettings.BombusAppearance), findAppearanceInt(bombus_app_list, defaultSettings.BombusAppearance), function(value)
		curSettings.BombusAppearance = bombus_app_list[value]
		config.saveFile("Data/config.json", curSettings)
	end)
	
	 --[[
	 local  list = {[1] = SystemExSlot1, [2] = SystemExSlot2} 
	 nativeSettings.addSelectorString("/DCO/Misc", SystemExSlot_String, SystemExSlot_Description, list, curSettings.SystemExSlot, defaultSettings.SystemExSlot, function(value)
	 		curSettings.SystemExSlot = value
			config.saveFile("Data/config.json", curSettings)
	end)
	]]
	 
end
function findAppearanceInt(list, value)
	for i,v in ipairs(list) do
		if v == value then
			return i
		end
	end
end
function refreshVariables()
	FlyingHP = curSettings.FlyingHP
	FlyingDPS = curSettings.FlyingDPS
	AndroidHP = curSettings.AndroidHP
	AndroidDPS = curSettings.AndroidDPS
	MechHP = curSettings.MechHP
	MechDPS = curSettings.MechDPS
	Drone_Core_Price = curSettings.Drone_Core_Price
	Disable_Android_Voices = curSettings.Disable_Android_Voices
	Permanent_Mechs = curSettings.Permanent_Mechs
	SystemExSlot = curSettings.SystemExSlot
	
	MeleeAndroidAppearance = curSettings.MeleeAndroidAppearance
	RangedAndroidAppearance = curSettings.RangedAndroidAppearance
	ShotgunnerAndroidAppearance = curSettings.ShotgunnerAndroidAppearance
	NetrunnerAndroidAppearance = curSettings.NetrunnerAndroidAppearance
	TechieAndroidAppearance = curSettings.TechieAndroidAppearance
	SniperAndroidAppearance = curSettings.SniperAndroidAppearance

	BombusAppearance = curSettings.BombusAppearance

end
function reloadDCOMods()
	refreshVariables()
	
	dofile("modules/Set Values.lua")
end


return DCO:new()
