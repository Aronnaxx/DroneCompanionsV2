R = { 
    description = "DCO"
}

function DCO:new()

	----------------------------BASE VENDOR THINGS--------------------------------------
	
	--Uncap vendor inventories
	Override('Vendor', 'GetMaxItemStacksPerVendor;Bool', function()
		return 1000
	end)
	
	--Create SC reqs
	for i=1,50 do
		createSCRequirement(i)
	end
	

	--[[
	--Remove old os's that are now techdecks
	createConstantStatModifier("DCO.VendorNoQuantity", "Additive", "BaseStats.Quantity", 0)
	old_os_list = {ToTweakDBID{ hash = 0xFB9102E1, length = 17 }, ToTweakDBID{ hash = 0x004E03B9, length = 37 }, ToTweakDBID{ hash = 0x79D9BA6D, length = 37 }, ToTweakDBID{ hash = 0x9FD04231, length = 34 }, ToTweakDBID{ hash = 0xAA4EF500, length = 41 }, ToTweakDBID{ hash = 0x84AAA45A, length = 37 }, ToTweakDBID{ hash = 0xD880C70F, length = 37 }, ToTweakDBID{ hash = 0x92EE016E, length = 37 }, ToTweakDBID{ hash = 0x0577D996, length = 37 }, ToTweakDBID{ hash = 0x8E177EC7, length = 37 }, ToTweakDBID{ hash = 0x71DE231D, length = 34 }, ToTweakDBID{ hash = 0x6A16C4E5, length = 37 }, ToTweakDBID{ hash = 0xE0D0EBD7, length = 37 }, ToTweakDBID{ hash = 0xF3AD94CC, length = 37 }, ToTweakDBID{ hash = 0xF71E3DD8, length = 33 }, ToTweakDBID{ hash = 0x0BE750D4, length = 37 }, ToTweakDBID{ hash = 0x7270E900, length = 37 }, ToTweakDBID{ hash = 0x171E2F7D, length = 37 }, ToTweakDBID{ hash = 0x0D057D07, length = 36 }}
	for i,v in ipairs(old_os_list) do
		TweakDB:SetFlat(v..'.quantity', {"DCO.VendorNoQuantity"})
	end
	
	]]
	-------------------------DISTRIBUTE DRONE CORES AS LOOT-------------------------
	TweakDB:CreateRecord("DCO.DroneCoreLoot", "gamedataLootItem_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneCoreLoot.dropChance", 1)
	TweakDB:SetFlatNoUpdate("DCO.DroneCoreLoot.dropCountMax", 3)
	TweakDB:SetFlatNoUpdate("DCO.DroneCoreLoot.dropCountMin", 1)
	TweakDB:SetFlat("DCO.DroneCoreLoot.itemID", "DCO.DroneCore")
	addToList("Loot.NPCGenericMechanical.lootItems", "DCO.DroneCoreLoot")
	
	TweakDB:SetFlatNoUpdate("Loot.NPCGenericMechanical.maxItemsToLoot", 2)
	TweakDB:SetFlat("Loot.NPCGenericMechanical.minItemsToLoot", 2)


	------------------------CREATE VENDOR ITEMS-----------------------------------
	
	--Techdecks
	createVendorItem("DCO.NomadTechDeck1Vendor", 1, "DCO.NomadDeck1")
	createVendorItem("DCO.NomadTechDeck2Vendor", 22, "DCO.NomadDeck2")
	createVendorItem("DCO.NomadTechDeck3Vendor", 44, "DCO.NomadDeck3")
	createVendorItem("DCO.StreetTechDeck1Vendor", 1, "DCO.StreetDeck1")
	createVendorItem("DCO.StreetTechDeck2Vendor", 20, "DCO.StreetDeck2")
	createVendorItem("DCO.StreetTechDeck3Vendor", 40, "DCO.StreetDeck3")
	createVendorItem("DCO.CorpoTechDeck1Vendor", 24, "DCO.CorpoDeck1")
	createVendorItem("DCO.CorpoTechDeck2Vendor", 48, "DCO.CorpoDeck2")

	--Tech mods
	createVendorItem("DCO.TechDeckMod1Vendor", 1, "DCO.TechDeckMod1")
	createVendorItem("DCO.TechDeckMod2Vendor", 1, "DCO.TechDeckMod2")
	createVendorItem("DCO.TechDeckMod3Vendor", 1, "DCO.TechDeckMod3")
	createVendorItem("DCO.TechDeckMod4Vendor", 20, "DCO.TechDeckMod4")
	createVendorItem("DCO.TechDeckMod5Vendor", 20, "DCO.TechDeckMod5")
	createVendorItem("DCO.TechDeckMod6Vendor", 20, "DCO.TechDeckMod6")
	createVendorItem("DCO.TechDeckMod7Vendor", 40, "DCO.TechDeckMod7")
	createVendorItem("DCO.TechDeckMod8Vendor", 40, "DCO.TechDeckMod8")
	createVendorItem("DCO.TechDeckMod9Vendor", 40, "DCO.TechDeckMod9")

	--Drone Modules
	createRandomQuantityVendorItem("DCO.DroneCoreVendorItem", 1, "DCO.DroneCore", 200, 400)

	--Drone Recipes
	createVendorItem("DCO.Tier1BombusRecipeVendor", 1, "DCO.Tier1BombusRecipe")
	createVendorItem("DCO.Tier1OctantArasakaRecipeVendor", 30, "DCO.Tier1OctantArasakaRecipe")
	createVendorItem("DCO.Tier1OctantMilitechRecipeVendor", 30, "DCO.Tier1OctantMilitechRecipe")
	createVendorItem("DCO.Tier1GriffinRecipeVendor", 10, "DCO.Tier1GriffinRecipe")
	createVendorItem("DCO.Tier1WyvernRecipeVendor", 10, "DCO.Tier1WyvernRecipe")
	createVendorItem("DCO.Tier1AndroidRangedRecipeVendor", 10, "DCO.Tier1AndroidRangedRecipe")
	createVendorItem("DCO.Tier1AndroidMeleeRecipeVendor", 10, "DCO.Tier1AndroidMeleeRecipe")
	createVendorItem("DCO.Tier1AndroidHeavyRecipeVendor", 30, "DCO.Tier1AndroidHeavyRecipe")
	createVendorItem("DCO.Tier1AndroidShotgunnerRecipeVendor", 10, "DCO.Tier1AndroidShotgunnerRecipe")
	createVendorItem("DCO.Tier1AndroidSniperRecipeVendor", 30, "DCO.Tier1AndroidSniperRecipe")
	createVendorItem("DCO.Tier1AndroidNetrunnerRecipeVendor", 30, "DCO.Tier1AndroidNetrunnerRecipe")
	createVendorItem("DCO.Tier1MechMilitechRecipeVendor", 50, "DCO.Tier1MechMilitechRecipe")
	createVendorItem("DCO.Tier1MechArasakaRecipeVendor", 50, "DCO.Tier1MechArasakaRecipe")
	createVendorItem("DCO.Tier1MechNCPDRecipeVendor", 30, "DCO.Tier1MechNCPDRecipe")



	-----------------------------DISTRIBUTE ITEMS----------------------------------------
	
	--Techdecks and techdeck modules
	addListToList("Vendors.bls_ina_se1_ripperdoc_01", "itemStock", {"DCO.NomadTechDeck3Vendor", "DCO.TechDeckMod6Vendor"})
	addListToList("Vendors.bls_ina_se1_ripperdoc_02", "itemStock", {"DCO.NomadTechDeck3Vendor", "DCO.TechDeckMod6Vendor"})
	addListToList("Vendors.hey_spr_ripperdoc_01", "itemStock", {"DCO.TechDeckMod8Vendor"})
	addListToList("Vendors.pac_wwd_ripperdoc_01", "itemStock", {"DCO.CorpoTechDeck1Vendor", "DCO.TechDeckMod7Vendor"})
	addListToList("Vendors.std_arr_ripperdoc_01", "itemStock", {"DCO.NomadTechDeck2Vendor", "DCO.TechDeckMod4Vendor"})
	addListToList("Vendors.std_rcr_ripperdoc_01", "itemStock", {"DCO.TechDeckMod5Vendor"})
	--addListToList("Vendors.wat_kab_ripperdoc_01", "itemStock", {"DCO." --southern kabuki
	--addListToList("Vendors.wat_kab_ripperdoc_02", "itemStock", {"DCO." --buck
	addListToList("Vendors.wat_kab_ripperdoc_03", "itemStock", {"DCO.TechDeckMod3Vendor"}) --dr chrome
	addListToList("Vendors.wat_lch_ripperdoc_01", "itemStock", {"DCO.StreetTechDeck2Vendor", "DCO.TechDeckMod1Vendor"})
	addListToList("Vendors.wat_nid_ripperdoc_01", "itemStock", {"DCO.NomadTechDeck1Vendor"})
	addListToList("Vendors.wbr_jpn_ripperdoc_01", "itemStock", {"DCO.StreetTechDeck1Vendor"})
	addListToList("Vendors.wbr_jpn_ripperdoc_02", "itemStock", {"DCO.TechDeckMod2Vendor"})
	addListToList("Vendors.cct_dtn_ripdoc_01", "itemStock", {"DCO.CorpoTechDeck2Vendor", "DCO.TechDeckMod9Vendor"})
	addListToList("Vendors.wbr_hil_ripdoc_01", "itemStock", {"DCO.StreetTechDeck3Vendor"})

	
	--Drone Modules at junk vendors
	addToList("Vendors.bls_ina_se1_junkshop_01.itemStock", "DCO.DroneCoreVendorItem")
	addToList("Vendors.bls_ina_se5_junkshop_01.itemStock", "DCO.DroneCoreVendorItem")
	addToList("Vendors.wbr_jpn_techstore_01.itemStock", "DCO.DroneCoreVendorItem")
	addToList("Vendors.wat_kab_junkshop_01.itemStock", "DCO.DroneCoreVendorItem")

	--Drone recipes and drone modules
	Flying_Vendor_List = {"DCO.DroneCoreVendorItem", "DCO.Tier1BombusRecipeVendor", "DCO.Tier1GriffinRecipeVendor", "DCO.Tier1WyvernRecipeVendor"}
	
	Octant_Vendor_List = {"DCO.DroneCoreVendorItem", "DCO.Tier1OctantArasakaRecipeVendor", "DCO.Tier1OctantMilitechRecipeVendor"}
	
	Android_Simple_Vendor_List = {"DCO.DroneCoreVendorItem", "DCO.Tier1AndroidRangedRecipeVendor", "DCO.Tier1AndroidMeleeRecipeVendor", "DCO.Tier1AndroidShotgunnerRecipeVendor"}

	Android_Advanced_Vendor_List = {"DCO.DroneCoreVendorItem", "DCO.Tier1AndroidHeavyRecipeVendor", "DCO.Tier1AndroidSniperRecipeVendor"}

	MechNCPD_Vendor_List = {"DCO.DroneCoreVendorItem", "DCO.Tier1MechNCPDRecipeVendor"}
	
	Mech_Vendor_List = {"DCO.DroneCoreVendorItem", "DCO.Tier1MechMilitechRecipeVendor", "DCO.Tier1MechArasakaRecipeVendor"}

	Netrunner_Vendor_List = {"DCO.DroneCoreVendorItem", "DCO.Tier1AndroidNetrunnerRecipeVendor"}
	
	addListToList("Vendors.bls_ina_se1_gunsmith_01a", "itemStock", Octant_Vendor_List)
	addListToList("Vendors.bls_ina_se1_gunsmith_02", "itemStock", Octant_Vendor_List)
	addListToList("Vendors.bls_ina_se5_gunsmith_01", "itemStock", MechNCPD_Vendor_List)
	addListToList("Vendors.cct_dtn_guns_01", "itemStock", Mech_Vendor_List)
	addListToList("Vendors.hey_gle_gunsmith_01", "itemStock", Android_Advanced_Vendor_List)
	addListToList("Vendors.hey_rey_gunsmith_01", "itemStock", Android_Advanced_Vendor_List)
	addListToList("Vendors.hey_spr_gunsmith_01", "itemStock", Android_Advanced_Vendor_List)
	addListToList("Vendors.pac_wwd_gunsmith_01", "itemStock", Netrunner_Vendor_List)
	addListToList("Vendors.std_arr_gunsmith_01", "itemStock", Android_Simple_Vendor_List)
	addListToList("Vendors.std_rcr_gunsmith_01", "itemStock", Android_Simple_Vendor_List)
	addListToList("Vendors.wat_kab_gunsmith_01", "itemStock", Flying_Vendor_List)
	addListToList("Vendors.wat_kab_gunsmith_02", "itemStock", Flying_Vendor_List)
	addListToList("Vendors.wat_lch_gunsmith_01", "itemStock", Flying_Vendor_List)
	addListToList("Vendors.wat_nid_gunsmith_01", "itemStock", Flying_Vendor_List)
	addListToList("Vendors.wbr_jpn_gunsmith_01", "itemStock", Android_Simple_Vendor_List)

end


return DCO:new()
