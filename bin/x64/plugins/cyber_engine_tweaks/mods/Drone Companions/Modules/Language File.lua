DCO = { 
    description = "DCO"
}


function DCO:new()

	--Translate the stuff inside of quotation marks.
	--\n is the newline character and should be kept
	
	--NATIVE SETTINGS INTEGRATION
	Tab_Name = "Drones"
	Subtab_1 = "Stats"
	Subtab_2 = "Pricing"
	Subtab_3 = "Miscellaneous"
	Subtab_4 = "Appearances"
	
	FlyingHP_String = "Flying Drone Health"
	AndroidHP_String = "Android Health"
	MechHP_String = "Mech Health"
	
	FlyingDPS_String = "Flying Drone Damage"
	AndroidDPS_String = "Android Damage"
	MechDPS_String = "Mech Damage"
	
	HP_Desc = "Set multiplier for Health."
	DPS_Desc = "Set multiplier for Damage."

	Drone_Core_Price_String = "Drone Module" --This should match up with localization key 1882. If you're not sure what that is go buy some Drone Modules at a weapon vendor and look at the text on your left that shows up when you exit the vendor inventory, like ITEM ADDED: DRONE MODULE (but in your respective language).
	Drone_Core_Price_Desc = "Set cost of item."
	
	Disable_Android_Voices_String = "Disable Android Voices"
	Disable_Android_Voices_Description = "Toggle Android's combat chatter."
	
	Permanent_Mechs_String = "Permanent Mechs"
	Permanent_Mechs_Description = "Disables Mech's health decay. Requires reloading a save."
	
	MeleeAndroidAppearance_String = "Melee Android"
	RangedAndroidAppearance_String = "Ranged Android"
	ShotgunnerAndroidAppearance_String = "Shotgunner Android"
	NetrunnerAndroidAppearance_String = "Netrunner Android"
	TechieAndroidAppearance_String = "Techie Android"
	SniperAndroidAppearance_String = "Sniper Android"

	BombusAppearance_String = "Bombus"
	
	--Stuff in quotes here needs to be translated
	android_app_list = 
	{[1] = "Maelstrom 1",
	[2] = "Maelstrom 2",
	[3] = "Maelstrom 3",
	[4] = "Maelstrom 4",
	[5] = "Wraiths 1",
	[6] = "Wraiths 2",
	[7] = "Wraiths 3",
	[8] = "Wraiths 4",
	[9] = "Wraiths 5",
	[10] = "Scavengers 1",
	[11] = "Scavengers 2",
	[12] = "Scavengers 3",
	[13] = "Scavengers 4",
	[14] = "Scavengers 5",
	[15] = "Scavengers 6",
	[16] = "Sixth Street 1",
	[17] = "Sixth Street 2",
	[18] = "Sixth Street 3",
	[19] = "Sixth Street 4",
	[20] = "Sixth Street 5",
	[21] = "Sixth Street 6",
	[22] = "Kerry 1",
	[23] = "Kerry 2",
	[24] = "Kerry 3",
	[25] = "Kerry 4",
	[26] = "Kerry 5",
	[27] = "Arasaka 1",
	[28] = "NCPD 1",
	[29] = "Militech 1",
	[30] = "MaxTac 1",
	[31] = "Kang Tao 1",
	[32] = "KangTao 2",
	[33] = "Badlands 1",
	[34] = "Badlands 2"}
	
	bombus_app_list = 
	{[1] = "Police",
	[2] = "Netwatch",
	[3] = "Purple",
	[4] = "White",
	[5] = "Beam",
	[6] = "Blue",
	[7] = "Service",
	[8] = "Delamain"}
	
	SelectAppearance_Description = "Select Drone's appearance."

	
	SystemExSlot_String = "System-EX Slot"
	SystemExSlot_Description = "Select the slot the Techdecks go into when using the mod System-EX."
	SystemExSlot1 = "Cyberdeck Slot"
	SystemExSlot2 = "OS Slot"
	
	--BASE DRONES
	Drone_Core_String = "Drone Module" --This should match up with localization key 1882. If you're not sure what that is go buy some Drone Modules at a weapon vendor and look at the text on your left that shows up when you exit the vendor inventory, like ITEM ADDED: DRONE MODULE (but in your respective language).
	Drone_Core_Desc = "Essential piece of all drones' operating systems."
	
	RequiresTechDeck_String = "" --"Requires a TechDeck to craft.\n\n"
	
	Arasaka_Octant_String = "Arasaka Octant Drone"
	Arasaka_Octant_Desc = "Assemble an Octant Drone companion.\n\n"..RequiresTechDeck_String.."Shoots bursts of bullets at its target.\n\nTechHacks applied to this Drone will last 50% longer.\n\nTechHacks will increase this Drone's armor by 30%."
	
	Militech_Octant_String = "Militech Octant Drone"
	Militech_Octant_Desc = "Assemble an Octant Drone companion.\n\n"..RequiresTechDeck_String.."Shoots bursts of bullets at its target.\n\nBullets explode on impact.\n\nRegenerates 5% health over 3 seconds when struck."
	
	Bombus_Desc = "Assemble a Bombus Drone companion. \n\n"..RequiresTechDeck_String.."Fires a laser at its target.\n\nWill run into a target and self-destruct on low health."
	
	Wyvern_Desc = "Assemble a Wyvern Drone companion."..RequiresTechDeck_String.."\n\nShoots smart bullets at its target.\n\nBullets have a chance to disorient their target."
	
	Griffin_Desc = "Assemble a Griffin Drone companion."..RequiresTechDeck_String.."\n\nShoots bursts of bullets at its target.\n\nTemporarily increases armor when hit."
	
	Mech_Unstable_String = "\n\nUnstable, decays Health over a 30 minute period."
	
	Militech_Mech_Desc = "Assemble a Mech companion. \n\n"..RequiresTechDeck_String.."Shoots heavy smart bullets at its target.\n\nWill stomp nearby enemies.\n\nBullets explode on impact. \n\nWeakspots have 50% more Health.\n\nCannot heal."..Mech_Unstable_String
	Militech_Mech_Permanent_Desc = "Assemble a Mech companion. \n\n"..RequiresTechDeck_String.."Shoots heavy smart bullets at its target.\n\nWill stomp nearby enemies.\n\nBullets explode on impact. \n\nWeakspots have 50% more Health.\n\nCannot heal."

	Arasaka_Mech_Desc = "Assemble a Mech companion. \n\n"..RequiresTechDeck_String.."Shoots heavy smart bullets at its target.\n\nWill stomp nearby enemies.\n\nTechHacks applied to this Drone will last 50% longer. \n\nHighlights all Drones during combat, and enables for them to be TechHacked through walls.\n\nCannot heal."..Mech_Unstable_String
	Arasaka_Mech_Permanent_Desc = "Assemble a Mech companion. \n\n"..RequiresTechDeck_String.."Shoots heavy smart bullets at its target.\n\nWill stomp nearby enemies.\n\nTechHacks applied to this Drone will last 50% longer. \n\nHighlights all Drones during combat, and enables for them to be TechHacked through walls.\n\nCannot heal."

	NCPD_Mech_Desc = "Assemble a Mech companion. \n\n"..RequiresTechDeck_String.."Shoots heavy smart bullets at its target.\n\nWill stomp nearby enemies.\n\nLow quality, has reduced Health and Damage.\n\nCannot heal."..Mech_Unstable_String
	NCPD_Mech_Permanent_Desc = "Assemble a Mech companion. \n\n"..RequiresTechDeck_String.."Shoots heavy smart bullets at its target.\n\nWill stomp nearby enemies.\n\nLow quality, has reduced Health and Damage.\n\nCannot heal."

	NCPD_Mech_String = "NCPD Mech"
	
	Android_Ranged_Desc = "Assemble a Ranged Android companion."..RequiresTechDeck_String.."\n\nUses an Assault Rifle."
	Android_Ranged_String = "Ranged Android"

	Android_Melee_Desc = "Assemble a Melee Android companion."..RequiresTechDeck_String.."\n\nUses a Melee Weapon."
	Android_Melee_String = "Melee Android"

	Android_Shotgunner_Desc = "Assemble a Shotgunner Android companion."..RequiresTechDeck_String.."\n\nUses a Shotgun."
	Android_Shotgunner_String = "Shotgunner Android"

	Android_Netrunner_Desc = "Assemble a Netrunner Android companion."..RequiresTechDeck_String.."\n\nUses a Handgun.\n\nWill upload various hacks onto enemies."
	Android_Netrunner_String = "Netrunner Android"

	Android_Techie_Desc = "Assemble a Techie Android companion."..RequiresTechDeck_String.."\n\nUses a Revolver.\n\nWill throw various grenades at enemies."
	Android_Techie_String = "Techie Android"

	Android_Sniper_Desc = "Assemble a Sniper Android companion."..RequiresTechDeck_String.."\n\nUses a Sniper Rifle."
	Android_Sniper_String = "Sniper Android"
	
	--DRONE SPAWNING
	Crafting_Tab_String = "Drones"
	
	No_TechDeck_String = "NO TECHDECK INSTALLED."
	Combat_Disabled_String = "COMBAT IS DISABLED. MUST EXIT SAFE AREA."
	Mech_Active_String =  "MECH ALREADY ACTIVE."
	Maximum_Drones_String = "MAXIMUM DRONES ACTIVE."
	Exit_Vehicle_String = "MUST EXIT VEHICLE FIRST."
	V_Busy_String = "V IS BUSY."
	Exit_Elevator_String = "MUST EXIT ELEVATOR FIRST."
	
	
	--TECHDECKS
	Mech_No_Repair_String = "Mechs cannot be healed with Repair."
	Shutdown_No_Combat_String = "Cannot be performed in combat."
	Kerenzikov_Not_Android_String = "Can only be used on Androids."
	
	One_Drone_String = "Allows control of 1 Drone."
	Two_Drones_String = "Allows control of 2 Drones."
	Three_Drones_String = "Allows control of 3 Drones."
	Accuracy_String = "Increases Drone accuracy by 30%."
	Armor_String = "Increases Drone armor by 20%."
	Health_String = "Increases Drone health by 20%."
	
	FlyingSE_String = "Drones heal 15% when killing a target."
	FlyingCheap_String = "Drones no longer die when using the Explode TechHack."
	FlyingExplosion_String = "Explode increases Drone's damage by 10% for 15 seconds. Stacks up to 5 times."
	
	MechRegen_String = "Reduces TechHack cost by 50%."
	TechHackCooldown_String = "Reduces TechHack cooldowns by 50%."
	OverdriveAll_String = "Overcharge applies to all Drones."

	AndroidRegen_String = "Drones regenerate 1% of their Health per second in combat."
	AndroidDilation_String = "Drones gain Sandevistan abilities."
	AndroidWeapons_String = "Drones can use high-tech weaponry."

	Nomad1Stats_String = Two_Drones_String.."\n"..Health_String.."\n"..Armor_String
	Nomad2Stats_String = Two_Drones_String.."\n"..Health_String.."\n"..Armor_String.."\n"..MechRegen_String.."\n"..TechHackCooldown_String
	Nomad3Stats_String = Three_Drones_String.."\n"..Health_String.."\n"..Armor_String.."\n"..MechRegen_String.."\n"..TechHackCooldown_String.."\n"..OverdriveAll_String

	Corpo1Stats_String = Two_Drones_String.."\n"..Accuracy_String.."\n"..Armor_String.."\n"..AndroidRegen_String.."\n"..AndroidDilation_String
	Corpo2Stats_String = Three_Drones_String.."\n"..Accuracy_String.."\n"..Armor_String.."\n"..AndroidRegen_String.."\n"..AndroidDilation_String.."\n"..AndroidWeapons_String

	Street1Stats_String = Two_Drones_String.."\n"..Health_String.."\n"..Accuracy_String
	Street2Stats_String = Two_Drones_String.."\n"..Health_String.."\n"..Accuracy_String.."\n"..FlyingSE_String.."\n"..FlyingCheap_String
	Street3Stats_String = Three_Drones_String.."\n"..Health_String.."\n"..Accuracy_String.."\n"..FlyingSE_String.."\n"..FlyingCheap_String.."\n"..FlyingExplosion_String

	Nomad0_Name = "Meta Transporter Mk. I"
	Nomad1_Name = "Meta Transporter Mk. I"
	Nomad2_Name = "Meta Transporter Mk. II"
	Nomad3_Name = "Meta Transporter Mk. III"

	Street0_Name = "Mox Circuit Driver Mk. I"
	Street1_Name = "Mox Circuit Driver Mk. I"
	Street2_Name = "Mox Circuit Driver Mk. II"
	Street3_Name = "Mox Circuit Driver Mk. III"

	Corpo0_Name = "Kang Tao Neural Simulator Mk. I"
	CorpoRare_Name = "Kang Tao Neural Simulator Mk. I"
	Corpo1_Name = "Kang Tao Neural Simulator Mk. I"
	Corpo2_Name = "Kang Tao Neural Simulator Mk. II"

	Nomad0_Desc = "Every Nomad's gotta learn to take care of themselves, and their equipment."
	Nomad1_Desc = "When Meta first declared independence, this, and the thousands of stolen repair drones, were all that kept their ships afloat."
	Nomad2_Desc = "Upgraded TechDeck allowed for Meta drones allowed for new shipping routes through harsh sandstorms and hostile territory."
	Nomad3_Desc = "The most modern Corporate-Nomad technology, ensuring that every delivery is made on time."

	Street0_Desc = "Training deck used to ensure the Mox stays up to speed against their more chromed-out adversaries."
	Street1_Desc = "Special modifications designed to emit explosive blasts without harming the integrity of the Drone ensure the Mox stay respected throughout NC."
	Street2_Desc = "Just as the Mox feed on their prey, so do their Drones."
	Street3_Desc = "Turning people into swiss cheese, setting them on fire, and blowing them up. In most places the Mox would be the bad guys, but not Night City."
	
	Corpo0_Desc = "Simple model used by new Corpo recruits to have power over something, anything."
	Corpo1_Desc = "Built to handle the startingly low supply of able-bodied individuals willing to die for the rich."
	Corpo2_Desc = "Some of the most advanced algorithms known to the corporate world are packed into this deck. Any further, and it'd be inhumane to send drones into battle anymore."

	TechDeck_Module_String = "" --": TechDeck Module"
	
	Rare_Module_String = "" --"\n\nPlaced in the first TechDeck slot."
	Epic_Module_String = "" --"\n\nPlaced in the second TechDeck slot."
	Legendary_Module_String = "" --"\n\nPlaced in the third TechDeck slot."
	
	Optics_Enhancer_String = "Critical Targetting Software"..TechDeck_Module_String
	Optics_Enhancer_Desc = "All TechHacks increase Drone damage by 10%."..Rare_Module_String
	
	Malfunction_Coordinator_String = "Malfunction Coordinator"..TechDeck_Module_String
	Malfunction_Coordinator_Desc = "Increases Drone explosion damage by 50%."..Rare_Module_String
	
	Trigger_Software_String = "Optics Enhancer"..TechDeck_Module_String
	Trigger_Software_Desc = "Unlocks the Optic Shock TechHack.\n\nMakes Drone perfectly accurate."..Rare_Module_String
	
	Plate_Energizer_String = "Plate Energizer"..TechDeck_Module_String
	Plate_Energizer_Desc = "Optical Camo regenerates 2% of Drone health per second."..Epic_Module_String
	
	Extra_Sensory_Processor_String = "Extra-Sensory Processor"..TechDeck_Module_String
	Extra_Sensory_Processor_Desc = "Unlocks the Kerenzikov TechHack.\n\nEnables all Androids to use Kerenzikov abilities."..Epic_Module_String
	
	Insta_Repair_Unit_String = "Insta-Repair Unit"..TechDeck_Module_String
	Insta_Repair_Unit_Desc = "Repairing Drones takes 50% less time."..Epic_Module_String
	
	Mass_Distortion_Core_String = "Mass Distortion Core"
	Mass_Distortion_Core_Desc = "Optical Camo applies to all Drones."..Legendary_Module_String
	
	Circuit_Charger_String = "Circuit Charger"..TechDeck_Module_String
	Circuit_Charger_Desc = "Unlocks Emergency Weapons System TechHack.\n\nOverloads all Drones' circuits, causing them to randomly emit explosions and apply Shock, Burn, or Poison on hit."..Legendary_Module_String
	
	CPU_Overloader_String = "CPU Overloader"..TechDeck_Module_String
	CPU_Overloader_Desc = "Overcharge speeds up Drones 100% more."..Legendary_Module_String
	
	
end


return DCO:new()
