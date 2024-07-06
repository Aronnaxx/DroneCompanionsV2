R = { 
    description = "DCO"
}
local CanDebugPrint = false --For turning on/off print statements
function DCO:new()


	Cron = require("Modules/utils/Cron.lua")
	MenuCron = require("Modules/utils/MenuCron.lua")
	GameSession = require("Modules/utils/GameSession.lua")
	Config = require("Modules/utils/config.lua")
	DroneRecords = 3 --Number of drone records to make. Increasing slows initial game load speed.
	drone_hack_list = {"DCO.Shutdown", "DCO.SelfDestruct", "DCO.Explode", "DCO.OpticalZoom", "DCO.AndroidKerenzikov", "DCO.EWS", "DCO.DroneCloak", "DCO.DroneHeal", --[["DCO.Wait",]] "DCO.Overdrive"}
	Friendly_Time = 0.5 --How long after spawn to set them friendly.
	
	--tdbs for the items that get crafted
	mechncpd_tdb = TweakDBID.new("DCO.Tier1MechNCPDItem")
	mechmilitech_tdb = TweakDBID.new("DCO.Tier1MechMilitechItem")
	mecharasaka_tdb = TweakDBID.new("DCO.Tier1MechArasakaItem")
	octant_tdb = ToTweakDBID{ hash = 0x397809FC, length = 19 }
	octantarasaka_tdb = TweakDBID.new("DCO.Tier1OctantArasakaItem")
	octantmilitech_tdb = TweakDBID.new("DCO.Tier1OctantMilitechItem")
	octanttrauma_tdb = TweakDBID.new("DCO.Tier1OctantTraumaItem")
	octantkangtao_tdb = TweakDBID.new("DCO.Tier1OctantKangTaoItem")

	androidmelee_tdb = ToTweakDBID{ hash = 0x1F473D15, length = 25 }
	androidranged_tdb = ToTweakDBID{ hash = 0x3C1D4405, length = 26 }
	androidshotgunner_tdb = ToTweakDBID{ hash = 0xF4AF643D, length = 30 }
	androidnetrunner_tdb = ToTweakDBID{ hash = 0xD48DB645, length = 29 }
	androidheavy_tdb = ToTweakDBID{ hash = 0x1455132C, length = 25 }
	androidsniper_tdb = ToTweakDBID{ hash = 0x4B7A2991, length = 26 }
	bombus_tdb = ToTweakDBID{ hash = 0xA39F6F8D, length = 19 }
	griffin_tdb = ToTweakDBID{ hash = 0x58EC5CFF, length = 20 }
	wyvern_tdb = ToTweakDBID{ hash = 0xDCC16EA2, length = 19 }
	bombusbeam_tdb = TweakDBID.new("DCO.Tier1BombusBeamItem")


	possible_tdb = {mechncpd_tdb, mechmilitech_tdb, mecharasaka_tdb, octant_tdb, octantarasaka_tdb, octantmilitech_tdb,   octanttrauma_tdb, octantkangtao_tdb, androidmelee_tdb, androidranged_tdb, androidshotgunner_tdb, androidnetrunner_tdb, androidheavy_tdb, androidsniper_tdb, bombus_tdb, bombusbeam_tdb, griffin_tdb, wyvern_tdb}
	
	

	Mech_List = {"DCO.Tier1MechMilitech", "DCO.Tier1MechArasaka", "DCO.Tier1MechNCPD"}
	Flying_List = {"DCO.Tier1OctantArasaka",  "DCO.Tier1OctantMilitech",  "DCO.Tier1Wyvern", "DCO.Tier1Bombus", "DCO.Tier1Griffin"}
	Android_List = {"DCO.Tier1AndroidHeavy", "DCO.Tier1AndroidMelee", "DCO.Tier1AndroidNetrunner", "DCO.Tier1AndroidRanged", "DCO.Tier1AndroidShotgunner", "DCO.Tier1AndroidSniper"}
	
	Drone_Lists = {Mech_List, Flying_List, Android_List}
	for a,b in ipairs(Drone_Lists) do
		temp = {}
		for i,v in ipairs(b) do
			table.insert(temp, v)
			for a=1,DroneRecords do
				table.insert(temp, v..a)
			end
		end
		for i,v in ipairs(temp) do
			if not has_value(b, v) then
				table.insert(b, v)
			end
		end
	end

	Full_Drone_List = {}
	for i,v in ipairs(Android_List) do
		table.insert(Full_Drone_List, v)
	end
	for i,v in ipairs(Flying_List) do
		table.insert(Full_Drone_List, v)
	end
	for i,v in ipairs(Mech_List) do
		table.insert(Full_Drone_List, v)
	end
	
	
	bombus_name = GetLocalizedText("LocKey#45199")
	wyvern_name = GetLocalizedText("LocKey#45200")
	griffin_name = GetLocalizedText("LocKey#45201")
	octantmilitech_name = Militech_Octant_String
	octantarasaka_name = Arasaka_Octant_String
	
	mechncpd_name = NCPD_Mech_String
	mecharasaka_name = GetLocalizedText("LocKey#48905")
	mechmilitech_name = GetLocalizedText("LocKey#48900")
	
	androidmelee_name = Android_Melee_String
	androidranged_name = Android_Ranged_String
	androidshotgunner_name = Android_Shotgunner_String
	androidsniper_name = Android_Sniper_String
	androidnetrunner_name = Android_Netrunner_String
	androidtechie_name = Android_Techie_String
	
	
	--drones_list = {"Octant Drone", "Arasaka Octant Drone", "KangTao Octant Drone", "Trauma Team Octant Drone", "Militech Octant Drone", "Bombus Drone", "Beam Bombus Drone", "Wyvern Drone", "Griffin Drone", "NCPD Robot", "NCPD Mech", "Militech Mech", "Arasaka Mech", "Robot R Mk.2", "Robot CTRP000", "Robot 7823D", "Robot 1634A", "Robot 6734D", "Robot 5634A", "Ranged Android", "Melee Android", "Shotgunner Android", "Netrunner Android", "Sniper Android", "Techie Android", "Training Android"}
	drones_list = {bombus_name, wyvern_name, griffin_name, octantmilitech_name, octantarasaka_name, mechncpd_name, mecharasaka_name, mechmilitech_name, androidmelee_name, androidranged_name, androidshotgunner_name, androidsniper_name, androidnetrunner_name, androidtechie_name}

	drone_records = {}
	drone_records[octantarasaka_name] = "DCO.Tier1OctantArasaka"
	drone_records[octantmilitech_name] = "DCO.Tier1OctantMilitech"
	drone_records[bombus_name] = "DCO.Tier1Bombus"
	drone_records[wyvern_name] = "DCO.Tier1Wyvern"
	drone_records[griffin_name] = "DCO.Tier1Griffin"
	drone_records[mechncpd_name] = "DCO.Tier1MechNCPD"
	drone_records[mechmilitech_name] = "DCO.Tier1MechMilitech"
	drone_records[mecharasaka_name] = "DCO.Tier1MechArasaka"
	drone_records[androidranged_name] = "DCO.Tier1AndroidRanged"
	drone_records[androidmelee_name] = "DCO.Tier1AndroidMelee"
	drone_records[androidshotgunner_name] = "DCO.Tier1AndroidShotgunner"
	drone_records[androidnetrunner_name] = "DCO.Tier1AndroidNetrunner"
	drone_records[androidtechie_name] = "DCO.Tier1AndroidHeavy"
	drone_records[androidsniper_name] = "DCO.Tier1AndroidSniper"
	
	--Appearances
	android_appearances = {}
	android_appearances["Maelstrom 1"] = "gang__android_ma_maelstrom_droid__lvl2_01"
	android_appearances["Maelstrom 2"] = "gang__android_ma_maelstrom_droid__lvl2_02"
	android_appearances["Maelstrom 3"] = "gang__android_ma_maelstrom_droid__lvl2_03"
	android_appearances["Maelstrom 4"] = "gang__android_ma_maelstrom_droid__lvl2_04"
	android_appearances["Wraiths 1"] = "gang__android_ma_wraith_droid__lvl1_01"
	android_appearances["Wraiths 2"] = "gang__android_ma_wraith_droid__lvl1_02"
	android_appearances["Wraiths 3"] = "gang__android_ma_wraith_droid__lvl1_03"
	android_appearances["Wraiths 4"] = "gang__android_ma_wraith_droid__lvl1_04"
	android_appearances["Wraiths 5"] = "gang__android_ma_wraith_droid__lvl1_05"
	android_appearances["Scavengers 1"] = "gang__android_ma_scavenger_droid__lvl2_01"
	android_appearances["Scavengers 2"] = "gang__android_ma_scavenger_droid__lvl2_02"
	android_appearances["Scavengers 3"] = "gang__android_ma_scavenger_droid__lvl2_03"
	android_appearances["Scavengers 4"] = "gang__android_ma_scavenger_droid__lvl2_04"
	android_appearances["Scavengers 5"] = "gang__android_ma_scavenger_droid__lvl2_05"
	android_appearances["Scavengers 6"] = "gang__android_ma_scavenger_droid__lvl2_06"
	android_appearances["Kang Tao 1"] = "gang__android_ma_kangtao_droid__lvl2_01"
	android_appearances["Sixth Street 1"] = "gang__android_ma_6th_street_droid_lvl1_01"
	android_appearances["Sixth Street 2"] = "gang__android_ma_6th_street_droid_lvl1_02"
	android_appearances["Sixth Street 3"] = "gang__android_ma_6th_street_droid_lvl1_03"
	android_appearances["Sixth Street 4"] = "gang__android_ma_6th_street_droid_lvl1_04"
	android_appearances["Sixth Street 5"] = "gang__android_ma_6th_street_droid_lvl1_05"
	android_appearances["Sixth Street 6"] = "gang__android_ma_6th_street_droid_lvl1_06"
	android_appearances["Kerry 1"] = "corpo__android_ma__sq011__kerry_bodyguard_01"
	android_appearances["Kerry 2"] = "corpo__android_ma__sq011__kerry_bodyguard_02"
	android_appearances["Kerry 3"] = "corpo__android_ma__sq011__kerry_bodyguard_03"
	android_appearances["Kerry 4"] = "corpo__android_ma__sq011__kerry_bodyguard_04"
	android_appearances["Kerry 5"] = "corpo__android_ma__sq011__kerry_bodyguard_05"
	android_appearances["Arasaka 1"] = "corpo__android_ma_arasaka_droid__lvl2_01"
	android_appearances["NCPD 1"] = "corpo__android_ma_ncpd_droid__lvl1_01"
	android_appearances["Militech 1"] = "corpo__android_ma_militech_droid__lvl2_01"
	android_appearances["MaxTac 1"] = "corpo__android_ma_maxtac_droid__lvl2_01"
	android_appearances["KangTao 2"] = "corpo__android_ma_kang_tao_droid__lvl2_01"
	android_appearances["Badlands 1"] = "gang__android_ma_bls_ina_se5_07_droid_01"
	android_appearances["Badlands 2"] = "gang__android_ma_bls_ina_se5_07_droid_02"
	android_appearances["Boxing 1"] = "special__training_dummy_ma_dummy_boxing"

	bombus_appearances = {}
	bombus_appearances["Police"] = "zetatech_bombus__basic_surveillance_police_01"
	bombus_appearances["Netwatch"] = "zetatech_bombus__basic_surveillance_netwatch_01"
	bombus_appearances["Purple"] = "zetatech_bombus__basic_nanny_drone_violet"
	bombus_appearances["White"] = "zetatech_bombus__basic_nanny_drone_white"
	bombus_appearances["Beam"] = "zetatech_bombus__basic_surveillance_drone_01"
	bombus_appearances["Blue"] = "zetatech_bombus__basic_nanny_drone_blue"
	bombus_appearances["Service"] = "zetatech_bombus__basic_surveillance_service_01"
	bombus_appearances["Delamain"] = "zetatech_bombus__basic_delamain_drone_01"
	

	--[[
	octantarasaka_rectdb = "DCO.Tier1OctantArasaka"
	octantmilitech_rectdb = "DCO.Tier1OctantMilitech"
	bombus_rectdb = "DCO.Tier1Bombus"
	wyvern_rectdb = "DCO.Tier1Wyvern"
	griffin_rectdb = "DCO.Tier1Griffin"
	mechncpd_rectdb = "DCO.Tier1MechNCPD"
	mechmilitech_rectdb = "DCO.Tier1MechMilitech"
	mecharasaka_rectdb = "DCO.Tier1MechArasaka"
	androidranged_rectdb = "DCO.Tier1AndroidRanged"
	androidmelee_rectdb = "DCO.Tier1AndroidMelee"
	androidshotgunner_rectdb = "DCO.Tier1AndroidShotgunner"
	androidnetrunner_rectdb = "DCO.Tier1AndroidNetrunner"
	androidtechie_rectdb = "DCO.Tier1AndroidHeavy"
	androidsniper_rectdb = "DCO.Tier1AndroidSniper"
	
	base_record_tdbs ={	octantarasaka_rectdb,
	octantmilitech_rectdb ,
	bombus_rectdb ,
	wyvern_rectdb ,
	griffin_rectdb ,
	mechncpd_rectdb ,
	mechmilitech_rectdb ,
	mecharasaka_rectdb ,
	androidranged_rectdb ,
	androidmelee_rectdb ,
	androidshotgunner_rectdb ,
	androidnetrunner_rectdb ,
	androidtechie_rectdb ,
	androidsniper_rectdb}
	
	records_to_item_tdbs = {}
	records_to_item_tdbs[octantarasaka_rectdb] = TweakDBID.new("DCO.Tier1OctantArasakaItem")
	records_to_item_tdbs[octantmilitech_rectdb] = TweakDBID.new("DCO.Tier1OctantMilitechItem")
	records_to_item_tdbs[bombus_rectdb] = TweakDBID.new("DCO.Tier1BombusItem")
	records_to_item_tdbs[wyvern_rectdb] = TweakDBID.new("DCO.Tier1WyvernItem")
	records_to_item_tdbs[griffin_rectdb] = TweakDBID.new("DCO.Tier1GriffinItem")
	records_to_item_tdbs[mechncpd_rectdb] = TweakDBID.new("DCO.Tier1MechNCPDItem") 
	records_to_item_tdbs[mechmilitech_rectdb] = TweakDBID.new("DCO.Tier1MechMilitechItem") 
	records_to_item_tdbs[mecharasaka_rectdb] = TweakDBID.new("DCO.Tier1MechArasakaItem")
	records_to_item_tdbs[androidranged_rectdb] = TweakDBID.new("DCO.Tier1AndroidRangedItem") 
	records_to_item_tdbs[androidmelee_rectdb] = TweakDBID.new("DCO.Tier1AndroidMeleeItem") 
	records_to_item_tdbs[androidshotgunner_rectdb] = TweakDBID.new("DCO.Tier1AndroidShotgunnerItem") 
	records_to_item_tdbs[androidnetrunner_rectdb] = TweakDBID.new("DCO.Tier1AndroidNetrunnerItem")  
	records_to_item_tdbs[androidtechie_rectdb] = TweakDBID.new("DCO.Tier1AndroidHeavyItem") 
	records_to_item_tdbs[androidsniper_rectdb] = TweakDBID.new("DCO.Tier1AndroidSniperItem") 
	
	record_ids_to_item_tdbs = {}
	for i,v in pairs(records_to_item_tdbs) do
		for a=1, DroneRecords do
			record_ids_to_item_tdbs[TweakDBID.new(i..a)] = v
			print(i..a)
			print(v)
			print(TweakDBID.new(i..a))
			print(record_ids_to_item_tdbs[TweakDBID.new(i..a)])
			print()
			
		end
	end
	
]]
	--[[
	drone_records["Octant Drone"] = "DCO.Tier1Octant"
	drone_records["Arasaka Octant Drone"] = "DCO.Tier1OctantArasaka"
	drone_records["KangTao Octant Drone"] = "DCO.Tier1OctantKangTao"
	drone_records["Trauma Team Octant Drone"] = "DCO.Tier1OctantTrauma"
	drone_records["Militech Octant Drone"] = "DCO.Tier1OctantMilitech"
	drone_records["Bombus Drone"] = "DCO.Tier1Bombus"
	drone_records["Beam Bombus Drone"] = "DCO.Tier1BombusBeam"
	drone_records["Wyvern Drone"] = "DCO.Tier1Wyvern"
	drone_records["Griffin Drone"] = "DCO.Tier1Griffin"
	drone_records["NCPD Robot"] = "DCO.Tier1MechNCPD"
	drone_records["NCPD Mech"] = "DCO.Tier1MechNCPD"
	drone_records["Militech Mech"] = "DCO.Tier1MechMilitech"
	drone_records["Arasaka Mech"] = "DCO.Tier1MechArasaka"
	drone_records["Robot R Mk.2"] = "DCO.Tier1AndroidRanged"
	drone_records["Robot CTRP000"] = "DCO.Tier1AndroidMelee"
	drone_records["Robot 7823D"] = "DCO.Tier1AndroidShotgunner"
	drone_records["Robot 1634A"] = "DCO.Tier1AndroidNetrunner"
	drone_records["Robot 6734D"] = "DCO.Tier1AndroidHeavy"
	drone_records["Robot 5634A"] = "DCO.Tier1AndroidSniper"
	drone_records["Ranged Android"] = "DCO.Tier1AndroidRanged"
	drone_records["Melee Android"] = "DCO.Tier1AndroidMelee"
	drone_records["Shotgunner Android"] = "DCO.Tier1AndroidShotgunner"
	drone_records["Netrunner Android"] = "DCO.Tier1AndroidNetrunner"
	drone_records["Techie Android"] = "DCO.Tier1AndroidHeavy"
	drone_records["Sniper Android"] = "DCO.Tier1AndroidSniper"
]]

	
end

