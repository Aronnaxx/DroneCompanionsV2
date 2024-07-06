R = { 
    description = "DCO"
}

function DCO:new()




	--------------------DRONE CORES--------------------------


	

	--Create drones cores
	TweakDB:CloneRecord("DCO.DroneCore", "Items.EpicMaterial1")
	TweakDB:SetFlatNoUpdate("DCO.DroneCore.localizedName", "yyy{"..Drone_Core_String.."}{"..Drone_Core_Desc.."}")
	TweakDB:SetFlatNoUpdate("DCO.DroneCore.localizedDescription", LocKey(49555ull))
	TweakDB:SetFlatNoUpdate("DCO.DroneCore.displayName", LocKey(1882ull))
	TweakDB:SetFlatNoUpdate("DCO.DroneCore.tags", {"Robot"})
	TweakDB:SetFlat("DCO.DroneCore.iconPath", "perkpoints_remover")

	--Set their price
	createConstantStatModifier("DCO.DroneCorePrice", "Multiplier", "BaseStats.Price", Drone_Core_Price)
	TweakDB:SetFlat("DCO.DroneCore.buyPrice", {"Price.BasePrice", "DCO.DroneCorePrice"})
	TweakDB:SetFlat("DCO.DroneCore.sellPrice", {"Price.BasePrice", "DCO.DroneCorePrice"})


	--icon
	createIcon("DCO.DroneCore", "DCODroneCore", "dronecore_atlas")
	
	-----------------CREATE DRONE RECORDS-------------------------
	
	--Create characters
	createSubCharacter("DCO.Tier1MechNCPD", "Character.Mech_NPC_Base", "NCPD", LocKey(48944ull))
	createSubCharacter("DCO.Tier1MechMilitech", "Character.Mech_NPC_Base", "Militech", LocKey(48900ull))
	createSubCharacter("DCO.Tier1MechArasaka", "Character.Mech_NPC_Base", "Arasaka", LocKey(48905ull))
	createSubCharacter("DCO.Tier1OctantArasaka", "Character.Drone_Octant_Base", "Arasaka",  LocKey(45202ull))
	createSubCharacter("DCO.Tier1OctantMilitech", "Character.Drone_Octant_Base", "Militech",  LocKey(45202ull))
	createSubCharacter("DCO.Tier1Wyvern", "Character.Drone_Wyvern_Base", "Militech",  LocKey(45200ull))
	createSubCharacter("DCO.Tier1Griffin", "Character.Drone_Griffin_Base", "Militech", LocKey(45201ull))
	createSubCharacter("DCO.Tier1AndroidRanged", "Character.wraiths_base_android", "Scavengers", LocKey(42656ull))
	createSubCharacter("DCO.Tier1AndroidMelee", "Character.wraiths_base_android", "Maelstrom", LocKey(50547ull))
	createSubCharacter("DCO.Tier1AndroidShotgunner", "Character.wraiths_base_android", "Wraiths", LocKey(50544ull))
	createSubCharacter("DCO.Tier1AndroidNetrunner", "Character.wraiths_base_android", "Wraiths", LocKey(50542ull))
	createSubCharacter("DCO.Tier1AndroidHeavy", "Character.wraiths_base_android", "Wraiths", LocKey(50538ull))
	createSubCharacter("DCO.Tier1AndroidSniper", "Character.wraiths_base_android", "Wraiths", LocKey(50536ull))
	createSubCharacter("DCO.Tier1Bombus", "Character.Drone_Bombus_Base", "Militech",  LocKey(45199ull))


	
	-------------------------BASE REACTION PRESET---------------------------
	TweakDB:CloneRecord("DCO.ReactionPreset", "ReactionPresets.Mechanical_Aggressive")
	rules = TweakDB:GetFlat("ReactionPresets.Mechanical_Aggressive.rules")
	toremove = {42, 38, 34, 32, 31, 26, 24, 14, 10, 9, 7, 6, 4, 3, 0}
	for i,v in ipairs(toremove) do
		table.remove(rules, v+1)
	end
	TweakDB:SetFlat("DCO.ReactionPreset.rules", rules)
	
	------------------ANDROID WEAPONS/ARCHETYPE------------------------------
	
	--Ranged
	createArchetypeAndEquipment("DCO.Tier1AndroidRanged", "ArchetypeData.AndroidRangedT2", "ArchetypeType.FastRangedT3", {"Ability.IsFastRangedArchetype",  "Ability.HasDodge", "Ability.CanCrouch", "Ability.HasKerenzikov", "Ability.CanSprint", "Ability.CanUseCovers", "Ability.IsTier2Archetype", "Ability.HasSandevistanTier1"}, "DCO.AndroidCopperhead", "DCO.AndroidSidewinder", {"DCO.AndroidLiberty"}, {"DCO.AndroidYukimura"})
	
	--Melee
	createArchetypeAndEquipmentMelee("DCO.Tier1AndroidMelee", "ArchetypeData.AndroidMeleeT2", "ArchetypeType.FastMeleeT3", {"Ability.HasDodge", "Ability.HasKerenzikov", "Ability.IsFastMeleeArchetype", "Ability.CanSprint", "Ability.CanSprintHarass", "Ability.HasSandevistanTier1", "Ability.HasChargeJump", "Ability.CanCatchUpDistance", "Ability.CanCatchUp", "Ability.CanUseCovers", "Ability.CanParry", "Ability.CanBlock", "Ability.IsTier2Archetype"}, "DCO.AndroidBaton", "DCO.AndroidKatana", {"DCO.AndroidCopperhead", "DCO.AndroidLexington"}, {"DCO.AndroidAjax", "DCO.AndroidOmaha"}) --Backup rifle for vehicle combat
	
	--Shotgunner
	createArchetypeAndEquipment("DCO.Tier1AndroidShotgunner", "ArchetypeData.AndroidRangedT2", "ArchetypeType.FastShotgunnerT3", {"Ability.IsShotgunnerArchetype", "Ability.HasKerenzikov", "Ability.CanCatchUp", "Ability.CanCatchUpDistance", "Ability.IsTier2Archetype", "Ability.HasChargeJump", "Ability.HasSandevistanTier1", "Ability.CanSprint", "Ability.HasDodge"}, "DCO.AndroidIgla", "DCO.AndroidSatara", {"DCO.AndroidUnity"}, {"DCO.AndroidQuasar"})
	
	--Netrunner
	createArchetypeAndEquipment("DCO.Tier1AndroidNetrunner", "ArchetypeData.AndroidRangedT2", "ArchetypeType.NetrunnerT3",
	{"Ability.IsNetrunnerArchetype","Ability.IsTier3Archetype", "Ability.HasKerenzikov", "Ability.CanUseCovers", "Ability.CanQuickhack", "Ability.CanOverheatQuickHack", "Ability.CanCatchUpDistance", "Ability.HasDodge", "Ability.CanOverloadQuickHack", "Ability.CanBuffCamoQuickHack", "Ability.CanDeathQuickHack", "Ability.CanWeaponMalfunctionQuickHack", "Ability.CanLocomotionMalfunctionQuickHack", "Ability.CanUseExtremeRing", "Ability.CanUseFarRing", "Ability.HasSandevistanTier1"}, 
	"DCO.AndroidLexington", "DCO.AndroidYukimura", {"DCO.AndroidUnity", "DCO.AndroidCopperhead"}, {"DCO.AndroidKenshin", "DCO.AndroidAjax"})
	
	--Techie
	createArchetypeAndEquipment("DCO.Tier1AndroidHeavy", "ArchetypeData.AndroidRangedT2", "ArchetypeType.HeavyRangedT3", {"Ability.IsFastRangedArchetype", "Ability.HasKerenzikov", "Ability.HasDodge", "Ability.CanCrouch", "Ability.CanSprint", "Ability.CanUseCovers", "Ability.IsTier3Archetype",  "Ability.HasSandevistanTier1", "Ability.CanUseGrenades"}, "DCO.AndroidOverture", "DCO.AndroidQuasar", {"DCO.AndroidNova", "DCO.AndroidCopperhead"}, {"DCO.AndroidBurya", "DCO.AndroidMasamune"})
	
	--Sniper
	createArchetypeAndEquipment("DCO.Tier1AndroidSniper", "ArchetypeData.AndroidRangedT2", "ArchetypeType.FastSniperT3", { "Ability.HasSandevistanTier1", "Ability.HasKerenzikov", "Ability.HasDodge", "Ability.CanCrouch", "Ability.CanSprint", "Ability.CanUseCovers",  "Ability.IsTier3Archetype", "Ability.CanCatchUpDistance", "Ability.IsBalanced", "Ability.CanCloseCombat", "Ability.IsSniperArchetype", "Ability.IsBalanced"}, "DCO.AndroidGrad", "DCO.AndroidNekomata", {"DCO.AndroidNue"}, {"DCO.AndroidOmaha"})
	
	--Unequip 2h weapons condition when one arm has been dismembered (UNUSED)
	TweakDB:CloneRecord("DCO.AndroidUnequip2HCondition", "WeaponConditions.BaseRangedPrimaryWeaponUnequipCondition")
	TweakDB:SetFlat("DCO.AndroidUnequip2HCondition.condition", "DCO.AndroidUnequip2HCondition_inline0")
	
	TweakDB:CloneRecord("DCO.AndroidUnequip2HCondition_inline0", "WeaponConditions.BaseRangedPrimaryWeaponUnequipCondition_inline0")
	addListToList("DCO.AndroidUnequip2HCondition_inline0", "OR", {"Condition.StatusEffectCrippledHandLeft", "Condition.StatusEffectCrippledArmLeft", "Condition.StatusEffectDismemberedHandLeft", "Condition.StatusEffectDismemberedArmLeft"})
	
	
	----------------------------MAKE ANDROID WEAPONS------------------------------------
	
	--Melee
	stats = {{"Multiplier", "NPCDamage", 1.3}}
	createAndroidWeapon("DCO.AndroidKatana", "Items.Preset_Katana_Military", stats)
	createAndroidWeapon("DCO.AndroidBaton", "Items.Preset_Baton_Alpha", stats)

	--Rifles
	stats = {{"Multiplier", "NPCDamage", 0.5}, {"Multiplier", "Accuracy", 0.8}, {"Multiplier", "HitReactionFactor", 0.5}}
	createAndroidWeapon("DCO.AndroidAjax", "Items.Preset_Ajax_Military", stats)
	createAndroidWeapon("DCO.AndroidCopperhead", "Items.Preset_Copperhead_Neon", stats)
	createAndroidWeapon("DCO.AndroidUmbra", "Items.Preset_Umbra_Neon", stats)
	createAndroidWeapon("DCO.AndroidMasamune", "Items.Preset_Masamune_Military", stats)
	
	stats = {{"Multiplier", "NPCDamage", 2}, {"Multiplier", "SmartGunNPCProjectileVelocity", 2}, {"Multiplier", "HitReactionFactor", 0.5}}
	createAndroidWeapon("DCO.AndroidSidewinder", "Items.Preset_Sidewinder_Military", stats)

	--Handguns/Revolvers
	stats = {{"Multiplier", "NPCDamage", 0.6}, {"Multiplier", "Accuracy", 0.8}, {"Multiplier", "HitReactionFactor", 0.5}}
	createAndroidWeapon("DCO.AndroidKenshin", "Items.Preset_Kenshin_Military", stats)
	createAndroidWeapon("DCO.AndroidOmaha", "Items.Preset_Omaha_Military", stats)
	createAndroidWeapon("DCO.AndroidBurya", "Items.Preset_Burya_Military", stats)
	createAndroidWeapon("DCO.AndroidQuasar", "Items.Preset_Quasar_Military", stats)
	createAndroidWeapon("DCO.AndroidLiberty", "Items.Preset_Liberty_Neon", stats)
	createAndroidWeapon("DCO.AndroidLexington", "Items.Preset_Lexington_Neon", stats)
	createAndroidWeapon("DCO.AndroidUnity", "Items.Preset_Unity_Neon", stats)
	createAndroidWeapon("DCO.AndroidNue", "Items.Preset_Nue_Neon", stats)
	createAndroidWeapon("DCO.AndroidNova", "Items.Preset_Nova_Neon", stats)
	createAndroidWeapon("DCO.AndroidOverture", "Items.Preset_Overture_Neon", stats)

	stats = {{"Multiplier", "NPCDamage", 1.8}, {"Multiplier", "SmartGunNPCProjectileVelocity", 2}, {"Multiplier", "HitReactionFactor", 0.5}}
	createAndroidWeapon("DCO.AndroidYukimura", "Items.Preset_Yukimura_Military", stats)

	--Sniper rifles
	stats = {{"Multiplier", "NPCDamage", 1.0}, {"Multiplier", "Accuracy", 1.0}}
	createAndroidWeapon("DCO.AndroidNekomata", "Items.Preset_Nekomata_Military", stats)
	createAndroidWeapon("DCO.AndroidGrad", "Items.Preset_Grad_Neon", stats)
	
	--Shotguns
	stats = {{"Multiplier", "NPCDamage", 1.0}, {"Additive", "HitReactionFactor", -0.5}, {"Multiplier", "SpreadMaxAI", 0.5}}
	createAndroidWeapon("DCO.AndroidSatara", "Items.Preset_Satara_Military", stats)	
	stats = {{"Multiplier", "NPCDamage", 1.0}, {"Additive", "HitReactionFactor", -0.5}, {"Multiplier", "SpreadMaxAI", 0.5}}
	createAndroidWeapon("DCO.AndroidIgla", "Items.Preset_Igla_Neon", stats)
	
	-----------------------RECIPES--------------------------------
	
	Uncommon_Recipe_Price = 600
	Rare_Recipe_Price = 2000
	Epic_Recipe_Price = 5000
	Epic_Mech_Price = 10000
	Legendary_Mech_Price = 20000
	
	--Make drone recipes
	
	--Octants
	Tier1Octant_Cost = {{"Items.RareMaterial1", 20}, {"Items.EpicMaterial1", 20}, {"DCO.DroneCore", 6}}
	
	createRecipe("DCO.Tier1OctantArasaka", LocKey(45202ull), "DroneModule", Tier1Octant_Cost, "Epic", Arasaka_Octant_Desc, Epic_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1OctantArasakaItem.localizedName", "yyy{"..Arasaka_Octant_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1OctantArasakaRecipe.localizedName", "yyy{"..Arasaka_Octant_String.."}{}")

	createRecipe("DCO.Tier1OctantMilitech", LocKey(45202ull), "DroneModule", Tier1Octant_Cost, "Epic", Militech_Octant_Desc, Epic_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1OctantMilitechItem.localizedName", "yyy{"..Militech_Octant_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1OctantMilitechRecipe.localizedName", "yyy{"..Militech_Octant_String.."}{}")



	--Flying drones
	Tier1Bombus_Cost = {{"Items.CommonMaterial1", 20}, {"Items.UncommonMaterial1", 20}, {"DCO.DroneCore", 2}}
	createRecipe("DCO.Tier1Bombus", LocKey(45199ull), "DroneModule", Tier1Bombus_Cost, "Uncommon", Bombus_Desc, Uncommon_Recipe_Price)


	Tier1Wyvern_Cost = {{"Items.UncommonMaterial1", 20}, {"Items.RareMaterial1", 20}, {"DCO.DroneCore", 4}}
	createRecipe("DCO.Tier1Wyvern", LocKey(45200ull), "DroneModule", Tier1Wyvern_Cost, "Rare", Wyvern_Desc, Rare_Recipe_Price)

	Tier1Griffin_Cost = {{"Items.UncommonMaterial1", 20}, {"Items.RareMaterial1", 20}, {"DCO.DroneCore", 4}}
	createRecipe("DCO.Tier1Griffin", LocKey(45201ull), "DroneModule", Tier1Griffin_Cost, "Rare", Griffin_Desc, Rare_Recipe_Price)

	--Mechs
	Tier1Mech_Cost = {{"Items.EpicMaterial1", 50}, {"Items.LegendaryMaterial1", 50}, {"DCO.DroneCore", 30}}
	createRecipe("DCO.Tier1MechMilitech", LocKey(48900ull), "DroneModule", Tier1Mech_Cost, "Legendary", Militech_Mech_Desc, Legendary_Mech_Price)
	
	createRecipe("DCO.Tier1MechArasaka", LocKey(48905ull), "DroneModule", Tier1Mech_Cost, "Legendary", Arasaka_Mech_Desc, Legendary_Mech_Price)
	
	Tier1MechNCPD_Cost = {{"Items.RareMaterial1", 50}, {"Items.EpicMaterial1", 50}, {"DCO.DroneCore", 20}}
	createRecipe("DCO.Tier1MechNCPD", LocKey(48944ull), "DroneModule", Tier1MechNCPD_Cost, "Epic", NCPD_Mech_Desc, Epic_Mech_Price)
	TweakDB:SetFlat("DCO.Tier1MechNCPDItem.localizedName", "yyy{"..NCPD_Mech_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1MechNCPDRecipe.localizedName", "yyy{"..NCPD_Mech_String.."}{}")


	--Rare Androids
	Tier1Android_Cost = {{"Items.UncommonMaterial1", 30}, {"Items.RareMaterial1", 30}, {"DCO.DroneCore", 8}}
	
	createRecipe("DCO.Tier1AndroidRanged", LocKey(42656ull), "DroneModule", Tier1Android_Cost, "Rare", Android_Ranged_Desc, Rare_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1AndroidRangedItem.localizedName", "yyy{"..Android_Ranged_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1AndroidRangedRecipe.localizedName", "yyy{"..Android_Ranged_String.."}{}")

	createRecipe("DCO.Tier1AndroidMelee", LocKey(50547ull), "DroneModule", Tier1Android_Cost, "Rare", Android_Melee_Desc, Rare_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1AndroidMeleeItem.localizedName", "yyy{"..Android_Melee_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1AndroidMeleeRecipe.localizedName", "yyy{"..Android_Melee_String.."}{}")

	createRecipe("DCO.Tier1AndroidShotgunner", LocKey(50544ull), "DroneModule", Tier1Android_Cost, "Rare", Android_Shotgunner_Desc, Rare_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1AndroidShotgunnerItem.localizedName", "yyy{"..Android_Shotgunner_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1AndroidShotgunnerRecipe.localizedName", "yyy{"..Android_Shotgunner_String.."}{}")

	--Epic Androids
	Tier1AndroidEpic_Cost = {{"Items.RareMaterial1", 30}, {"Items.EpicMaterial1", 30}, {"DCO.DroneCore", 12}}
	
	createRecipe("DCO.Tier1AndroidNetrunner", LocKey(50542ull), "DroneModule", Tier1AndroidEpic_Cost, "Epic", Android_Netrunner_Desc, Epic_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1AndroidNetrunnerItem.localizedName", "yyy{"..Android_Netrunner_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1AndroidNetrunnerRecipe.localizedName", "yyy{"..Android_Netrunner_String.."}{}")

	createRecipe("DCO.Tier1AndroidHeavy", LocKey(50538ull), "DroneModule", Tier1AndroidEpic_Cost, "Epic", Android_Techie_Desc, Epic_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1AndroidHeavyItem.localizedName", "yyy{"..Android_Techie_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1AndroidHeavyRecipe.localizedName", "yyy{"..Android_Techie_String.."}{}")

	createRecipe("DCO.Tier1AndroidSniper", LocKey(50536ull), "DroneModule", Tier1AndroidEpic_Cost, "Epic", Android_Sniper_Desc, Epic_Recipe_Price)
	TweakDB:SetFlat("DCO.Tier1AndroidSniperItem.localizedName", "yyy{"..Android_Sniper_String.."}{}")
	TweakDB:SetFlat("DCO.Tier1AndroidSniperRecipe.localizedName", "yyy{"..Android_Sniper_String.."}{}")


	--Add bombus recipe and 10 drone cores to starting equipment
	TweakDB:CreateRecord("DCO.BombusStartingItem", "gamedataInventoryItem_Record")
	TweakDB:SetFlatNoUpdate("DCO.BombusStartingItem.quantity", 1)
	TweakDB:SetFlat("DCO.BombusStartingItem.item", "DCO.Tier1BombusRecipe")

	addToList("ProgressionBuilds.StreetKidStarting.startingItems", "DCO.BombusStartingItem")
	addToList("ProgressionBuilds.NomadStarting.startingItems", "DCO.BombusStartingItem")
	addToList("ProgressionBuilds.CorpoStarting.startingItems", "DCO.BombusStartingItem")

	TweakDB:CreateRecord("DCO.DroneCoreStartingItem", "gamedataInventoryItem_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneCoreStartingItem.quantity", 10)
	TweakDB:SetFlat("DCO.DroneCoreStartingItem.item", "DCO.DroneCore")
	
	addToList("ProgressionBuilds.StreetKidStarting.startingItems", "DCO.DroneCoreStartingItem")
	addToList("ProgressionBuilds.NomadStarting.startingItems", "DCO.DroneCoreStartingItem")
	addToList("ProgressionBuilds.CorpoStarting.startingItems", "DCO.DroneCoreStartingItem")

	
	--------------------------------ICONS-------------------------------------------
	createBaseDroneIcon("DCO.Tier1AndroidRanged", "DCOAndroidRanged", "androidranged_atlas")
	createBaseDroneIcon("DCO.Tier1AndroidMelee", "DCOAndroidMelee", "androidmelee_atlas")
	createBaseDroneIcon("DCO.Tier1AndroidShotgunner", "DCOAndroidShotgunner", "androidshotgunner_atlas")
	createBaseDroneIcon("DCO.Tier1AndroidNetrunner", "DCOAndroidNetrunner", "androidnetrunner_atlas")
	createBaseDroneIcon("DCO.Tier1AndroidSniper", "DCOAndroidSniper", "androidsniper_atlas")
	createBaseDroneIcon("DCO.Tier1AndroidHeavy", "DCOAndroidHeavy", "androidtechie_atlas")
	
	createBaseDroneIcon("DCO.Tier1Bombus", "DCOAndroidBombus", "bombus_atlas")
	createBaseDroneIcon("DCO.Tier1Wyvern", "DCOWyvern", "wyvern_atlas")
	createBaseDroneIcon("DCO.Tier1Griffin", "DCOGriffin", "griffin_atlas")
	createBaseDroneIcon("DCO.Tier1OctantMilitech", "DCOOctantMilitech", "octantmilitech_atlas")
	createBaseDroneIcon("DCO.Tier1OctantArasaka", "DCOOctantArasaka", "octantarasaka_atlas")

	createBaseDroneIcon("DCO.Tier1MechNCPD", "DCOMechNCPD", "mechncpd_atlas")
	createBaseDroneIcon("DCO.Tier1MechArasaka", "DCOMechArasaka", "mecharasaka_atlas")
	createBaseDroneIcon("DCO.Tier1MechMilitech", "DCOMechMilitech", "mechmilitech_atlas")

	------------------------------APPEARANCES----------------------------
	
	--Androids
	for i,v in ipairs(Android_List) do
		TweakDB:SetFlat(v..".entityTemplatePath", "base\\characters\\entities\\gang\\dco_android.ent")
	end
	
	tanktop = CName.new("gang__android_ma_scavenger_droid__lvl2_03") --Ranged
	wires = CName.new("gang__android_ma_maelstrom_droid__lvl2_03") --Netrunner
	patriot = CName.new("gang__android_ma_6th_street_droid_lvl1_06")--Shotgunner
	
	gasmask = CName.new("gang__android_ma_wraith_droid__lvl1_05") --Techie
	cleansaka = CName.new("gang__android_ma_maelstrom_droid__lvl2_02") --Sniper
	boxeyes = CName.new("gang__android_ma_maelstrom_droid__lvl2_01") --Melee

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
	
	--Flying drones
	for i=1, DroneRecords do
		--TweakDB:SetFlat("DCO.Tier1Bombus"..i..".appearanceName", "zetatech_bombus__basic_surveillance_drone_01")
		TweakDB:SetFlat("DCO.Tier1Bombus"..i..".appearanceName", CName.new(bombus_appearances[BombusAppearance]))
	end
	
	
	--	TweakDB:SetFlat("DCO.Tier1AndroidMelee1.entityTemplatePath", "base\\mechanical\\prototypes\\spiderbot_01_prototype_dco.ent")
		--TweakDB:SetFlat("DCO.Tier1Bombus1.entityTemplatePath", "base\\mechanical\\prototypes\\spiderbot_01_prototype_dco.ent")

	-----------------------REMOVE ITEM ADDED NOTIFICATION----------------------------
end
function createBaseDroneIcon(recordName, icon, atlasname)
	TweakDB:CreateRecord("UIIcon."..icon, "gamedataUIIcon_Record")
	TweakDB:SetFlatNoUpdate("UIIcon."..icon..".atlasPartName", "icon_part")
	TweakDB:SetFlat("UIIcon."..icon..".atlasResourcePath", "base\\icon\\"..atlasname..".inkatlas")
	
	TweakDB:SetFlatNoUpdate(recordName.."Item.iconPath", icon)
	TweakDB:SetFlat(recordName.."Item.icon", "UIIcon."..icon)

	--Set the icon path as a flat in our records
	
	for i=1, DroneRecords do	
		TweakDB:SetFlat(recordName..i..".DCOAtlasResource", "base\\icon\\"..atlasname..".inkatlas")
	end

end
function createIcon(recordName, icon, atlasname)
	TweakDB:CreateRecord("UIIcon."..icon, "gamedataUIIcon_Record")
	TweakDB:SetFlatNoUpdate("UIIcon."..icon..".atlasPartName", "icon_part")
	TweakDB:SetFlat("UIIcon."..icon..".atlasResourcePath", "base\\icon\\"..atlasname..".inkatlas")
	
	TweakDB:SetFlatNoUpdate(recordName..".iconPath", icon)
	TweakDB:SetFlat(recordName..".icon", "UIIcon."..icon)



end
function createLeftHandEquipment(weapon, list, toClone)
	TweakDB:CloneRecord(toClone.."Left", toClone)
	TweakDB:SetFlatNoUpdate(toClone.."Left.item", weapon)
	TweakDB:SetFlat(toClone.."Left.equipSlot", "AttachmentSlots.WeaponLeft")
	
	addToList(list, toClone.."Left")
end
function createAndroidWeapon(recordName, weapon, statsList)
	TweakDB:CloneRecord(recordName, weapon)
	TweakDB:SetFlat(recordName..".npcRPGData", recordName.."_inline0")
	
	TweakDB:CloneRecord(recordName.."_inline0", TweakDB:GetFlat(weapon..".npcRPGData"))
	temp = {}
	for i,v in ipairs(statsList) do
		createConstantStatModifier(recordName..v[2], v[1], "BaseStats."..v[2], v[3])
		table.insert(temp, recordName..v[2])
	end
	addListToList(recordName.."_inline0", "statModifiers", temp)
	
end
function createRecipe(recordName, displayName, icon, costList, quality, description, buyPrice)

	--Recipe
	TweakDB:CloneRecord(recordName.."Recipe", "Items.Recipe_TitaniumPlating")
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.displayName", displayName)
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.buyPrice", {"Price.BasePrice", recordName.."RecipePrice"})
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.sellPrice", {"Price.BasePrice", recordName.."RecipePrice"})
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.localizedDescription", LocKey(0ull))
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.iconPath", icon)
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.craftingResult", recordName.."Recipe_inline1")
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.tags", {"Recipe", "SkipActivityLogOnRemove","Robot"})
	TweakDB:SetFlatNoUpdate(recordName.."Recipe.quality", "Quality."..quality)
	TweakDB:Update(recordName.."Recipe")
	
	--Price
	createConstantStatModifier(recordName.."RecipePrice", "Multiplier", "BaseStats.Price", buyPrice)
	
	--Crafting result
	TweakDB:CreateRecord(recordName.."Recipe_inline1", "gamedataCraftingResult_Record")
	TweakDB:SetFlatNoUpdate(recordName.."Recipe_inline1.amount", -1)
	TweakDB:SetFlat(recordName.."Recipe_inline1.item", recordName.."Item")

	--Item
	TweakDB:CloneRecord(recordName.."Item", "Items.TitaniumPlating")
	TweakDB:SetFlatNoUpdate(recordName.."Item.displayName", displayName)
	TweakDB:SetFlatNoUpdate(recordName.."Item.localizedDescription", LocKey(0ull))
	TweakDB:SetFlatNoUpdate(recordName.."Item.iconPath", icon)
	TweakDB:SetFlatNoUpdate(recordName.."Item.itemType", "ItemType.Gen_Misc")
	TweakDB:SetFlatNoUpdate(recordName.."Item.OnEquip", {recordName.."ItemLogicPackage"})
	TweakDB:SetFlatNoUpdate(recordName.."Item.placementSlots", {})
	TweakDB:SetFlatNoUpdate(recordName.."Item.quality", "Quality."..quality)
	TweakDB:SetFlatNoUpdate(recordName.."Item.CraftingData", recordName.."Item_inline0")
	TweakDB:SetFlat(recordName.."Item.tags", {"HideAtVendor", "HideInBackpackUI",  "Robot", "SkipActivityLog"}) --Hide it in the backpack so it doesn't seem like an item, and make it show up in cyberware screen
	
	--OnEquip Description
	TweakDB:CreateRecord(recordName.."ItemLogicPackage", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat(recordName.."ItemLogicPackage.UIData", recordName.."ItemLogicPackageDescription")
	
	TweakDB:CreateRecord(recordName.."ItemLogicPackageDescription", "gamedataGameplayLogicPackageUIData_Record")
	TweakDB:SetFlat(recordName.."ItemLogicPackageDescription.localizedDescription", description)
	
	
	--Crafting data
	TweakDB:CloneRecord(recordName.."Item_inline0", "Items.TitaniumPlating_inline3")
	recipe_list = {}
	
	--Recipe elements
	for i,v in ipairs(costList) do
		TweakDB:CreateRecord(recordName.."Item_inline"..i, "gamedataRecipeElement_Record")
		TweakDB:SetFlatNoUpdate(recordName.."Item_inline"..i..".ingredient", v[1])
		TweakDB:SetFlat(recordName.."Item_inline"..i..".amount", v[2])
		table.insert(recipe_list, recordName.."Item_inline"..i)
	end
	
	TweakDB:SetFlat(recordName.."Item_inline0.craftingRecipe", recipe_list)
	
end



function createArchetypeAndEquipment(recordName, archetype, archetypetype, archetypeStats, basicweapon, advancedweapon, basicbackupweapon, advancedbackupweapon)

	--Create archetype
	TweakDB:CloneRecord(recordName.."Archetype", archetype)
	TweakDB:SetFlatNoUpdate(recordName.."Archetype.type", archetypetype)
	TweakDB:SetFlat(recordName.."Archetype.abilityGroups", {recordName.."Archetype_inline0"})
	
	TweakDB:CreateRecord(recordName.."Archetype_inline0", "gamedataGameplayAbilityGroup_Record")
	TweakDB:SetFlat(recordName.."Archetype_inline0.abilities", archetypeStats)
	
	--Set archetype and equipment
	TweakDB:SetFlat(recordName..".archetypeData", recordName.."Archetype")
	TweakDB:SetFlat(recordName..".secondaryEquipment", recordName.."SecondaryEquipment")
	TweakDB:SetFlat(recordName..".primaryEquipment", recordName.."PrimaryEquipment")

	for i=1,DroneRecords do
		TweakDB:SetFlat(recordName..i..".archetypeData", recordName.."Archetype")
		TweakDB:SetFlat(recordName..i..".secondaryEquipment", recordName.."SecondaryEquipment")
		TweakDB:SetFlat(recordName..i..".primaryEquipment", recordName.."PrimaryEquipment")
	end
	
	--Create equipment

	TweakDB:CreateRecord(recordName.."PrimaryEquipment", "gamedataNPCEquipmentGroup_Record")
	TweakDB:SetFlat(recordName.."PrimaryEquipment.equipmentItems", {recordName.."PrimaryPool"})
	
	TweakDB:CreateRecord(recordName.."PrimaryPool", "gamedataNPCEquipmentItemPool_Record")
	TweakDB:SetFlat(recordName.."PrimaryPool.pool", {recordName.."PrimaryPoolEntryBasic", recordName.."PrimaryPoolEntryAdvanced"})
	
	--Basic equipment
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryBasic", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryBasic.weight", 1)
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryBasic.items", {recordName.."PrimaryPoolEntryBasic_inline1"})
	
	TweakDB:CloneRecord(recordName.."PrimaryPoolEntryBasic_inline1", "Character.ma_bls_se5_07_android_bodyguard_inline1")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryBasic_inline1.unequipCondition", {"DCO.AndroidUnequip2HCondition"})
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryBasic_inline1.onBodySlot", "")
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryBasic_inline1.item", basicweapon)
	
	--Advanced equipment
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryAdvanced", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryAdvanced.weight", 69420)
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryAdvanced.items", {recordName.."PrimaryPoolEntryAdvanced_inline1"})
	
	TweakDB:CloneRecord(recordName.."PrimaryPoolEntryAdvanced_inline1", "Character.ma_bls_se5_07_android_bodyguard_inline1")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryAdvanced_inline1.unequipCondition", {"DCO.AndroidUnequip2HCondition"})
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryAdvanced_inline1.onBodySlot", "")
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryAdvanced_inline1.item", advancedweapon)
	
	--Create backup equipment

	TweakDB:CreateRecord(recordName.."SecondaryEquipment", "gamedataNPCEquipmentGroup_Record")
	TweakDB:SetFlat(recordName.."SecondaryEquipment.equipmentItems", {recordName.."SecondaryPool"})
	
	TweakDB:CreateRecord(recordName.."SecondaryPool", "gamedataNPCEquipmentItemPool_Record")
	TweakDB:SetFlat(recordName.."SecondaryPool.pool", {recordName.."SecondaryPoolEntryBasic", recordName.."SecondaryPoolEntryAdvanced"})
	
	--Basic backup equipment
	TweakDB:CreateRecord(recordName.."SecondaryPoolEntryBasic", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."SecondaryPoolEntryBasic.weight", 1)
	
	items_list = {}
	for i,v in ipairs(basicbackupweapon) do
		TweakDB:CloneRecord(recordName.."SecondaryPoolEntryBasic_inline"..i, "Character.CommunityCorpoSecondaryHandgunPool_inline3")
		TweakDB:SetFlat(recordName.."SecondaryPoolEntryBasic_inline"..i..".item", v)
		table.insert(items_list, recordName.."SecondaryPoolEntryBasic_inline"..i)
	end
	TweakDB:SetFlat(recordName.."SecondaryPoolEntryBasic.items", items_list)

	--Advanced backup equipment
	TweakDB:CreateRecord(recordName.."SecondaryPoolEntryAdvanced", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."SecondaryPoolEntryAdvanced.weight", 69420)
	TweakDB:SetFlat(recordName.."SecondaryPoolEntryAdvanced.items", {recordName.."SecondaryPoolEntryAdvanced_inline1"})
	
	items_list = {}
	for i,v in ipairs(advancedbackupweapon) do
		TweakDB:CloneRecord(recordName.."SecondaryPoolEntryAdvanced_inline"..i, "Character.CommunityCorpoSecondaryHandgunPool_inline3")
		TweakDB:SetFlat(recordName.."SecondaryPoolEntryAdvanced_inline"..i..".item", v)
		table.insert(items_list, recordName.."SecondaryPoolEntryAdvanced_inline"..i)
	end
	TweakDB:SetFlat(recordName.."SecondaryPoolEntryAdvanced.items", items_list)
	

end
function createArchetypeAndEquipmentMelee(recordName, archetype, archetypetype, archetypeStats, basicweapon, advancedweapon, basicbackupweapon, advancedbackupweapon)

	--Create archetype
	TweakDB:CloneRecord(recordName.."Archetype", archetype)
	TweakDB:SetFlatNoUpdate(recordName.."Archetype.type", archetypetype)
	TweakDB:SetFlat(recordName.."Archetype.abilityGroups", {recordName.."Archetype_inline0"})
	
	TweakDB:CreateRecord(recordName.."Archetype_inline0", "gamedataGameplayAbilityGroup_Record")
	TweakDB:SetFlat(recordName.."Archetype_inline0.abilities", archetypeStats)
	
	--Set archetype and equipment
	TweakDB:SetFlat(recordName..".archetypeData", recordName.."Archetype")
	TweakDB:SetFlat(recordName..".secondaryEquipment", recordName.."SecondaryEquipment")
	TweakDB:SetFlat(recordName..".primaryEquipment", recordName.."PrimaryEquipment")

	for i=1,DroneRecords do
		TweakDB:SetFlat(recordName..i..".archetypeData", recordName.."Archetype")
		TweakDB:SetFlat(recordName..i..".secondaryEquipment", recordName.."SecondaryEquipment")
		TweakDB:SetFlat(recordName..i..".primaryEquipment", recordName.."PrimaryEquipment")
	end
	
	--Create primary equipment
	TweakDB:CreateRecord(recordName.."PrimaryEquipment", "gamedataNPCEquipmentGroup_Record")
	TweakDB:SetFlat(recordName.."PrimaryEquipment.equipmentItems", {recordName.."PrimaryPool"})
	
	TweakDB:CreateRecord(recordName.."PrimaryPool", "gamedataNPCEquipmentItemPool_Record")
	TweakDB:SetFlat(recordName.."PrimaryPool.pool", {recordName.."PrimaryPoolEntryBasic", recordName.."PrimaryPoolEntryAdvanced"})
	
	--Basic equipment
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryBasic", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryBasic.weight", 1)
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryBasic.items", {recordName.."PrimaryPoolEntryBasic_inline1"})
	
	TweakDB:CloneRecord(recordName.."PrimaryPoolEntryBasic_inline1", "Character.max_border_guards_baton_inline1")
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryBasic_inline1.item", basicweapon)
	
	--Advanced equipment
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryAdvanced", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryAdvanced.weight", 69420)
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryAdvanced.items", {recordName.."PrimaryPoolEntryAdvanced_inline1"})
	
	TweakDB:CloneRecord(recordName.."PrimaryPoolEntryAdvanced_inline1", "Character.max_border_guards_baton_inline1")
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryAdvanced_inline1.item", advancedweapon)
	
	--Create backup equipment

	TweakDB:CreateRecord(recordName.."SecondaryEquipment", "gamedataNPCEquipmentGroup_Record")
	TweakDB:SetFlat(recordName.."SecondaryEquipment.equipmentItems", {recordName.."SecondaryPool"})
	
	TweakDB:CreateRecord(recordName.."SecondaryPool", "gamedataNPCEquipmentItemPool_Record")
	TweakDB:SetFlat(recordName.."SecondaryPool.pool", {recordName.."SecondaryPoolEntryBasic", recordName.."SecondaryPoolEntryAdvanced"})
	
	--Basic backup equipment
	TweakDB:CreateRecord(recordName.."SecondaryPoolEntryBasic", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."SecondaryPoolEntryBasic.weight", 1)
	
	items_list = {}
	for i,v in ipairs(basicbackupweapon) do
		TweakDB:CloneRecord(recordName.."SecondaryPoolEntryBasic_inline"..i, "Character.CommunityCorpoSecondaryHandgunPool_inline3")
		TweakDB:SetFlat(recordName.."SecondaryPoolEntryBasic_inline"..i..".item", v)
		table.insert(items_list, recordName.."SecondaryPoolEntryBasic_inline"..i)
	end
	TweakDB:SetFlat(recordName.."SecondaryPoolEntryBasic.items", items_list)

	--Advanced backup equipment
	TweakDB:CreateRecord(recordName.."SecondaryPoolEntryAdvanced", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."SecondaryPoolEntryAdvanced.weight", 69420)
	TweakDB:SetFlat(recordName.."SecondaryPoolEntryAdvanced.items", {recordName.."SecondaryPoolEntryAdvanced_inline1"})
	
	items_list = {}
	for i,v in ipairs(advancedbackupweapon) do
		TweakDB:CloneRecord(recordName.."SecondaryPoolEntryAdvanced_inline"..i, "Character.CommunityCorpoSecondaryHandgunPool_inline3")
		TweakDB:SetFlat(recordName.."SecondaryPoolEntryAdvanced_inline"..i..".item", v)
		table.insert(items_list, recordName.."SecondaryPoolEntryAdvanced_inline"..i)
	end
	TweakDB:SetFlat(recordName.."SecondaryPoolEntryAdvanced.items", items_list)
	
	
end

function createStat(recordName, baseStat)
	TweakDB:CloneRecord(recordName, baseStat)
	--TweakDB:SetFlat(recordName..".enumName", "")
end

function createSubCharacter(recordName, copiedRecord, visualTag, displayName)

	--Copies all flats from a character record to a subcharacter record
	
	copy_stats = {"abilities", "actionMap", "affiliation", "alternativeDisplayName", "alternativeFullDisplayName", "appearanceName", "archetypeData", "archetypeName", "attachmentSlots", "audioResourceName", "audioMeleeMaterial", "baseAttitudeGroup", "bountyDrawTable", "canHaveGenericTalk", "characterType", "communitySquad", "contentAssignment", "crowdAppearanceNames", "crowdMemberSettings", "defaultCrosshair", "defaultEquipment", "despawnChildCommunityWhenPlayerInVehicle", "devNotes", "disableDefeatedState", "displayDescription", "displayName", "driving", "dropsAmmoOnDeath", "dropsMoneyOnDeath", "dropsWeaponOnDeath", "effectors", "enableSensesOnStart", "entityTemplatePath", "enumComment", "enumName", "EquipmentAreas", "forceCanHaveGenericTalk", "forcedTBHZOffset", "fullDisplayName", "genders", "globalSquad", "hasDirectionalStarts", "holocallInitializerPath", "idleActions", "isBumpable", "isChild", "isCrowd", "isLightCrowd", "isPrevention", "itemGroups", "items", "lootBagEntity", "lootDrop", "minigameInstance", "multiplayerTemplatePaths", "objectActions", "onSpawnGLPs", "persistentName", "primaryEquipment", "priority", "quest", "rarity", "reactionPreset", "referenceName", "savable", "scannerModulePreset", "secondaryEquipment", "securitySquad", "sensePreset", "skipDisplayArchetype", "squadParamsID", "startingEquippedItems", "stateMachineName", "staticCommunityAppearancesDistributionEnabled", "statModifierGroups", "statModifiers", "statPools", "tags", "threatTrackingPreset", "uiNameplate", "useForcedTBHZOffset", "vendorID", "visualTags", "voiceTag",  "weakspots",  "cpoCharacterBuild",  "cpoClassName"}

	flat_stats = {"alertedSensesPreset","combatSensesPreset", "keepColliderOnDeath",  "relaxedSensesPreset", "statusEffectParamsPackageName", "weaponSlot"}
	
	flat_float_stats = {"airDeathRagdollDelay", "combatDefaultZOffset", "mass", "massNormalizedCoefficient", "pseudoAcceleration", "sizeBack", "sizeFront", "sizeLeft", "sizeRight", "speedIdleThreshold", "startingRecoveryBalance",  "tiltAngleOnSpeed", "turnInertiaDamping", "walkTiltCoefficient"}
	
	TweakDB:CreateRecord(recordName, "gamedataSubCharacter_Record")
	
	for i,v in ipairs(copy_stats) do
		flat = TweakDB:GetFlat(copiedRecord.."."..v)
		if flat then
			TweakDB:SetFlatNoUpdate(recordName.."."..v, flat)
		end
	end
	
	for i,v in ipairs(flat_stats) do
		flat = TweakDB:GetFlat(copiedRecord.."."..v)
		if flat then
			TweakDB:SetFlat(recordName.."."..v, flat)
		end
	end
	
	for i,v in ipairs(flat_float_stats) do
		flat = TweakDB:GetFlat(copiedRecord.."."..v)
		if flat then
			TweakDB:SetFlat(recordName.."."..v, flat, 'Float')
		end
	end
	
	--Set a few specific flats
	TweakDB:SetFlatNoUpdate(recordName..".displayName", displayName)
	TweakDB:SetFlatNoUpdate(recordName..".visualTags", {visualTag})
	TweakDB:SetFlatNoUpdate(recordName..".tags", {"Robot"})
	TweakDB:SetFlatNoUpdate(recordName..".objectActions", drone_hack_list)
	TweakDB:SetFlatNoUpdate(recordName..".squadParamsID", "FactionSquads.MilitechSquad")
	TweakDB:SetFlatNoUpdate(recordName..".affiliation", "Factions.Unaffiliated")
	--TweakDB:SetFlatNoUpdate(recordName..".reactionPreset", "ReactionPresets.Follower")
	TweakDB:SetFlatNoUpdate(recordName..".baseAttitudeGroup", "player")
	TweakDB:SetFlatNoUpdate(recordName..".lootBagEntity", "None")
	TweakDB:SetFlatNoUpdate(recordName..".disableDefeatedState", true)
	TweakDB:SetFlatNoUpdate(recordName..".dropsWeaponOnDeath", false)
	TweakDB:SetFlatNoUpdate(recordName..".reactionPreset", "DCO.ReactionPreset")
	TweakDB:SetFlatNoUpdate(recordName..".dropsAmmoOnDeath", false)
	TweakDB:SetFlatNoUpdate(recordName..".lootDrop", "LootTables.Empty")
	TweakDB:SetFlatNoUpdate(recordName..".uiNameplate", "UINameplate.CombatSettings")
	addListToList(recordName, "statModifiers", {"DCO.FollowerDefeatedImmunityStat", "Character.ScaleToPlayerLevel"})
	
	TweakDB:Update(recordName)
	
	
	--Make 1-2-3 versions
	for i=1,DroneRecords do

		TweakDB:CloneRecord(recordName..i, recordName)
		
		--Set flat of associated item
		TweakDB:SetFlat(recordName..i..".DCOItem", recordName.."Item")
		
		for _,v in ipairs(flat_stats) do
			flat = TweakDB:GetFlat(recordName.."."..v)
			if flat then
				TweakDB:SetFlat(recordName..i.."."..v, flat)
			end
		end
		
		for _,v in ipairs(flat_float_stats) do
			flat = TweakDB:GetFlat(recordName.."."..v)
			if flat then
				TweakDB:SetFlat(recordName..i.."."..v, flat, 'Float')
			end
		end
	end
	
end

function createSubCharacterEnemy(recordName, copiedRecord)

	--Copies all flats from a character record to a subcharacter record
	
	copy_stats = {"abilities", "actionMap", "affiliation", "alternativeDisplayName", "alternativeFullDisplayName", "appearanceName", "archetypeData", "archetypeName", "attachmentSlots", "audioResourceName", "audioMeleeMaterial", "baseAttitudeGroup", "bountyDrawTable", "canHaveGenericTalk", "characterType", "communitySquad", "contentAssignment", "crowdAppearanceNames", "crowdMemberSettings", "defaultCrosshair", "defaultEquipment", "despawnChildCommunityWhenPlayerInVehicle", "devNotes", "disableDefeatedState", "displayDescription", "displayName", "driving", "dropsAmmoOnDeath", "dropsMoneyOnDeath", "dropsWeaponOnDeath", "effectors", "enableSensesOnStart", "entityTemplatePath", "enumComment", "enumName", "EquipmentAreas", "forceCanHaveGenericTalk", "forcedTBHZOffset", "fullDisplayName", "genders", "globalSquad", "hasDirectionalStarts", "holocallInitializerPath", "idleActions", "isBumpable", "isChild", "isCrowd", "isLightCrowd", "isPrevention", "itemGroups", "items", "lootBagEntity", "lootDrop", "minigameInstance", "multiplayerTemplatePaths", "objectActions", "onSpawnGLPs", "persistentName", "primaryEquipment", "priority", "quest", "rarity", "reactionPreset", "referenceName", "savable", "scannerModulePreset", "secondaryEquipment", "securitySquad", "sensePreset", "skipDisplayArchetype", "squadParamsID", "startingEquippedItems", "stateMachineName", "staticCommunityAppearancesDistributionEnabled", "statModifierGroups", "statModifiers", "statPools", "tags", "threatTrackingPreset", "uiNameplate", "useForcedTBHZOffset", "vendorID", "visualTags", "voiceTag",  "weakspots",  "cpoCharacterBuild",  "cpoClassName"}

	flat_stats = {"alertedSensesPreset","combatSensesPreset", "keepColliderOnDeath",  "relaxedSensesPreset", "statusEffectParamsPackageName", "weaponSlot"}
	
	flat_float_stats = {"airDeathRagdollDelay", "combatDefaultZOffset", "mass", "massNormalizedCoefficient", "pseudoAcceleration", "sizeBack", "sizeFront", "sizeLeft", "sizeRight", "speedIdleThreshold", "startingRecoveryBalance",  "tiltAngleOnSpeed", "turnInertiaDamping", "walkTiltCoefficient"}
	
	TweakDB:CreateRecord(recordName, "gamedataSubCharacter_Record")
	
	for i,v in ipairs(copy_stats) do
		flat = TweakDB:GetFlat(copiedRecord.."."..v)
		if flat then
			TweakDB:SetFlatNoUpdate(recordName.."."..v, flat)
		end
	end
	
	for i,v in ipairs(flat_stats) do
		flat = TweakDB:GetFlat(copiedRecord.."."..v)
		if flat then
			TweakDB:SetFlat(recordName.."."..v, flat)
		end
	end
	
	for i,v in ipairs(flat_float_stats) do
		flat = TweakDB:GetFlat(copiedRecord.."."..v)
		if flat then
			TweakDB:SetFlat(recordName.."."..v, flat, 'Float')
		end
	end
	
	--TweakDB:SetFlatNoUpdate(recordName..".objectActions", drone_hack_list)
	TweakDB:SetFlatNoUpdate(recordName..".lootDrop", "LootTables.Empty")
	addListToList(recordName, "statModifiers", {"Character.ScaleToPlayerLevel"})
	
	TweakDB:Update(recordName)
	
	
	--Make 1-2-3 versions
	for i=1,1000 do

		TweakDB:CloneRecord(recordName..i, recordName)
		for _,v in ipairs(flat_stats) do
			flat = TweakDB:GetFlat(recordName.."."..v)
			if flat then
				TweakDB:SetFlat(recordName..i.."."..v, flat)
			end
		end
		
		for _,v in ipairs(flat_float_stats) do
			flat = TweakDB:GetFlat(recordName.."."..v)
			if flat then
				TweakDB:SetFlat(recordName..i.."."..v, flat, 'Float')
			end
		end
		
		TweakDB:SetFlat(recordName..i..".rarity", "NPCRarity.Boss")
		TweakDB:SetFlat(recordName..i..".tags", {})
		TweakDB:SetFlat(recordName..i..".reactionPreset", "ReactionPresets.Ganger_Aggressive")
		TweakDB:SetFlat(recordName..i..".baseAttitudeGroup", "hostile")

	end
	
end
return DCO:new()
