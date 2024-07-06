R = { 
    description = "DCO"
}

function DCO:new()


	-------------------------REMOVE MECH STRAFING------------------------------------------

	addToList("RoyceExo.StrafeLeft_inline1.AND", "DCO.IsNotDCO")
	addToList("RoyceExo.StrafeRight_inline1.AND", "DCO.IsNotDCO")


	------------------------DISABLING COMBAT FOR EXECINSTRUCTIONSAFE-----------------------------
	DisableCombat = false
	Override('AIActionHelper', 'TryChangingAttitudeToHostile;ScriptedPuppetGameObject', function(owner, target, wrappedMethod)
		if DisableCombat then
			return false
		end
		return wrappedMethod(owner, target)
	end)
	
	Observe('PreventionSystem', 'execInstructionSafe', function(self)
		DisableCombat = true
		Cron.After(3, function()
			DisableCombat = false
		end)
	end)
	-----------------------PREVENT DEFEATED STATE--------------------------------------------------
	
	addToList("BaseStatusEffect.FollowerDefeated.immunityStats", "DCO.FollowerDefeatedImmunity")
	
	createStat("DCO.FollowerDefeatedImmunity", "BaseStats.CanGrappleAndroids")

	createConstantStatModifier("DCO.FollowerDefeatedImmunityStat", "Additive", "DCO.FollowerDefeatedImmunity", 1) --to be used in method that creates npcs

	---------------------------EQUIP ALL WEAPONS IN VEHICLES---------------------------------------------
	
	weapon_types = {"PrecisionRifle", "SniperRifle", "LightMachineGun", "HeavyMachineGun", "AssaultRifle", "Shotgun", "ShotgunDual"}
	cond_list = {"VehicleActions.PassengerSportEquipAnyHandgun", "VehicleActions.PassengerSportFailSafeEquipHandgun", "VehicleActions.GunnerEquipRifle", "VehicleActions.EquipAnyRifleFromInventory"}

	for i,v in ipairs(weapon_types) do
		createEquipAI("DCO.Equip"..v, "ItemType.Wea_"..v)
		table.insert(cond_list, "DCO.Equip"..v)
	end
	
	table.insert(cond_list, "VehicleActions.FailSafeEquipRifle")
	table.insert(cond_list, "VehicleActions.Success")
	TweakDB:SetFlat("VehicleActions.PassengerEquipWeapon.nodes", cond_list)


	------------------------------PROCESS DRONE STIMULIS-----------------------------------------------
	
	Override('SenseComponent', 'ShouldIgnoreIfPlayerCompanion;EntityEntity', function(owner, target, wrappedMethod)
		if TweakDBInterface.GetCharacterRecord(target:GetRecordID()):TagsContains(CName.new("Robot")) then
			return false
		end
		return wrappedMethod(owner, target)
	end)
	
	
	--Make the player go into combat with them.
	Observe('AIActionHelper', 'TryChangingAttitudeToHostile;ScriptedPuppetGameObject', function(owner, target)
		if TweakDBInterface.GetCharacterRecord(target:GetRecordID()):TagsContains(CName.new("Robot")) and not TweakDBInterface.GetCharacterRecord(owner:GetRecordID()):TagsContains(CName.new("Robot"))  then
		
			if not DisableCombat then
				--Include player in this
				AIActionHelper.TryChangingAttitudeToHostile(owner, Game.GetPlayer())
				TargetTrackingExtension.InjectThreat(owner, Game.GetPlayer(), 0.1)
			end
		end
	end)

	--Observe bc override breaks shit somehow
	Override('ReactionManagerComponent', 'OnDetectedEvent', function(self, evt, wrappedMethod)
		  if not TweakDBInterface.GetCharacterRecord(evt.target:GetRecordID()):TagsContains(CName.new("Robot")) then
			return wrappedMethod(evt)
		end
		broadcaster = StimBroadcasterComponent:new()
		deviceLink =  PuppetDeviceLinkPS:new()
		scriptedPuppetTarget = ScriptedPuppet:new()
		securitySystem = SecuritySystemControllerPS:new()
		securitySystemInput = SecuritySystemInput:new()
		ownerPuppet  = self:GetOwnerPuppet()
		owner  = self:GetOwner()
		if ScriptedPuppet.IsBlinded(ownerPuppet) then
		  return false
		end
		if IsDefined(evt.target) and evt.isVisible then
			deviceLink = owner:GetDeviceLink()
			
			if IsDefined(deviceLink) then
			  deviceLink:NotifyAboutSpottingPlayer(true)
			end
			
			if self:IsPlayerAiming() and self:IsReactionAvailableInPreset(gamedataStimType.AimingAt) or self:DidTargetMakeMeAlerted(evt.target) then
			  if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, evt.target) then
				TargetTrackingExtension.InjectThreat(ownerPuppet, evt.target)
			  end
			else 
			  broadcaster = evt.target:GetStimBroadcasterComponent()
			  securitySystem = ownerPuppet:GetSecuritySystem()
			  if self.reactionPreset:Type() == gamedataReactionPresetType.Civilian_Guard then
				broadcaster:SendDrirectStimuliToTarget(owner, gamedataStimType.SecurityBreach, owner)
			  else 
				if IsDefined(securitySystem) then
				  securitySystemInput = deviceLink:ActionSecurityBreachNotification(evt.target:GetWorldPosition(), evt.target, ESecurityNotificationType.DEFAULT)
				  if securitySystem:DetermineSecuritySystemState(securitySystemInput, true) == ESecuritySystemState.COMBAT then
					if AIActionHelper.TryChangingAttitudeToHostile(ownerPuppet, evt.target) then
					  TargetTrackingExtension.InjectThreat(ownerPuppet, evt.target)
					end
				  else 
					ownerPuppet:TriggerSecuritySystemNotification(evt.target:GetWorldPosition(), evt.target, ESecurityNotificationType.DEFAULT)
				  end
				end
			  end
			  if self:IsTargetArmed(evt.target) and IsDefined(broadcaster) then
				broadcaster:SendDrirectStimuliToTarget(owner, gamedataStimType.WeaponDisplayed, owner)
			  end
			end		
		  end
	
	end)
	

	-------------------------BOMBUS MORE DEATH EXPLOSION DAMAGE----------------------------------------------
	
	TweakDB:CreateRecord("DCO.BombusGLP", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.BombusGLP.effectors", {"DCO.BombusGLP_inline0"})
	
	TweakDB:CloneRecord("DCO.BombusGLP_inline0", "DCO.FlyingDroneGLP_inline0")
	TweakDB:SetFlat("DCO.BombusGLP_inline0.attackRecord", "DCO.BombusDeathExplosion")
	TweakDB:SetFlat("DCO.BombusGLP_inline0.attackPositionSlotName", CName.new("Chest"))
	
	TweakDB:CloneRecord("DCO.BombusDeathExplosion", "DCO.FlyingDroneDeathExplosion")
	TweakDB:SetFlatNoUpdate("DCO.BombusDeathExplosion.range", 5)
	TweakDB:SetFlatNoUpdate("DCO.BombusDeathExplosion.effectTag", "frag_explosion_underwater_shallow")
	createConstantStatModifier("DCO.BombusDeathExplosion_inline0", "Multiplier", "BaseStats.PhysicalDamage", 3)
	addToList("DCO.BombusDeathExplosion.statModifiers", "DCO.BombusDeathExplosion_inline0")
	
	for i=1, DroneRecords do
		addToList("DCO.Tier1Bombus"..i..".onSpawnGLPs", "DCO.BombusGLP")
	end
	

	--------------------------BALANCING------------------------------------------------------------------------
		
	--Flying
	createConstantStatModifier("DCO.FlyingDroneHPBonus", "Multiplier", "BaseStats.Health", 1.5 * FlyingHP)
	createConstantStatModifier("DCO.FlyingDroneVisibilityBonus", "Multiplier", "BaseStats.Visibility", 0.5)
	createConstantStatModifier("DCO.FlyingDroneTBHBonus", "Multiplier", "BaseStats.TBHsBaseCoefficient", 2.0)
	createConstantStatModifier("DCO.FlyingDroneDPSBonus", "Multiplier", "BaseStats.NPCDamage", 1.5 * FlyingDPS)
	addListToList("DCO.FlyingStatGroup", "statModifiers", {"DCO.FlyingDroneHPBonus", "DCO.FlyingDroneDPSBonus", "DCO.FlyingDroneVisibilityBonus", "DCO.FlyingDroneTBHBonus"})
	
	--Android
	createConstantStatModifier("DCO.AndroidHPBonus", "Multiplier", "BaseStats.Health", 1 * AndroidHP)
	createConstantStatModifier("DCO.AndroidDPSBonus", "Multiplier", "BaseStats.NPCDamage", 1.5 * AndroidDPS)
	createConstantStatModifier("DCO.AndroidStaggerBonus", "Additive", "BaseStats.StaggerDamageThreshold", 31)
	createConstantStatModifier("DCO.AndroidImpactBonus", "Additive", "BaseStats.ImpactDamageThreshold", 21)
	createConstantStatModifier("DCO.AndroidKnockdownBonus", "Additive", "BaseStats.KnockdownDamageThreshold", -60)

	addListToList("DCO.AndroidStatGroup", "statModifiers", {"DCO.AndroidHPBonus", "DCO.AndroidDPSBonus", "DCO.AndroidStaggerBonus", "DCO.AndroidImpactBonus", "DCO.AndroidKnockdownBonus"})
	
	--Mech
	createConstantStatModifier("DCO.MechHPBonus", "Multiplier", "BaseStats.Health", 1 * MechHP)
	createConstantStatModifier("DCO.MechVisibilityBonus", "Multiplier", "BaseStats.Visibility", 3)
	createConstantStatModifier("DCO.MechDPSBonus", "Multiplier", "BaseStats.NPCDamage", 1.5 * MechDPS)
	addListToList("DCO.MechStatGroup", "statModifiers", {"DCO.MechHPBonus", "DCO.MechDPSBonus", "DCO.MechVisibilityBonus"})
	
	--Bombus
	
	createConstantStatModifier("DCO.BombusDismembermentBonus", "Additive", "BaseStats.HitDismembermentFactor", 3)
	for i=1, DroneRecords do
		addToList("DCO.Tier1Bombus"..i..".statModifiers", "DCO.BombusDismembermentBonus")
	end
	

	--Octant
	createConstantStatModifier("DCO.OctantHPBonus", "Multiplier", "BaseStats.Health", 1.2)
	createConstantStatModifier("DCO.OctantDPSBonus", "Multiplier", "BaseStats.NPCDamage", 1)
	createConstantStatModifier("DCO.OctantHitReactionBonus", "Additive", "BaseStats.HitReactionFactor", 0)
	createConstantStatModifier("DCO.OctantVisibilityBonus", "Multiplier", "BaseStats.Visibility", 2)

	for i=1, DroneRecords do
		addListToList("DCO.Tier1OctantArasaka"..i, "statModifiers", {"DCO.OctantHPBonus", "DCO.OctantDPSBonus", "DCO.OctantHitReactionBonus", "DCO.OctantVisibilityBonus"})
		addListToList("DCO.Tier1OctantMilitech"..i, "statModifiers", {"DCO.OctantHPBonus", "DCO.OctantDPSBonus", "DCO.OctantHitReactionBonus", "DCO.OctantVisibilityBonus"})

	end
	

	
	----------------------------FLYING DRONE SPECIAL DEFENSES------------------------------------
	

	--Militech Octant
	
	createOnHitEffect("DCO.HitRepair", 3)
	
	TweakDB:SetFlat("DCO.HitRepairOnHitSE.packages", {"DCO.HitRepairOnHitSE_inline2"})
	
	TweakDB:CreateRecord("DCO.HitRepairOnHitSE_inline2", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.HitRepairOnHitSE_inline2.effectors", {"DCO.HitRepairOnHitSE_inline3"})
	
	TweakDB:CloneRecord("DCO.HitRepairOnHitSE_inline3", "DCO.DroneHealEffector")
	TweakDB:SetFlatNoUpdate("DCO.HitRepairOnHitSE_inline3.prereqRecord", "Prereqs.AlwaysTruePrereq")
	TweakDB:SetFlat("DCO.HitRepairOnHitSE_inline3.poolModifier", "DCO.HitRepairOnHitSE_inline4")
	
	TweakDB:CloneRecord("DCO.HitRepairOnHitSE_inline4", "DCO.DroneHealEffector_inline0")
	TweakDB:SetFlat("DCO.HitRepairOnHitSE_inline4.valuePerSec", 1.67)
	
	for i=1, DroneRecords do
		addToList("DCO.Tier1OctantMilitech"..i..".abilities", "DCO.HitRepairOnHit")
	end
	
	--Arasaka Octant
	--(the armor logic gets applied in techdecks section)
	
	createCombinedStatModifier("DCO.OctantArasakaTechHackArmor", "Additive", "*", "Self", "DCO.DroneOctantArasakaStat", "BaseStats.Armor", 30)
	
	createConstantStatModifier("DCO.IsOctantArasaka", "Additive", "DCO.DroneOctantArasakaStat", 1)
	
	for i=1,DroneRecords do
		addToList("DCO.Tier1OctantArasaka"..i..".statModifiers", "DCO.IsOctantArasaka")
	end
	
	
	--Griffin
	createOnHitEffect("DCO.HitArmor", 10)
		
	TweakDB:SetFlat("DCO.HitArmorOnHitSE.packages", {"DCO.HitArmorOnHitSE_inline2"})
	TweakDB:SetFlat("DCO.HitArmorOnHitSE.maxStacks", "DCO.HitArmorOnHitSE_inline4")

	TweakDB:CreateRecord("DCO.HitArmorOnHitSE_inline2", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.HitArmorOnHitSE_inline2.stats", {"DCO.HitArmorOnHitSE_inline3"})
	TweakDB:SetFlat("DCO.HitArmorOnHitSE_inline2.stackable", true)

	createConstantStatModifier("DCO.HitArmorOnHitSE_inline3", "Additive", "BaseStats.Armor", 5)
	
	TweakDB:CreateRecord("DCO.HitArmorOnHitSE_inline4", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate("DCO.HitArmorOnHitSE_inline4.statModsLimit", -1)
	TweakDB:SetFlat("DCO.HitArmorOnHitSE_inline4.statModifiers", {"DCO.HitArmorOnHitSE_inline5"})
	
	createConstantStatModifier("DCO.HitArmorOnHitSE_inline5", "Additive", "BaseStats.MaxStacks", 10)

	
	for i=1, DroneRecords do
		addToList("DCO.Tier1Griffin"..i..".abilities", "DCO.HitArmorOnHit")
	end
	
	
	--Wyvern
	
	TweakDB:CreateRecord("DCO.WyvernDisorient", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.WyvernDisorient.abilityPackage", "DCO.WyvernDisorient_inline0")
	
	TweakDB:CreateRecord("DCO.WyvernDisorient_inline0", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.WyvernDisorient_inline0.effectors", {"DCO.WyvernDisorient_inline1", "DCO.WyvernDisorient_inline2"})
	
	TweakDB:CreateRecord("DCO.WyvernDisorient_inline1", "gamedataAddStatusEffectToAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline1.isRandom", true)
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline1.stacks", 1)
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline1.applicationChance", 0.07)
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline1.effectorClassName", "AddStatusEffectToAttackEffector")
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline1.prereqRecord", "Perks.IsAttackRanged")
	TweakDB:SetFlat("DCO.WyvernDisorient_inline1.statusEffect", "BaseStatusEffect.Blind")

	TweakDB:CreateRecord("DCO.WyvernDisorient_inline2", "gamedataAddStatusEffectToAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline2.isRandom", true)
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline2.stacks", 1)
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline2.applicationChance", 0.07)
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline2.effectorClassName", "AddStatusEffectToAttackEffector")
	TweakDB:SetFlatNoUpdate("DCO.WyvernDisorient_inline2.prereqRecord", "Perks.IsAttackRanged")
	TweakDB:SetFlat("DCO.WyvernDisorient_inline2.statusEffect", "BaseStatusEffect.Stun")

	for i=1,DroneRecords do
		addToList("DCO.Tier1Wyvern"..i..".abilities", "DCO.WyvernDisorient")
	end	
	
	--[[createConstantStatModifier("DCO.WyvernNearRingNull", "Multiplier", "BaseStats.CanUseNearRing", 0)
	
	
	TweakDB:CreateRecord("DCO.WyvernMap", "gamedataActionMap_Record")
	TweakDB:SetFlat("DCO.WyvernMap.defaultMap", "DCO.WyvernMap_inline0")
	
	TweakDB:CreateRecord("DCO.WyvernMap_inline0", "gamedataAINodeMap_Record")
	mapnodes = TweakDB:GetFlat("DroneArchetype.Map_inline0.map")
	table.remove(mapnodes, 4)
	table.insert(mapnodes, "DCO.WyvernMap_inline1")
	TweakDB:SetFlat("DCO.WyvernMap_inline0.map", mapnodes)
	
	TweakDB:CloneRecord("DCO.WyvernMap_inline1", "DroneArchetype.Map_inline4")
	TweakDB:SetFlat("DCO.WyvernMap_inline1.isOverriddenBy", "DCO.WyvernMovementPolicyCompositeDefault")
	
	TweakDB:CloneRecord("DCO.WyvernMovementPolicyCompositeDefault", "DroneArchetype.MovementPolicyCompositeDefault")
	TweakDB:SetFlat("DCO.WyvernMovementPolicyCompositeDefault.nodes", {"MovementActions.SuccessOnInterruptionSignals", "DroneActions.LocomotionMalfunction",
	"DroneActions.CombatWhistle", "DroneActions.CatchUpFallbackProcedure", "DroneActions.HoldPositionWhileShooting", "DroneActions.RepositionWhileTargetUnreachableNear", "DroneActions.RepositionWhileTargetUnreachableFar",
	"DroneActions.WaitWhileTargetUnreachable", "DCO.WyvernRingSelector", "DroneActions.HoldPosition", "DroneActions.LookAtTargetDuringMoveCommand", "GenericArchetype.Success"})
	
	TweakDB:CloneRecord("DCO.WyvernRingSelector", "DroneActions.RingSelector")
	TweakDB:SetFlat("DCO.WyvernRingSelector.actions", {"DroneActions.ExtremeRing", "DroneActions.ExtremeRingSlow"})
	
	
	for i=1,DroneRecords do
		TweakDB:SetFlat("DCO.Tier1Wyvern"..i..".actionMap", "DCO.WyvernMap")
	end
	]]
	
	----------------------------------OCTANT DRONES SPECIAL EFFECTS-----------------------------
	
	--Arasaka
	createConstantStatModifier("DCO.OctantArasakaTechHackDuration", "Additive", "DCO.DroneTechHackDuration", 0.5)
	
	for i=1, DroneRecords do
		addToList("DCO.Tier1OctantArasaka"..i..".statModifiers", "DCO.OctantArasakaTechHackDuration")
	end

	--Militech
	TweakDB:CreateRecord("DCO.OctantMilitechEquipment", "gamedataNPCEquipmentGroup_Record")
	TweakDB:SetFlat("DCO.OctantMilitechEquipment.equipmentItems", {"DCO.OctantMilitechEquipment_inline0"})
	
	TweakDB:CloneRecord("DCO.OctantMilitechEquipment_inline0", "Character.Drone_Octant_Base_inline1")
	TweakDB:SetFlat("DCO.OctantMilitechEquipment_inline0.item", "DCO.OctantMilitechAutocannon")
	
	TweakDB:CloneRecord("DCO.OctantMilitechAutocannon", "Items.Octant_Autocannon")
	TweakDB:SetFlatNoUpdate("DCO.OctantMilitechAutocannon.rangedAttacks", "DCO.OctantMilitechAutocannon_inline0") 
	
	addListToList("DCO.OctantMilitechAutocannon", "attacks", {"DCO.OctantMilitechAutocannon_inline2", "DCO.OctantMilitechAutocannon_inline3"})
	
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1OctantMilitech"..i..".primaryEquipment", "DCO.OctantMilitechEquipment")
	end
	
	
	TweakDB:CreateRecord("DCO.OctantMilitechAutocannon_inline0", "gamedataRangedAttackPackage_Record")
	TweakDB:SetFlatNoUpdate("DCO.OctantMilitechAutocannon_inline0.chargeFire", "DCO.OctantMilitechAutocannon_inline1")
	TweakDB:SetFlat("DCO.OctantMilitechAutocannon_inline0.defaultFire", "DCO.OctantMilitechAutocannon_inline1")

	TweakDB:CreateRecord("DCO.OctantMilitechAutocannon_inline1", "gamedataRangedAttack_Record")
	TweakDB:SetFlatNoUpdate("DCO.OctantMilitechAutocannon_inline1.NPCAttack", "DCO.OctantMilitechAutocannon_inline3")
	TweakDB:SetFlatNoUpdate("DCO.OctantMilitechAutocannon_inline1.NPCTimeDilated", "DCO.OctantMilitechAutocannon_inline2")
	TweakDB:SetFlatNoUpdate("DCO.OctantMilitechAutocannon_inline1.playerAttack", "DCO.OctantMilitechAutocannon_inline3")
	TweakDB:SetFlat("DCO.OctantMilitechAutocannon_inline1.playerTimeDilated", "DCO.OctantMilitechAutocannon_inline2")

	TweakDB:CloneRecord("DCO.OctantMilitechAutocannon_inline2", "Attacks.NPCBulletProjectile")
	TweakDB:SetFlat("DCO.OctantMilitechAutocannon_inline2.explosionAttack", "DCO.OctantMilitechAutocannon_inline4")
	TweakDB:SetFlat("DCO.OctantMilitechAutocannon_inline2.hitCooldown", 0.1)
	addToList("DCO.OctantMilitechAutocannon_inline2.statModifiers", "DCO.OctantMilitechAutocannon_inline6")

	TweakDB:CloneRecord("DCO.OctantMilitechAutocannon_inline3", "Attacks.NPCBulletEffect")
	TweakDB:SetFlat("DCO.OctantMilitechAutocannon_inline3.explosionAttack", "DCO.OctantMilitechAutocannon_inline4")
	addToList("DCO.OctantMilitechAutocannon_inline3.statModifiers", "DCO.OctantMilitechAutocannon_inline6")

	TweakDB:CloneRecord("DCO.OctantMilitechAutocannon_inline4", "Attacks.BulletExplosion")
	TweakDB:SetFlatNoUpdate("DCO.OctantMilitechAutocannon_inline4.hitFlags", {})
	addToList("DCO.OctantMilitechAutocannon_inline4.statModifiers", "DCO.OctantMilitechAutocannon_inline5")
	
	createConstantStatModifier("DCO.OctantMilitechAutocannon_inline5", "Multiplier", "BaseStats.PhysicalDamage", 0.1)
	createConstantStatModifier("DCO.OctantMilitechAutocannon_inline6", "Multiplier", "BaseStats.PhysicalDamage", 0.45)


	-----------------------------FLYING SANDEVISTAN EFFECTS---------------------------------------
	
	
	-----------------------------------ANDROID AI----------------------------------------------
	
	--Give androids human ai, so they dont just walk right at enemy, but actually use cover and make decisions.
	
	Basic_Android_List = {"DCO.Tier1AndroidMelee", "DCO.Tier1AndroidRanged", "DCO.Tier1AndroidShotgunner"}
	
	Fancy_Android_List = {"DCO.Tier1AndroidHeavy", "DCO.Tier1AndroidSniper", "DCO.Tier1AndroidNetrunner"}
	
	for a=1,DroneRecords do

		for i,v in ipairs(Basic_Android_List) do
			TweakDB:SetFlat(v..a..".actionMap", "Gang.Map")
		end
		
		for i,v in ipairs(Fancy_Android_List) do
			TweakDB:SetFlat(v..a..".actionMap", "Corpo.Map")
		end
	end
	

	------------------------------------SMART COMPOSITE-----------------------------------------
	
	--Give followers better movement, rather than sticking 2 inches from the player
	nodelist = TweakDB:GetFlat("MovementActions.MovementPolicyCompositeDefault.nodes") 
	TweakDB:SetFlat("FollowerActions.CombatMovementComposite.nodes", nodelist)

	
	------------------PREVENTION SYSTEM ATTITUDE FIX-----------------
	

	--If it's one of our drones, don't change their attitude when this happens
	Override('PreventionSystem', 'ChangeAttitude', function(self, owner, target, desiredAttitude, wrappedMethod)
		if TweakDBInterface.GetCharacterRecord(owner:GetRecordID()):TagsContains(CName.new("Robot")) then
			return
		end
		wrappedMethod(owner, target, desiredAttitude)
	end)
	
	-----------------------FIX STAGGER--------------------------------
	
	Override('HitReactionComponent', 'SendDataToAIBehavior', function(self, reactionPlayed, wrappedMethod)
	

		--When it does the weird auto stagger thing
		if reactionPlayed == animHitReactionType.Stagger or reactionPlayed == animHitReactionType.Impact or reactionPlayed == animHitReactionType.Pain then
			
			--Dont stagger mechs or bosses from our melee android (maybe unused)
			if self.ownerNPC:GetNPCType() == gamedataNPCType.Mech then
				if TweakDBInterface.GetCharacterRecord(self.attackData.instigator:GetRecordID()):TagsContains(CName.new("Robot")) then
					return
				end
			end
			
			--Bosses don't stagger
			if self.ownerNPC:IsBoss() then
				if TweakDBInterface.GetCharacterRecord(self.attackData.instigator:GetRecordID()):TagsContains(CName.new("Robot")) then
					return					
				end
			end
			
			--If one of our companions been hit
			if TweakDBInterface.GetCharacterRecord(self.ownerNPC:GetRecordID()):TagsContains(CName.new("Robot")) then
				return
			end
				
			
		end
		wrappedMethod(reactionPlayed)
	end)
	
	--Handle mechs as well
	Override('HitReactionComponent', 'SendMechDataToAIBehavior', function(self, reactionPlayed, wrappedMethod)

		--When it does the weird auto stagger thing
		if reactionPlayed == animHitReactionType.Stagger or reactionPlayed == animHitReactionType.Impact or reactionPlayed == animHitReactionType.Pain then
			
			--Dont stagger mechs from our melee android
			if self.ownerNPC:GetNPCType() == gamedataNPCType.Mech and not (self.attackData.instigator:GetNPCType() == gamedataNPCType.Mech) then
				if TweakDBInterface.GetCharacterRecord(self.attackData.instigator:GetRecordID()):TagsContains(CName.new("Robot")) then
					return
				end
			end
			
			--If one of our companions been hit
			if TweakDBInterface.GetCharacterRecord(self.ownerNPC:GetRecordID()):TagsContains(CName.new("Robot")) and not (self.attackData.instigator:GetNPCType() == gamedataNPCType.Mech) then
				return
			end
		end
		wrappedMethod(reactionPlayed)
	end)
	
	
	
	---------------------------------FIX MINOTAUR ARM EXPLOSION STAGGER--------------------------------
	Observe('NPCPuppet', 'OnStatusEffectApplied', function(self, statusEffect)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) then
			if statusEffect.staticData:GetID() == TweakDBID.new("Minotaur.RightArmDestroyed") then
				StatusEffectHelper.ApplyStatusEffect(self, TweakDBID.new("Minotaur.RightExplosion"))
			elseif statusEffect.staticData:GetID() == TweakDBID.new("Minotaur.LeftArmDestroyed") then
				StatusEffectHelper.ApplyStatusEffect(self, TweakDBID.new("Minotaur.LeftExplosion"))
			end
		end
	end)	
	
	--------------------------------OUT OF COMBAT REGEN--------------------------------------------
	
	--base prereq
	TweakDB:CreateRecord("DCO.InCombatSE", "gamedataStatusEffect_Record")
	TweakDB:SetFlatNoUpdate("DCO.InCombatSE.duration", "BaseStats.InfiniteDuration")
	TweakDB:SetFlat("DCO.InCombatSE.statusEffectType", "BaseStatusEffectTypes.Misc")

	TweakDB:CreateRecord("DCO.InCombat", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.InCombat.statusEffect", "DCO.InCombatSE")
	TweakDB:SetFlat("DCO.InCombat.prereqClassName", "StatusEffectPrereq")

	TweakDB:CreateRecord("DCO.NotInCombat", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.NotInCombat.statusEffect", "DCO.InCombatSE")
	TweakDB:SetFlat("DCO.NotInCombat.prereqClassName", "StatusEffectAbsentPrereq")


	--ability
	TweakDB:CreateRecord("DCO.DronePassiveRegenAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.DronePassiveRegenAbility.abilityPackage", "DCO.DronePassiveRegenAbility_inline1")
	
	TweakDB:CreateRecord("DCO.DronePassiveRegenAbility_inline1", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.DronePassiveRegenAbility_inline1.effectors", {"DCO.DronePassiveRegenAbility_inline2"})
	
	TweakDB:CloneRecord("DCO.DronePassiveRegenAbility_inline2", "Ability.HasPassiveHealthRegeneration_inline1")
	TweakDB:SetFlatNoUpdate("DCO.DronePassiveRegenAbility_inline2.prereqRecord", "DCO.NotInCombat")
	TweakDB:SetFlat("DCO.DronePassiveRegenAbility_inline2.poolModifier", "DCO.DronePassiveRegenAbility_inline3")

	TweakDB:CloneRecord("DCO.DronePassiveRegenAbility_inline3", "Ability.HasPassiveHealthRegeneration_inline2")
	TweakDB:SetFlatNoUpdate("DCO.DronePassiveRegenAbility_inline3.startDelay", 2)
	TweakDB:SetFlatNoUpdate("DCO.DronePassiveRegenAbility_inline3.delayOnChange", true)
	TweakDB:SetFlat("DCO.DronePassiveRegenAbility_inline3.valuePerSec", 2)
	
	for i,v in ipairs(Flying_List) do
		addToList(v..".abilities", "DCO.DronePassiveRegenAbility")
	end
	for i,v in ipairs(Android_List) do
		addToList(v..".abilities", "DCO.DronePassiveRegenAbility")
	end
	

	----------------------------SMART BULLETS TRACK----------------------------------------
	
	--Except mechs bc that crashes the game when the target dies
	Override('AISubActionShootWithWeapon_Record_Implementation', 'ShouldTrackTarget;gamePuppetAISubActionShootWithWeapon_RecordWeaponObject', function(owner, record, weapon, wrappedMethod)

		if not (owner:GetNPCType() == gamedataNPCType.Mech) then
			if not IsDefined(owner) or not IsDefined(weapon) or not IsDefined(record) then
				return false
			end
			characterRecord = TweakDBInterface.GetCharacterRecord(owner:GetRecordID())
			if characterRecord:TagsContains(CName.new("Robot")) then
				if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, CName.new("WeaponJam")) then
					return false
				end
				
				
				npcType = owner:GetNPCType()

				randChance = math.random(1, 100)
				ownerAccuracy = Game.GetStatsSystem():GetStatValue(owner:GetEntityID(), gamedataStatType.Accuracy)
				ownerAccuracy = 0
	
				randLimit = 100 -(70 + ownerAccuracy * 4)
				return randChance>randLimit
			end
		
		end
		return wrappedMethod(owner, record, weapon)

	end)
	
	-------------------------------LOWER FLYING DRONES-------------------------------------
	for i,v in ipairs(Flying_List) do
		TweakDB:SetFlat(v..".combatDefaultZOffset", -0.2)
	end
	


	-------------------------FLYING DRONE SHOOT WHEN PLAYER IN VEHICLE----------------------
	
	--Allow shooting when player is mounted
	--Creates new shoot action that disregards angles ie logic and reason
	
	--wyvern
	TweakDB:SetFlat("DroneActions.ShootDefault_inline1.AND", {"DCO.ShootDefault_inline0", "DroneActions.ShootDefault_inline2", "DroneActions.ShootDefault_inline3", "Condition.OptimalDistance10mTolerance", "Condition.NotFriendlyFire"})
	
	TweakDB:CreateRecord("DCO.ShootDefault_inline0", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline0.OR", {"Condition.TargetBelow15deg", "DCO.ShootDefault_inline1"})
	
	TweakDB:CreateRecord("DCO.ShootDefault_inline1", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline1.AND", {"Condition.FollowerInVehicle", "DCO.IsDCO"})

	--griffin
	TweakDB:SetFlat("DroneGriffinActions.ShootDefault_inline1.AND", {"DroneGriffinActions.ShootDefault_inline2", "Condition.NotAIMoveCommand", "Condition.NotAIUseWorkspotCommand", "Condition.NotIsUsingOffMeshLink", "Condition.DroneGriffinShootCooldown", "DroneGriffinActions.ShootDefault_inline3", "DroneGriffinActions.ShootDefault_inline4", "DCO.ShootDefault_inline3"})
	
	TweakDB:CreateRecord("DCO.ShootDefault_inline3", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline3.OR", {"Condition.TargetBelow45deg", "DCO.ShootDefault_inline4"})
	
	TweakDB:CreateRecord("DCO.ShootDefault_inline4", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline4.AND", {"Condition.FollowerInVehicle", "DCO.IsDCO"})

	--Octant
	TweakDB:SetFlat("DroneOctantActions.ShootDefault_inline1.AND", {"DCO.ShootDefault_inline6", "DroneOctantActions.ShootDefault_inline2", "DroneOctantActions.ShootDefault_inline3", "Condition.MaxVisibilityToTargetDistance3m", "Condition.NotFriendlyFire"})
	
	TweakDB:CreateRecord("DCO.ShootDefault_inline6", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline6.OR", {"Condition.TargetBelow35deg", "DCO.ShootDefault_inline7"})
	
	TweakDB:CreateRecord("DCO.ShootDefault_inline7", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline7.AND", {"Condition.FollowerInVehicle", "DCO.IsDCO"})

	
	--Remove pausing of shooting when player is mounted
	
	--wyvern
	TweakDB:SetFlat("DroneActions.ShootDefault_inline13.OR", {"DroneActions.ShootDefault_inline14", "Condition.CombatTargetChanged", "Condition.FriendlyFire", "DCO.ShootDefault_inline2"})
	TweakDB:SetFlat("DroneActions.ShootDefault_inline6.OR", {"DroneActions.ShootDefault_inline7", "Condition.DontShootCombatTarget", "Condition.FriendlyFire", "DCO.ShootDefault_inline2"})

	TweakDB:CreateRecord("DCO.ShootDefault_inline2", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline2.AND", {"DCO.IsNotDCO", "Condition.TargetAbove90deg"})

	--griffin
	TweakDB:SetFlat("DroneGriffinActions.ShootBurstStatic_inline15.OR", {"Condition.NotMinAccuracyValue0dot95", "Condition.CombatTargetChanged", "DCO.ShootDefault_inline2", "Condition.AIMoveCommand", "Condition.AIUseWorkspotCommand", "Condition.FriendlyFire", "DroneGriffinActions.ShootBurstStatic_inline16"})
	TweakDB:SetFlat("DroneGriffinActions.ShootBurstStatic_inline4.OR", {"DCO.ShootDefault_inline2", "Condition.DontShootCombatTarget", "Condition.FriendlyFire", "DroneGriffinActions.ShootBurstStatic_inline5"})
	TweakDB:SetFlat("DroneGriffinActions.ShootBurstStatic_inline8.OR", {"DCO.ShootDefault_inline2", "Condition.DontShootCombatTarget", "Condition.FriendlyFire", "DroneGriffinActions.ShootBurstStatic_inline9"})
	
	--Octant
	TweakDB:SetFlat("DroneOctantActions.ShootDefault_inline13.OR", {"Condition.NotMinAccuracyValue0dot95", "Condition.CombatTargetChanged", "DCO.ShootDefault_inline2", "Condition.AIMoveCommand", "Condition.AIUseWorkspotCommand", "Condition.FriendlyFire", "DroneOctantActions.ShootDefault_inline14"})
	TweakDB:SetFlat("DroneOctantActions.ShootDefault_inline8.OR", {"DCO.ShootDefault_inline2", "Condition.DontShootCombatTarget", "Condition.FriendlyFire", "DroneOctantActions.ShootDefault_inline9"})
	
	--Fix problem with shaking
	addToList("DroneActions.TargetUnreachableRepositionActivationCondition_inline0.AND", "DCO.RepositionCond")
	addToList("DroneActions.WaitWhileTargetUnreachable_inline1.AND", "DCO.RepositionCond")
	addToList("DroneActions.CatchUpSharedVisibilityTargetUnreachable_inline8.AND", "DCO.RepositionCond")
	addToList("DroneActions.CatchUpSprintVisibility_inline6.AND", "DCO.RepositionCond")
	
	TweakDB:CreateRecord("DCO.RepositionCond", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.RepositionCond.OR", {"DCO.RepositionCond_inline0", "DCO.IsNotDCO"})
	
	TweakDB:CreateRecord("DCO.RepositionCond_inline0", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.RepositionCond_inline0.AND", {"Condition.NotFollowerInVehicle", "DCO.IsDCO"})



	-----------------------------MAKE FLYING DRONES ATTACK MORE OFTEN---------------------
	
	--Disable optimal distance trash and friendly fire check
	
	--Wyvern
	TweakDB:SetFlat("DroneActions.ShootDefault_inline1.AND", {"DCO.ShootDefault_inline0", "DroneActions.ShootDefault_inline2", "DroneActions.ShootDefault_inline3", "DCO.ShootDefault_inline10"})
	
	TweakDB:CreateRecord("DCO.ShootDefault_inline10", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline10.OR", {"DCO.IsDCO", "DCO.ShootDefault_inline11"})

	TweakDB:CreateRecord("DCO.ShootDefault_inline11", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.ShootDefault_inline11.AND", {"Condition.OptimalDistance10mTolerance", "Condition.NotFriendlyFire"})

	--Griffin
	addToList("DroneGriffinActions.ShootDefault_inline4.OR", "DCO.IsDCO")

	--Octant
	TweakDB:SetFlat("DroneOctantActions.ShootDefault_inline1.AND", {"DCO.ShootDefault_inline6", "DroneOctantActions.ShootDefault_inline2", "DroneOctantActions.ShootDefault_inline3", "Condition.MaxVisibilityToTargetDistance3m", "DCO.OctantShootDefault_inline0"})
	
	TweakDB:CreateRecord("DCO.OctantShootDefault_inline0", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.OctantShootDefault_inline0.OR", {"DCO.IsDCO", "Condition.NotFriendlyFire"})

	
	-------------------------------BEAM BOMBUS AI----------------------------------------------
	--Give weapons and map
	for i=1, DroneRecords do
		--TweakDB:SetFlatNoUpdate("DCO.Tier1Bombus"..i..".primaryEquipment", "Character.sq025_delamain_drone_bombus_suicidal_inline0")
		TweakDB:SetFlat("DCO.Tier1Bombus"..i..".actionMap", "DroneBombusFastArchetype.Map")
	end
	
	--Fix attacks
	TweakDB:SetFlat("DroneBombusActions.ShootBeam_inline2.attackRange", 20)
	TweakDB:SetFlat("DroneBombusActions.ShootBeam_inline2.attackDuration", 30)
	TweakDB:SetFlat("DroneBombusActions.ShootBeam_inline2.attackTime", 2)
	TweakDB:SetFlat("Attacks.BombusFlame.range", 20)
	
	--Fix damage
	TweakDB:SetFlat("Attacks.BombusFlame.statModifiers", {"AttackModifier.PhysicalEnemyDamage", "AttackModifier.NPCAttacksPerSecondFactor", "DCO.BombusFlameDamage"})
	
	createConstantStatModifier("DCO.BombusFlameDamage", "Multiplier", "BaseStats.PhysicalDamage", 2)
	
	--Speed up beams
	TweakDB:SetFlat("DroneBombusFastArchetype.WeaponHandlingComposite.nodes", {"ItemHandling.SuccessIfEquipping", "DroneBombusActions.CommitSuicide", "DroneBombusActions.ShootBeam", "DCO.BombusLookAtTarget", "GenericArchetype.Success"})
	
	--Look at target 
	TweakDB:CloneRecord("DCO.BombusLookAtTarget", "DroneActions.LookAtTargetDuringMoveCommand")
	TweakDB:SetFlatNoUpdate("DCO.BombusLookAtTarget.activationCondition", "")
	TweakDB:SetFlatNoUpdate("DCO.BombusLookAtTarget.loop", "")
	TweakDB:SetFlat("DCO.BombusLookAtTarget.lookats", {"DroneBombusActions.ShootBeam_inline8"})
	

	--Increase range
	TweakDB:SetFlat("DroneBombusActions.ShootBeamActivationCondition.AND", {"DroneBombusActions.ShootBeamActivationCondition_inline0", "Condition.TargetBelow15m"})
	TweakDB:SetFlat("DroneBombusActions.ShootBeamDeactivationCondition.OR", {"Condition.NotMinAccuracyValue0dot95", --[["DroneBombusActions.ShootBeamDeactivationCondition_inline0",]]"Condition.TargetAbove15m", "Condition.CombatTargetChanged","Condition.AIUseWorkspotCommand", "Condition.HealthBelow50perc"})
	
	--Custom BEAM
	TweakDB:CreateRecord("DCO.BombusBeamEquipment", "gamedataNPCEquipmentGroup_Record")
	TweakDB:SetFlat("DCO.BombusBeamEquipment.equipmentItems", {"DCO.BombusBeamEquipment_inline0"})
	
	TweakDB:CloneRecord("DCO.BombusBeamEquipment_inline0", "Character.sq025_delamain_drone_bombus_suicidal_inline1")
	TweakDB:SetFlat("DCO.BombusBeamEquipment_inline0.item", "DCO.BombusTorch")
	
	TweakDB:CloneRecord("DCO.BombusTorch", "Items.Bombus_Torch")
	TweakDB:SetFlat("DCO.BombusTorch.npcRPGData", "DCO.BombusTorch_inline0")
	
	TweakDB:CreateRecord("DCO.BombusTorch_inline0", "gamedataRPGDataPackage_Record")
	TweakDB:SetFlat("DCO.BombusTorch_inline0.statModifierGroups", {"Items.Bombus_Torch_Handling_Stats"})
	
	TweakDB:SetFlat("Items.Bombus_Torch_Handling_Stats_inline12.value", 5) --physical impulse
	TweakDB:SetFlat("Items.Bombus_Torch_Handling_Stats_inline11.value", 0.12) --TBH
	TweakDB:SetFlat("Items.Bombus_Torch_Handling_Stats_inline2.value", 30) --Burst shots
	TweakDB:SetFlat("Items.Bombus_Torch_Handling_Stats_inline4.value", 999999) --Magazine capacity
	
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1Bombus"..i..".primaryEquipment", "DCO.BombusBeamEquipment")
	end
	
	--Custom movement
	TweakDB:SetFlat("DroneBombusFastArchetype.MovementPolicyCompositeDefault.nodes", {"DroneActions.LocomotionMalfunction",  "DroneBombusActions.FollowTargetFast", "DCO.BombusBeamFollowFast", "DroneBombusActions.HoldPosition", "GenericArchetype.Success"})
	
	TweakDB:CloneRecord("DCO.BombusBeamFollowFast", "DroneBombusActions.FollowTargetFast")
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamFollowFast.activationCondition", "DCO.BombusBeamFollowFast_inline0")
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamFollowFast.loop", "DCO.BombusBeamFollowFast_inline2")
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamFollowFast.animationWrapperOverrides", {"Sandevistan"})
	TweakDB:SetFlat("DCO.BombusBeamFollowFast.subActions", {"DCO.BombusBeamSlowdown"})
	
	TweakDB:CreateRecord("DCO.BombusBeamFollowFast_inline0", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat("DCO.BombusBeamFollowFast_inline0.condition", "DCO.BombusBeamFollowFast_inline1")
	
	TweakDB:CreateRecord("DCO.BombusBeamFollowFast_inline1", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.BombusBeamFollowFast_inline1.AND", {"Condition.TargetAbove15m", "Condition.NotAIMoveCommand", "Condition.NotAIUseWorkspotCommand", "Condition.NotIsUsingOffMeshLink", "Condition.HealthAbove50Perc"})
	
	TweakDB:CloneRecord("DCO.BombusBeamFollowFast_inline2", "DroneBombusActions.FollowTargetFast_inline2")
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamFollowFast_inline2.movePolicy", "DCO.BombusBeamFollowFast_inline5")
	TweakDB:SetFlat("DCO.BombusBeamFollowFast_inline2.toNextPhaseCondition", {"DCO.BombusBeamFollowFast_inline3"})
	
	TweakDB:CreateRecord("DCO.BombusBeamFollowFast_inline3", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat("DCO.BombusBeamFollowFast_inline3.condition", "DCO.BombusBeamFollowFast_inline4")
	
	TweakDB:CreateRecord("DCO.BombusBeamFollowFast_inline4", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.BombusBeamFollowFast_inline4.OR", {"Condition.TargetBelow15m", "Condition.AIMoveCommand", "Condition.AIUseWorkspotCommand", "Condition.PathFindingFailed", "Condition.NotMinAccuracySharedValue1", "Condition.HealthBelow50perc"})
	
	TweakDB:CloneRecord("DCO.BombusBeamFollowFast_inline5", "DroneBombusActions.FollowTargetFast_inline3")
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamFollowFast_inline5.dontUseStart", true)
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamFollowFast_inline5.movementType", "Walk")
	TweakDB:SetFlat("DCO.BombusBeamFollowFast_inline5.distance", 12)

	TweakDB:CloneRecord("DCO.BombusBeamSlowdown", "MovementActions.SandevistanCatchUpDistance_inline3")	
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamSlowdown.easeOut", CName.new("None"))
	TweakDB:SetFlatNoUpdate("DCO.BombusBeamSlowdown.multiplier", 6)
	TweakDB:SetFlat("DCO.BombusBeamSlowdown.overrideMultiplerWhenPlayerInTimeDilation", 3)
	
	--Fix lookat data
	TweakDB:CloneRecord("DCO.BombusLookAtWeapons", "DroneBombusActions.ShootBeam_inline8")
	TweakDB:CloneRecord("DCO.BombusLookAtHorizontal", "DroneBombusActions.ShootBeam_inline8")
	TweakDB:CloneRecord("DCO.BombusLookAtVertical", "DroneBombusActions.ShootBeam_inline8")

	TweakDB:SetFlat("DCO.BombusLookAtWeapons.preset", "LookatPreset.DroneHighSpeedWeapons")
	TweakDB:SetFlat("DCO.BombusLookAtHorizontal.preset", "LookatPreset.DroneHighSpeedHorizontal")
	TweakDB:SetFlat("DCO.BombusLookAtVertical.preset", "LookatPreset.DroneHighSpeedVertical")

	TweakDB:SetFlat("DroneBombusActions.ShootBeam.lookats", {"DCO.BombusLookAtWeapons", "DCO.BombusLookAtHorizontal", "DCO.BombusLookAtVertical"})
	
	--------------------------------SUICIDE BOMBUS AI----------------------------------------------
		
	--Use movement that works (UNUSED)
	TweakDB:SetFlat("DroneBombusSuicideArchetype.MovementPolicyCompositeDefault.nodes", {"DroneActions.LocomotionMalfunction", "DroneBombusActions.FollowTargetFast", "GenericArchetype.Success"})
	
	--Only at low hp
	addToList("DroneBombusActions.FollowTargetFast_inline1.AND", "Condition.HealthBelow50perc")
	
	--Make movement much faster by using the stability of Walk + time dilationing it
	TweakDB:SetFlat("DroneBombusActions.FollowTargetFast_inline2.movePolicy", "DCO.BombusSuicideMovePolicy")
	
	TweakDB:CloneRecord("DCO.BombusSuicideMovePolicy", "DroneBombusActions.FollowTargetFast_inline3")
	TweakDB:SetFlatNoUpdate("DCO.BombusSuicideMovePolicy.distance", 1)
	TweakDB:SetFlatNoUpdate("DCO.BombusSuicideMovePolicy.dontUseStart", true)
	TweakDB:SetFlat("DCO.BombusSuicideMovePolicy.movementType", "Walk")

	TweakDB:SetFlatNoUpdate("DroneBombusActions.FollowTargetFast.animationWrapperOverrides", {"Sandevistan"})
	TweakDB:SetFlat("DroneBombusActions.FollowTargetFast.subActions", {"DCO.BombusSuicideSlowdown"})

	TweakDB:CloneRecord("DCO.BombusSuicideSlowdown", "MovementActions.SandevistanCatchUpDistance_inline3")	
	TweakDB:SetFlatNoUpdate("DCO.BombusSuicideSlowdown.easeOut", CName.new("None"))
	TweakDB:SetFlatNoUpdate("DCO.BombusSuicideSlowdown.multiplier", 12)
	TweakDB:SetFlat("DCO.BombusSuicideSlowdown.overrideMultiplerWhenPlayerInTimeDilation", 6)

	--Make blow up happen properly
	TweakDB:SetFlat("DroneBombusActions.FollowTargetFast_inline5.OR", {"Condition.TargetBelow1dot5m", "Condition.AIMoveCommand", "Condition.AIUseWorkspotCommand", "Condition.PathFindingFailed", "Condition.NotMinAccuracySharedValue1"})
	
	TweakDB:SetFlat("DroneBombusActions.CommitSuicide_inline1.AND", {"Condition.NotAIMoveCommand", "Condition.NotAIUseWorkspotCommand", "Condition.TargetBelow3dot5m", "Condition.HealthBelow50perc"})
	


	------------------------------FLYING DRONES ADVANCED WEAPONS-------------------------------
	
	
	--Griffin
	createExplosiveDroneWeapon("DCO.AdvancedGriffinRifleRight", "Items.Griffin_Rifle_Right", "Attacks.NPCBulletEffect", "Attacks.NPCBulletProjectile", "Attacks.BulletExplosion", 0.5, 0.5)
	createDroneEquipment("DCO.Griffin", "Items.Griffin_Rifle_Right", "DCO.AdvancedGriffinRifleRight")
	
	--Handle left hand
	createExplosiveDroneWeapon("DCO.AdvancedGriffinRifleLeft", "Items.Griffin_Rifle_Left", "Attacks.NPCBulletEffect", "Attacks.NPCBulletProjectile", "Attacks.BulletExplosion", 0.5, 0.5)
	createDroneEquipment("DCO.GriffinLeft", "Items.Griffin_Rifle_Left", "DCO.AdvancedGriffinRifleLeft")
	addToList("DCO.GriffinPrimaryEquipment.equipmentItems", "DCO.GriffinLeftPrimaryPool")

	TweakDB:SetFlat("DCO.GriffinLeftPrimaryPoolEntryAdvanced_inline1.equipSlot", "AttachmentSlots.WeaponLeft")
	TweakDB:SetFlat("DCO.GriffinLeftPrimaryPoolEntryBasic_inline1.equipSlot", "AttachmentSlots.WeaponLeft")

	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1Griffin"..i..".primaryEquipment", "DCO.GriffinPrimaryEquipment")
	end
	
	--Wyvern
	createExplosiveDroneWeapon("DCO.AdvancedWyvernRifle", "Items.Wyvern_Rifle", "Attacks.NPCSmartBullet", "Attacks.NPCSmartBullet", "Attacks.BulletSmartBulletHighExplosion", 0.5, 0.5)
	createDroneEquipment("DCO.Wyvern", "Items.Wyvern_Rifle", "DCO.AdvancedWyvernRifle")
	
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1Wyvern"..i..".primaryEquipment", "DCO.WyvernPrimaryEquipment")
	end
	
	--Arasaka Octant
	TweakDB:CloneRecord("DCO.OctantArasakaSmartAutocannon", "Items.Octant_Autocannon")
	TweakDB:SetFlatNoUpdate("DCO.OctantArasakaSmartAutocannon.evolution", "WeaponEvolution.Smart")
	TweakDB:SetFlatNoUpdate("DCO.OctantArasakaSmartAutocannon.npcRPGData", "DCO.OctantArasakaSmartAutocannon_inline0")
	TweakDB:SetFlat("DCO.OctantArasakaSmartAutocannon.rangedAttacks", "Attacks.SmartBulletDronePackage")

	TweakDB:CloneRecord("DCO.OctantArasakaSmartAutocannon_inline0", "Items.Octant_Autocannon_inline0")
	TweakDB:SetFlat("DCO.OctantArasakaSmartAutocannon_inline0.statModifierGroups", {"Items.Octant_Autocannon_Handling_Stats", "Items.Wyvern_Rifle_SmartGun_Stats", "Items.Wyvern_Rifle_Projectile_Stats"})
	
	createDroneEquipment("DCO.OctantArasaka", "Items.Octant_Autocannon", "DCO.OctantArasakaSmartAutocannon")
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1OctantArasaka"..i..".primaryEquipment", "DCO.OctantArasakaPrimaryEquipment")
	end
	
	--Militech Octant
	
	createExplosiveDroneWeapon("DCO.AdvancedOctantMilitechAutocannon", "DCO.OctantArasakaSmartAutocannon", "Attacks.NPCSmartBullet", "Attacks.NPCSmartBullet", "Attacks.BulletSmartBulletHighExplosion", 0.5, 0.5)
	createDroneEquipment("DCO.OctantMilitech", "DCO.OctantMilitechAutocannon", "DCO.AdvancedOctantMilitechAutocannon")
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1OctantMilitech"..i..".primaryEquipment", "DCO.OctantMilitechPrimaryEquipment")
	end
	
	
	--Bombus Giga Beam
	--[[
	--Apply the status effect to our bombi when needed
	Observe('NPCPuppet', 'OnPlayerCompanionCacheData', function(self, evt)
		if self:GetRecord():TagsContains(CName.new("Robot")) and not (self:GetAttitudeAgent():GetAttitudeGroup() == CName.new("player")) then
		
			--Make sure they are always on the player's attitude group
			self:GetAttitudeAgent():SetAttitudeGroup(CName.new("player"))
		end
	end)
	]]
	--Create Status effect and AI Cond
	TweakDB:CreateRecord("DCO.AdvancedWeaponsSE", "gamedataStatusEffect_Record")
	TweakDB:SetFlatNoUpdate("DCO.AdvancedWeaponsSE.duration", "BaseStats.InfiniteDuration")
	TweakDB:SetFlat("DCO.AdvancedWeaponsSE.statusEffectType", "BaseStatusEffectTypes.Misc")

	TweakDB:CreateRecord("DCO.HasAdvancedWeapons", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.HasAdvancedWeapons.statusEffect", "DCO.EWSSE")
	TweakDB:SetFlatNoUpdate("DCO.HasAdvancedWeapons.invert", false)
	TweakDB:SetFlat("DCO.HasAdvancedWeapons.target", "AIActionTarget.Owner")

	TweakDB:CreateRecord("DCO.NotHasAdvancedWeapons", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.NotHasAdvancedWeapons.statusEffect", "DCO.EWSSE")
	TweakDB:SetFlatNoUpdate("DCO.NotHasAdvancedWeapons.invert", true)
	TweakDB:SetFlat("DCO.NotHasAdvancedWeapons.target", "AIActionTarget.Owner")

	--Giga beam action
	
	TweakDB:CloneRecord("DCO.ShootGigaBeam", "DroneBombusActions.ShootBeam")
	TweakDB:SetFlatNoUpdate("DCO.ShootGigaBeam.activationCondition", "DCO.ShootGigaBeam_inline0")
	--TweakDB:SetFlatNoUpdate("DCO.ShootGigaBeam.cooldowns", {"DCO.ShootGigaBeam_inline3"})
	TweakDB:SetFlatNoUpdate("DCO.ShootGigaBeam.loop", "DCO.ShootGigaBeam_inline5")
	TweakDB:SetFlat("DCO.ShootGigaBeam.loopSubActions", {"DCO.ShootGigaBeam_inline2"})
	
	--Shooty
	TweakDB:CloneRecord("DCO.ShootGigaBeam_inline2", "DroneBombusActions.ShootBeam_inline2")
	TweakDB:SetFlatNoUpdate("DCO.ShootGigaBeam_inline2.attackDuration", 10)
	TweakDB:SetFlat("DCO.ShootGigaBeam_inline2.attack", "DCO.GigaBeam")
	
	--Condition
	TweakDB:CreateRecord("DCO.ShootGigaBeam_inline0", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat("DCO.ShootGigaBeam_inline0.condition", "DCO.ShootGigaBeam_inline1")

	TweakDB:CloneRecord("DCO.ShootGigaBeam_inline1", "DroneBombusActions.ShootBeam_inline1")
	addToList("DCO.ShootGigaBeam_inline1.AND", "DCO.HasAdvancedWeapons")
	addToList("DCO.ShootGigaBeam_inline1.AND", "DCO.ShootGigaBeam_inline4")

	--cooldown
	TweakDB:CreateRecord("DCO.ShootGigaBeam_inline3", "gamedataAIActionCooldown_Record")
	TweakDB:SetFlatNoUpdate("DCO.ShootGigaBeam_inline3.duration", 60)
	TweakDB:SetFlat("DCO.ShootGigaBeam_inline3.name", "HackBuffCamo")
	
	TweakDB:CreateRecord("DCO.ShootGigaBeam_inline4", "gamedataAICooldownCond_Record")
	TweakDB:SetFlat("DCO.ShootGigaBeam_inline4.cooldowns", {"DCO.ShootGigaBeam_inline3"})
	
	--Action phase
	TweakDB:CloneRecord("DCO.ShootGigaBeam_inline5", "DroneBombusActions.ShootBeam_inline5")
	TweakDB:SetFlatNoUpdate("DCO.ShootGigaBeam_inline5.toNextPhaseCondition", {})
	TweakDB:SetFlat("DCO.ShootGigaBeam_inline5.toNextPhaseConditionCheckInterval", 0)

	
	--Add action to beam list (DISABLED FOR NOW, GONNA GIVE SOMEONE A SEIZURE)
	--TweakDB:SetFlat("DroneBombusFastArchetype.WeaponHandlingComposite.nodes", {"ItemHandling.SuccessIfEquipping", "DroneBombusActions.CommitSuicide", "DCO.ShootGigaBeam", "DroneBombusActions.ShootBeam", "DCO.BombusLookAtTarget", "GenericArchetype.Success"})
	
	--Add giga beam to attacks
	addToList("DCO.BombusTorch.attacks", "DCO.GigaBeam")
	
	--Create Giga Beam
	TweakDB:CloneRecord("DCO.GigaBeam", "Attacks.PlasmaBeam")
	TweakDB:SetFlat("DCO.GigaBeam.hitCooldown", 0.12)
	TweakDB:SetFlatNoUpdate("DCO.GigaBeam.attackType", "AttackType.Ranged")
	TweakDB:SetFlat("DCO.GigaBeam.statModifiers", TweakDB:GetFlat("Attacks.BombusFlame.statModifiers"))
	addToList("DCO.GigaBeam.statModifiers", "DCO.GigaBeamDamage")
	
	createConstantStatModifier("DCO.GigaBeamDamage", "Multiplier", "BaseStats.PhysicalDamage", 4)



	--Bombus knockdown beam
	createDroneEquipment("DCO.Bombus", "DCO.BombusTorch", "DCO.AdvancedBombusTorch")
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1Bombus"..i..".primaryEquipment", "DCO.BombusPrimaryEquipment")
	end
	
	TweakDB:CloneRecord("DCO.AdvancedBombusTorch", "DCO.BombusTorch")
	TweakDB:SetFlat("DCO.AdvancedBombusTorch.npcRPGData", "DCO.AdvancedBombusTorch_inline0")
	
	TweakDB:CloneRecord("DCO.AdvancedBombusTorch_inline0", "DCO.BombusTorch_inline0")
	addListToList("DCO.AdvancedBombusTorch_inline0", "statModifiers", {"DCO.AdvancedBombusTorch_inline1", "DCO.AdvancedBombusTorch_inline2", "DCO.AdvancedBombusTorch_inline3"})
	
	createConstantStatModifier("DCO.AdvancedBombusTorch_inline1", "Additive", "BaseStats.HitReactionFactor", 3)
	createConstantStatModifier("DCO.AdvancedBombusTorch_inline2", "Additive", "BaseStats.PhysicalImpulse", 25)
	createConstantStatModifier("DCO.AdvancedBombusTorch_inline3", "Additive", "BaseStats.KnockdownImpulse", 30)

	-------------------------PREVENT COMBAT STIMS FROM CYBER ENEMIES-----------------------------
	addToList("SpecialActions.CoverUseCombatStimConsumable_inline11.AND", "DCO.IsNotDCO")
	addToList("SpecialActions.UseCombatStimConsumable_inline5.AND", "DCO.IsNotDCO")

	------------------------------REMOVE GRIFFIN SHOOT COOLDOWN-----------------------------------
	
	TweakDB:SetFlat("DroneGriffinActions.ShootCooldown.duration", 0.01) --Might affect octant chase?
	
	--------------------------------FIX OUR MECHS DEATH EXPLOSION DAMAGE-----------------------------
	
	--Didnt do damage before, just trigger a fancy effect
	--Uses some old data from techdecks section
	
	TweakDB:CreateRecord("DCO.MechGLP", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.MechGLP.effectors", {"DCO.MechGLP_inline0"})
	
	TweakDB:CloneRecord("DCO.MechGLP_inline0", "DCO.FlyingDroneGLP_inline0")
	TweakDB:SetFlat("DCO.MechGLP_inline0.attackRecord", "DCO.MechDeathExplosion")
	TweakDB:SetFlat("DCO.MechGLP_inline0.attackPositionSlotName", CName.new("Chest"))
	
	TweakDB:CloneRecord("DCO.MechDeathExplosion", "DCO.FlyingDroneDeathExplosion")
	TweakDB:SetFlatNoUpdate("DCO.MechDeathExplosion.range", 5)
	createConstantStatModifier("DCO.MechDeathExplosion_inline0", "Multiplier", "BaseStats.PhysicalDamage", 0.2)
	addToList("DCO.MechDeathExplosion.statModifiers", "DCO.MechDeathExplosion_inline0")
	
	for i,v in ipairs(Mech_List) do
		addToList(v..".onSpawnGLPs", "DCO.MechGLP")
	end
	

	--------------------------------DISABLE REVEAL POSITION WHEN PLAYER HACKS----------------
	
	Override('NPCPuppet', 'RevealPlayerPositionIfNeeded;ScriptedPuppetEntityID', function(ownerPuppet, playerID, wrappedMethod)
	
		--Check if its one of our drones
		if TweakDBInterface.GetCharacterRecord(ownerPuppet:GetRecordID()):TagsContains(CName.new("Robot")) then
			return false
		end
		return wrappedMethod(ownerPuppet, playerID)
	end)
	


	-----------------------------DRONES DONT SHOOT CORPSES-------------------------------------
	
	--Lower shots per ai action
	TweakDB:SetFlat("MinotaurMech.AimAttackHMG_inline10.numberOfShots", 12)
	TweakDB:SetFlat("MinotaurMech.AimAttackHMGLeft_inline1.numberOfShots", 12)
	TweakDB:SetFlat("MinotaurMech.AimAttackHMGOnPlace_inline10.numberOfShots", 12)
	TweakDB:SetFlat("MinotaurMech.AimAttackHMGOnPlace_inline12.numberOfShots", 12)
	TweakDB:SetFlat("MinotaurMech.AimAttackHMGOnPlaceLeft_inline12.numberOfShots", 12)
	TweakDB:SetFlat("MinotaurMech.AimAttackHMGOnPlaceRight_inline12.numberOfShots", 12)
	TweakDB:SetFlat("MinotaurMech.AimAttackHMGRight_inline1.numberOfShots", 12)

	TweakDB:SetFlat("DroneOctantActions.ShootDefault_inline6.numberOfShots", 10)
		

	------------------------------ADD KNOCKDOWN IMMUNITIES-----------------------------------------------
	
	--Add to all mechs and flying drones bc why not should've had it in the first place
	createConstantStatModifier("DCO.KnockdownImmunity", "Additive", "BaseStats.KnockdownImmunity", 1)
	addToList("Character.Mech_Primary_Stat_ModGroup.statModifiers", "DCO.KnockdownImmunity")
	addToList("Character.Drone_Primary_Stat_ModGroup.statModifiers", "DCO.KnockdownImmunity")
	addToList("NPCRarity.Boss.statModifiers", "DCO.KnockdownImmunity")
	
	--------------------------------INFINITE SYSTEM COLLAPSE DURATION--------------------------------------
	TweakDB:SetFlat("BaseStatusEffect.SystemCollapse.duration", "BaseStats.InfiniteDuration")
	
	
	-----------------------------SMASHER KILLED TARGET FIX---------------------------------------------
	TweakDB:CloneRecord("DCO.TargetHealthBelow1perc", "Condition.HealthBelow1perc")
	TweakDB:SetFlat("DCO.TargetHealthBelow1perc.target", "AIActionTarget.CombatTarget")
	
	addToList("AdamSmasherBoss.AimAttackLMGCover_inline4.OR", "DCO.TargetHealthBelow1perc")
	
	------------------------------FIX MECH/OCTANT AI PAUSE + BOXING FIGHTS---------------------------------
	mechcount=0 --Shooting sequence
	mechcount2 = 0 --Turning sequence
	octantcount = 0 --Shooting sequence
	bombuscount = 0 --followtargetfast w/ dead target
	smasherlmgcount = 0
	--[[
	Observe('TweakAIActionSequence', 'GetActionRecord', function(self, context)
		if TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context):GetRecordID()):TagsContains(CName.new("Robot")) then
			local recordID
			if self.sequenceRecord then
				recordID = self.sequenceRecord:GetID()
			end
			print("SEQUENCE RECORD")
			print(recordID)
		end
	end)
	]]
	Override('TweakAIActionAbstract', 'Update', function(self, context, wrappedMethod)


		if TweakDBInterface.GetCharacterRecord(ScriptExecutionContext.GetOwner(context):GetRecordID()):TagsContains(CName.new("Robot")) then

			--Fix boxing fights by disabling their AI
			if StatusEffectSystem.ObjectHasStatusEffectWithTag(Game.GetPlayer(), CName.new("FistFight")) then
				return AIbehaviorUpdateOutcome.FAILURE
			end
			--action record can be nil sometimes
			local recordID
			if self.actionRecord then
				recordID = self.actionRecord:GetID()
			end

			--print("ACTION RECORD: UPDATE")
			--print(recordID)
		
			if recordID == TweakDBID.new("MinotaurMech.AimAttackHMG") then
				mechcount = mechcount + 1
				if mechcount>50 then
					mechcount = 0
					return AIbehaviorUpdateOutcome.SUCCESS
				end
				ret = wrappedMethod(context)
				if ret == AIbehaviorUpdateOutcome.SUCCESS then
					mechcount = 0
				end

				return ret
			elseif recordID == TweakDBID.new("MinotaurMech.RotateToTargetNoLimit") then
				mechcount2 = mechcount2 + 1
				if mechcount2>20 then
					mechcount2 = 0
					return AIbehaviorUpdateOutcome.SUCCESS
				end
				ret = wrappedMethod(context)
				if ret == AIbehaviorUpdateOutcome.SUCCESS then
					mechcount2 = 0
				end
				return ret
			elseif recordID == TweakDBID.new("DroneOctantActions.ShootDefault") then
				octantcount = octantcount + 1
				if octantcount > 50 then
					octantcount = 0
					return AIbehaviorUpdateOutcome.SUCCESS
				end
				ret = wrappedMethod(context)
				if ret == AIbehaviorUpdateOutcome.SUCCESS then
					octantcount = 0
				end
				
				return ret
			elseif recordID == TweakDBID.new("DroneBombusActions.FollowTargetFast") then
				bombuscount = bombuscount + 1
				if bombuscount>30 then
					bombuscount = 0
					return AIbehaviorUpdateOutcome.SUCCESS
				end
				ret = wrappedMethod(context)
				if ret == AIbehaviorUpdateOutcome.SUCCESS then
					bombuscount = 0
				end
				return ret
			end
		end

		return wrappedMethod(context)
	end)
	
	
	---------------------------KEEP THEM AGGRO'D ON DRONES------------------------------
	
	
	--Keeps reinjecting the threats because when the player was far away they could just leave combat.
	--[[
	reinject = true
	Observe('SetTopThreatToCombatTarget', 'IsTargetValid', function(self, context, target)
		if reinject and target and TweakDBInterface.GetCharacterRecord(target:GetRecordID()):TagsContains(CName.new("Robot")) and not DisableCombat then
			reinject = false
			Cron.After(0.1, function()
				TargetTrackingExtension.InjectThreat(ScriptExecutionContext.GetOwner(context), Game.GetPlayer(), 0.1)
				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not DisableCombat then
						TargetTrackingExtension.InjectThreat(ScriptExecutionContext.GetOwner(context), v, 0.5)
					end
				end
				reinject = true
			end)
		end
	end)
	]]

	---------------------------INCREASE FOLLOW SPEED---------------------------------------
	
	--Removed player must be sprinting condition
	TweakDB:SetFlat("Condition.FollowFarStopCondition_inline1.AND", {"Condition.IsDistanceToDestinationInMediumRange"})
	
	---------------------------FIX ANDROID PAUSING FOLLOW---------------------------------
	
	--Make new action
	TweakDB:CloneRecord("DCO.AndroidFollowFar", "FollowerActions.FollowFar")
	TweakDB:SetFlatNoUpdate("DCO.AndroidFollowFar.activationCondition", "DCO.AndroidFollowFar_inline0")
	TweakDB:SetFlat("DCO.AndroidFollowFar.loop", "DCO.AndroidFollowFar_inline2")
	
	--Condition stuff
	TweakDB:CreateRecord("DCO.AndroidFollowFar_inline0", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat("DCO.AndroidFollowFar_inline0.condition", "DCO.AndroidFollowFar_inline1")
	
	TweakDB:CloneRecord("DCO.AndroidFollowFar_inline1", "FollowerActions.FollowFar_inline1")
	addToList("DCO.AndroidFollowFar_inline1.AND", "Condition.Android")
	
	--Movement stuff
	TweakDB:CloneRecord("DCO.AndroidFollowFar_inline2", "FollowerActions.FollowFar_inline2")
	TweakDB:SetFlat("DCO.AndroidFollowFar_inline2.movePolicy", "DCO.AndroidFollowFar_inline3")
	
	TweakDB:CloneRecord("DCO.AndroidFollowFar_inline3", "FollowerActions.FollowSprintMovePolicy")
	TweakDB:SetFlat("DCO.AndroidFollowFar_inline3.movementType", "Walk")
	
	--Add our new action
	temp = TweakDB:GetFlat("FollowerActions.FollowComposite.nodes")
	if not has_value(temp, TweakDBID.new("DCO.AndroidFollowFar")) then
		table.insert(temp, 7, "DCO.AndroidFollowFar")
		TweakDB:SetFlat("FollowerActions.FollowComposite.nodes", temp)
	end
	
	--addToList("FollowerActions.FollowComposite.nodes", "DCO.AndroidFollowFar")
	
	--Disable old ones for androids
	addToList("FollowerActions.FollowFar_inline1.AND", "Condition.NotAndroid")
		

	---------------------------PREVENT ROBOTS FROM TRYING TO STEALTH-----------------------
	
	--They t-pose first
	TweakDB:SetFlat("FollowerActions.EnterStealth_inline0.condition", "DCO.EnterStealthCondition")
	
	TweakDB:CloneRecord("DCO.EnterStealthCondition", "Condition.EnterStealthCondition")
	addToList("DCO.EnterStealthCondition.AND", "Condition.Human")
	
	--------------------------BASE ANDROID STATS--------------------------------------------
	
	--We remove arm dismemberment bc it bugs out the weapons and ai
	limb_stats = {"WoundLArmDamageThreshold", "WoundRArmDamageThreshold",  "DismLArmDamageThreshold", "DismRArmDamageThreshold"}
	leg_stats = {"DismLLegDamageThreshold", "DismRLegDamageThreshold"}
	head_stats = {"WoundHeadDamageThreshold", "DismHeadDamageThreshold"}
	
	temp = {}
	for i,v in ipairs(limb_stats) do
		createConstantStatModifier("DCO.Android"..v.."Adjust", "Additive", "BaseStats."..v, 9999)
		table.insert(temp, "DCO.Android"..v.."Adjust")
	end
	for i,v in ipairs(leg_stats) do
		createConstantStatModifier("DCO.Android"..v.."Adjust", "Additive", "BaseStats."..v, -20)
		table.insert(temp, "DCO.Android"..v.."Adjust")
	end
	for i,v in ipairs(head_stats) do
		createConstantStatModifier("DCO.Android"..v.."Adjust", "Additive", "BaseStats."..v, 10)
		table.insert(temp, "DCO.Android"..v.."Adjust")
	end
	addListToList("DCO.AndroidStatGroup", "statModifiers", temp)
	

	-----------------------------FIX BOMBUS AND SYSTEM COLLAPSE----------------------
	
	TweakDB:CreateRecord("DCO.BombusSystemCollapsePackage", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.BombusSystemCollapsePackage.effectors", {"DCO.BombusSystemCollapseEffector"})
	
	TweakDB:CreateRecord("DCO.BombusSystemCollapseEffector", "gamedataEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.BombusSystemCollapseEffector.effectorClassName", "ModifyStatPoolValueEffector")
	TweakDB:SetFlatNoUpdate("DCO.BombusSystemCollapseEffector.prereqRecord", "DCO.BombusSystemCollapseEffectorPrereq")
	TweakDB:SetFlat("DCO.BombusSystemCollapseEffector.statPoolUpdates", {"DCO.BombusSystemCollapseEffectorStatPool"})
	TweakDB:SetFlat("DCO.BombusSystemCollapseEffector.usePercent", true)

	TweakDB:CloneRecord("DCO.BombusSystemCollapseEffectorPrereq", "Spawn_glp.DroneGriffin_ExplodeOnDeath_inline3")
	TweakDB:SetFlat("DCO.BombusSystemCollapseEffectorPrereq.prereqClassName", "StatusEffectPrereq")
	
	TweakDB:CloneRecord("DCO.BombusSystemCollapseEffectorStatPool", "Ability.HasElectricExplosion_inline5")
	
	for i=1, DroneRecords do
		addToList("DCO.Tier1Bombus"..i..".onSpawnGLPs", "DCO.BombusSystemCollapsePackage")
	end
	

	------------------------------SET WYVERNS TO RARE---------------------------------------
	
	--Griffins are rare as well
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1Wyvern"..i..".rarity", "NPCRarity.Rare")
	end
	
	-----------------------
	------------------------------TELEPORTING------------------------------------------
	
	--Disable android and mech teleporting
	--addToList("FollowerActions.TeleportToTarget_inline1.AND", "DCO.IsNotDCO") 
	
	--Leave it for flying drones bc they get stuck easy
	--addToList("DroneActions.EvaluateTeleportToTarget_inline2.AND", "DCO.IsNotDCO")
	
	--Disable it for mechs
	--addToList("FollowerActions.TeleportToTarget_inline1.AND", "DCO.NotMechAI")
	
	--Remove cooldown
	TweakDB:SetFlat("FollowerActions.TeleportToFollower_inline0.duration", 0.1)
	
	--Enable teleporting because of distance
	TweakDB:CreateRecord("DCO.FollowerTeleportDistance", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.FollowerTeleportDistance.AND", {"Condition.FollowerAbove17m", "DCO.FollowerBelow100m"})
	
	addToList("FollowerActions.TeleportToTarget_inline2.OR", "DCO.FollowerTeleportDistance")
	--addToList("FollowerActions.TeleportToTarget_inline1.AND", "DCO.FollowerTeleportDistance")

	--Disable teleporting when realllly far away
	addToList("DroneActions.EvaluateTeleportToTarget_inline2.AND", "DCO.FollowerBelow100m")
	TweakDB:CloneRecord("DCO.FollowerBelow100m", "Condition.FollowerBelow10m")
	vec = Vector2:new()
	vec.X = -1
	vec.Y = 100
	TweakDB:SetFlat("DCO.FollowerBelow100m.distance", vec)
	

	---------------------------FLYING DRONE STRAFING------------------------------------------
	
	--Remove not-follower check
	TweakDB:SetFlat("DroneActions.StrafeSelectorActivationCondition.AND", {"Condition.NotStatusEffectWhistleLvl3", "Condition.NotIsUsingOffMeshLink", "Condition.NotAIMoveCommand", "Condition.NotAIUseWorkspotCommand", "Condition.NotIsNPCUnderLocomotionMalfunctionQuickhack", "Condition.CanMoveInRegardsToShooting", "Condition.NotTargetInVehicle"})
	
	
	-----------------------------DROP DRONE CORES WHEN SYSTEM COLLAPSED---------------------------------

	Override('ScriptedPuppet', 'ProcessLoot', function(self, wrappedMethod)

		charRecord = TweakDBInterface.GetCharacterRecord(self:GetRecordID())
		if not charRecord:TagsContains(CName.new("Robot")) then
			wrappedMethod()
			return
		end		

		
		Game.GetTransactionSystem():RemoveAllItems(self) --Needed for weapons removal


		if not self:IsLooted() then

			ingdata = CraftingSystem.GetInstance():GetItemCraftingCost(TweakDBInterface.GetItemRecord(TweakDBID.new(TweakDB:GetFlat(self:GetRecordID()..'.DCOItem'))))
			death_loot =  (Game.GetStatsSystem():GetStatValue(Game.GetPlayer():GetEntityID(), gamedataStatType.NPCUnequipItemDuration) > 0)
			if StatusEffectSystem.ObjectHasStatusEffect(self, TweakDBID.new("BaseStatusEffect.SystemCollapse")) or death_loot then
				for i,v in ipairs(ingdata) do
					Game.GetTransactionSystem():GiveItemByTDBID(Game.GetPlayer(), v.id:GetID(), math.ceil(v.quantity * 0.5))
				end
			end
			
			if ScriptedPuppet.HasLootableItems(self) then
				ScriptedPuppet.EvaluateLootQuality(self)
			end
			self:CacheLootForDroping()
		end

		
	end)
	
	-----------------------------DISABLE UNCONTROLLED MOVEMENT WITH SYSTEM COLLAPSE----------------------
	Override('DroneComponent', 'OnDeath', function(self, evt, wrappedMethod)
		owner = self:GetOwner()
		if not TweakDBInterface.GetCharacterRecord(owner:GetRecordID()):TagsContains(CName.new("Robot")) then
			return wrappedMethod(evt)
		end
		if StatusEffectSystem.ObjectHasStatusEffect(owner, TweakDBID.new("BaseStatusEffect.SystemCollapse")) then
	      GameObject.PlaySound(owner, CName.new("drone_destroyed"))
		  GameObject.StartReplicatedEffectEvent(owner, CName.new("hacks_system_collapse"))
		  self:RemoveSpawnGLPs(owner)
		  if TweakDB:GetFlat(owner:GetRecordID()..'keepColliderOnDeath') then
			reenableColliderEvent = ReenableColliderEvent:new()
			Game.GetDelaySystem():DelayEvent(owner, reenableColliderEvent, 0.20)
		  end
		  owner:QueueEvent(CreateForceRagdollEvent(CName.new("ForceRagdollTask")))
		else
			return wrappedMethod(evt)
		end


	end)
		
	-----------------------------------------------------------------------------------------
	-----------------------------ANDROID TECHIES--------------------------------------------
	-----------------------------------------------------------------------------------------
	
	----------------------------DEFAULT THROW GRENADES----------------------------------------------
	
	--Selector conditions. AND-OR-2ANDs
	
	--Make an OR that goes in the original AND
	TweakDB:CreateRecord("DCO.ThrowGrenadeSelectorCondition", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.ThrowGrenadeSelectorCondition.OR", {"DCO.ThrowGrenadeSelectorConditionOriginal", "DCO.ThrowGrenadeSelectorConditionAndroid"})

	--Clone the original
	--Remove istargetfollower, add human check
	TweakDB:CloneRecord("DCO.ThrowGrenadeSelectorConditionOriginal", "Condition.ThrowGrenadeSelectorCondition")
	TweakDB:SetFlat("DCO.ThrowGrenadeSelectorConditionOriginal.AND", {"Condition.InitThrowGrenadeCooldown", "Condition.NotAIThrowGrenadeCommand", "Condition.NotAIAimAtTargetCommand", "Condition.NotTicketCatchUp", "Condition.MinAccuracyValue0", "Condition.BaseThrowGrenadeSelectorCondition", "Condition.NotIsFollower", "Condition.NotTargetInSafeZone", "Condition.ThrowGrenadeSelectorCondition_inline0", "Condition.Human"})
	
	--addToList("DCO.ThrowGrenadeSelectorConditionOriginal.AND", "Condition.Human")

	--Set our original to be now linked to the OR
	TweakDB:SetFlat("Condition.ThrowGrenadeSelectorCondition.AND", {"DCO.ThrowGrenadeSelectorCondition"})
	
	--Make our android condition
	TweakDB:CreateRecord("DCO.ThrowGrenadeSelectorConditionAndroid", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.ThrowGrenadeSelectorConditionAndroid.AND", {"DCO.IsDCO", "Condition.Android", "Condition.InitThrowGrenadeCooldown", "Condition.NotAIThrowGrenadeCommand", "Condition.NotAIAimAtTargetCommand", "Condition.NotTicketCatchUp", "Condition.MinAccuracyValue0", "DCO.BaseThrowGrenadeSelectorConditionAndroid",  "DCO.ThrowGrenadeCooldown_inline0"})
	
	
	--Make our own base throw grenade selector condition
	TweakDB:CreateRecord("DCO.BaseThrowGrenadeSelectorConditionAndroid", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.BaseThrowGrenadeSelectorConditionAndroid.AND", {"DCO.IsDCO", "Condition.Android", "Condition.NotHasAnyWeaponLeft", "Condition.AbilityCanUseGrenades", "Condition.NotIsInWorkspot", "Condition.NotIsUsingOffMeshLink", "Condition.NotIsEnteringOrLeavingCover", "Condition.NotTicketEquip", "Condition.HasAnyWeapon", "Condition.NotTicketSync", "Condition.NotTicketTakeCover", "Condition.ThrowCond"})
	
	----------------------------------COVER THROW GRENADES----------------------------------
	
	--Make an OR that goes in the original AND
	TweakDB:CreateRecord("DCO.CoverThrowGrenadeSelectorCondition", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.CoverThrowGrenadeSelectorCondition.OR", {"DCO.CoverThrowGrenadeSelectorConditionOriginal", "DCO.CoverThrowGrenadeSelectorConditionAndroid"})

	--Clone the original
	--Add human check, remove target is follower check
	TweakDB:CloneRecord("DCO.CoverThrowGrenadeSelectorConditionOriginal", "Condition.CoverThrowGrenadeSelectorCondition")
	TweakDB:SetFlat("DCO.CoverThrowGrenadeSelectorConditionOriginal.AND", {"Condition.AbilityCanUseGrenades", "Condition.NotHasAnyWeaponLeft", "Condition.NotTicketEquip", "Condition.NotTicketSync", "Condition.ThrowCond", "Condition.NotIsFollower", "Condition.CheckChosenExposureMethodAll", "Condition.NotTargetInSafeZone", "Condition.Human"})
	
	--addToList("DCO.CoverThrowGrenadeSelectorConditionOriginal.AND", "Condition.Human")
	
	--Set our original to be now linked to the OR
	TweakDB:SetFlat("Condition.CoverThrowGrenadeSelectorCondition.AND", {"DCO.CoverThrowGrenadeSelectorCondition"})
	
	--Make our android condition
	TweakDB:CreateRecord("DCO.CoverThrowGrenadeSelectorConditionAndroid", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.CoverThrowGrenadeSelectorConditionAndroid.AND", {"DCO.IsDCO", "Condition.Android", "Condition.AbilityCanUseGrenades", "Condition.NotHasAnyWeaponLeft", "Condition.NotTicketEquip", "Condition.NotTicketSync", "Condition.ThrowCond", "DCO.CheckChosenExposureMethodAll",  "DCO.ThrowGrenadeCooldown_inline0"})
	
	---------------------------------COMMAND THROW GRENADES---------------------------------
	TweakDB:CreateRecord("DCO.CommandThrowGrenadeSelector", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.CommandThrowGrenadeSelector.OR", {"Condition.BaseThrowGrenadeSelectorCondition", "DCO.BaseThrowGrenadeSelectorConditionAndroid"})
	
	TweakDB:SetFlat("ItemHandling.CommandThrowGrenadeSelector_inline1.AND", {"Condition.AIThrowGrenadeCommand", "DCO.CommandThrowGrenadeSelector", "DCO.ThrowGrenadeCooldown_inline0"})
		
	
	----------------------------------MAKE GRENADE AI-----------------------------------------
		

	--Make base cooldown
	--Make cooldown
	TweakDB:CreateRecord("DCO.ThrowGrenadeCooldown", "gamedataAIActionCooldown_Record")
	TweakDB:SetFlatNoUpdate("DCO.ThrowGrenadeCooldown.duration", 8)
	TweakDB:SetFlat("DCO.ThrowGrenadeCooldown.name", "ThrowGrenade")
	
	TweakDB:CreateRecord("DCO.ThrowGrenadeCooldown_inline0", "gamedataAICooldownCond_Record")
	TweakDB:SetFlat("DCO.ThrowGrenadeCooldown_inline0.cooldowns", {"DCO.ThrowGrenadeCooldown"})
	
	--Base conditions
	near_conditions = {"Condition.Android", "Condition.ThrowGrenadeNearCondition"}
	regular_conditions = {"Condition.Android", "Condition.ThrowGrenadeCondition"}
	
	--Cutting
	createAndroidGrenadeAction("DCO.ThrowCuttingGrenadeNear", "ItemHandling.ThrowGrenadeNearCutting", "DCO.AndroidGrenadeCutting", near_conditions, "HackBuffSturdiness")
	
	createAndroidGrenadeAction("DCO.ThrowCuttingGrenadeCover", "CoverActions.ThrowGrenadeCoverCutting", "DCO.AndroidGrenadeCutting", regular_conditions, "HackBuffSturdiness")
	createAndroidGrenadeAction("DCO.ThrowCuttingGrenade", "ItemHandling.ThrowGrenadeCutting", "DCO.AndroidGrenadeCutting", regular_conditions, "HackBuffSturdiness")
	
	--EMP
	conditions = {"Condition.Android", "DCO.TargetIsRobot", "Condition.ThrowGrenadeNearCondition"}
	createAndroidGrenadeAction("DCO.ThrowEMPGrenadeNear", "ItemHandling.ThrowGrenadeNearEMP", "DCO.AndroidGrenadeEMPRegular", conditions, "HackBuffCamo")
	
	conditions = {"Condition.Android", "DCO.TargetIsRobot", "Condition.ThrowGrenadeCondition"}
	createAndroidGrenadeAction("DCO.ThrowEMPGrenadeCover", "CoverActions.ThrowGrenadeCoverEMP", "DCO.AndroidGrenadeEMPHoming", conditions, "HackBuffCamo")
	createAndroidGrenadeAction("DCO.ThrowEMPGrenade", "ItemHandling.ThrowGrenadeEMP", "DCO.AndroidGrenadeEMPHoming", conditions, "HackBuffCamo")

	--Biohazard
	conditions = {"Condition.Android", "DCO.TargetIsHuman", "Condition.ThrowGrenadeNearCondition"}
	createAndroidGrenadeAction("DCO.ThrowBiohazardGrenadeNear", "ItemHandling.ThrowGrenadeNearBiohazard", "DCO.AndroidGrenadeBiohazardRegular", conditions, "HackDeath")
	
	conditions = {"Condition.Android", "DCO.TargetIsHuman", "Condition.ThrowGrenadeCondition"}
	createAndroidGrenadeAction("DCO.ThrowBiohazardGrenadeCover", "CoverActions.ThrowGrenadeCoverBiohazard", "DCO.AndroidGrenadeBiohazardHoming", conditions, "HackDeath")
	createAndroidGrenadeAction("DCO.ThrowBiohazardGrenade", "ItemHandling.ThrowGrenadeBiohazard", "DCO.AndroidGrenadeBiohazardHoming", conditions, "HackDeath")

	--Incendiary
	createAndroidGrenadeAction("DCO.ThrowIncendiaryGrenadeNear", "ItemHandling.ThrowGrenadeNearIncendiary", "DCO.AndroidGrenadeIncendiaryRegular", near_conditions, "HackOverload")
	
	createAndroidGrenadeAction("DCO.ThrowIncendiaryGrenadeCover", "CoverActions.ThrowGrenadeCoverIncendiary", "DCO.AndroidGrenadeIncendiaryHoming", regular_conditions, "HackOverload")
	createAndroidGrenadeAction("DCO.ThrowIncendiaryGrenade", "ItemHandling.ThrowGrenadeIncendiary", "DCO.AndroidGrenadeIncendiaryHoming", regular_conditions, "HackOverload")
	
	--Frag
	createAndroidGrenadeAction("DCO.ThrowFragGrenadeNear", "ItemHandling.ThrowGrenadeNearFrag", "DCO.AndroidGrenadeFragRegular", near_conditions, "HackOverheat")
	
	createAndroidGrenadeAction("DCO.ThrowFragGrenadeCover", "CoverActions.ThrowGrenadeCoverFrag", "DCO.AndroidGrenadeFragHoming", regular_conditions, "HackOverheat")
	createAndroidGrenadeAction("DCO.ThrowFragGrenade", "ItemHandling.ThrowGrenadeFrag", "DCO.AndroidGrenadeFragHoming", regular_conditions ,"HackOverheat")
	
	--Flash
	createAndroidGrenadeAction("DCO.ThrowFlashGrenadeNear", "ItemHandling.ThrowGrenadeNearFlash", "Items.GrenadeFlashRegular", near_conditions, "HackWeaponMalfunction")
	
	createAndroidGrenadeAction("DCO.ThrowFlashGrenadeCover", "CoverActions.ThrowGrenadeCoverFlash", "Items.GrenadeFlashHoming", regular_conditions, "HackWeaponMalfunction")
	createAndroidGrenadeAction("DCO.ThrowFlashGrenade", "ItemHandling.ThrowGrenadeFlash", "Items.GrenadeFlashHoming", regular_conditions, "HackWeaponMalfunction")
	
	--Add them to the selectors
	cover_grenade_actions = {"DCO.ThrowCuttingGrenadeCover", "DCO.ThrowEMPGrenadeCover", "DCO.ThrowBiohazardGrenadeCover", "DCO.ThrowFlashGrenadeCover", "DCO.ThrowFragGrenadeCover", "DCO.ThrowIncendiaryGrenadeCover"}
	grenade_actions = {"DCO.ThrowCuttingGrenade", "DCO.ThrowEMPGrenade", "DCO.ThrowBiohazardGrenade", "DCO.ThrowFlashGrenade", "DCO.ThrowFragGrenade", "DCO.ThrowIncendiaryGrenade"}
	near_grenade_actions = {"DCO.ThrowCuttingGrenadeNear", "DCO.ThrowEMPGrenadeNear", "DCO.ThrowBiohazardGrenadeNear", "DCO.ThrowFlashGrenadeNear", "DCO.ThrowFragGrenadeNear", "DCO.ThrowIncendiaryGrenadeNear"}

	temp = TweakDB:GetFlat("ItemHandling.ThrowGrenadeSelector.actions")
	TweakDB:SetFlat("ItemHandling.ThrowGrenadeSelector.actions", near_grenade_actions)
	addListToList("ItemHandling.ThrowGrenadeSelector", "actions", grenade_actions)
	addListToList("ItemHandling.ThrowGrenadeSelector", "actions", temp)
	
	temp = TweakDB:GetFlat("ItemHandling.CommandThrowGrenadeSelector.actions")
	TweakDB:SetFlat("ItemHandling.CommandThrowGrenadeSelector.actions", near_grenade_actions)
	addListToList("ItemHandling.CommandThrowGrenadeSelector", "actions", grenade_actions)
	addListToList("ItemHandling.CommandThrowGrenadeSelector", "actions", temp)

	temp = TweakDB:GetFlat("CoverActions.CoverThrowGrenadeSelector.actions")
	TweakDB:SetFlat("CoverActions.CoverThrowGrenadeSelector.actions", cover_grenade_actions)
	addListToList("CoverActions.CoverThrowGrenadeSelector", "actions", temp)

	temp = TweakDB:GetFlat("CoverActions.CommandCoverThrowGrenadeSelector.actions")
	TweakDB:SetFlat("CoverActions.CommandCoverThrowGrenadeSelector.actions", cover_grenade_actions)
	addListToList("CoverActions.CommandCoverThrowGrenadeSelector", "actions", temp)

	----------------------------MAKE OUR ANDROID GRENADES-----------------------------------
	
	--Make base homing parameters
	TweakDB:CloneRecord("DCO.HomingGDM", "Items.GrenadeFragHoming_inline0")
	TweakDB:SetFlat("DCO.HomingGDM.freezeDelay", 1.1)
	
	--Make grenades
	createAndroidDamageGrenade("DCO.AndroidGrenadeFragRegular", "Items.GrenadeFragRegular", 8)
	createAndroidDamageGrenade("DCO.AndroidGrenadeFragHoming", "Items.GrenadeFragHoming", 8)

	createAndroidSEGrenade("DCO.AndroidGrenadeBiohazardRegular", "Items.GrenadeBiohazardRegular", 1.5, "BaseStats.ChemicalDamage", "Attacks.LowChemicalDamageOverTime")
	createAndroidSEGrenade("DCO.AndroidGrenadeBiohazardHoming", "Items.GrenadeBiohazardHoming", 1.5, "BaseStats.ChemicalDamage", "Attacks.LowChemicalDamageOverTime")

	createAndroidSEGrenade("DCO.AndroidGrenadeEMPRegular", "Items.GrenadeEMPRegular", 1.5, "BaseStats.ElectricDamage", "Attacks.LowElectricDamageOverTime")
	createAndroidSEGrenade("DCO.AndroidGrenadeEMPHoming", "Items.GrenadeEMPHoming", 1.5, "BaseStats.ElectricDamage", "Attacks.LowElectricDamageOverTime")
	
	createAndroidSEGrenade("DCO.AndroidGrenadeIncendiaryRegular", "Items.GrenadeIncendiaryRegular", 1.5, "BaseStats.ThermalDamage", "Attacks.EnemyNetrunnerThermalDamageOverTime")
	createAndroidSEGrenade("DCO.AndroidGrenadeIncendiaryHoming", "Items.GrenadeIncendiaryHoming", 1.5, "BaseStats.ThermalDamage", "Attacks.EnemyNetrunnerThermalDamageOverTime")
	
	createAndroidDamageGrenade("DCO.AndroidGrenadeCutting", "Items.GrenadeCuttingRegular", 0.4)
	TweakDB:SetFlat("DCO.AndroidGrenadeCutting_inline0.hitCooldown", 0.8, 'Float')
	TweakDB:SetFlat("DCO.AndroidGrenadeCutting.isContinuousEffect", true)
	TweakDB:SetFlat("DCO.AndroidGrenadeCutting.delayToDetonate", 2.0, 'Float')
	TweakDB:SetFlat("DCO.AndroidGrenadeCutting.numberOfHitsForAdditionalAttack", 5, 'Int')
	freeflats = {"addAxisRotationDelay", "addAxisRotationSpeedMax", "addAxisRotationSpeedMin", "effectCooldown", "freezeDelayAfterBounce", "minimumDistanceFromFloor", "stopAttackDelay"}
	for i,v in ipairs(freeflats) do
		TweakDB:SetFlat("DCO.AndroidGrenadeCutting."..v, TweakDB:GetFlat("Items.GrenadeCuttingRegular."..v), 'Float')
	end
	
	-----------------------------------------------------------------------------------------
	----------------------------ANDROID NETRUNNERS-------------------------------------------
	-----------------------------------------------------------------------------------------
	
	
	----------------------------ANDROID NETRUNNER AI-----------------------------------------
	
	--Adjust map
	for i=1, DroneRecords do
		TweakDB:SetFlat("DCO.Tier1AndroidNetrunner"..i..".actionMap", "CorpoNetrunner.Map")
	end
	
	
	------------------------------------STANDING CONDITIONS--------------------------------
	TweakDB:CloneRecord("DCO.HumanHackSelectorCondition", "Condition.HackSelectorCondition")
	addToList("DCO.HumanHackSelectorCondition.AND", "Condition.Human")
	
	TweakDB:CreateRecord("DCO.AndroidHackSelectorCondition", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.AndroidHackSelectorCondition.AND", {"Condition.AbilityCanQuickhack", "Condition.CombatTarget", "Condition.TargetAbove7m", "Condition.NotIsUsingOffMeshLink", "Condition.TargetNotPlayerFollower", "Condition.Android", "DCO.NetrunnerHackCooldownCond", "DCO.IsDCO"})
	
	TweakDB:CreateRecord("DCO.HackSelectorCondition", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.HackSelectorCondition.OR", {"DCO.AndroidHackSelectorCondition", "DCO.HumanHackSelectorCondition"})
	
	TweakDB:SetFlat("Condition.HackSelectorCondition.AND", {"DCO.HackSelectorCondition"})
	
	------------------------------------COVER CONDITIONS---------------------------------------
	
	TweakDB:CloneRecord("DCO.HumanCoverHackSelectorCondition", "Condition.CoverHackSelectorCondition")
	addToList("DCO.HumanCoverHackSelectorCondition.AND", "Condition.Human")
	
	TweakDB:CreateRecord("DCO.AndroidCoverHackSelectorCondition", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.AndroidCoverHackSelectorCondition.AND", {"Condition.AbilityCanQuickhack", "Condition.CombatTarget", "Condition.TargetAbove7m", "Condition.InCover", "Condition.TargetNotPlayerFollower", "Condition.Android", "DCO.NetrunnerHackCooldownCond", "DCO.IsDCO"})
	
	TweakDB:CreateRecord("DCO.CoverHackSelectorCondition", "gamedataAIActionOR_Record")
	TweakDB:SetFlat("DCO.CoverHackSelectorCondition.OR", {"DCO.AndroidCoverHackSelectorCondition", "DCO.HumanCoverHackSelectorCondition"})
	
	TweakDB:SetFlat("Condition.CoverHackSelectorCondition.AND", {"DCO.CoverHackSelectorCondition"})
	
	
	----------------------------------------BASE COOLDOWNS-------------------------------------
	TweakDB:CreateRecord("DCO.NetrunnerHackCooldown", "gamedataAIActionCooldown_Record")
	TweakDB:SetFlatNoUpdate("DCO.NetrunnerHackCooldown.duration", 8)
	TweakDB:SetFlat("DCO.NetrunnerHackCooldown.name", "ThrowGrenade")
	
	TweakDB:CreateRecord("DCO.NetrunnerHackCooldownCond", "gamedataAICooldownCond_Record")
	TweakDB:SetFlat("DCO.NetrunnerHackCooldownCond.cooldowns", {"DCO.NetrunnerHackCooldown"})


	--All hacks cooldowns
	createHackCooldown("DCO.DamageHackCooldown", "NetrunnerActions.HackOverheat_inline0", 40)
	createHackCooldown("DCO.ContagionHackCooldown", "NetrunnerActions.HackOverload_inline0", 40)
	createHackCooldown("DCO.BlindHackCooldown", "NetrunnerActions.HackBuffCamo_inline0", 40)
	createHackCooldown("DCO.CrippleHackCooldown", "NetrunnerActions.HackLocomotion_inline0", 40)
	createHackCooldown("DCO.WeaponHackCooldown", "NetrunnerActions.HackWeaponMalfunction_inline0", 40)
	createHackCooldown("DCO.CyberpsychosisHackCooldown", "NetrunnerActions.HackDeath_inline0", 180)
	createHackCooldown("DCO.GrenadeHackCooldown", "NetrunnerActions.BuffSturdiness_inline0", 90)

	----------------------------------ADD HACKS TO AI----------------------------------------------
	hacklist = {"DCO.AndroidMadness", "DCO.AndroidOverload", "DCO.AndroidSynapseBurnout", "DCO.AndroidContagion", "DCO.AndroidOverheat", "DCO.AndroidWeaponJam", "DCO.AndroidBlind", "DCO.AndroidCripple"}
	coverhacklist = {"DCO.AndroidCoverMadness", "DCO.AndroidCoverOverload", "DCO.AndroidCoverSynapseBurnout", "DCO.AndroidCoverContagion", "DCO.AndroidCoverOverheat", "DCO.AndroidCoverWeaponJam", "DCO.AndroidCoverBlind", "DCO.AndroidCoverCripple"}	
	
	addListToList("NetrunnerActions.HackActionSelector", "actions", hacklist)
	addListToList("NetrunnerActions.CoverHackSelector", "actions", coverhacklist)
	addListToList("NetrunnerActions.CommandCoverHackSelector", "actions", coverhacklist)

	-------------------------------VARIOUS CONDTIONS------------------------------------------
	createSEHackCond("DCO.NotTargetHasMadness", "BaseStatusEffect.Madness")
	createSEHackCond("DCO.NotTargetHasAndroidOverheatSE", "DCO.AndroidOverheatSE")
	createSEHackCond("DCO.NotTargetHasAndroidOverloadSE", "DCO.AndroidOverloadSE")
	createSEHackCond("DCO.NotTargetHasAndroidContagionSE", "DCO.AndroidContagionSE")
	createSEHackCond("DCO.NotTargetHasWeaponMalfunction", "BaseStatusEffect.WeaponMalfunction")
	createSEHackCond("DCO.NotTargetHasAndroidBlindSE", "DCO.AndroidBlindSE")
	createSEHackCond("DCO.NotTargetHasAndroidCrippleSE", "DCO.AndroidCrippleSE")

	DamageSEList = {"DCO.NotTargetHasMadness", "DCO.NotTargetHasAndroidOverheatSE", "DCO.NotTargetHasAndroidOverloadSE", "DCO.NotTargetHasAndroidContagionSE"}
	
	ControlSEList = {"DCO.NotTargetHasMadness", "DCO.NotTargetHasWeaponMalfunction", "DCO.NotTargetHasAndroidBlindSE", "DCO.NotTargetHasAndroidCrippleSE"}
	
	--Base hack cooldown
	TweakDB:CreateRecord("DCO.NetrunnerHackCooldown", "gamedataAIActionCooldown_Record")
	TweakDB:SetFlatNoUpdate("DCO.NetrunnerHackCooldown.duration", 8)
	TweakDB:SetFlat("DCO.NetrunnerHackCooldown.name", "ThrowGrenade")
	
	TweakDB:CreateRecord("DCO.NetrunnerHackCooldown_inline0", "gamedataAICooldownCond_Record")
	TweakDB:SetFlat("DCO.NetrunnerHackCooldown_inline0.cooldowns", {"DCO.NetrunnerHackCooldown"})
	
	----------------------------ANDROID OVERHEAT---------------------------------------------
	createAndroidHack("DCO.AndroidOverheat", "DCO.AndroidOverheatSE", 5, "DCO.ContagionHackCooldown")
	createHackStatusEffect("DCO.AndroidOverheatSE", "AIQuickHackStatusEffect.HackOverheat", 10)
	createContinuousAttack("DCO.AndroidOverheatSE", "BaseStats.ThermalDamage", "Attacks.EnemyNetrunnerThermalDamageOverTime", 0.1)
	addStatusEffectNotPresentCond("DCO.AndroidOverheat_inline5", "DCO.AndroidOverheatSE")
	
	---------------------------ANDROID OVERLOAD---------------------------------------------
	createAndroidHack("DCO.AndroidOverload", "DCO.AndroidOverloadSE", 5, "DCO.ContagionHackCooldown")
	createHackStatusEffect("DCO.AndroidOverloadSE", "BaseStatusEffect.OverloadLevel2", 10)
	createContinuousAttack("DCO.AndroidOverloadSE", "BaseStats.ElectricDamage", "Attacks.OverloadQuickHackAttackLevel1", 0.1)
	addStatusEffectNotPresentCond("DCO.AndroidOverload_inline5", "DCO.AndroidOverloadSE")

	--Make the icon show up on NPCs
	TweakDB:CloneRecord("DCO.AndroidOverloadSEUIData", "BaseStatusEffect.Electrocuted_inline23")
	TweakDB:SetFlat("DCO.AndroidOverloadSEUIData.priority", -9) 
	TweakDB:SetFlat("DCO.AndroidOverloadSE.uiData", "DCO.AndroidOverloadSEUIData")
	
	--Add a check if they are a robot
	TweakDB:CloneRecord("DCO.TargetIsRobot", "Condition.Android")
	TweakDB:SetFlatNoUpdate("DCO.TargetIsRobot.target", "AIActionTarget.CombatTarget")
	TweakDB:SetFlat("DCO.TargetIsRobot.allowedNPCTypes", {"NPCType.Android", "NPCType.Drone", "NPCType.Mech"})
	
	addToList("DCO.AndroidOverload_inline5.AND", "DCO.TargetIsRobot")
	
	-------------------------ANDROID SYNAPSE BURNOUT----------------------------------------
	createAndroidHack("DCO.AndroidSynapseBurnout", "BaseStatusEffect.BrainMeltLevel2", 5, "DCO.DamageHackCooldown")
	
	--Prereq that target is low hp
	addToList("DCO.AndroidSynapseBurnout_inline5.AND", "DCO.AndroidSynapseBurnoutLowHPCond")
	TweakDB:CloneRecord("DCO.AndroidSynapseBurnoutLowHPCond", "Condition.HealthBelow50perc")
	TweakDB:SetFlat("DCO.AndroidSynapseBurnoutLowHPCond.target", "AIActionTarget.CombatTarget")
	
	------------------------ANDROID CONTAGION----------------------------------------------
	createAndroidHack("DCO.AndroidContagion", "DCO.AndroidContagionSE", 5, "DCO.ContagionHackCooldown")
	createHackStatusEffect("DCO.AndroidContagionSE", "BaseStatusEffect.Poisoned", 20)
	createContinuousAttack("DCO.AndroidContagionSE", "BaseStats.ChemicalDamage", "Attacks.ContagionPoisonAttack", 0.05)
	addStatusEffectNotPresentCond("DCO.AndroidContagion_inline5", "DCO.AndroidContagionSE")

	--Make sure it's on humans only
	TweakDB:CloneRecord("DCO.TargetIsHuman", "Condition.Android")
	TweakDB:SetFlatNoUpdate("DCO.TargetIsHuman.target", "AIActionTarget.CombatTarget")
	TweakDB:SetFlat("DCO.TargetIsHuman.allowedNPCTypes", {"NPCType.Human"})
	
	--High HP req
	TweakDB:CloneRecord("DCO.AndroidContagionHighHPCond", "Condition.HealthAbove75perc")
	TweakDB:SetFlat("DCO.AndroidContagionHighHPCond.target", "AIActionTarget.CombatTarget")
	
	--High hp humans only
	addListToList("DCO.AndroidContagion_inline5", "AND", {"DCO.TargetIsHuman", "DCO.AndroidContagionHighHPCond"})
	
	----------------------------ANDROID WEAPON JAM---------------------------------------------
	createAndroidHack("DCO.AndroidWeaponJam", "DCO.AndroidWeaponJamSE", 5, "DCO.WeaponHackCooldown")
	createHackStatusEffect("DCO.AndroidWeaponJamSE", "BaseStatusEffect.WeaponMalfunction", 12)
	addStatusEffectNotPresentCond("DCO.AndroidWeaponJam_inline5", "BaseStatusEffect.WeaponMalfunction")
	TweakDB:SetFlat("DCO.AndroidWeaponJam_inline3.statusEffect", "BaseStatusEffect.WeaponMalfunction")

	----------------------------ANDROID BLIND---------------------------------------------
	createAndroidHack("DCO.AndroidBlind", "DCO.AndroidBlindSE", 5, "DCO.BlindHackCooldown")
	createHackStatusEffect("DCO.AndroidBlindSE", "BaseStatusEffect.Blind", 8)
	addStatusEffectNotPresentCond("DCO.AndroidBlind_inline5", "DCO.AndroidBlindSE")

	----------------------------ANDROID CRIPPLE---------------------------------------------
	createAndroidHack("DCO.AndroidCripple", "DCO.AndroidCrippleSE", 5, "DCO.CrippleHackCooldown")
	createHackStatusEffect("DCO.AndroidCrippleSE", "BaseStatusEffect.LocomotionMalfunction", 12)
	addStatusEffectNotPresentCond("DCO.AndroidCripple_inline5", "DCO.AndroidCrippleSE")
	
	----------------------------ANDROID MADNESS--------------------------------------------
	
	--This is actually System Reset, just didn't wanna change the name
	
	createAndroidHack("DCO.AndroidMadness", "DCO.AndroidMadnessSE", 5, "DCO.CyberpsychosisHackCooldown")
	createHackStatusEffect("DCO.AndroidMadnessSE", "BaseStatusEffect.Madness", 60)
	TweakDB:SetFlat("DCO.AndroidMadness_inline3.statusEffect", "BaseStatusEffect.SystemCollapse")

	--Add a check if they are a robot but not a mech
	TweakDB:CloneRecord("DCO.TargetIsRobotNoMech", "Condition.Android")
	TweakDB:SetFlatNoUpdate("DCO.TargetIsRobotNoMech.target", "AIActionTarget.CombatTarget")
	TweakDB:SetFlat("DCO.TargetIsRobotNoMech.allowedNPCTypes", {"NPCType.Android", "NPCType.Drone"})
	
	--Apply to robots only
	addToList("DCO.AndroidMadness_inline5.AND", "DCO.TargetIsRobotNoMech")
	
	---------------------------COVER VERSIONS------------------------------------------
	createAndroidCoverHack("DCO.AndroidCoverOverheat", "DCO.AndroidOverheat")
	createAndroidCoverHack("DCO.AndroidCoverOverload", "DCO.AndroidOverload")
	createAndroidCoverHack("DCO.AndroidCoverContagion", "DCO.AndroidContagion")
	createAndroidCoverHack("DCO.AndroidCoverSynapseBurnout", "DCO.AndroidSynapseBurnout")
	createAndroidCoverHack("DCO.AndroidCoverWeaponJam", "DCO.AndroidWeaponJam")
	createAndroidCoverHack("DCO.AndroidCoverCripple", "DCO.AndroidCripple")
	createAndroidCoverHack("DCO.AndroidCoverBlind", "DCO.AndroidBlind")
	createAndroidCoverHack("DCO.AndroidCoverMadness", "DCO.AndroidMadness")

	--------------------------REMOVE CONNECTION LINK-------------------------------------
	
	
	Observe('ScriptedPuppet', 'OnNetworkLinkQuickhackEvent', function(self, evt)
		runner = Game.FindEntityByID(evt.netrunnerID)
		if TweakDBInterface.GetCharacterRecord(runner:GetRecordID()):TagsContains(CName.new("Robot")) then
			Cron.After(5, function()
				self:GetPS():DrawBetweenEntities(false, true, self:GetFxResourceByKey(CName.new("pingNetworkLink")), evt.to, evt.from, false, false, false, false)
			end)
		end
	end)

	---------------------------FIX SINGLE HACK PER TARGET BUG---------------------------
	TweakDB:SetFlat("AIQuickHackStatusEffect.BeingHacked_inline1.value", 5)
	
	
	--------------------------DISABLE REGULAR HACK ACTIONS FOR ANDROIDS-----------------
	
	disableList = {"Death", "Locomotion", "Overheat", "Overload", "WeaponMalfunction"}
	for i,v in ipairs(disableList) do
		addToList("NetrunnerActions.Hack"..v.."_inline2.AND", "Condition.Human")
	end

end
function createFlyingDroneSandevistanAbility(recordName, toClone, slowtime, duration, conditionList)
	TweakDB:CloneRecord(recordName, toClone)
	TweakDB:SetFlatNoUpdate(recordName..".activationCondition", recordName.."_inline1")
	TweakDB:SetFlat(recordName..".subActions", {recordName.."_inline0"})
	
	--Slowtime
	TweakDB:CreateRecord(recordName.."_inline0", "gamedataAISubActionApplyTimeDilation_Record")
	TweakDB:SetFlatNoUpdate(recordName.."_inline0.duration", duration)
	TweakDB:SetFlatNoUpdate(recordName.."_inline0.multiplier", slowtime)
	TweakDB:SetFlatNoUpdate(recordName.."_inline0.easeOut","KereznikovDodgeEaseOut")
	TweakDB:SetFlat(recordName.."_inline0.overrideMultiplerWhenPlayerInTimeDilation", 3)

	--Conditions
	TweakDB:CreateRecord(recordName.."_inline1", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat(recordName.."_inline1.condition", recordName.."_inline2")
	
	TweakDB:CreateRecord(recordName.."_inline3", "gamedataAIActionAND_Record")
	TweakDB:SetFlat(recordName.."_inline3.AND", conditionList)
	
end
function createOnHitEffect(recordName, duration)

	--Status effect
	TweakDB:CreateRecord(recordName.."OnHitSE", "gamedataStatusEffect_Record") 
	TweakDB:SetFlatNoUpdate(recordName.."OnHitSE.duration", recordName.."OnHitSE_inline0")
	TweakDB:SetFlatNoUpdate(recordName.."OnHitSE.isAffectedByTimeDilationNPC", true)
	TweakDB:SetFlatNoUpdate(recordName.."OnHitSE.isAffectedByTimeDilationPlayer", true)
	TweakDB:SetFlatNoUpdate(recordName.."OnHitSE.savable", true)
	TweakDB:SetFlat(recordName.."OnHitSE.statusEffectType", "BaseStatusEffectTypes.Misc")

	TweakDB:CreateRecord(recordName.."OnHitSE_inline0", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate(recordName.."OnHitSE_inline0.statModsLimit", -1)
	TweakDB:SetFlat(recordName.."OnHitSE_inline0.statModifiers", {recordName.."OnHitSE_inline1"})
	
	createConstantStatModifier(recordName.."OnHitSE_inline1", "Additive", "BaseStats.MaxDuration", duration)
	
	--Ability
	TweakDB:CreateRecord(recordName.."OnHit", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat(recordName.."OnHit.abilityPackage", recordName.."OnHit_inline0")
	
	TweakDB:CreateRecord(recordName.."OnHit_inline0", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat(recordName.."OnHit_inline0.effectors", {recordName.."OnHit_inline1"})
	
	
	--camo
	TweakDB:CreateRecord(recordName.."OnHit_inline1", "gamedataApplyStatusEffectEffector_Record")
	TweakDB:SetFlatNoUpdate(recordName.."OnHit_inline1.count", 1)
	TweakDB:SetFlatNoUpdate(recordName.."OnHit_inline1.effectorClassName", "ApplyStatusEffectEffector")
	TweakDB:SetFlatNoUpdate(recordName.."OnHit_inline1.statusEffect", recordName.."OnHitSE")
	TweakDB:SetFlat(recordName.."OnHit_inline1.prereqRecord", recordName.."OnHit_inline2")


	--prereq
	TweakDB:CreateRecord(recordName.."OnHit_inline2", "gamedataMultiPrereq_Record")
	TweakDB:SetFlat(recordName.."OnHit_inline2.aggregationType", "AND")
	TweakDB:SetFlat(recordName.."OnHit_inline2.nestedPrereqs", {recordName.."OnHit_inline3"})
	TweakDB:SetFlat(recordName.."OnHit_inline2.prereqClassName", "gameMultiPrereq")

	--on hit
	TweakDB:CloneRecord(recordName.."OnHit_inline3", "Items.ElectroshockMechanismEffector_inline0")
	
end
function fastTravelTeleport()
	pos = Game.GetPlayer():GetWorldPosition()
	pos.x = pos.x-0.2 
	
	for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
		if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not (v:GetNPCType() == gamedataNPCType.Mech) and not v:IsDead() then
			cmd = AITeleportCommand:new() 

			cmd.position = pos 
			cmd.doNavTest = false 
			AIComponent.SendCommand(v, cmd)
			if (v:GetNPCType() == gamedataNPCType.Drone) then
				v:QueueEvent(CreateForceRagdollEvent(CName.new("ForceRagdollTask")))
			end

			pos.x = pos.x + 0.1
		end
	end
	
	--[[
	--Keep teleporting them bc apparently there's a bug
	for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
		if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not (v:GetNPCType() == gamedataNPCType.Mech) and not v:IsDead() then
			posx = v:GetWorldPosition().x
			print(math.abs(posx, pos.x))
			if math.abs(posx - pos.x) >30 then
				fastTravelTeleport()
				return
			end
		end
	end]]
end
function createDroneEquipment(recordName, basicweapon, advancedweapon)
	--Create primary equipment
	TweakDB:CreateRecord(recordName.."PrimaryEquipment", "gamedataNPCEquipmentGroup_Record")
	TweakDB:SetFlat(recordName.."PrimaryEquipment.equipmentItems", {recordName.."PrimaryPool"})
	
	TweakDB:CreateRecord(recordName.."PrimaryPool", "gamedataNPCEquipmentItemPool_Record")
	TweakDB:SetFlat(recordName.."PrimaryPool.pool", {recordName.."PrimaryPoolEntryBasic", recordName.."PrimaryPoolEntryAdvanced"})
	
	--Basic equipment
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryBasic", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryBasic.weight", 1)
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryBasic.items", {recordName.."PrimaryPoolEntryBasic_inline1"})
	
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryBasic_inline1", "gamedataNPCEquipmentItem_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryBasic_inline1.equipSlot", "AttachmentSlots.WeaponRight")
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryBasic_inline1.item", basicweapon)
	
	--Advanced equipment
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryAdvanced", "gamedataNPCEquipmentItemsPoolEntry_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryAdvanced.weight", 69420)
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryAdvanced.items", {recordName.."PrimaryPoolEntryAdvanced_inline1"})
	
	TweakDB:CreateRecord(recordName.."PrimaryPoolEntryAdvanced_inline1", "gamedataNPCEquipmentItem_Record")
	TweakDB:SetFlatNoUpdate(recordName.."PrimaryPoolEntryAdvanced_inline1.equipSlot", "AttachmentSlots.WeaponRight")
	TweakDB:SetFlat(recordName.."PrimaryPoolEntryAdvanced_inline1.item", advancedweapon)
	
end
function createExplosiveDroneWeapon(recordName, weaponClone, effectClone, projectileClone, explodeClone, bulletDamage, explosionDamage)

	TweakDB:CloneRecord(recordName, weaponClone)
	TweakDB:SetFlatNoUpdate(recordName..".rangedAttacks", recordName.."_inline0") 
	
	addListToList(recordName, "attacks", {recordName.."_inline2", recordName.."_inline3"})
	
	TweakDB:CreateRecord(recordName.."_inline0", "gamedataRangedAttackPackage_Record")
	TweakDB:SetFlatNoUpdate(recordName.."_inline0.chargeFire", recordName.."_inline1")
	TweakDB:SetFlat(recordName.."_inline0.defaultFire", recordName.."_inline1")

	TweakDB:CreateRecord(recordName.."_inline1", "gamedataRangedAttack_Record")
	TweakDB:SetFlatNoUpdate(recordName.."_inline1.NPCAttack", recordName.."_inline3")
	TweakDB:SetFlatNoUpdate(recordName.."_inline1.NPCTimeDilated", recordName.."_inline2")
	TweakDB:SetFlatNoUpdate(recordName.."_inline1.playerAttack", recordName.."_inline3")
	TweakDB:SetFlat(recordName.."_inline1.playerTimeDilated", recordName.."_inline2")

	TweakDB:CloneRecord(recordName.."_inline2", projectileClone)
	TweakDB:SetFlat(recordName.."_inline2.explosionAttack", recordName.."_inline4")
	TweakDB:SetFlat(recordName.."_inline2.hitCooldown", 0.1)
	addToList(recordName.."_inline2.statModifiers", recordName.."_inline6")

	TweakDB:CloneRecord(recordName.."_inline3", effectClone)
	TweakDB:SetFlat(recordName.."_inline3.explosionAttack", recordName.."_inline4")
	addToList(recordName.."_inline3.statModifiers", recordName.."_inline6")

	TweakDB:CloneRecord(recordName.."_inline4", explodeClone)
	--TweakDB:SetFlatNoUpdate(recordName.."_inline4.hitFlags", {})
	TweakDB:SetFlatNoUpdate(recordName.."_inline4.playerIncomingDamageMultiplier", 1)
	TweakDB:SetFlatNoUpdate(recordName.."_inline4.range", 2)
	addToList(recordName.."_inline4.statModifiers", recordName.."_inline5")
	
	createConstantStatModifier(recordName.."_inline5", "Multiplier", "BaseStats.PhysicalDamage", explosionDamage)
	createConstantStatModifier(recordName.."_inline6", "Multiplier", "BaseStats.PhysicalDamage", bulletDamage)
end
function createAndroidSandevistanDash(recordName, toClone)
	TweakDB:CloneRecord(recordName, toClone)
	TweakDB:SetFlatNoUpdate(recordName..".activationCondition", recordName.."_inline2")
	TweakDB:SetFlat(recordName..".animData", recordName.."_inline0")
	
	--Anim stuff
	TweakDB:CloneRecord(recordName.."_inline0", TweakDB:GetFlat(toClone..".animData"))
	TweakDB:SetFlat(recordName.."_inline0.animVariationSubAction", recordName.."_inline1")
	
	TweakDB:CreateRecord(recordName.."_inline1", "gamedataAISubActionRandomize_Record")
	TweakDB:SetFlat(recordName.."_inline1.animVariationRandomize", {0, 0})
	
	--Android condition
	TweakDB:CloneRecord(recordName.."_inline2", TweakDB:GetFlat(toClone..".activationCondition"))
	TweakDB:SetFlat(recordName.."_inline2.condition", recordName.."_inline3")
	
	TweakDB:CloneRecord(recordName.."_inline3", TweakDB:GetFlat(TweakDB:GetFlat(toClone..".activationCondition")..'.condition'))
	addToList(recordName.."_inline3.AND", "Condition.Android")
end
function createAndroidSEGrenade(recordName, toClone, damage, damageType, attackRecord)
	TweakDB:CloneRecord(recordName, toClone)
	TweakDB:SetFlatNoUpdate(recordName..".deliveryMethod", "DCO.HomingGDM")
	TweakDB:SetFlat(recordName..".attack", recordName.."_inline0")
	
	TweakDB:CloneRecord(recordName.."_inline0", TweakDB:GetFlat(toClone..".attack"))
	TweakDB:SetFlat(recordName.."_inline0.statusEffects", {recordName.."_inline1"})
	
	TweakDB:CloneRecord(recordName.."_inline1", gf(gf(toClone..".attack")..'.statusEffects')[1])
	TweakDB:SetFlat(recordName.."_inline1.statusEffect", recordName.."_inline2")

	TweakDB:CloneRecord(recordName.."_inline2", gf(gf(gf(toClone..".attack")..'.statusEffects')[1]..'.statusEffect'))
	addToList(recordName.."_inline2.packages", recordName.."_inline3")
	
	TweakDB:CreateRecord(recordName.."_inline3", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat(recordName.."_inline3.effectors", {recordName.."_inline4"})
	
	TweakDB:CloneRecord(recordName.."_inline4", "BaseStatusEffect.LightPoision_inline9")
	TweakDB:SetFlat(recordName.."_inline4.attackRecord", recordName.."_inline5")
	
	TweakDB:CloneRecord(recordName.."_inline5", attackRecord)
	addToList(recordName.."_inline5.statModifiers", recordName.."_inline6")
	
	createConstantStatModifier(recordName.."_inline6", "Multiplier", damageType, damage)
end
function gf(flat)
	return TweakDB:GetFlat(flat)
end
function createAndroidDamageGrenade(recordName, toClone, damage)
	TweakDB:CloneRecord(recordName, toClone)
	TweakDB:SetFlat(recordName..".attack", recordName.."_inline0")
	
	TweakDB:CloneRecord(recordName.."_inline0", TweakDB:GetFlat(toClone..".attack"))
	addToList(recordName.."_inline0.statModifiers", recordName.."_inline1")
	
	createConstantStatModifier(recordName.."_inline1", "Multiplier", "BaseStats.PhysicalDamage", damage)
end
function createTargetHPCondition(recordName, maxhp, minhp)
	TweakDB:CreateRecord(recordName, "gamedataAIStatPoolCond_Record")
	TweakDB:SetFlatNoUpdate(recordName..".isIncreasing", -1)
	perc = Vector2:new()
	perc.X=minhp
	perc.Y=maxhp
	TweakDB:SetFlatNoUpdate(recordName..".percentage", perc)
	TweakDB:SetFlatNoUpdate(recordName..".statPool", "BaseStatPools.Health")
	TweakDB:SetFlat(recordName..".target", "AIActionTarget.CombatTarget")
end
function createAndroidGrenadeAction(recordName, toClone, grenade, conditionstemp, cooldownName)
	local conditions = {}
	for i,v in ipairs(conditionstemp) do
		table.insert(conditions, v)
	end
	
	--Base action record
	TweakDB:CloneRecord(recordName, toClone)
	TweakDB:SetFlatNoUpdate(recordName..".activationCondition", recordName.."_inline1")
	TweakDB:SetFlatNoUpdate(recordName..".tickets", {})
	TweakDB:SetFlatNoUpdate(recordName..".cooldowns", {recordName.."_inline3", "DCO.ThrowGrenadeCooldown"})
	TweakDB:SetFlat(recordName..".startupSubActions", {recordName.."_inline0"})
	
	--Grenade force equip
	TweakDB:CloneRecord(recordName.."_inline0", TweakDB:GetFlat(toClone..".startupSubActions")[1])
	TweakDB:SetFlat(recordName.."_inline0.itemID", grenade)
	
	--Make condition
	TweakDB:CreateRecord(recordName.."_inline1", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat(recordName.."_inline1.condition", recordName.."_inline2")
	
	table.insert(conditions, recordName.."_inline4")
	table.insert(conditions, "DCO.ThrowGrenadeCooldown_inline0")
	TweakDB:CreateRecord(recordName.."_inline2", "gamedataAIActionAND_Record")
	TweakDB:SetFlat(recordName.."_inline2.AND", conditions)
	
	--Make cooldown
	TweakDB:CreateRecord(recordName.."_inline3", "gamedataAIActionCooldown_Record")
	TweakDB:SetFlatNoUpdate(recordName.."_inline3.duration", 60)
	TweakDB:SetFlat(recordName.."_inline3.name", cooldownName)
	
	TweakDB:CreateRecord(recordName.."_inline4", "gamedataAICooldownCond_Record")
	TweakDB:SetFlat(recordName.."_inline4.cooldowns", {recordName.."_inline3"})
	
end
function createSEHackCond(recordName, SE)
	TweakDB:CreateRecord(recordName, "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate(recordName..".statusEffect", SE)
	TweakDB:SetFlatNoUpdate(recordName..".invert", true)
	TweakDB:SetFlat(recordName..".target", "AIActionTarget.CombatTarget")

end
function addStatusEffectNotPresentCond(condition, SE)
	TweakDB:CreateRecord(condition.."SECond", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate(condition.."SECond.statusEffect", SE)
	TweakDB:SetFlatNoUpdate(condition.."SECond.invert", true)
	TweakDB:SetFlat(condition.."SECond.target", "AIActionTarget.CombatTarget")

	addToList(condition..".AND", condition.."SECond")
end
function makeSpreadEffectors(objectAction, count)

	--Clone all the initial object actions
	createConstantStatModifier(objectAction.."SpreadTime", "Additive", "BaseStats.MaxDuration", 1)
	for i=1, count do
		TweakDB:CloneRecord(objectAction..i, objectAction)
		TweakDB:SetFlat(objectAction..i..".activationTime", {objectAction.."SpreadTime"})
		TweakDB:SetFlat(objectAction..i..".isQuickHack", true)
	end
	
	--First has to be separate
	addToList(objectAction..".completionEffects", objectAction.."Effect") --add to completion effects
		
	TweakDB:CloneRecord(objectAction.."Effect", "QuickHack.MadnessLvl3Hack_inline1") --effect triggerer
	TweakDB:SetFlat(objectAction.."Effect"..".effectorToTrigger", objectAction.."Effect".."SpreadEffector")
		
	TweakDB:CloneRecord(objectAction.."Effect".."SpreadEffector", "QuickHack.MadnessLvl3Hack_inline2") --spread effector
	--TweakDB:SetFlat(objectAction.."Effect".."SpreadEffector.spreadDistance", 16, 'Int')
	TweakDB:SetFlat(objectAction.."Effect".."SpreadEffector.objectAction", objectAction.."1")

	for i=1,(count-1) do
		addToList(objectAction..i..".completionEffects", objectAction.."Effect"..i) --add to completion effects
		
		TweakDB:CloneRecord(objectAction.."Effect"..i, "QuickHack.MadnessLvl3Hack_inline1") --effect triggerer
		TweakDB:SetFlat(objectAction.."Effect"..i..".effectorToTrigger", objectAction.."Effect"..i.."SpreadEffector")
		
		TweakDB:CloneRecord(objectAction.."Effect"..i.."SpreadEffector", "QuickHack.MadnessLvl3Hack_inline2") --spread effector
		TweakDB:SetFlat(objectAction.."Effect"..i.."SpreadEffector.objectAction", objectAction..(i+1))
		--TweakDB:SetFlat(objectAction.."Effect"..i.."SpreadEffector.spreadDistance", 16, 'Int')
	end

	
end
function createHackCooldown(recordName, baseRecord, cooldown)
	TweakDB:CloneRecord(recordName, baseRecord)
	TweakDB:SetFlat(recordName..".duration", cooldown)
end
function createContinuousAttack(SE, damageType, attackRecord, strength)
	TweakDB:SetFlat(SE..".packages", {SE.."_inline0"})
	
	TweakDB:CloneRecord(SE.."_inline0", "AIQuickHackStatusEffect.HackOverheat_inline0")
	TweakDB:SetFlat(SE.."_inline0.effectors", {SE.."_inline1"})
	
	TweakDB:CloneRecord(SE.."_inline1", "AIQuickHackStatusEffect.HackOverheat_inline1")
	TweakDB:SetFlatNoUpdate(SE.."_inline1.prereqRecord", "Prereqs.AlwaysTruePrereq")
	TweakDB:SetFlat(SE.."_inline1.attackRecord", SE.."_inline2")
	
	TweakDB:CloneRecord(SE.."_inline2", attackRecord)
	TweakDB:SetFlatNoUpdate(SE.."_inline2.effectName", "damage_over_time")
	TweakDB:SetFlatNoUpdate(SE.."_inline2.effectTag", "default")
	TweakDB:SetFlat(SE.."_inline2.statModifiers", {SE.."_inline3", SE.."_inline4"})
	
	TweakDB:CloneRecord(SE.."_inline3", "Character.NPC_Base_Curves_inline1")
	TweakDB:SetFlatNoUpdate(SE.."_inline3.refObject", "Root")
	TweakDB:SetFlat(SE.."_inline3.statType", damageType)
	
	createConstantStatModifier(SE.."_inline4", "Multiplier", damageType, strength)
end
function createHackStatusEffect(recordName, cloneSE, duration)

	TweakDB:CloneRecord(recordName, cloneSE)
	TweakDB:SetFlatNoUpdate(recordName..".gameplayTags", {"Debuff", "NPCQuickhack"})
	TweakDB:SetFlat(recordName..".duration", recordName.."Duration")
	
	TweakDB:CreateRecord(recordName.."Duration", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate(recordName.."Duration.statModsLimit", -1)
	TweakDB:SetFlat(recordName.."Duration.statModifiers", {recordName.."DurationStat"})
	createConstantStatModifier(recordName.."DurationStat", "Additive", "BaseStats.MaxDuration", duration)
	
end
function createAndroidCoverHack(recordName, toClone)
	TweakDB:CloneRecord(recordName, toClone)
	TweakDB:SetFlatNoUpdate(recordName..".animData", gf("NetrunnerActions.CoverHackOverheat.animData"))
	TweakDB:SetFlatNoUpdate(recordName..".recovery", gf("NetrunnerActions.CoverHackOverheat.recovery"))
	TweakDB:SetFlatNoUpdate(recordName..".startup", gf("NetrunnerActions.CoverHackOverheat.startup"))
	TweakDB:SetFlatNoUpdate(recordName..".subActions", gf("NetrunnerActions.CoverHackOverheat.subActions"))
	TweakDB:SetFlat(recordName..".loop", recordName.."_inline0")

	--Make new loop
	TweakDB:CloneRecord(recordName.."_inline0", "NetrunnerActions.CoverHackAction_inline5")
	TweakDB:SetFlat(recordName.."_inline0.toNextPhaseCondition", {recordName.."_inline1"})
	
	TweakDB:CreateRecord(recordName.."_inline1", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat(recordName.."_inline1.condition", recordName.."_inline2")
	
	TweakDB:CloneRecord(recordName.."_inline2", "NetrunnerActions.CoverHackAction_inline8")
	addToList(recordName.."_inline2.OR", toClone.."_inline9")
	
	--Dont forget about cooldown cond removal below addToList
	--CorpoNetrunner.CoverDeactivationCondition, replace other thingy in OR record w/ this
end
function createAndroidHack(recordName, statusEffect, uploadTime, cooldown)

	--Action
	TweakDB:CloneRecord(recordName, "NetrunnerActions.HackOverheat")
	TweakDB:SetFlatNoUpdate(recordName..".activationCondition", recordName.."_inline4")
	TweakDB:SetFlatNoUpdate(recordName..".cooldowns", {cooldown, "DCO.NetrunnerHackCooldown"})
	TweakDB:SetFlatNoUpdate(recordName..".tickets", {})
	TweakDB:SetFlatNoUpdate(recordName..".loop", recordName.."_inline6")
	TweakDB:SetFlat(recordName..".loopSubActions", {"NetrunnerActions.HackAction_inline2", "NetrunnerActions.HackAction_inline3", recordName.."_inline0"})
	
	--Loop
	TweakDB:CloneRecord(recordName.."_inline6", "NetrunnerActions.HackAction_inline6")
	TweakDB:SetFlat(recordName.."_inline6.toNextPhaseCondition", {recordName.."_inline7"})
	
	--Loop condition break
	TweakDB:CloneRecord(recordName.."_inline7", "NetrunnerActions.HackAction_inline8")
	TweakDB:SetFlat(recordName.."_inline7.condition", recordName.."_inline8")
	
	TweakDB:CloneRecord(recordName.."_inline8", "NetrunnerActions.HackAction_inline9")
	addToList(recordName.."_inline8.OR", recordName.."_inline9")
	
	TweakDB:CreateRecord(recordName.."_inline9", "gamedataAICooldownCond_Record")
	TweakDB:SetFlat(recordName.."_inline9.cooldowns", {cooldown})
	
	--Condition
	TweakDB:CreateRecord(recordName.."_inline4", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat(recordName.."_inline4.condition", recordName.."_inline5")
	
	TweakDB:CreateRecord(recordName.."_inline5", "gamedataAIActionAND_Record")
	TweakDB:SetFlat(recordName.."_inline5.AND", {"Condition.Android", "DCO.NotTargetHasMadness"})
	
	--Apply object action
	TweakDB:CloneRecord(recordName.."_inline0", "NetrunnerActions.HackOverheat_inline3")
	TweakDB:SetFlat(recordName.."_inline0.actionResult", recordName.."_inline1")
	
	--Object action
	TweakDB:CloneRecord(recordName.."_inline1", "AIQuickHack.HackOverheat")
	TweakDB:SetFlatNoUpdate(recordName.."_inline1.activationTime", {recordName.."_inline2"})
	TweakDB:SetFlat(recordName.."_inline1.completionEffects", {recordName.."_inline3"})
	TweakDB:SetFlat(recordName.."_inline1.isQuickHack", true)
	
	--Upload time
	createConstantStatModifier(recordName.."_inline2", "Additive", "BaseStats.MaxDuration", uploadTime)
	
	--Object action effect
	TweakDB:CloneRecord(recordName.."_inline3", "AIQuickHack.HackOverheat_inline1")
	TweakDB:SetFlat(recordName.."_inline3.statusEffect", statusEffect)
	
	
end

function createEquipAI(recordName, itemType)
	
	TweakDB:CloneRecord(recordName.."", "VehicleActions.EquipAnyRifleFromInventory")
	TweakDB:SetFlat(recordName..".activationCondition", recordName.."_inline0")
	TweakDB:SetFlat(recordName..".loopSubActions", {recordName.."_inline4"})

	TweakDB:CreateRecord(recordName.."_inline0", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat(recordName.."_inline0.condition", recordName.."_inline1")
	
	TweakDB:CreateRecord(recordName.."_inline1", "gamedataAIActionAND_Record")
	TweakDB:SetFlat(recordName.."_inline1.AND", {recordName.."_inline8", recordName.."_inline2"})
	
	TweakDB:CreateRecord(recordName.."_inline2", "gamedataAIActionOR_Record")
	TweakDB:SetFlat(recordName.."_inline2.OR", {recordName.."_inline3", recordName.."_inline5"})
	
	TweakDB:CloneRecord(recordName.."_inline3", "Condition.HasPrimaryEquipmentRifleInInventory")
	TweakDB:SetFlat(recordName.."_inline3.itemType", itemType)

	TweakDB:CloneRecord(recordName.."_inline4", "VehicleActions.EquipAnyRifleFromInventory_inline5")
	TweakDB:SetFlat(recordName.."_inline4.itemType", itemType)

	TweakDB:CreateRecord(recordName.."_inline5", "gamedataAIActionOR_Record")
	TweakDB:SetFlat(recordName.."_inline5.OR", {recordName.."_inline6", recordName.."_inline7"})

	TweakDB:CloneRecord(recordName.."_inline6", "Condition.HasRifle_inline0")
	TweakDB:SetFlat(recordName.."_inline6.itemType", itemType)
	
	TweakDB:CloneRecord(recordName.."_inline7", "Condition.HasRifle_inline1")
	TweakDB:SetFlat(recordName.."_inline7.itemType", itemType)
	
	TweakDB:CloneRecord(recordName.."_inline8", recordName.."_inline5")
	TweakDB:SetFlat(recordName.."_inline8.invert", true)
	
end
return DCO:new()