function createRandomQuantityVendorItem(RecordName, SCReq, item, qmin, qmax)
	TweakDB:CreateRecord(RecordName, "gamedataVendorItem_Record")
	TweakDB:SetFlatNoUpdate(RecordName..".availabilityPrereq", "SCReq"..SCReq)
	TweakDB:SetFlatNoUpdate(RecordName..".item", item)
	TweakDB:SetFlatNoUpdate(RecordName..".quantity", {RecordName.."Quantity"})
	TweakDB:Update(RecordName)

	TweakDB:CreateRecord(RecordName.."Quantity", "gamedataRandomStatModifier_Record")
	TweakDB:SetFlatNoUpdate(RecordName.."Quantity.statType", "BaseStats.Quantity")
	TweakDB:SetFlatNoUpdate(RecordName.."Quantity.modifierType", "Additive")
	TweakDB:SetFlatNoUpdate(RecordName.."Quantity.min", qmin)
	TweakDB:SetFlatNoUpdate(RecordName.."Quantity.max", qmax)
	TweakDB:Update(RecordName.."Quantity")

end
--[[
function addToList(list, tdb)
	temp = TweakDB:GetFlat(list)
	if not TweakDB:GetFlat("ListAdditions."..list..tdb) then
		TweakDB:SetFlat("ListAdditions."..list..tdb, true)
		table.insert(temp, tdb)
		TweakDB:SetFlat(list, temp)
	end
end]]

