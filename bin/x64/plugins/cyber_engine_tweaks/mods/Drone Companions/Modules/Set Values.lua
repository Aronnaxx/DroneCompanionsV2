R = { 
    description = "DCO"
}

function DCO:new()

	TweakDB:SetFlat("DCO.DroneCorePrice.value", Drone_Core_Price)
	
	TweakDB:SetFlat("DCO.FlyingDroneHPBonus.value", 1.8 * FlyingHP)
	TweakDB:SetFlat("DCO.FlyingDroneDPSBonus.value", 1.5*FlyingDPS)
	
	TweakDB:SetFlat("DCO.AndroidHPBonus.value", 1.2 * AndroidHP)
	TweakDB:SetFlat("DCO.AndroidDPSBonus.value", 1.5*AndroidDPS)
	
	TweakDB:SetFlat("DCO.MechHPBonus.value", 1.2 * MechHP)
	TweakDB:SetFlat("DCO.MechDPSBonus.value", 1.5*MechDPS)
	
	if Permanent_Mechs then
		TweakDB:SetFlat("DCO.Tier1MechNCPDItemLogicPackageDescription.localizedDescription", NCPD_Mech_Permanent_Desc)
		TweakDB:SetFlat("DCO.Tier1MechArasakaItemLogicPackageDescription.localizedDescription", Arasaka_Mech_Permanent_Desc)
		TweakDB:SetFlat("DCO.Tier1MechMilitechItemLogicPackageDescription.localizedDescription", Militech_Mech_Permanent_Desc)
		
		TweakDB:SetFlat("DCO.MechRegenAbility_inline2.valuePerSec", 0)
		TweakDB:SetFlat("DCO.MechRegenAbility_inline4.valuePerSec", 0)
		
	else
		TweakDB:SetFlat("DCO.Tier1MechNCPDItemLogicPackageDescription.localizedDescription", NCPD_Mech_Desc)
		TweakDB:SetFlat("DCO.Tier1MechArasakaItemLogicPackageDescription.localizedDescription", Arasaka_Mech_Desc)
		TweakDB:SetFlat("DCO.Tier1MechMilitechItemLogicPackageDescription.localizedDescription", Militech_Mech_Desc)	
		
		TweakDB:SetFlat("DCO.MechRegenAbility_inline2.valuePerSec", 0.056)
		TweakDB:SetFlat("DCO.MechRegenAbility_inline4.valuePerSec", 0.056)
		
	end
		
		
	--Fix bug
	CName.add("gang__android_ma_bls_ina_se5_07_droid_01")
	CName.add("gang__android_ma_bls_ina_se5_07_droid_02")
	
	for i=1, DroneRecords do
	--[[
		TweakDB:SetFlat("DCO.Tier1AndroidMelee"..i..".appearanceName", boxeyes)
		TweakDB:SetFlat("DCO.Tier1AndroidRanged"..i..".appearanceName", tanktop)
		TweakDB:SetFlat("DCO.Tier1AndroidShotgunner"..i..".appearanceName", patriot)
		TweakDB:SetFlat("DCO.Tier1AndroidHeavy"..i..".appearanceName", gasmask)
		TweakDB:SetFlat("DCO.Tier1AndroidNetrunner"..i..".appearanceName", wires)
		TweakDB:SetFlat("DCO.Tier1AndroidSniper"..i..".appearanceName", cleansaka)
	]]
		TweakDB:SetFlat("DCO.Tier1AndroidMelee"..i..".appearanceName", CName.new(android_appearances[MeleeAndroidAppearance]))
		TweakDB:SetFlat("DCO.Tier1AndroidRanged"..i..".appearanceName", CName.new(android_appearances[RangedAndroidAppearance]))
		TweakDB:SetFlat("DCO.Tier1AndroidShotgunner"..i..".appearanceName", CName.new(android_appearances[ShotgunnerAndroidAppearance]))
		TweakDB:SetFlat("DCO.Tier1AndroidHeavy"..i..".appearanceName", CName.new(android_appearances[TechieAndroidAppearance]))
		TweakDB:SetFlat("DCO.Tier1AndroidNetrunner"..i..".appearanceName", CName.new(android_appearances[NetrunnerAndroidAppearance]))
		TweakDB:SetFlat("DCO.Tier1AndroidSniper"..i..".appearanceName", CName.new(android_appearances[SniperAndroidAppearance]))
	end
	
	for i=1, DroneRecords do
		--TweakDB:SetFlat("DCO.Tier1Bombus"..i..".appearanceName", "zetatech_bombus__basic_surveillance_drone_01")
		TweakDB:SetFlat("DCO.Tier1Bombus"..i..".appearanceName", CName.new(bombus_appearances[BombusAppearance])) --"zetatech_bombus__basic_surveillance_drone_01")
	end

end


return DCO:new()