function addToList(list, ability)
	--TweakDB:SetFlat("RTDB.ActionTargetPrereq.target", ability)
	--abilityhash=TweakDB:GetFlat("RTDB.ActionTargetPrereq.target")
	abilityhash = TweakDBID.new(ability)
	templist = TweakDB:GetFlat(list)
	if TweakDB:GetFlat(list) == nil then
		return
	end
	if has_value(templist, abilityhash) then
	
	else

		table.insert(templist, ability)
		TweakDB:SetFlat(list, templist)
	end
end
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
function addCName(list, ability)
	abilityhash=ability
	templist = TweakDB:GetFlat(list)
	if TweakDB:GetFlat(list) == nil then
		return
	end
	if has_value(templist, abilityhash) then
	
	else

		table.insert(templist, ability)
		TweakDB:SetFlat(list, templist)
	end
end
function createConstantStatModifier(recordName, modifierType, statType, value)
	TweakDB:CreateRecord(recordName, "gamedataConstantStatModifier_Record")
	TweakDB:SetFlatNoUpdate(recordName..".modifierType", modifierType)
	TweakDB:SetFlatNoUpdate(recordName..".statType", statType)
	TweakDB:SetFlatNoUpdate(recordName..".value", value)
	TweakDB:Update(recordName)
end
function createCombinedStatModifier(recordName, modifierType, opSymbol, refObject, refStat, statType, value)

	TweakDB:CreateRecord(recordName, "gamedataCombinedStatModifier_Record")
	TweakDB:SetFlatNoUpdate(recordName..".modifierType", modifierType)
	TweakDB:SetFlatNoUpdate(recordName..".opSymbol", opSymbol)
	TweakDB:SetFlatNoUpdate(recordName..".refObject", refObject)
	TweakDB:SetFlatNoUpdate(recordName..".refStat", refStat)
	TweakDB:SetFlatNoUpdate(recordName..".statType", statType)
	TweakDB:SetFlatNoUpdate(recordName..".value", value)
	TweakDB:Update(recordName)

end
function addListToList(recordName, list, list2)
	for i,v in ipairs(list2) do
		addToListMult(recordName.."."..list, v)
	end
	TweakDB:Update(recordName)
end
function addToListMult(list, ability)
	TweakDB:SetFlat("RTDB.ActionTargetPrereq.target", ability)
	abilityhash=TweakDB:GetFlat("RTDB.ActionTargetPrereq.target")
	templist = TweakDB:GetFlat(list)
	if TweakDB:GetFlat(list) == nil then
		return
	end
	if has_value(templist, abilityhash) then
	
	else

		table.insert(templist, ability)
		TweakDB:SetFlatNoUpdate(list, templist)
	end
end
function createVendorItem(RecordName, SCReq, item)
	TweakDB:CreateRecord(RecordName, "gamedataVendorItem_Record")
	TweakDB:SetFlatNoUpdate(RecordName..".availabilityPrereq", "SCReq"..SCReq)
	TweakDB:SetFlatNoUpdate(RecordName..".item", item)
	TweakDB:SetFlatNoUpdate(RecordName..".quantity", {"Vendors.IsPresent"})
	TweakDB:Update(RecordName)
end
function createSCRequirement(value)
	TweakDB:CloneRecord("SCReq"..value, "Vendors.GlenCredAvailability")
	TweakDB:SetFlat("SCReq"..value..".valueToCheck", value)
end
function debugPrint(filename, str)
	if not CanDebugPrint then 
		return 
	end
	print(filename.." "..str)
end


return DCO:new()
