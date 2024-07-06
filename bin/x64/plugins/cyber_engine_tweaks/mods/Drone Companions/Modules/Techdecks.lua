R = { 
    description = "DCO"
}
local filename = "DCO/TechDecks"

function DCO:new()




	--------------------------------------------------------------------
	-------------------------TECHACKS-----------------------------------
	---------------------------------------------------------------------
	CName.add("Techdeck")

	--Fix cost bug w/ power levels
	Override('BaseScriptableAction', 'GetPowerLevelDiff', function(self, wrappedMethod)
		targetID = self:GetRequesterID()
		target = Game.FindEntityByID(targetID)
		if target:GetRecord():TagsContains(CName.new("Robot")) then
			return 0
		end
		return wrappedMethod()
	end)
	
	--Remove base cost of 1
	

		Override('BaseScriptableAction', 'GetCost', function(self, wrappedMethod)
			ret = wrappedMethod()
			targetID = self:GetRequesterID()
			target = Game.FindEntityByID(targetID)
			if target:IsNPC() and target:GetRecord():TagsContains(CName.new("Robot")) then
				ret = ret - 1
			end
			return ret	
		end)

	Override('BaseScriptableAction', 'GetBaseCost', function(self, wrappedMethod)
			ret = wrappedMethod()
			targetID = self:GetRequesterID()
			target = Game.FindEntityByID(targetID)
			if target:IsNPC() and target:GetRecord():TagsContains(CName.new("Robot")) then
				ret = ret - 1
			end
			return ret	
		end)
		
	--Base memory cost reduction
	createCombinedStatModifier("DCO.TechHackCostReductionMod", "AdditiveMultiplier", "*", "Player", "DCO.TechHackCostReduction", "BaseStats.Memory", -1)

	----------------------------WAIT--------------------------------------
	
	--Create techhack
	CName.add("DCOWait")
	
	createTechHack("DCO.Wait", "DCOWait", LocKey(10547ull), "ChoiceCaptionParts.BackOutIcon", "DCO.RobotSE", -1, 1, 1, 1, {}, {"Stealth", "Quickhack", "Robot"}, "", "wounded_disabled_icon")
	TweakDB:SetFlat("DCO.Wait.targetPrereqs", {"Prereqs.TargetNotInCombatPrereq"})

	
	--Adjust ai
	--[[
	TweakDB:SetFlat("DroneActions.FollowComposite.nodes", {"DCO.WaitAction", "DroneActions.FollowSprint", "DroneActions.FollowWalk", "GenericArchetype.Success"})
	
	temp = TweakDB:GetFlat("FollowerActions.FollowComposite.nodes")
	if not has_value(temp, TweakDBID.new("DCO.WaitAction")) then
		table.insert(temp, 1, "DCO.WaitAction")
		TweakDB:SetFlat("FollowerActions.FollowComposite.nodes", temp)
	end
	]]
	--Action
	TweakDB:CloneRecord("DCO.WaitAction", "GenericArchetype.Success")
	TweakDB:SetFlat("DCO.WaitAction.activationCondition", "DCO.WaitAction_inline0")
	
	TweakDB:CreateRecord("DCO.WaitAction_inline0", "gamedataAIActionCondition_Record")
	TweakDB:SetFlat("DCO.WaitAction_inline0.condition", "DCO.WaitAction_inline1")
	
	TweakDB:CreateRecord("DCO.WaitAction_inline1", "gamedataAIActionAND_Record")
	TweakDB:SetFlat("DCO.WaitAction_inline1.AND", {"DCO.HasWaitSE"})
	
	TweakDB:CreateRecord("DCO.HasWaitSE", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.HasWaitSE.statusEffect", "DCO.WaitSE")
	TweakDB:SetFlatNoUpdate("DCO.HasWaitSE.invert", false)
	TweakDB:SetFlat("DCO.HasWaitSE.target", "AIActionTarget.Owner")

	TweakDB:CreateRecord("DCO.NotHasWaitSE", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.NotHasWaitSE.statusEffect", "DCO.WaitSE")
	TweakDB:SetFlatNoUpdate("DCO.NotHasWaitSE.invert", true)
	TweakDB:SetFlat("DCO.NotHasWaitSE.target", "AIActionTarget.Owner")

	---------------------------SELF DESTRUCT-----------------------------
--ChoiceCaptionParts.ChangeToFriendlyIcon
	CName.add("DCOSelfDestruct")
	
	createTechHack("DCO.SelfDestruct", "DCOSelfDestruct", LocKey(550ull), "ChoiceCaptionParts.GrenadeExplodeIcon", "BaseStatusEffect.SuicideWithWeapon", 30, 1, 1, 2, {}, {"Debuff", "Stealth", "Quickhack", "Blind", "Deaf", "SuicideWithWeapon", "Robot"}, "", "")
	addToList("DCO.SelfDestructSE.packages", "BaseStatusEffect.SuicideWithWeapon_inline3") --Add suicide effect
	TweakDB:SetFlatNoUpdate("DCO.SelfDestruct.instigatorPrereqs", {}) --Remove cooldown check
	TweakDB:SetFlat("DCO.SelfDestruct.targetPrereqs", {}) --{"DCO.NotAndroidPrereq"}) --Self repair check

	TweakDB:SetFlat("DCO.SelfDestructEffect.statusEffect", "BaseStatusEffect.SuicideWithWeapon")

	TweakDB:CloneRecord("DCO.SelfDestructEffect2", "QuickHack.SystemCollapseLvl3Hack_inline0")
	TweakDB:SetFlat("DCO.SelfDestructEffect2.statusEffect", "BaseStatusEffect.Electrocuted")

	TweakDB:CloneRecord("DCO.NotAndroidPrereq", "Prereqs.NPCIsAndroid")
	TweakDB:SetFlat("DCO.NotAndroidPrereq.invert", true)
	
	-----------------------EXPLODE WITHOUT KILL----------------------------
	CName.add("DCOExplode")

	createTechHack("DCO.Explode", "DCOExplode", LocKey(550ull), "ChoiceCaptionParts.GrenadeExplodeIcon", "BaseStatusEffect.SeeThroughWalls", 1, 1, 1, 2, {}, {"Buff", "Stealth", "Robot"}, "", "")

	--Status effect prereq
	TweakDB:CreateRecord("DCO.ExplodePrereq", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodePrereq.prereqClassName", "StatusEffectPrereq")
	TweakDB:SetFlat("DCO.ExplodePrereq.statusEffect", "DCO.ExplodeSE")

	TweakDB:CreateRecord("DCO.ExplodeAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.ExplodeAbility.abilityPackage", "DCO.ExplodeAbility_inline1")
	
	TweakDB:CreateRecord("DCO.ExplodeAbility_inline1", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.ExplodeAbility_inline1.effectors", {"DCO.ExplodeAbility_inline2", "DCO.ExplodeAbility_inline3", "DCO.ExplodeAbility_inline4"})
	
	TweakDB:CreateRecord("DCO.ExplodeAbility_inline2", "gamedataTriggerAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline2.attackRecord", "DCO.FlyingExplodeHackExplosion")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline2.effectorClassName", "TriggerAttackOnOwnerEffect")
	TweakDB:SetFlat("DCO.ExplodeAbility_inline2.prereqRecord", "DCO.ExplodeAbility_inline5")

	TweakDB:CreateRecord("DCO.ExplodeAbility_inline3", "gamedataTriggerAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline3.attackRecord", "DCO.AndroidDeathExplosion")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline3.effectorClassName", "TriggerAttackOnOwnerEffect")
	TweakDB:SetFlat("DCO.ExplodeAbility_inline3.prereqRecord", "DCO.ExplodeAbility_inline6")

	TweakDB:CreateRecord("DCO.ExplodeAbility_inline4", "gamedataTriggerAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline4.attackRecord", "DCO.MechDeathExplosion")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline4.effectorClassName", "TriggerAttackOnOwnerEffect")
	TweakDB:SetFlat("DCO.ExplodeAbility_inline4.prereqRecord", "DCO.ExplodeAbility_inline7")

	TweakDB:CreateRecord("DCO.ExplodeAbility_inline5", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline5.aggregationType", "AND")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline5.nestedPrereqs", {"Prereqs.NPCIsDrone", "DCO.ExplodePrereq"})
	TweakDB:SetFlat("DCO.ExplodeAbility_inline5.prereqClassName", "gameMultiPrereq")
	
	TweakDB:CreateRecord("DCO.ExplodeAbility_inline6", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline6.aggregationType", "AND")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline6.nestedPrereqs", {"Prereqs.NPCIsAndroid", "DCO.ExplodePrereq"})
	TweakDB:SetFlat("DCO.ExplodeAbility_inline6.prereqClassName", "gameMultiPrereq")
	
	TweakDB:CreateRecord("DCO.ExplodeAbility_inline7", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline7.aggregationType", "AND")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeAbility_inline7.nestedPrereqs", {"Prereqs.NPCIsMech", "DCO.ExplodePrereq"})
	TweakDB:SetFlat("DCO.ExplodeAbility_inline7.prereqClassName", "gameMultiPrereq")
	
	for i,v in ipairs(Full_Drone_List) do
		addToList(v..".abilities", "DCO.ExplodeAbility")
	end
	
	--Make mech's explosion show up
	Observe('NPCPuppet', 'OnStatusEffectApplied', function(self, statusEffect)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) then
			if statusEffect.staticData:GetID() == TweakDBID.new("DCO.ExplodeSE") then
				GameObject.StartReplicatedEffectEvent(self, CName.new("explode_death"))
			end
		end
	end)

	-----------------------------EXPLODE WITHOUT KILL + BONUS------------------------------------------
	CName.add("DCOExplode")
	
	createTechHack("DCO.ExplodeBonus", "DCOExplode", LocKey(550ull), "ChoiceCaptionParts.GrenadeExplodeIcon", "BaseStatusEffect.SeeThroughWalls", 20, 1, 1, 2, {{"AdditiveMultiplier", "NPCDamage", 0.1}}, {"Buff", "Stealth", "Robot"}, "", "increased_stats_icon")
	addToList("DCO.ExplodeBonus.completionEffects", "DCO.ExplodeEffect")
	
	TweakDB:SetFlat("DCO.ExplodeBonusSE.maxStacks", "DCO.ExplodeBonusStacks")
	
	TweakDB:SetFlat("DCO.ExplodeBonusPackage.stackable", true)
	
	TweakDB:CreateRecord("DCO.ExplodeBonusStacks", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate("DCO.ExplodeBonusStacks.statModsLimit", -1)
	TweakDB:SetFlat("DCO.ExplodeBonusStacks.statModifiers", {"DCO.ExplodeBonusStacks_inline0"})
	
	createConstantStatModifier("DCO.ExplodeBonusStacks_inline0", "Additive", "BaseStats.MaxStacks", 5)

	------------------------SHUT DOWN-------------------------------------
	
	CName.add("DCOShutdown")
	createTechHack("DCO.Shutdown", "DCOShutdown", LocKey(256ull), "ChoiceCaptionParts.LockedIcon", "BaseStatusEffect.SystemCollapse", 30, 1, 1, 2, {}, {"Stealth", "Robot"}, "", "")
	TweakDB:SetFlat("DCO.Shutdown.targetPrereqs", {"Prereqs.TargetNotInCombatPrereq"})
	TweakDB:SetFlat("DCO.ShutdownEffect.statusEffect", "BaseStatusEffect.SystemCollapse")
	
	--Base check for heal effect not active, fixes bug with shutting down healing drone
	TweakDB:CreateRecord("DCO.DroneHealPresentCheck", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealPresentCheck.prereqClassName", "StatusEffectAbsentPrereq")
	TweakDB:SetFlat("DCO.DroneHealPresentCheck.statusEffect", "DCO.DroneHealSE")

	
	----------------------------------SELF-REPAIR--------------------------------
	CName.add("DCODroneHeal")
	createTechHack("DCO.DroneHeal", "DCODroneHeal", LocKey(266ull), "ChoiceCaptionParts.Techie", "BaseStatusEffect.Health_Regen", 30, 1, 60, 4, {}, {"Buff", "Stealth", "Robot"}, "", "regeneration_icon")
	--addToList("DCO.DroneHealSE.packages", "BaseStatusEffect.Health_Regen_inline3")
	addToList("DCO.DroneHealPackage.effectors", "DCO.DroneHealEffector")
	addToList("DCO.DroneHeal.targetPrereqs", "DCO.IsNotMech")

	TweakDB:CloneRecord("DCO.DroneHealEffector", "BaseStatusEffect.Health_Regen_inline4")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealEffector.prereqRecord", "DCO.DroneHealModStatPrereqInv")
	TweakDB:SetFlat("DCO.DroneHealEffector.poolModifier", "DCO.DroneHealEffector_inline0")
	
	TweakDB:CloneRecord("DCO.DroneHealEffector_inline0", "BaseStatusEffect.Health_Regen_inline5")
	TweakDB:SetFlat("DCO.DroneHealEffector_inline0.valuePerSec", 3.3)
	
	
	--Stat prereq
	TweakDB:CreateRecord("DCO.DroneHealModStatPrereqInv", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealModStatPrereqInv.comparisonType", "Equal")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealModStatPrereqInv.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealModStatPrereqInv.statType", "HasTimedImmunity")
	TweakDB:SetFlat("DCO.DroneHealModStatPrereqInv.valueToCheck", 0)

	--Set strength
	--TweakDB:SetFlat("BaseStatusEffect.Health_Regen_inline5.valuePerSec", 3.3)

	
	--Not a mech prereq
	TweakDB:CloneRecord("DCO.IsNotMech", "Prereqs.NPCIsMech")
	TweakDB:SetFlat("DCO.IsNotMech.invert", true)
	
	
	--Handle Mech text
	Override('QuickhacksListGameController', 'SelectData', function(self, data, wrappedMethod)
		wrappedMethod(data)

		ent = Game.FindEntityByID(data.actionOwner)
		if ent:GetRecord():TagsContains(CName.new("Robot")) then
			if ent:GetNPCType() == gamedataNPCType.Mech and GetLocalizedText(self.selectedData.title) == GetLocalizedText("LocKey#266") then
				inkTextRef.SetText(self.warningText, Mech_No_Repair_String)
			end
			if GetLocalizedText(self.selectedData.title) == GetLocalizedText("LocKey#256") and Game.GetPlayer():IsInCombat() then
				inkTextRef.SetText(self.warningText, Shutdown_No_Combat_String)			
			end
			if GetLocalizedText(self.selectedData.title) == GetLocalizedText("LocKey#10547") and Game.GetPlayer():IsInCombat() then
				inkTextRef.SetText(self.warningText, Shutdown_No_Combat_String)			
			end
			if GetLocalizedText(self.selectedData.title) == GetLocalizedText("LocKey#3665") and not (ent:GetNPCType() == gamedataNPCType.Android) then
				inkTextRef.SetText(self.warningText, Kerenzikov_Not_Android_String)			
			end
		end
		

	end)



	
	----------------------------------CLOAK-------------------------------------
	CName.add("DCODroneCloak")
	createTechHack("DCO.DroneCloak", "DCODroneCloak", LocKey(3702ull), "ChoiceCaptionParts.GlitchScreenBlindIcon", "BaseStatusEffect.Cloaked", 30, 1, 90, 6, {{"Multiplier", "Visibility", 0.1}, {"Additive", "SmartTargetingDisruptionProbability", 1}, {"Additive", "TBHsBaseCoefficient", 10}}, {"Cloak", "Buff", "Stealth", "Robot"}, "", "optical_camo")
	addToList("DCO.DroneCloakSE.packages", "BaseStatusEffect.Cloaked_inline0")



	--------------------------OVERDRIVE-----------------------------
	CName.add("DCOOverdrive")
	overdrive_stats = {}
	createTechHack("DCO.Overdrive", "DCOOverdrive", LocKey(260ull), "ChoiceCaptionParts.HuntForPsychoIcon", "BaseStatusEffect.SeeThroughWalls", 30, 3, 120, 8, overdrive_stats, {"Buff", "Stealth", "Robot"}, "BaseStatusEffect.Electrocuted_inline0", "sandevistan_buff_icon")
	TweakDB:SetFlat("DCO.OverdriveSE.SFX", {"DCO.OverdriveSESFX1", "DCO.OverdriveSESFX2"})
	
	TweakDB:CreateRecord("DCO.OverdriveSESFX1", "gamedataStatusEffectFX_Record")
	TweakDB:SetFlat("DCO.OverdriveSESFX1.name", "quickhack_cyberpsychosis")
	
	TweakDB:CreateRecord("DCO.OverdriveSESFX2", "gamedataStatusEffectFX_Record")
	TweakDB:SetFlat("DCO.OverdriveSESFX2.name", "status_electrocuted")
	
	Observe('NPCPuppet', 'OnStatusEffectApplied', function(self, statusEffect)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) then
			if statusEffect.staticData:GetID() == TweakDBID.new("DCO.OverdriveSE") or statusEffect.staticData:GetID() == TweakDBID.new("DCO.OverdriveSESpread") then
				debugPrint(filename, "status effect is overdrive")
				durationMod = Game.GetStatsSystem():GetStatValue(self:GetEntityID(), gamedataStatType.CanUpgradeToLegendaryQuality)
				
				dilation = 2.0 + Game.GetStatsSystem():GetStatValue(Game.GetPlayer():GetEntityID(), gamedataStatType.CanUseTerrainCamo)
				duration = (30 + 30 * durationMod) * (dilation)
				self:SetIndividualTimeDilation(CName.new("Sandevistan"), dilation, duration)
				debugPrint(filename, "set the dilation")
			end
		end
	end)
	
	----------------------------------OPTICAL ZOOM-------------------------------------
	CName.add("DCOOpticalZoom")
	createTechHack("DCO.OpticalZoom", "DCOOpticalZoom", LocKey(15009ull), "ChoiceCaptionParts.CameraTagSeenEnemiesIcon", "DCO.RobotSE", 30, 1, 60, 4, {{"Additive", "Accuracy", 20}}, {"Buff", "Stealth", "Robot"}, "", "second_wind")
	
	----------------------------------KERENZIKOV-------------------------------------
	CName.add("DCOKerenzikov")
	TweakDB:CloneRecord("DCO.KerenzikovCaption", "ChoiceCaptionParts.ClientInDistressIcon")
	TweakDB:SetFlat("DCO.KerenzikovCaption.texturePartID", "UIIcon.kerenzikov_buff")
	
	createTechHack("DCO.AndroidKerenzikov", "DCOKerenzikov", LocKey(3665ull), "DCO.KerenzikovCaption", "DCO.RobotSE", 30, 1, 90, 6, {{"AdditiveMultiplier", "HasKerenzikov", 1}}, {"Buff", "Stealth", "Robot"}, "", "kerenzikov_buff")
	TweakDB:SetFlat("DCO.AndroidKerenzikov.targetPrereqs", {"Prereqs.NPCIsAndroid"})
	
	--SE Clone
	TweakDB:CloneRecord("DCO.AndroidKerenzikovSESpread", "DCO.AndroidKerenzikovSE")
	TweakDB:SetFlat("DCO.AndroidKerenzikovSESpread.packages", {"DCO.AndroidKerenzikovSESpreadPackage"})
	
	TweakDB:CloneRecord("DCO.AndroidKerenzikovSESpreadPackage", "DCO.AndroidKerenzikovPackage")
	
	--Effector
	addToList("DCO.AndroidKerenzikovPackage.effectors", "DCO.AndroidKerenzikovMassEffector")
	
	TweakDB:CreateRecord("DCO.AndroidKerenzikovMassEffector", "gamedataEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.AndroidKerenzikovMassEffector.effectorClassName", "PingSquadEffector")
	TweakDB:SetFlat("DCO.AndroidKerenzikovMassEffector.prereqRecord", "Prereqs.AlwaysTruePrereq")
	TweakDB:SetFlat("DCO.AndroidKerenzikovMassEffector.level", 71, 'Float')
	
	--------------------------EMERGENCY WEAPONS SYSTEM-----------------------------
	
	CName.add("DCOEWS")
	--status effects stat
	ews_stats = {{"Additive", "CanUseCoolingSystem", 1}}

	TweakDB:CloneRecord("DCO.EWSCaption", "ChoiceCaptionParts.ClientInDistressIcon")
	TweakDB:SetFlat("DCO.EWSCaption.texturePartID", "UIIcon.Ability.HasBerserk")
	
	createTechHack("DCO.EWS", "DCOEWS", LocKey(26053ull), "DCO.EWSCaption", "BaseStatusEffect.SeeThroughWalls", 30, 3, 120, 8, ews_stats, {"Buff", "Stealth", "Robot"}, "", "agony")
	TweakDB:SetFlat("DCO.EWSSE.SFX", {"DCO.EWSSESFX1", "DCO.EWSSESFX2"})
	
	TweakDB:CreateRecord("DCO.EWSSESFX1", "gamedataStatusEffectFX_Record")
	TweakDB:SetFlat("DCO.EWSSESFX1.name", "status_burning")
	
	TweakDB:CreateRecord("DCO.EWSSESFX2", "gamedataStatusEffectFX_Record")
	TweakDB:SetFlat("DCO.EWSSESFX2.name", "quickhack_cyberpsychosis_mech")
	
	TweakDB:CloneRecord("DCO.EWSSESpread", "DCO.EWSSE")
	
	
	
	Observe('NPCPuppet', 'OnStatusEffectApplied', function(self, statusEffect)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) then
			if statusEffect.staticData:GetID() == TweakDBID.new("DCO.EWSSE") then
				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					if not StatusEffectSystem.ObjectHasStatusEffect(v, TweakDBID.new("DCO.EWSSE")) and v:GetRecord():TagsContains(CName.new("Robot")) then
						StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("DCO.EWSSESpread"))
					end
				end
			end
		end
	end)
	
	----------------------------HEAL ON KILL---------------------------------
	TweakDB:CreateRecord("DCO.HealOnKillAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.HealOnKillAbility.abilityPackage", "DCO.HealOnKillAbility_inline0")
	
	TweakDB:CreateRecord("DCO.HealOnKillAbility_inline0", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.HealOnKillAbility_inline0.effectors", {"DCO.HealOnKillAbility_inline4"})

	TweakDB:CreateRecord("DCO.HealOnKillAbility_inline4", "gamedataApplyEffectorEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline4.effectorClassName", "ApplyEffectorEffector")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline4.effectorToApply", "DCO.HealOnKillAbility_inline1")
	TweakDB:SetFlat("DCO.HealOnKillAbility_inline4.prereqRecord", "DCO.HealOnKillAbility_inline3")

	
	TweakDB:CreateRecord("DCO.HealOnKillAbility_inline1", "gamedataEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline1.statPoolUpdates", {"DCO.HealOnKillAbility_inline5"})
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline1.effectorClassName", "ModifyStatPoolValueEffector")
	TweakDB:SetFlat("DCO.HealOnKillAbility_inline1.prereqRecord", "DCO.HealOnKillAbility_inline2")
	TweakDB:SetFlat("DCO.HealOnKillAbility_inline1.usePercent", true)

	TweakDB:CreateRecord("DCO.HealOnKillAbility_inline2", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline2.aggregationType", "AND")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline2.nestedPrereqs", {"Prereqs.AnyTakedownOrKill", "DCO.HealOnKillAbility_inline3"})
	TweakDB:SetFlat("DCO.HealOnKillAbility_inline2.prereqClassName", "gameMultiPrereq")
	
	TweakDB:CreateRecord("DCO.HealOnKillAbility_inline3", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline3.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline3.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline3.statType", "CanUseHolographicCamo")
	TweakDB:SetFlat("DCO.HealOnKillAbility_inline3.valueToCheck", 0)
	
	TweakDB:CreateRecord("DCO.HealOnKillAbility_inline5", "gamedataStatPoolUpdate_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealOnKillAbility_inline5.statPoolType", "BaseStatPools.Health")
	TweakDB:SetFlat("DCO.HealOnKillAbility_inline5.statPoolValue", 15)

	for i,v in ipairs(Flying_List) do
		addToList(v..".abilities", "DCO.HealOnKillAbility")
	end
	
	for i,v in ipairs(Android_List) do
		addToList(v..".abilities", "DCO.HealOnKillAbility")
	end
	---------------------------FIX ELECTROCUTED UI DATA----------------------------
	
	--Random bug where this doesnt show up on enemies
	TweakDB:SetFlat("BaseStatusEffect.Electrocuted_inline23.priority", -9)
	
	--[[
	--------------------------EXPLODE HITS W/ OVERCHARGE------------------------
	
	explode_chance = 1
	
	--Create ability
	TweakDB:CreateRecord("DCO.OverchargeExplosionsAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility.abilityPackage", "DCO.OverchargeExplosionsAbility_inline0")
	
	TweakDB:CreateRecord("DCO.OverchargeExplosionsAbility_inline0", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility_inline0.effectors", {"DCO.OverchargeExplosionsAbility_inline4"})

	TweakDB:CreateRecord("DCO.OverchargeExplosionsAbility_inline4", "gamedataApplyEffectorEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline4.effectorClassName", "ApplyEffectorEffector")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline4.effectorToApply", "DCO.OverchargeExplosionsAbility_inline1")
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility_inline4.prereqRecord", "DCO.OverchargeExplosionsAbility_inline3")

	TweakDB:CreateRecord("DCO.OverchargeExplosionsAbility_inline1", "gamedataTriggerAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline1.attackRecord", "DCO.OverchargeExplosionsAttack")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline1.effectorClassName", "TriggerAttackOnTargetEffect")
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility_inline1.prereqRecord", "DCO.OverchargeExplosionsAbility_inline2")
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility_inline1.applicationChance", explode_chance, 'Float')
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility_inline1.isRandom", true)

	TweakDB:CreateRecord("DCO.OverchargeExplosionsAbility_inline2", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline2.aggregationType", "AND")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline2.nestedPrereqs", {"DCO.AttackPrereq"})
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility_inline2.prereqClassName", "gameMultiPrereq")
	
	TweakDB:CloneRecord("DCO.AttackPrereq", "Perks.IsAttackMelee")
	TweakDB:SetFlat("DCO.AttackPrereq.conditions", {})
	
	TweakDB:CreateRecord("DCO.OverchargeExplosionsAbility_inline3", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline3.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline3.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAbility_inline3.statType", "CanUseAntiStun")
	TweakDB:SetFlat("DCO.OverchargeExplosionsAbility_inline3.valueToCheck", 0)
	
	for i,v in ipairs(Full_Drone_List) do
		addToList(v..".abilities", "DCO.OverchargeExplosionsAbility")
	end
	
	--Create attack record
	TweakDB:CloneRecord("DCO.OverchargeExplosionsAttack", "Attacks.EMPGrenade")
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAttack.statModifiers", {})
	TweakDB:SetFlatNoUpdate("DCO.OverchargeExplosionsAttack.attackType", "AttackType.Explosion")
	TweakDB:SetFlat("DCO.OverchargeExplosionsAttack.playerIncomingDamageMultiplier", 1)

	Observe('TriggerAttackOnTargetEffect', 'ActionOn', function(self, owner)
		print("trying!")
		print(IsDefined(Game.GetTargetingSystem():GetLookAtObject(owner, true)))
	end)

	Observe('TriggerAttackOnTargetEffect', 'RepeatedAction', function()
		print("tryinasdasdg!")
	end)
	--------------------------EMP ON HIT------------------------------------------
	
	emp_chance = 0.1
	
	--Create ability
	TweakDB:CreateRecord("DCO.EMPOnHitAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.EMPOnHitAbility.abilityPackage", "DCO.EMPOnHitAbility_inline0")
	
	TweakDB:CreateRecord("DCO.EMPOnHitAbility_inline0", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.EMPOnHitAbility_inline0.effectors", {"DCO.EMPOnHitAbility_inline4"})

	TweakDB:CreateRecord("DCO.EMPOnHitAbility_inline4", "gamedataApplyEffectorEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline4.effectorClassName", "ApplyEffectorEffector")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline4.effectorToApply", "DCO.EMPOnHitAbility_inline1")
	TweakDB:SetFlat("DCO.EMPOnHitAbility_inline4.prereqRecord", "DCO.EMPOnHitAbility_inline3")

	
	TweakDB:CreateRecord("DCO.EMPOnHitAbility_inline1", "gamedataTriggerAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline1.attackRecord", "DCO.EMPOnHitAttack")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline1.effectorClassName", "TriggerAttackByChanceEffector")
	TweakDB:SetFlat("DCO.EMPOnHitAbility_inline1.prereqRecord", "DCO.EMPOnHitAbility_inline2")
	TweakDB:SetFlat("DCO.EMPOnHitAbility_inline1.chance", emp_chance, 'Float')

	TweakDB:CreateRecord("DCO.EMPOnHitAbility_inline2", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline2.aggregationType", "AND")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline2.nestedPrereqs", {"Items.ElectroshockMechanismEffector_inline0", "DCO.EMPOnHitAbility_inline3"})
	TweakDB:SetFlat("DCO.EMPOnHitAbility_inline2.prereqClassName", "gameMultiPrereq")
	
	TweakDB:CreateRecord("DCO.EMPOnHitAbility_inline3", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline3.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline3.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAbility_inline3.statType", "CanUseHolographicCamo")
	TweakDB:SetFlat("DCO.EMPOnHitAbility_inline3.valueToCheck", 0)
	
	for i,v in ipairs(Full_Drone_List) do
		addToList(v..".abilities", "DCO.EMPOnHitAbility")
	end
	
	--Create attack record
	TweakDB:CloneRecord("DCO.EMPOnHitAttack", "Attacks.EMPGrenade")
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAttack.statModifiers", {})
	TweakDB:SetFlatNoUpdate("DCO.EMPOnHitAttack.attackType", "AttackType.Explosion")
	TweakDB:SetFlat("DCO.EMPOnHitAttack.playerIncomingDamageMultiplier", 1)

	]]
	----------------------------ANDROID SELF DESTRUCT-------------------------------

	--Create ability
	TweakDB:CreateRecord("DCO.AndroidSuicideAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.AndroidSuicideAbility.abilityPackage", "DCO.AndroidSuicideGLP")
	
	TweakDB:CreateRecord("DCO.AndroidSuicideGLP", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.AndroidSuicideGLP.effectors", {"DCO.AndroidSuicideGLP_inline0"})

	TweakDB:CreateRecord("DCO.AndroidSuicideGLP_inline0", "gamedataTriggerAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.AndroidSuicideGLP_inline0.attackRecord", "DCO.AndroidDeathExplosion")
	TweakDB:SetFlatNoUpdate("DCO.AndroidSuicideGLP_inline0.effectorClassName", "SimpleTriggerAttackEffect")
	TweakDB:SetFlat("DCO.AndroidSuicideGLP_inline0.prereqRecord", "DCO.AndroidSuicideGLP_inline1")

	TweakDB:CreateRecord("DCO.AndroidSuicideGLP_inline1", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.AndroidSuicideGLP_inline1.prereqClassName", "StatusEffectPrereq")
	TweakDB:SetFlat("DCO.AndroidSuicideGLP_inline1.statusEffect", "BaseStatusEffect.SuicideWithWeapon")

	TweakDB:CloneRecord("DCO.AndroidDeathExplosion", "Attacks.EMPGrenade")
	TweakDB:SetFlatNoUpdate("DCO.AndroidDeathExplosion.playerIncomingDamageMultiplier", 1)
	
	TweakDB:SetFlat("DCO.AndroidDeathExplosion.statModifiers", {"DCO.AndroidDeathExplosion_inline0", "DCO.AndroidDeathExplosion_inline1", "DCO.AndroidDeathExplosion_inline2", "DCO.AndroidDeathExplosion_inline3"})
	createCombinedStatModifier("DCO.AndroidDeathExplosion_inline0", "AdditiveMultiplier", "*", "Parent", "DCO.DroneDeathExplosion", "BaseStats.ElectricDamage", 1)
	createConstantStatModifier("DCO.AndroidDeathExplosion_inline1", "Additive", "BaseStats.ElectricDamage", 1)
	createCombinedStatModifier("DCO.AndroidDeathExplosion_inline2", "Additive", "*", "Parent", "BaseStats.Health", "BaseStats.ElectricDamage", 1)
	createConstantStatModifier("DCO.AndroidDeathExplosion_inline3", "Multiplier", "BaseStats.ElectricDamage", 0.75)


	for i,v in ipairs(Android_List) do
		--addToList(v..".onSpawnGLPs", "DCO.AndroidSuicideGLP")
		addToList(v..".abilities", "DCO.AndroidSuicideAbility")
		
	end
	

	--Do the dismembering and killing
	Observe('NPCPuppet', 'OnStatusEffectApplied', function(self, statusEffect)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) and self:GetNPCType() == gamedataNPCType.Android and statusEffect.staticData:GetID() == TweakDBID.new("BaseStatusEffect.SuicideWithWeapon") then
			DismembermentComponent.RequestDismemberment(self, gameDismBodyPart.RIGHT_ARM, gameDismWoundType.COARSE)
			DismembermentComponent.RequestDismemberment(self, gameDismBodyPart.LEFT_ARM, gameDismWoundType.COARSE)
			DismembermentComponent.RequestDismemberment(self, gameDismBodyPart.RIGHT_LEG, gameDismWoundType.COARSE)
			DismembermentComponent.RequestDismemberment(self, gameDismBodyPart.LEFT_LEG, gameDismWoundType.COARSE)
			DismembermentComponent.RequestDismemberment(self, gameDismBodyPart.HEAD, gameDismWoundType.CLEAN)
			self:Kill()
			
		end
	end)
	


	-----------------------BLUEPRINT--------------------------------
	
	TweakDB:CreateRecord("DCO.TechDeckBlueprint", "gamedataItemBlueprint_Record")
	TweakDB:SetFlat("DCO.TechDeckBlueprint.rootElement", "DCO.TechDeckBlueprint_inline0")
	
	TweakDB:CreateRecord("DCO.TechDeckBlueprint_inline0", "gamedataItemBlueprintElement_Record")
	TweakDB:SetFlatNoUpdate("DCO.TechDeckBlueprint_inline0.slot", "AttachmentSlots.GenericItemRoot")
	TweakDB:SetFlat("DCO.TechDeckBlueprint_inline0.childElements", {"DCO.TechDeckBlueprint_inline1", "DCO.TechDeckBlueprint_inline2", "DCO.TechDeckBlueprint_inline3"})
	
	TweakDB:CreateRecord("DCO.TechDeckBlueprint_inline1", "gamedataItemBlueprintElement_Record")
	TweakDB:SetFlat("DCO.TechDeckBlueprint_inline1.slot", "AttachmentSlots.BotCpuSlot1")
	TweakDB:SetFlat("AttachmentSlots.BotCpuSlot1.localizedName", "Cyberware Slot")
	TweakDB:SetFlat("AttachmentSlots.BotCpuSlot1.unlockedBy", "Rare")

	TweakDB:CreateRecord("DCO.TechDeckBlueprint_inline2", "gamedataItemBlueprintElement_Record")
	TweakDB:SetFlat("DCO.TechDeckBlueprint_inline2.slot", "AttachmentSlots.BotCpuSlot2")
	TweakDB:SetFlat("AttachmentSlots.BotCpuSlot2.localizedName", "Cyberware Slot")
	TweakDB:SetFlat("AttachmentSlots.BotCpuSlot2.unlockedBy", "Epic")

	TweakDB:CreateRecord("DCO.TechDeckBlueprint_inline3", "gamedataItemBlueprintElement_Record")
	TweakDB:SetFlat("DCO.TechDeckBlueprint_inline3.slot", "AttachmentSlots.BotCpuSlot3")
	TweakDB:SetFlat("AttachmentSlots.BotCpuSlot3.localizedName", "Cyberware Slot")
	TweakDB:SetFlat("AttachmentSlots.BotCpuSlot3.unlockedBy", "Legendary")

	--Enable our new slots to work.
	Override('InventoryDataManagerV2', 'GetAttachmentSlotsForInventory;', function(wrappedMethod)
		slots = wrappedMethod()
		table.insert(slots, TweakDBID.new("AttachmentSlots.BotCpuSlot1"))
		table.insert(slots, TweakDBID.new("AttachmentSlots.BotCpuSlot2"))
		table.insert(slots, TweakDBID.new("AttachmentSlots.BotCpuSlot3"))

		return slots
	end)
	
	--Dont allow them to be equipped from backpack
	Override('BackpackMainGameController', 'OnItemDisplayClick', function(self, evt, wm)
		tdb = ItemID.GetTDBID(evt.itemData.ID)
		if TweakDBInterface.GetItemRecord(tdb):TagsContains(CName.new("DCOMod")) then
			return
		end

		wm(evt)

	end)
	----------------------TECHDECKS--------------------------------

	--Make sandevistan and berserk clone bc we overwrite them
	TweakDB:CloneRecord("DCO.BerserkC1MK1", "Items.BerserkC1MK1")
	TweakDB:SetFlat("DCO.BerserkC1MK1.cyberwareType", CName.new("Berserk"))
	
	TweakDB:CloneRecord("DCO.BerserkC2MK1", "Items.BerserkC2MK1")
	TweakDB:SetFlat("DCO.BerserkC2MK1.cyberwareType", CName.new("Berserk"))
	
	TweakDB:CloneRecord("DCO.SandevistanC1MK1", "Items.SandevistanC1MK1")
	TweakDB:SetFlat("DCO.SandevistanC1MK1.cyberwareType", CName.new("Sandevistan"))
	
	--Make base stat prereqs
	
	TweakDB:CreateRecord("DCO.RareTechStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.RareTechStatPrereq.comparisonType", "GreaterOrEqual")
	TweakDB:SetFlatNoUpdate("DCO.RareTechStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.RareTechStatPrereq.statType", "TechnicalAbility")
	TweakDB:SetFlat("DCO.RareTechStatPrereq.valueToCheck", 6)
	
	TweakDB:CloneRecord("DCO.EpicTechStatPrereq", "DCO.RareTechStatPrereq")
	TweakDB:SetFlat("DCO.EpicTechStatPrereq.valueToCheck", 12)
	
	TweakDB:CloneRecord("DCO.LegendaryTechStatPrereq", "DCO.EpicTechStatPrereq")
	TweakDB:SetFlat("DCO.LegendaryTechStatPrereq.valueToCheck", 18)
	
	--Make techdecks
	
	--Hack lists
	Common_Hack_List = { "DCO.Shutdown", "DCO.SelfDestruct"}
	Rare_Hack_List = { "DCO.Shutdown", "DCO.SelfDestruct", "DCO.DroneHeal"}
	Epic_Hack_List = {"DCO.Shutdown", "DCO.SelfDestruct", "DCO.DroneHeal", "DCO.DroneCloak"}
	Legendary_Hack_List = {"DCO.Shutdown", "DCO.SelfDestruct", "DCO.DroneHeal", "DCO.DroneCloak", "DCO.Overdrive"}

	Street_Rare_Hack_List = { "DCO.Shutdown", "DCO.Explode", "DCO.DroneHeal"}
	Street_Epic_Hack_List = {"DCO.Shutdown", "DCO.Explode", "DCO.DroneHeal", "DCO.DroneCloak"}
	Street_Legendary_Hack_List = {"DCO.Shutdown", "DCO.ExplodeBonus", "DCO.DroneHeal", "DCO.DroneCloak", "DCO.Overdrive"}

	Nomad0DescList = {"DCO.OneDroneDesc", "DCO.ArmorDesc"}
	Nomad1DescList = {"DCO.TwoDronesDesc", "DCO.ArmorDesc", "DCO.TechHackCooldownDesc"}
	Nomad2DescList = {"DCO.TwoDronesDesc", "DCO.HealthDesc", "DCO.ArmorDesc",  "DCO.MechRegenDesc", "DCO.TechHackCooldownDesc"}
	Nomad3DescList = {"DCO.ThreeDronesDesc", "DCO.HealthDesc", "DCO.ArmorDesc", "DCO.MechRegenDesc", "DCO.TechHackCooldownDesc", "DCO.OverdriveAllDesc"}

	Street0DescList = {"DCO.OneDroneDesc", "DCO.HealthDesc"}
	Street1DescList = {"DCO.TwoDronesDesc", "DCO.HealthDesc", "DCO.FlyingCheapDesc"}
	Street2DescList = {"DCO.TwoDronesDesc", "DCO.HealthDesc", "DCO.AccuracyDesc", "DCO.FlyingCheapDesc", "DCO.FlyingSEDesc"}
	Street3DescList = {"DCO.ThreeDronesDesc", "DCO.HealthDesc", "DCO.AccuracyDesc", "DCO.FlyingCheapDesc", "DCO.FlyingSEDesc", "DCO.FlyingExplosionDesc"}

	Corpo0DescList = {"DCO.OneDroneDesc", "DCO.AccuracyDesc"}
	Corpo1DescList = {"DCO.TwoDronesDesc", "DCO.ArmorDesc", "DCO.AccuracyDesc", "DCO.AndroidRegenDesc", "DCO.AndroidDilationDesc"}
	Corpo2DescList = {"DCO.ThreeDronesDesc", "DCO.ArmorDesc", "DCO.AccuracyDesc", "DCO.AndroidRegenDesc", "DCO.AndroidDilationDesc", "DCO.AndroidWeaponsDesc"}

	--Make records to hold strings
	createTechDeckEffectDescription("DCO.OneDroneDesc", One_Drone_String)
	createTechDeckEffectDescription("DCO.TwoDronesDesc", Two_Drones_String)
	createTechDeckEffectDescription("DCO.ThreeDronesDesc", Three_Drones_String)
	createTechDeckEffectDescription("DCO.AccuracyDesc", Accuracy_String)
	createTechDeckEffectDescription("DCO.ArmorDesc", Armor_String)
	createTechDeckEffectDescription("DCO.HealthDesc", Health_String)
	createTechDeckEffectDescription("DCO.FlyingSEDesc", FlyingSE_String)
	createTechDeckEffectDescription("DCO.FlyingCheapDesc", FlyingCheap_String)
	createTechDeckEffectDescription("DCO.FlyingExplosionDesc", FlyingExplosion_String)
	createTechDeckEffectDescription("DCO.TechHackCooldownDesc", TechHackCooldown_String)
	createTechDeckEffectDescription("DCO.MechRegenDesc", MechRegen_String) --not actually mech regen anymore but wont change
	createTechDeckEffectDescription("DCO.OverdriveAllDesc", OverdriveAll_String)
	createTechDeckEffectDescription("DCO.AndroidRegenDesc", AndroidRegen_String)
	createTechDeckEffectDescription("DCO.AndroidDilationDesc", AndroidDilation_String)
	createTechDeckEffectDescription("DCO.AndroidWeaponsDesc", AndroidWeapons_String)
	

	--Create base tech deck stats (UNUSED ATM)
	createConstantStatModifier("DCO.QuickhackSpreadNumber", "Additive", "BaseStats.QuickHackSpreadNumber", 2)
	createConstantStatModifier("DCO.QuickhackSpreadRange", "Additive", "BaseStats.QuickHackSpreadDistance", 16)

	--Common
	--[[
	stats = {{"Additive", "DCO.DroneNumber", 1}, {"Additive", "DCO.DroneArmor", 20}}
	createTechDeck("DCO.NomadDeck0", Nomad0_Name, Nomad0_Desc, Nomad0DescList, stats, "Common", 2,  Common_Hack_List)

	stats = {{"Additive", "DCO.DroneNumber", 1}, {"Additive", "DCO.DroneHP", 0.2}}
	createTechDeck("DCO.StreetDeck0", Street0_Name, Street0_Desc, Street0DescList, stats, "Common", 2,  Common_Hack_List)

	stats = {{"Additive", "DCO.DroneNumber", 1}, {"Additive", "DCO.DroneAccuracy", 0.2}}
	createTechDeck("DCO.CorpoDeck0", Corpo0_Name, Corpo0_Desc, Corpo0DescList, stats, "Common", 2,  Common_Hack_List)
]]
	--Rare
	stats = {{"Additive", "DCO.DroneNumber", 2}, {"Additive", "DCO.DroneArmor", 20}, {"Additive", "DCO.DroneNomadCooldown", 1}}
	createTechDeck("DCO.NomadDeck1", Nomad1_Name, Nomad1_Desc, Nomad1DescList, stats, "Rare", 4, Rare_Hack_List)

	stats = {{"Additive", "DCO.DroneNumber", 2}, {"Additive", "DCO.DroneHP", 0.2}}
	createTechDeck("DCO.StreetDeck1", Street1_Name, Street1_Desc, Street1DescList, stats, "Rare", 4, Street_Rare_Hack_List)
	
	--Epic
	stats = {{"Additive", "DCO.DroneNumber", 2}, {"Additive", "DCO.DroneHP", 0.2}, {"Additive", "DCO.DroneArmor", 20}, {"Additive", "DCO.DroneNomadCooldown", 1}, {"Additive", "DCO.TechHackCostReduction", 0.5}}
	createTechDeck("DCO.NomadDeck2", Nomad2_Name, Nomad2_Desc, Nomad2DescList, stats, "Epic", 6, Epic_Hack_List)

	stats = {{"Additive", "DCO.DroneNumber", 2}, {"Additive", "DCO.DroneAccuracy", 0.3}, {"Additive", "DCO.DroneHP", 0.2}, {"Additive", "DCO.DroneHealOnKill", 1}}
	createTechDeck("DCO.StreetDeck2", Street2_Name, Street2_Desc, Street2DescList, stats, "Epic", 6, Street_Epic_Hack_List)
	
	stats = {{"Additive", "DCO.DroneNumber", 2}, {"Additive", "DCO.DroneAccuracy", 0.3}, {"Additive", "DCO.DroneArmor", 20}, {"Additive", "DCO.DroneAndroidRegen", 1}, {"Additive", "DCO.DroneAndroidDilation", 1}}
	createTechDeck("DCO.CorpoDeck1", Corpo1_Name, Corpo1_Desc, Corpo1DescList, stats, "Epic", 6, Epic_Hack_List)
	
	--Legendary
	stats = {{"Additive", "DCO.DroneNumber", 3}, {"Additive", "DCO.DroneHP", 0.2}, {"Additive", "DCO.DroneArmor", 20}, {"Additive", "DCO.DroneNomadCooldown", 1}, {"Additive", "DCO.DroneOverdriveAll", 1}, {"Additive", "DCO.TechHackCostReduction", 0.5}}
	createTechDeck("DCO.NomadDeck3", Nomad3_Name, Nomad3_Desc, Nomad3DescList, stats, "Legendary", 8, Legendary_Hack_List)

	stats = {{"Additive", "DCO.DroneNumber", 3}, {"Additive", "DCO.DroneHP", 0.2}, {"Additive", "DCO.DroneAccuracy", 0.3}, {"Additive", "DCO.DroneHealOnKill", 1}}
	createTechDeck("DCO.StreetDeck3", Street3_Name, Street3_Desc, Street3DescList, stats, "Legendary", 8, Street_Legendary_Hack_List)
	
	
	stats = {{"Additive", "DCO.DroneNumber", 3}, {"Additive", "DCO.DroneAccuracy", 0.3}, {"Additive", "DCO.DroneArmor", 20}, {"Additive", "DCO.DroneAndroidRegen", 1}, {"Additive", "DCO.DroneAndroidWeapons", 1}, {"Additive", "DCO.DroneAndroidDilation", 1}}

	createTechDeck("DCO.CorpoDeck2", Corpo2_Name, Corpo2_Desc, Corpo2DescList, stats, "Legendary", 8, Legendary_Hack_List)
	
	------------------------------------TECHDECK MODS----------------------------------------------
	

	CName.add("DCOMod")
	
	--Rare
	statList = {{"Additive", "DCO.DroneHackDamage", 1}}
	createTechDeckMod("DCO.TechDeckMod1", Optics_Enhancer_String, "", Optics_Enhancer_Desc, "AttachmentSlots.BotCpuSlot1", statList, "Rare")
	
	statList = {{"Additive", "DCO.DroneDeathExplosion", 0.5}}
	createTechDeckMod("DCO.TechDeckMod2", Malfunction_Coordinator_String, "", Malfunction_Coordinator_Desc,  "AttachmentSlots.BotCpuSlot1", statList, "Rare")
	
	statList = {}
	createTechDeckMod("DCO.TechDeckMod3", Trigger_Software_String, "", Trigger_Software_Desc, "AttachmentSlots.BotCpuSlot1", statList, "Rare")
	addToList("DCO.TechDeckMod3.objectActions", "DCO.OpticalZoom")
	
	--Epic
	statList = {{"Additive", "DCO.DroneCloakHeal", 1}}
	createTechDeckMod("DCO.TechDeckMod4", Plate_Energizer_String, "", Plate_Energizer_Desc, "AttachmentSlots.BotCpuSlot2", statList, "Epic")
	
	statList = {}
	createTechDeckMod("DCO.TechDeckMod5", Extra_Sensory_Processor_String, "", Extra_Sensory_Processor_Desc, "AttachmentSlots.BotCpuSlot2", statList, "Epic")
	
	statList = {{"Additive", "DCO.DroneHealMod", 1}}
	createTechDeckMod("DCO.TechDeckMod6", Insta_Repair_Unit_String, "", Insta_Repair_Unit_Desc, "AttachmentSlots.BotCpuSlot2", statList, "Epic")
	
	--Legendary
	statList = {{"Additive", "DCO.DroneMassCloak", 1}}
	createTechDeckMod("DCO.TechDeckMod7", Mass_Distortion_Core_String, "", Mass_Distortion_Core_Desc, "AttachmentSlots.BotCpuSlot3", statList, "Legendary")
	
	statList = {}
	createTechDeckMod("DCO.TechDeckMod8", Circuit_Charger_String, "", Circuit_Charger_Desc, "AttachmentSlots.BotCpuSlot3", statList, "Legendary")
	addToList("DCO.TechDeckMod8.objectActions", "DCO.EWS")

	statList = {{"Additive", "DCO.DroneOverdriveSpeed", 1}}
	createTechDeckMod("DCO.TechDeckMod9", CPU_Overloader_String, "", CPU_Overloader_Desc, "AttachmentSlots.BotCpuSlot3", statList, "Legendary")
	
	
	
	
	------------------------------ICONS--------------------------------------
	
	for i=1,9 do
		createIcon("DCO.TechDeckMod"..i, "DCOTechDeckMod"..i, "techdeckmod"..i.."_atlas")
	end

	createIcon("DCO.StreetDeck1", "DCOStreetTechDeck", "streettechdeck_atlas")
	createIcon("DCO.StreetDeck2", "DCOStreetTechDeck", "streettechdeck_atlas")
	createIcon("DCO.StreetDeck3", "DCOStreetTechDeck", "streettechdeck_atlas")

	createIcon("DCO.NomadDeck1", "DCONomadTechDeck", "nomadtechdeck_atlas")
	createIcon("DCO.NomadDeck2", "DCONomadTechDeck", "nomadtechdeck_atlas")
	createIcon("DCO.NomadDeck3", "DCONomadTechDeck", "nomadtechdeck_atlas")

	createIcon("DCO.CorpoDeck1", "DCOCorpoTechDeck", "corpotechdeck_atlas")
	createIcon("DCO.CorpoDeck2", "DCOCorpoTechDeck", "corpotechdeck_atlas")


	-----------------------------------------------------------------------------------------------------------
	-------------------------------------ABILITY IMPLEMENTATIONS--------------------------------------------
	--------------------------------------------------------------------------------------------------------
	
	
	
	------------------------CUSTOM DRONE STATS-----------------------------------
	
	--Base stats to be applied to drone records
	createStat("DCO.DroneNumber", "BaseStats.NPCAnimationTime")
	createStat("DCO.DroneHP", "BaseStats.NPCCorpoEquipItemDuration")	
	createStat("DCO.DroneArmor", "BaseStats.NPCCorpoUnequipItemDuration")
	createStat("DCO.DroneAccuracy", "BaseStats.NPCEquipItemDuration")
	createStat("DCO.DroneNomadCooldown", "BaseStats.NPCGangEquipItemDuration")
	createStat("DCO.DroneStatusEffect", "BaseStats.CanUseCoolingSystem")
	createStat("DCO.DroneAndroidDilation", "BaseStats.NPCLoopDuration")
	createStat("DCO.DroneDeathExplosion", "BaseStats.NPCRecoverDuration")
	createStat("DCO.DroneCheapCost", "BaseStats.NPCUnequipItemDuration")
	createStat("DCO.DroneDamage", "BaseStats.NPCStartupDuration")
	createStat("DCO.DroneAndroidRegen", "BaseStats.CanCallReinforcements")
	createStat("DCO.DroneOverdriveAll", "BaseStats.CanElectrocuteNullifyStats")
	createStat("DCO.DroneAndroidWeapons", "BaseStats.CanCatchUp")
	createStat("DCO.DroneFlyingExplosions", "BaseStats.HasWallRunSkill") --used in ews
	createStat("DCO.TechHackCostReduction", "BaseStats.CanCloseCombat")

	createStat("DCO.DroneCloakHeal", "BaseStats.CallReinforcement")
	createStat("DCO.DroneHealMod", "BaseStats.HasTimedImmunity")
	createStat("DCO.DroneMassCloak", "BaseStats.CanAskToHolsterWeapon")
	createStat("DCO.DroneHackDamage", "BaseStats.CanUseRetractableShield")
	createStat("DCO.DroneOverdriveSpeed", "BaseStats.CanUseTerrainCamo")
	createStat("DCO.DroneWeakspotHP", "BaseStats.CanUseZoom")
	createStat("DCO.DroneTechHackDuration", "BaseStats.CanUpgradeToLegendaryQuality")
	createStat("DCO.DroneOctantArasakaStat", "BaseStats.CanHeartattackQuickHack")
	createStat("DCO.DroneHealOnKill", "BaseStats.CanUseHolographicCamo")
	--createStat("DCO.DroneHitExplosions", "BaseStats.CanUseAntiStun")

	------------------------ADD BASE STATS LISTS----------------------------
	
	--Androids
	Android_Stats = {{"AdditiveMultiplier", "DCO.DroneHP", "BaseStats.Health", 1},
	{"AdditiveMultiplier", "DCO.DroneDamage", "BaseStats.NPCDamage",1},
	{"Additive", "DCO.DroneArmor", "BaseStats.Armor", 1},
	{"AdditiveMultiplier", "DCO.DroneAccuracy", "BaseStats.Accuracy",1 },
	{"Additive", "DCO.DroneAndroidRegen", "BaseStats.CanCallDrones", 1},
	{"Additive", "DCO.DroneHealMod", "DCO.DroneHealMod", 1},
	{"Additive", "DCO.DroneMassCloak", "DCO.DroneMassCloak", 1},
	{"Additive", "DCO.DroneOverdriveAll", "DCO.DroneOverdriveAll", 1},
	{"Additive", "DCO.DroneHackDamage", "DCO.DroneHackDamage", 1},
	{"Additive", "DCO.DroneHealOnKill", "DCO.DroneHealOnKill", 1},
	--{"Additive", "DCO.DroneHitExplosions", "DCO.DroneHitExplosions", 1},

	{"AdditiveMultiplier", "DCO.DroneAndroidDilation", "BaseStats.HasSandevistan", 1},
	{"AdditiveMultiplier", "DCO.DroneAndroidDilation", "BaseStats.HasSandevistanTier1", 1},
	--{"AdditiveMultiplier", "DCO.DroneAndroidDilation", "BaseStats.HasKerenzikov", 1},
	{"Additive", "DCO.DroneCloakHeal", "DCO.DroneCloakHeal", 1},
	--{"Additive", "DCO.DroneFlyingExplosions", "DCO.DroneFlyingExplosions", 1},
	--{"Additive", "DCO.DroneStatusEffect", "DCO.DroneStatusEffect", 1},
	{"Additive", "DCO.DroneDeathExplosion", "DCO.DroneDeathExplosion", 1}--[[,
	
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.DismHeadDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.DismLArmDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.DismRArmDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.DismRLegDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.DismLLegDamageThreshold", 1},
	
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.WoundHeadDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.WoundLArmDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.WoundRArmDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.WoundRLegDamageThreshold", 1},
	{"AdditiveMultiplier", "DCO.DroneLimbHealth", "BaseStats.WoundLLegDamageThreshold", 1}]]}
	createDroneStatGroup("DCO.AndroidStatGroup", Android_Stats)
	
	createConstantStatModifier("DCO.AndroidArmorAdjust", "Additive", "BaseStats.Armor", -20)
	addToList("DCO.AndroidStatGroup.statModifiers", "DCO.AndroidArmorAdjust")
	
	
	for i,v in ipairs(Android_List) do
		addToList(v..".statModifierGroups", "DCO.AndroidStatGroup")
		addToList(v..".abilities", "DCO.DroneRegenAbility")
	end

	
	--Flying
	Flying_Stats = {{"AdditiveMultiplier", "DCO.DroneHP", "BaseStats.Health", 1},
	{"AdditiveMultiplier", "DCO.DroneDamage", "BaseStats.NPCDamage",1},
	{"Additive", "DCO.DroneArmor", "BaseStats.Armor", 1},
	{"Additive", "DCO.DroneHealMod", "DCO.DroneHealMod", 1},
	{"Additive", "DCO.DroneMassCloak", "DCO.DroneMassCloak", 1},
	{"Additive", "DCO.DroneHackDamage", "DCO.DroneHackDamage", 1},
	{"Additive", "DCO.DroneOverdriveAll", "DCO.DroneOverdriveAll", 1},
	{"AdditiveMultiplier", "DCO.DroneAndroidDilation", "BaseStats.HasSandevistan", 1},
	{"Additive", "DCO.DroneHealOnKill", "DCO.DroneHealOnKill", 1},
	--{"Additive", "DCO.DroneHitExplosions", "DCO.DroneHitExplosions", 1},

	{"Additive", "DCO.DroneCloakHeal", "DCO.DroneCloakHeal", 1},
	{"Additive", "DCO.DroneAndroidRegen", "BaseStats.CanCallDrones", 1},
	{"AdditiveMultiplier", "DCO.DroneAccuracy", "BaseStats.Accuracy",1 },
	--{"Additive", "DCO.DroneFlyingExplosions", "DCO.DroneFlyingExplosions", 1},
	--{"Additive", "DCO.DroneStatusEffect", "DCO.DroneStatusEffect", 1},
	{"Additive", "DCO.DroneDeathExplosion", "DCO.DroneDeathExplosion", 1}}
	createDroneStatGroup("DCO.FlyingStatGroup", Flying_Stats)
	
	createConstantStatModifier("DCO.FlyingArmorAdjust", "Additive", "BaseStats.Armor", -15)
	addToList("DCO.FlyingStatGroup.statModifiers", "DCO.FlyingArmorAdjust")
	
	for i,v in ipairs(Flying_List) do
		addToList(v..".statModifierGroups", "DCO.FlyingStatGroup")
		addToList(v..".abilities", "DCO.DroneRegenAbility")
	end



	--Mech
	Mech_Stats = {{"AdditiveMultiplier", "DCO.DroneHP", "BaseStats.Health", 1},
	{"AdditiveMultiplier", "DCO.DroneDamage", "BaseStats.NPCDamage",1},
	{"Additive", "DCO.DroneArmor", "BaseStats.Armor", 1},
	{"Additive", "DCO.DroneHealMod", "DCO.DroneHealMod", 1},
	{"Additive", "DCO.DroneHealOnKill", "DCO.DroneHealOnKill", 1},
	{"Additive", "DCO.DroneMassCloak", "DCO.DroneMassCloak", 1},
	{"Additive", "DCO.DroneHackDamage", "DCO.DroneHackDamage", 1},
	{"Additive", "DCO.DroneOverdriveAll", "DCO.DroneOverdriveAll", 1},
	--{"Additive", "DCO.DroneHitExplosions", "DCO.DroneHitExplosions", 1},

	{"Additive", "DCO.DroneDeathExplosion", "DCO.DroneDeathExplosion", 1},
	{"AdditiveMultiplier", "DCO.DroneAccuracy", "BaseStats.Accuracy",1 },
	{"Additive", "DCO.TechHackCostReduction", "DCO.TechHackCostReduction", 1}}
	createDroneStatGroup("DCO.MechStatGroup", Mech_Stats)
	
	createConstantStatModifier("DCO.MechArmorAdjust", "Additive", "BaseStats.Armor", -20)
	addToList("DCO.MechStatGroup.statModifiers", "DCO.MechArmorAdjust")
	
	for i,v in ipairs(Mech_List) do
		addToList(v..".statModifierGroups", "DCO.MechStatGroup")
		addToList(v..".abilities", "DCO.MechRegenAbility")
	end
	
	
	--[[
	-------------------------OVERDRIVE ACCURACY------------------------------
	
	addToList("DCO.OverdrivePackage.stats", "DCO.DroneOverdriveAccuracyStat")
	createCombinedStatModifier("DCO.DroneOverdriveAccuracyStat", "AdditiveMultiplier", "*", "Player", "DCO.DroneOverdriveAccuracy", "BaseStats.Accuracy", 10)

	--------------------------OVERDRIVE COOLDOWN------------------------------
	
	--Duration edit
	addToList("DCO.OverdriveCooldownDuration.statModifiers", "DCO.DroneHackDamageDuration")
	createCombinedStatModifier("DCO.DroneHackDamageDuration", "AdditiveMultiplier", "*", "Player", "DCO.DroneHackDamage", "BaseStats.MaxDuration", -0.5)
	
	---------------------------CLOAK AND REPAIR COOLDOWN-----------------------
	addToList("DCO.DroneCloakCooldownDuration.statModifiers", "DCO.DroneNomadReductionDuration")
	addToList("DCO.DroneHealCooldownDuration.statModifiers", "DCO.DroneNomadReductionDuration")
	createCombinedStatModifier("DCO.DroneNomadReductionDuration", "AdditiveMultiplier", "*", "Player", "DCO.DroneNomadCooldown", "BaseStats.MaxDuration", -0.5)
	]]
	
	
	----------------------------COOLDOWNS---------------------------------------
	createCombinedStatModifier("DCO.DroneNomadReductionDuration", "AdditiveMultiplier", "*", "Player", "DCO.DroneNomadCooldown", "BaseStats.MaxDuration", -0.5)

	
	----------------------------MASS OVERDRIVE---------------------------------
	--SE Clone
	TweakDB:CloneRecord("DCO.OverdriveSESpread", "DCO.OverdriveSE")
	TweakDB:SetFlat("DCO.OverdriveSESpread.packages", {"DCO.OverdriveSESpreadPackage"})
	
	TweakDB:CloneRecord("DCO.OverdriveSESpreadPackage", "DCO.OverdrivePackage")
	
	--Effector
	addToList("DCO.OverdrivePackage.effectors", "DCO.OverdriveMassEffector")
	
	TweakDB:CreateRecord("DCO.OverdriveMassEffector", "gamedataEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.OverdriveMassEffector.effectorClassName", "PingSquadEffector")
	TweakDB:SetFlat("DCO.OverdriveMassEffector.prereqRecord", "DCO.OverdriveMassStatPrereq")
	TweakDB:SetFlat("DCO.OverdriveMassEffector.level", 70, 'Float')
	
	--Stat prereq
	TweakDB:CreateRecord("DCO.OverdriveMassStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.OverdriveMassStatPrereq.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.OverdriveMassStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.OverdriveMassStatPrereq.statType", "CanElectrocuteNullifyStats")
	TweakDB:SetFlat("DCO.OverdriveMassStatPrereq.valueToCheck", 0)
	

	------------------------------MASS CLOAK------------------------------------
	--SE Clone
	TweakDB:CloneRecord("DCO.DroneCloakSESpread", "DCO.DroneCloakSE")
	TweakDB:SetFlat("DCO.DroneCloakSESpread.packages", {"DCO.DroneCloakSESpreadPackage", "BaseStatusEffect.Cloaked_inline0"})
	
	TweakDB:CloneRecord("DCO.DroneCloakSESpreadPackage", "DCO.DroneCloakPackage")
	
	--Effector
	addToList("DCO.DroneCloakPackage.effectors", "DCO.DroneCloakMassEffector")
	
	TweakDB:CreateRecord("DCO.DroneCloakMassEffector", "gamedataEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakMassEffector.effectorClassName", "PingSquadEffector")
	TweakDB:SetFlat("DCO.DroneCloakMassEffector.prereqRecord", "DCO.DroneCloakMassStatPrereq")
	TweakDB:SetFlat("DCO.DroneCloakMassEffector.level", 69, 'Float')
	
	--Stat prereq
	TweakDB:CreateRecord("DCO.DroneCloakMassStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakMassStatPrereq.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakMassStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakMassStatPrereq.statType", "CanAskToHolsterWeapon")
	TweakDB:SetFlat("DCO.DroneCloakMassStatPrereq.valueToCheck", 0)
	
	--Make our ping squad effector do this instead
	Override('PingSquadEffector', 'MarkSquad', function(self, mark, root, wrappedMethod)
		if self.quickhackLevel == 69  and mark then
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not v:IsDead() and not StatusEffectSystem.ObjectHasStatusEffect(v, TweakDBID.new("DCO.DroneCloakSE")) then
					StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("DCO.DroneCloakSESpread"))
				end
			end
			return
		end
		if self.quickhackLevel == 70 and mark then
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				debugPrint(filename, "u wot m9")
				debugPrint(filename, self.owner:GetRecordID())
				debugPrint(filename, v:GetRecordID())
				if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not v:IsDead() and not StatusEffectSystem.ObjectHasStatusEffect(v, TweakDBID.new("DCO.OverdriveSE")) then
					debugPrint(filename, ">>> applied?")
					StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("DCO.OverdriveSESpread"))
				end
			end
			return
		end
		if self.quickhackLevel == 71  and mark then
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and droneAlive(v) and v:GetNPCType() == gamedataNPCType.Android and not StatusEffectSystem.ObjectHasStatusEffect(v, TweakDBID.new("DCO.AndroidKerenzikovSE")) then
					StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("DCO.AndroidKerenzikovSESpread"))
				end
			end
			return
		end
		wrappedMethod(mark, root)
	end)
	-------------------------------DRONE HEAL-----------------------------------
	
	--Duration edit
	addToList("DCO.DroneHealDuration.statModifiers", "DCO.DroneHealModDuration")
	createCombinedStatModifier("DCO.DroneHealModDuration", "AdditiveMultiplier", "*", "Player", "DCO.DroneHealMod", "BaseStats.MaxDuration", -0.5)
	
	--Additional healing effector
	addToList("DCO.DroneHealPackage.effectors", "DCO.DroneHealModEffector")

	TweakDB:CloneRecord("DCO.DroneHealModEffector", "BaseStatusEffect.Health_Regen_inline4")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealModEffector.prereqRecord", "DCO.DroneHealModStatPrereq")
	TweakDB:SetFlat("DCO.DroneHealModEffector.poolModifier", "DCO.DroneHealModEffector_inline0")
	
	TweakDB:CloneRecord("DCO.DroneHealModEffector_inline0", "BaseStatusEffect.Health_Regen_inline5")
	TweakDB:SetFlat("DCO.DroneHealModEffector_inline0.valuePerSec", 6.6)
	
	
	--Stat prereq
	TweakDB:CreateRecord("DCO.DroneHealModStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealModStatPrereq.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealModStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.DroneHealModStatPrereq.statType", "HasTimedImmunity")
	TweakDB:SetFlat("DCO.DroneHealModStatPrereq.valueToCheck", 0)
	
	
	------------------------------DRONE CLOAK HEAL--------------------------
	
	addToList("DCO.DroneCloakPackage.effectors", "DCO.DroneCloakHealEffector")
	addToList("DCO.DroneCloakSESpreadPackage.effectors", "DCO.DroneCloakHealEffector")

	TweakDB:CloneRecord("DCO.DroneCloakHealEffector", "BaseStatusEffect.Health_Regen_inline4")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakHealEffector.prereqRecord", "DCO.DroneCloakHealStatPrereq")
	TweakDB:SetFlat("DCO.DroneCloakHealEffector.poolModifier", "DCO.DroneCloakHealEffector_inline0")
	
	TweakDB:CloneRecord("DCO.DroneCloakHealEffector_inline0", "BaseStatusEffect.Health_Regen_inline5")
	TweakDB:SetFlat("DCO.DroneCloakHealEffector_inline0.valuePerSec", 2)
	
	
	--Stat prereq
	TweakDB:CreateRecord("DCO.DroneCloakHealStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakHealStatPrereq.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakHealStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.DroneCloakHealStatPrereq.statType", "CallReinforcement")
	TweakDB:SetFlat("DCO.DroneCloakHealStatPrereq.valueToCheck", 0)
	
	
	---------------------------DRONE HACK DAMAGE--------------------------------
	TweakDB:CreateRecord("DCO.DroneHackDamageEffector", "gamedataApplyStatGroupEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneHackDamageEffector.effectorClassName", "ApplyStatGroupEffector")
	TweakDB:SetFlatNoUpdate("DCO.DroneHackDamageEffector.prereqRecord", "DCO.DroneHackDamageStatPrereq")
	TweakDB:SetFlat("DCO.DroneHackDamageEffector.statGroup", "DCO.DroneHackDamageEffector_inline0")


	TweakDB:CreateRecord("DCO.DroneHackDamageEffector_inline0", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneHackDamageEffector_inline0.statModsLimit", -1)
	TweakDB:SetFlat("DCO.DroneHackDamageEffector_inline0.statModifiers", {"DCO.DroneHackDamageEffector_inline1"})
	
	createConstantStatModifier("DCO.DroneHackDamageEffector_inline1", "AdditiveMultiplier", "BaseStats.NPCDamage", 0.1)
	
	TweakDB:CreateRecord("DCO.DroneHackDamageStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneHackDamageStatPrereq.comparisonType", "Greater")
	TweakDB:SetFlatNoUpdate("DCO.DroneHackDamageStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.DroneHackDamageStatPrereq.statType", "CanUseRetractableShield")
	TweakDB:SetFlat("DCO.DroneHackDamageStatPrereq.valueToCheck", 0)
	
	
	------------------------------MECH REGEN----------------------------------------
	
	TweakDB:CloneRecord("DCO.MechRegenAbility", "Ability.HasPassiveHealthRegeneration")
	TweakDB:SetFlat("DCO.MechRegenAbility.abilityPackage", "DCO.MechRegenAbility_inline0")
	
	TweakDB:CloneRecord("DCO.MechRegenAbility_inline0", "Ability.HasPassiveHealthRegeneration_inline0")
	TweakDB:SetFlat("DCO.MechRegenAbility_inline0.effectors", {--[["DCO.MechRegenAbility_inline1", ]]"DCO.MechRegenAbility_inline3"})

	--Ability version (DISABLED)
	TweakDB:CloneRecord("DCO.MechRegenAbility_inline1", "Ability.HasPassiveHealthRegeneration_inline1")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline1.prereqRecord", "DCO.MechRegenStatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline1.modificationType", "Decay")
	TweakDB:SetFlat("DCO.MechRegenAbility_inline1.poolModifier", "DCO.MechRegenAbility_inline2")

	TweakDB:CloneRecord("DCO.MechRegenAbility_inline2", "Ability.HasPassiveHealthRegeneration_inline2")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline2.rangeEnd", 100)
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline2.rangeBegin", 30)
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline2.startDelay", 0)
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline2.delayOnChange", false)
	TweakDB:SetFlat("DCO.MechRegenAbility_inline2.valuePerSec", .056)

	--Stat prereq
	TweakDB:CreateRecord("DCO.MechRegenStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenStatPrereq.comparisonType", "GreaterOrEqual")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenStatPrereq.statType", "CanCloseCombat")
	TweakDB:SetFlat("DCO.MechRegenStatPrereq.valueToCheck", 1)

	--Generic version
	TweakDB:CloneRecord("DCO.MechRegenAbility_inline3", "Ability.HasPassiveHealthRegeneration_inline1")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline3.prereqRecord", "Prereqs.AlwaysTruePrereq") --"DCO.MechRegenStatPrereqInv")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline3.modificationType", "Decay")
	TweakDB:SetFlat("DCO.MechRegenAbility_inline3.poolModifier", "DCO.MechRegenAbility_inline4")

	TweakDB:CloneRecord("DCO.MechRegenAbility_inline4", "Ability.HasPassiveHealthRegeneration_inline2")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline4.rangeEnd", 100)
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline4.startDelay", 0)
	TweakDB:SetFlatNoUpdate("DCO.MechRegenAbility_inline4.delayOnChange", false)
	TweakDB:SetFlat("DCO.MechRegenAbility_inline4.valuePerSec", .056)

	--Stat prereq
	TweakDB:CreateRecord("DCO.MechRegenStatPrereqInv", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenStatPrereqInv.comparisonType", "Equal")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenStatPrereqInv.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.MechRegenStatPrereqInv.statType", "CanCloseCombat")
	TweakDB:SetFlat("DCO.MechRegenStatPrereqInv.valueToCheck", 0)

	--Fix death animation
	Override('WithoutHitDataDeathTask', 'GetDeathReactionType', function(self, context, wrappedMethod)
		if ScriptExecutionContext.GetOwner(context):GetNPCType() == gamedataNPCType.Mech then
			return EnumInt(animHitReactionType.Death)
		end
		return wrappedMethod(context)
	end)
	
	------------------------DEATH EXPLOSION MULT------------------------------

	for i=1,DroneRecords do
		addToList("DCO.Tier1OctantArasaka"..i..".onSpawnGLPs", "DCO.FlyingDroneGLP")
		addToList("DCO.Tier1OctantMilitech"..i..".onSpawnGLPs", "DCO.FlyingDroneGLP")
		addToList("DCO.Tier1Griffin"..i..".onSpawnGLPs", "DCO.FlyingDroneGLP")
		addToList("DCO.Tier1Wyvern"..i..".onSpawnGLPs", "DCO.FlyingDroneGLP")
	end
	
	TweakDB:CreateRecord("DCO.FlyingDroneGLP", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.FlyingDroneGLP.effectors", {"Spawn_glp.Drone_GLP_inline0", "Spawn_glp.Drone_GLP_inline2", "DCO.FlyingDroneGLP_inline0"})
	
	TweakDB:CloneRecord("DCO.FlyingDroneGLP_inline0", "Spawn_glp.DroneGriffin_ExplodeOnDeath_inline0")
	TweakDB:SetFlat("DCO.FlyingDroneGLP_inline0.attackRecord", "DCO.FlyingDroneDeathExplosion")
	TweakDB:SetFlat("DCO.FlyingDroneGLP_inline0.attackPositionSlotName", CName.new("Chest"))

	TweakDB:CloneRecord("DCO.FlyingDroneDeathExplosion", "Attacks.DroneOctantDeathExplosion")
	TweakDB:SetFlat("DCO.FlyingDroneDeathExplosion.statModifiers", {"DCO.FlyingDroneDeathExplosion_inline0", "DCO.FlyingDroneDeathExplosion_inline1", "DCO.FlyingDroneDeathExplosion_inline2", "DCO.FlyingDroneDeathExplosion_inline3"})
	
	createCombinedStatModifier("DCO.FlyingDroneDeathExplosion_inline0", "AdditiveMultiplier", "*", "Parent", "DCO.DroneDeathExplosion", "BaseStats.PhysicalDamage", 1)
	createConstantStatModifier("DCO.FlyingDroneDeathExplosion_inline1", "Additive", "BaseStats.PhysicalDamage", 1)
	createCombinedStatModifier("DCO.FlyingDroneDeathExplosion_inline2", "Additive", "*", "Parent", "BaseStats.Health", "BaseStats.PhysicalDamage", 1)
	createConstantStatModifier("DCO.FlyingDroneDeathExplosion_inline3", "Multiplier", "BaseStats.PhysicalDamage", 0.5)

	
	----------------------------------MAKE EXPLODE MORE WORTHWHILE-----------------------
	
	TweakDB:CreateRecord("DCO.FlyingExplodeHackAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.FlyingExplodeHackAbility.abilityPackage", "DCO.FlyingExplodeHackGLP")
	
	--Give flying drones a big kaboom
	for i,v in ipairs(Flying_List) do
		if not(TweakDB:GetFlat(v..".audioResourceName") == CName.new("dev_drone_bombus_01")) then
		--	addToList(v..".onSpawnGLPs", "DCO.FlyingExplodeHackGLP")
			addToList(v..".abilities", "DCO.FlyingExplodeHackAbility")
			
		end
	end

	--Make big kaboom
	TweakDB:CreateRecord("DCO.FlyingExplodeHackGLP", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.FlyingExplodeHackGLP.effectors", {"DCO.FlyingExplodeHackGLP_inline0"})
	
	TweakDB:CreateRecord("DCO.FlyingExplodeHackGLP_inline0", "gamedataTriggerAttackEffector_Record")
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplodeHackGLP_inline0.attackRecord", "DCO.FlyingExplodeHackExplosion")
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplodeHackGLP_inline0.effectorClassName", "TriggerAttackOnOwnerEffect")
	TweakDB:SetFlat("DCO.FlyingExplodeHackGLP_inline0.prereqRecord", "DCO.FlyingExplodeHackGLP_inline1")
	TweakDB:SetFlat("DCO.FlyingExplodeHackGLP_inline0.attackPositionSlotName", CName.new("Chest"))

	TweakDB:CreateRecord("DCO.FlyingExplodeHackGLP_inline1", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplodeHackGLP_inline1.prereqClassName", "StatusEffectPrereq")
	TweakDB:SetFlat("DCO.FlyingExplodeHackGLP_inline1.statusEffect", "BaseStatusEffect.SuicideWithWeapon")
		
	TweakDB:CloneRecord("DCO.FlyingExplodeHackExplosion", "DCO.FlyingDroneDeathExplosion")
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplodeHackExplosion.range", 5)
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplodeHackExplosion.effectTag", "frag_explosion_underwater_shallow")
	createConstantStatModifier("DCO.FlyingExplodeHackExplosion_inline0", "Multiplier", "BaseStats.PhysicalDamage", 1.5)
	addToList("DCO.FlyingExplodeHackExplosion.statModifiers", "DCO.FlyingExplodeHackExplosion_inline0")
	
	--Make mechs explode their weakspots as well
	Observe('NPCPuppet', 'OnStatusEffectApplied', function(self, statusEffect)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) and self:GetNPCType() == gamedataNPCType.Mech and statusEffect.staticData:GetID() == TweakDBID.new("BaseStatusEffect.SuicideWithWeapon") then
			weakspots = self:GetWeakspotComponent():GetWeakspots()
			for i,v in ipairs(weakspots) do
				ScriptedWeakspotObject.Kill(weakspot, Game.GetPlayer())
			end
			StatusEffectHelper.ApplyStatusEffect(self, TweakDBID.new("Minotaur.RightArmDestroyed"))
			StatusEffectHelper.ApplyStatusEffect(self, TweakDBID.new("Minotaur.LeftArmDestroyed"))
			
			self:Kill()
		end
	end)
	
	------------------------ANDROID DILATION ABILITIES-------------------------
	
	--Add the default additive mult of -1, that gets cancelled out when player increases dilation stat
	createConstantStatModifier("DCO.DroneAndroidDilationDefaultSandevistan", "AdditiveMultiplier", "BaseStats.HasSandevistanTier1", -1)
	createConstantStatModifier("DCO.DroneAndroidDilationDefaultSandevistanTier1", "AdditiveMultiplier", "BaseStats.HasSandevistan", -1)
	createConstantStatModifier("DCO.DroneAndroidDilationDefaultKerenzikov", "AdditiveMultiplier", "BaseStats.HasKerenzikov", -1)

	addListToList("DCO.AndroidStatGroup", "statModifiers", {"DCO.DroneAndroidDilationDefaultSandevistan", "DCO.DroneAndroidDilationDefaultSandevistanTier1", "DCO.DroneAndroidDilationDefaultKerenzikov"})
	
	------------------------ANDROID REGEN ABILITY-------------------------
	
	TweakDB:CreateRecord("DCO.DroneRegenAbility", "gamedataGameplayAbility_Record")
	TweakDB:SetFlat("DCO.DroneRegenAbility.abilityPackage", "DCO.DroneRegenAbility_inline1")
	
	TweakDB:CreateRecord("DCO.DroneRegenAbility_inline1", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat("DCO.DroneRegenAbility_inline1.effectors", {"DCO.DroneRegenAbility_inline2"})
	
	TweakDB:CloneRecord("DCO.DroneRegenAbility_inline2", "Ability.HasPassiveHealthRegeneration_inline1")
	TweakDB:SetFlatNoUpdate("DCO.DroneRegenAbility_inline2.prereqRecord", "DCO.DroneRegenStatPrereq")
	TweakDB:SetFlat("DCO.DroneRegenAbility_inline2.poolModifier", "DCO.DroneRegenAbility_inline3")

	TweakDB:CloneRecord("DCO.DroneRegenAbility_inline3", "Ability.HasPassiveHealthRegeneration_inline2")
	TweakDB:SetFlatNoUpdate("DCO.DroneRegenAbility_inline3.startDelay", 2)
	TweakDB:SetFlatNoUpdate("DCO.DroneRegenAbility_inline3.delayOnChange", true)
	TweakDB:SetFlat("DCO.DroneRegenAbility_inline3.valuePerSec", 1)
	
	TweakDB:CreateRecord("DCO.DroneRegenStatPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.DroneRegenStatPrereq.comparisonType", "GreaterOrEqual")
	TweakDB:SetFlatNoUpdate("DCO.DroneRegenStatPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.DroneRegenStatPrereq.statType", "CanCallDrones")
	TweakDB:SetFlat("DCO.DroneRegenStatPrereq.valueToCheck", 1)


	
	---------------------------EWS EXPLOSION ABILITY----------------------------------
	
	--Base stat prereq
	TweakDB:CreateRecord("DCO.HealthMonitorBombMultiPrereq", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealthMonitorBombMultiPrereq.aggregationType", "AND")
	TweakDB:SetFlatNoUpdate("DCO.HealthMonitorBombMultiPrereq.nestedPrereqs", {--[[ "DCO.FlyingExplosionsPrereq",]] "DCO.HealthMonitorBombMultiPrereq_inline0"})
	TweakDB:SetFlat("DCO.HealthMonitorBombMultiPrereq.prereqClassName", "gameMultiPrereq")
	
	--Has overcharge prereq
	TweakDB:CreateRecord("DCO.HealthMonitorBombMultiPrereq_inline0", "gamedataMultiPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealthMonitorBombMultiPrereq_inline0.aggregationType", "OR")
	TweakDB:SetFlatNoUpdate("DCO.HealthMonitorBombMultiPrereq_inline0.nestedPrereqs", {"DCO.HealthMonitorBombMultiPrereq_inline1", "DCO.HealthMonitorBombMultiPrereq_inline2"})
	TweakDB:SetFlat("DCO.HealthMonitorBombMultiPrereq_inline0.prereqClassName", "gameMultiPrereq")
	

	TweakDB:CreateRecord("DCO.HealthMonitorBombMultiPrereq_inline1", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealthMonitorBombMultiPrereq_inline1.prereqClassName", "StatusEffectPrereq")
	TweakDB:SetFlat("DCO.HealthMonitorBombMultiPrereq_inline1.statusEffect", "DCO.EWSSE")

	TweakDB:CreateRecord("DCO.HealthMonitorBombMultiPrereq_inline2", "gamedataStatusEffectPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.HealthMonitorBombMultiPrereq_inline2.prereqClassName", "StatusEffectPrereq")
	TweakDB:SetFlat("DCO.HealthMonitorBombMultiPrereq_inline2.statusEffect", "DCO.EWSSESpread")


	--Player has stat prereq
	TweakDB:CreateRecord("DCO.FlyingExplosionsPrereq", "gamedataStatPrereq_Record")
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplosionsPrereq.comparisonType", "GreaterOrEqual")
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplosionsPrereq.prereqClassName", "StatPrereq")
	TweakDB:SetFlatNoUpdate("DCO.FlyingExplosionsPrereq.statType", "HasWallRunSkill")
	TweakDB:SetFlat("DCO.FlyingExplosionsPrereq.valueToCheck", 1)

	--Create abilities
	--[[
	createHealthMonitorBombAbility("DCO.GriffinExplosion", "Attacks.LightBiotechGrenade", 5)
	createHealthMonitorBombAbility("DCO.WyvernExplosion", "Attacks.EMPGrenade", 5)
	createHealthMonitorBombAbility("DCO.OctantExplosion", "Attacks.IncendiaryGrenade", 5)
	createHealthMonitorBombAbility("DCO.BombusExplosion", "DCO.BombusExplosionEffect", 5)
	]]
	
	createHealthMonitorBombAbility("DCO.EWSExplosion", "DCO.BombusExplosionEffect", 6)


	TweakDB:CloneRecord("DCO.BombusExplosionEffect", "Attacks.FragGrenadeUnderwaterShallow")
	TweakDB:SetFlatNoUpdate("DCO.BombusExplosionEffect.range", 3.5)
	TweakDB:SetFlatNoUpdate("DCO.BombusExplosionEffect.effectTag", "missile_explosion")
	TweakDB:SetFlat("DCO.BombusExplosionEffect.statusEffects", {"DCO.BombusExplosionEffect_inline0"})
	
	TweakDB:CloneRecord("DCO.BombusExplosionEffect_inline0", "Attacks.BaseFragExplosion_inline0")
	TweakDB:SetFlat("DCO.BombusExplosionEffect_inline0.statusEffect", "BaseStatusEffect.Bleeding")
	
	
	--Add abilities
	for i,v in ipairs(Full_Drone_List) do
		addToList(v..".abilities", "DCO.EWSExplosion")
	end
	--[[
	for i=1,DroneRecords do
		addToList("DCO.Tier1Griffin"..i..".abilities", "DCO.GriffinExplosion")
		addToList("DCO.Tier1Wyvern"..i..".abilities", "DCO.WyvernExplosion")
		addToList("DCO.Tier1OctantArasaka"..i..".abilities", "DCO.OctantExplosion")
		addToList("DCO.Tier1OctantMilitech"..i..".abilities", "DCO.OctantExplosion")
		addToList("DCO.Tier1Bombus"..i..".abilities", "DCO.BombusExplosion")
		
		addToList("DCO.Tier1AndroidRanged"..i..".abilities", "DCO.WyvernExplosion")
		addToList("DCO.Tier1AndroidMelee"..i..".abilities", "DCO.WyvernExplosion")
		addToList("DCO.Tier1AndroidShotgunner"..i..".abilities", "DCO.WyvernExplosion")
		addToList("DCO.Tier1AndroidHeavy"..i..".abilities", "DCO.WyvernExplosion")
		addToList("DCO.Tier1AndroidSniper"..i..".abilities", "DCO.WyvernExplosion")
		addToList("DCO.Tier1AndroidNetrunner"..i..".abilities", "DCO.WyvernExplosion")

	end
	]]
	--[[
	----------------------------------ARASAKA MECH SHOCK/BLIND IMMUNITY----------------------------------------------
	
	createConstantStatModifier("DCO.MechArasakaShockImmunity", "Additive", "BaseStats.ElectrocuteImmunity", 1)
	createConstantStatModifier("DCO.MechArasakaEMPImmunity", "Additive", "BaseStats.EMPImmunity", 1)
	createConstantStatModifier("DCO.MechArasakaBlindImmunity", "Additive", "BaseStats.BlindImmunity", 1)

	for i=1, DroneRecords do
		addListToList("DCO.Tier1MechArasaka"..i, "statModifiers", {"DCO.MechArasakaShockImmunity", "DCO.MechArasakaEMPImmunity", "DCO.MechArasakaBlindImmunity"})
	end	
	]]
	
	-------------------------------ARASAKA MECH HIGHLIGHTING----------------------------------------------
	
	--Add base tag
	CName.add("DCOHighlight")
	for i=1,DroneRecords do
		TweakDB:SetFlat("DCO.Tier1MechArasaka"..i..".tags", {"Robot", "DCOHighlight"})
	end
	
	--Make scannable through walls
	Override('ScanningComponent', 'OnRevealStateChanged', function(self, evt, wrappedMethod)
		if not self:GetEntity():IsNPC() or not self:GetEntity():GetRecord():TagsContains(CName.new("Robot")) then
			wrappedMethod(evt)
			return
		end
		
		if evt.state == ERevealState.STARTED then
			self:SetScannableThroughWalls(true)
		elseif evt.state == ERevealState.STOPPED then
			self:SetScannableThroughWalls(false)
		end
		
	end)
	
	--Make the highlight effect get applied/removed
	Observe('NPCPuppet', 'OnPlayerCompanionCacheData', function(self, evt)
		if self:GetRecord():TagsContains(CName.new("DCOHighlight")) and droneAlive(self) then
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if v:GetRecord():TagsContains("Robot") and droneAlive(v) then
					if Game.GetPlayer():IsInCombat() then
						StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("DCO.HighlightSE"))
					else
						StatusEffectHelper.RemoveStatusEffect(v, TweakDBID.new("DCO.HighlightSE"))
					end
				end
			end
		end
	end)

	Observe('NPCPuppet', 'OnIncapacitated', function(self)
		
		--Remove drone highlight when they die
		if self:GetRecord():TagsContains("Robot") then
			StatusEffectHelper.RemoveStatusEffect(v, TweakDBID.new("DCO.HighlightSE"))
		end
		
		--Remove all drone highlights when highlighter dies
		if self:GetRecord():TagsContains(CName.new("DCOHighlight")) then
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if v:GetRecord():TagsContains("Robot") then
					StatusEffectHelper.RemoveStatusEffect(v, TweakDBID.new("DCO.HighlightSE"))
				end
			end
		end
	end)
	TweakDB:CloneRecord("DCO.HighlightSE", "BaseStatusEffect.Ping")
	
	
	-----------------------------------ARASAKA MECH TECHACK DURATION------------------------------------------
	createCombinedStatModifier("DCO.TechHackDurationModifier", "AdditiveMultiplier", "*", "Self", "DCO.DroneTechHackDuration", "BaseStats.MaxDuration", 1)
	addToList("DCO.DroneCloakDuration.statModifiers", "DCO.TechHackDurationModifier")
	addToList("DCO.OverdriveDuration.statModifiers", "DCO.TechHackDurationModifier")

	createConstantStatModifier("DCO.MechArasakaTechHackDuration", "Additive", "DCO.DroneTechHackDuration", 0.5)
	for i=1, DroneRecords do
		addToList("DCO.Tier1MechArasaka"..i..".statModifiers", "DCO.MechArasakaTechHackDuration")
	end	

	-----------------------------------NCPD MECH NERFS---------------------------------------------------------
	createConstantStatModifier("DCO.MechNCPDHP", "Multiplier", "BaseStats.Health", 0.67)
	createConstantStatModifier("DCO.MechNCPDDPS", "Multiplier", "BaseStats.NPCDamage", 0.67)

	for i=1, DroneRecords do
		addListToList("DCO.Tier1MechNCPD"..i, "statModifiers", {"DCO.MechNCPDDPS", "DCO.MechNCPDHP"})
	end
	-----------------------------------MILITECH MECH WEAKSPOT HP BONUS------------------------------------------
	createCombinedStatModifier("DCO.MechWeakspotHPModifier", "AdditiveMultiplier", "*", "Owner", "DCO.DroneWeakspotHP", "BaseStats.Health", 1)
	addToList("Weakspots.Mech_Weapon_Weakspot_Stats.statModifiers", "DCO.MechWeakspotHPModifier")
	
	createConstantStatModifier("DCO.MechMilitechWeakspotHPBonus", "Additive", "DCO.DroneWeakspotHP", 0.5)
	for i=1, DroneRecords do
		addToList("DCO.Tier1MechMilitech"..i..".statModifiers", "DCO.MechMilitechWeakspotHPBonus")
	end
	
	-------------------------------------EXPLOSIVE MILITECH MECH BULLETS---------------------------------------
	
	MechBulletExplosion = TweakDBInterface.GetAttack_GameEffectRecord(TweakDBID.new("Attacks.BulletSmartBulletHighExplosion"))
	
	Override('sampleSmartBullet' ,'OnCollision', function(self, projectileHitEvent, wrappedMethod)
		charRecord = TweakDBInterface.GetCharacterRecord(self.owner:GetRecordID())
		if charRecord:TagsContains(CName.new("Robot")) and charRecord:VisualTagsContains(CName.new("Militech")) and self.owner:GetNPCType() == gamedataNPCType.Mech then
		damageHitEvent = gameprojectileHitEvent:new()
			for i=1, table.getn(projectileHitEvent.hitInstances) do
				hitInstance = projectileHitEvent.hitInstances[i]
				if self.alive then
					gameObj = GameObject:new()
					gameObj = hitInstance.hitObject
					weaponObj = WeaponObject:new()
					weaponObj = self.weapon
					targetHasJammer = IsDefined(gameObj) and gameObj:HasTag(CName.new("jammer"))

					if not targetHasJammer then
						table.insert(damageHitEvent.hitInstances, hitInstance)
					end
	
					if not gameObj:HasTag(CName.new("bullet_no_destroy")) and self.BulletCollisionEvaluator:HasReportedStopped() and hitInstance.position == self.BulletCollisionEvaluator:GetStoppedPosition() then
						self:BulletRelease()
						if not self.HasExploded and IsDefined(self.attack) then
							self.hasExploded = true
							Attack_GameEffect.SpawnExplosionAttack(MechBulletExplosion, weaponObj, self.owner, self, hitInstance.position, 0.05)
						end
						if not targetHasJammer and not gameObj:HasTag(CName.new("MeatBag")) then
							self.countTime = 0
							self.alive = false
							self.hit = true
						end
					end
				end
			end
			if table.getn(damageHitEvent.hitInstances)>0 then
				self.DealDamage(damageHitEvent)
			end
			return
		end
		
		wrappedMethod(projectileHitEvent)
	end)
		
	---------------------------STATUS EFFECT ABILITIES---------------------
	
	createStatusEffectAbility("DCO.CanCauseBurn", "Ability.CanCauseBurn", "BaseStats.BurningApplicationRate", "BaseStats.ThermalDamage")
	createStatusEffectAbility("DCO.CanCauseShock", "Ability.CanCauseElectrocution", "BaseStats.ElectrocutedApplicationRate", "BaseStats.ElectricDamage")
	createStatusEffectAbility("DCO.CanCausePoison", "Ability.CanCausePoison", "BaseStats.PoisonedApplicationRate", "BaseStats.ChemicalDamage")
	createStatusEffectAbility("DCO.CanCauseBleed", "Ability.CanCausePoison", "BaseStats.BleedingApplicationRate", "BaseStats.PhysicalDamage")

	for i,v in ipairs(Full_Drone_List) do
		addListToList(v, "abilities", {"DCO.CanCauseShock", "DCO.CanCauseBurn", "DCO.CanCausePoison"})
	end
	
	--[[
	for i=1,DroneRecords do
		addToList("DCO.Tier1Griffin"..i..".abilities", "DCO.CanCausePoison")
		addToList("DCO.Tier1Wyvern"..i..".abilities", "DCO.CanCauseShock")
		addToList("DCO.Tier1OctantArasaka"..i..".abilities", "DCO.CanCauseBleed")
		addToList("DCO.Tier1OctantMilitech"..i..".abilities", "DCO.CanCauseBleed")
		addToList("DCO.Tier1Bombus"..i..".abilities", "DCO.CanCauseBurn")
		
		addToList("DCO.Tier1AndroidRanged"..i..".abilities", "DCO.CanCauseBleed")
		addToList("DCO.Tier1AndroidMelee"..i..".abilities", "DCO.CanCauseBleed")
		addToList("DCO.Tier1AndroidShotgunner"..i..".abilities", "DCO.CanCauseBurn")
		addToList("DCO.Tier1AndroidHeavy"..i..".abilities", "DCO.CanCauseShock")
		addToList("DCO.Tier1AndroidSniper"..i..".abilities", "DCO.CanCausePoison")
		addToList("DCO.Tier1AndroidNetrunner"..i..".abilities", "DCO.CanCauseShock")

	end
	]]
	
	-----------------------------COST LESS TO CRAFT--------------------------

	half_craftables = {"OctantArasaka", "OctantMilitech", "Griffin", "Wyvern", "Bombus", "AndroidRanged", "AndroidMelee", "AndroidShotgunner", "AndroidHeavy", "AndroidSniper", "AndroidNetrunner"}
	
	Override('CraftingSystem', 'GetItemCraftingCost;Item_Recordarray<RecipeElement_Record>', function(self, record, craftingData, wrappedMethod)
	
		baseIngredients = wrappedMethod(record, craftingData)
		
		statsObjID = StatsObjectID:new()
		statsObjID = Game.GetPlayer():GetEntityID()
		playerHasStat = Game.GetStatsSystem():GetStatValue(statsObjID, gamedataStatType.NPCUnequipItemDuration)
			
		if playerHasStat == 1 then
			recordID = record:GetID()
			halfcraftablefound = false
			for i,v in ipairs(half_craftables) do
				if TweakDBID.new("DCO.Tier1"..v.."Item") == recordID then
					halfcraftablefound = true
					break
				end
			end
			
			if halfcraftablefound then
				for i,v in ipairs(baseIngredients) do
					if v.id:GetID() == TweakDBID.new("DCO.DroneCore") then
						temp = v.quantity
						temp =  math.ceil(temp - (v.baseQuantity/2))
						v.quantity = temp
						baseIngredients[i] = v
					end
				end
			end
		end
		return baseIngredients
		
		
	end)
	
	
	
	----------------------------------ADVANCED WEAPONS SELECTION-------------------------------------
	
	--Check for our custom weight, and if so, return the first object when player has the perk, second if they have the perk
	Override('AIActionTransactionSystem', 'ChooseSingleItemsSetFromPool;Int32Uint32NPCEquipmentItemPool_Record', function(powerLevel, seed, itemPool, wrappedMethod)
		DCOWeightFound = false
		poolSize = itemPool:GetPoolCount()
		for i=0,poolSize-1 do
			tempPoolEntry = itemPool:GetPoolItem(i)
			weight = tempPoolEntry:Weight()
			if weight == 69420 then
				DCOWeightFound = true
				break
			end
		end
		if DCOWeightFound then
			statsObjID = StatsObjectID:new()
			statsObjID = Game.GetPlayer():GetEntityID()
			playerHasStat = Game.GetStatsSystem():GetStatValue(statsObjID, gamedataStatType.CanCatchUp)
			if playerHasStat == 1 then
				return itemPool:GetPoolItem(1):Items()
			else
				return itemPool:GetPoolItem(0):Items()
			end
		end
		return wrappedMethod(powerLevel, seed, itemPool)
	end)
	
	---------------------------------ARMOR PROCESSING FOR OUR DRONES-----------------------------------------------
	TweakDB:SetFlat("DCO.BossToDroneDamage", 1, 'Float')
	TweakDB:SetFlat("DCO.BossToMechDamage", 4, 'Float')
	TweakDB:SetFlat("DCO.OdaToDroneDamage", 12, 'Float')
	TweakDB:SetFlat("DCO.SasquatchToDroneDamage", 12, 'Float')
	TweakDB:SetFlat("DCO.SmasherToDroneDamage", 1, 'Float')
	TweakDB:SetFlat("DCO.ExoToDroneDamage", 6, 'Float')

	
	Override('DamageSystem', 'ProcessArmor', function(self, hitEvent, wrappedMethod)
		
		if hitEvent.target and TweakDBInterface.GetCharacterRecord(hitEvent.target:GetRecordID()):TagsContains(CName.new("Robot")) then
			 weapon = hitEvent.attackData:GetWeapon()
		    if IsDefined(weapon) and WeaponObject.CanIgnoreArmor(weapon) then
				return
			end
			if not IsDefined(weapon) then
				return
			end
			armorPoints = Game.GetStatsSystem():GetStatValue(hitEvent.target:GetEntityID(), gamedataStatType.Armor)
			reduction = 1-armorPoints/100.0
			if reduction<0.5 then
				reduction = 0.5
			end
			if reduction>1.5 then
				reduction = 1.5
			end
			
			--Adjust boss damage to our drones
			attackValues = hitEvent.attackComputed:GetAttackValues()
			instigator = hitEvent.attackData:GetInstigator()
			target = hitEvent.target
			targetType = target:GetNPCType()
			instigatorArchetype = TweakDBInterface.GetCharacterRecord(instigator:GetRecordID()):ArchetypeName()
			for i,v in ipairs(attackValues) do
				attackValues[i] = attackValues[i] * reduction
				if instigator:IsBoss() then
					attackValues[i] = attackValues[i] * TweakDB:GetFlat("DCO.BossToDroneDamage")
					
					--Special bosses do 3x more
					if instigatorArchetype == CName.new("oda") then
						attackValues[i] = attackValues[i] * TweakDB:GetFlat("DCO.OdaToDroneDamage")
					elseif instigatorArchetype == CName.new("adamsmasher") then
						attackValues[i] = attackValues[i] * TweakDB:GetFlat("DCO.SmasherToDroneDamage")
					elseif instigatorArchetype == CName.new("sasquatch") then
						attackValues[i] = attackValues[i] * TweakDB:GetFlat("DCO.SasquatchToDroneDamage")
					elseif instigatorArchetype == CName.new("exo") then
						attackValues[i] = attackValues[i] * TweakDB:GetFlat("DCO.ExoToDroneDamage")
					end
					
					--Mechs need to be shredded
					if targetType == gamedataNPCType.Mech then
						attackValues[i] = attackValues[i] * TweakDB:GetFlat("DCO.BossToMechDamage")
					end
				end
			end
			hitEvent.attackComputed:SetAttackValues(attackValues)

			return
		end
		
		--Make our drones do less damage to bosses
		if TweakDBInterface.GetCharacterRecord(hitEvent.attackData:GetInstigator():GetRecordID()):TagsContains(CName.new("Robot")) then
attackValues = hitEvent.attackComputed:GetAttackValues()
			target = hitEvent.target
			if target:IsBoss() then
				for i,v in ipairs(attackValues) do
					attackValues[i] = attackValues[i] * 0.5
				end
			end
			hitEvent.attackComputed:SetAttackValues(attackValues)

		end
			
		wrappedMethod(hitEvent)
	end)
	
	
	
	-------------------------SOME TECHHACK TECHNICALITIES--------------------------------
	
	------------------------ENABLE TECH HACKS W/OUT CYBERDECK TAG-------------------------
	
	Override('EquipmentSystem', 'IsCyberdeckEquipped;GameObject', function(owner, wrappedMethod)
		statsObjID = StatsObjectID:new()
		statsObjID = Game.GetPlayer():GetEntityID()
		if Game.GetStatsSystem():GetStatValue(statsObjID, gamedataStatType.NPCAnimationTime) >0 then --If dronenumber >0
			return true
		end
		return wrappedMethod(owner)
	end)
	
	
	------------------------------TECHDECK CYBERDECK UI ELEMENTS----------------------------
	
	--Memory widget near health bar
	Override('healthbarWidgetGameController', 'IsCyberdeckEquipped', function(self, wrappedMethod)
		statsObjID = StatsObjectID:new()
		statsObjID = Game.GetPlayer():GetEntityID()
		if Game.GetStatsSystem():GetStatValue(statsObjID, gamedataStatType.NPCAnimationTime) >0 then --If dronenumber >0
			return true
		end
		return wrappedMethod(owner)
	end)
	
	--Use cyberdeck style tooltip for techdecks
	Override('RipperDocGameController', 'ShowCWTooltip', function(self, itemData, itemTooltipData, wrappedMethod)
		if itemTooltipData.description == "LocKey#49555" then
			self.TooltipsManager:ShowTooltip(CName.new("cyberdeckTooltip"), itemTooltipData, inkMargin:new(60.00, 60.00, 0.00, 0.00))
			return
		end
		wrappedMethod(itemData, itemTooltipData)
		
	end)
	
	--Fix attribute requirement for cyberdecks
	Override('CyberdeckTooltip', 'UpdateRequirements', function(self, wrappedMethod)
		wrappedMethod()
		record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(self.data.inventoryItemData.ID))
		if record:TagsContains(CName.new("Robot")) and not InventoryItemData.IsEquippable(self.data.inventoryItemData) then
			requiredValue = record:EquipPrereqs()[1]:ValueToCheck()
			textParams = inkTextParams:new()
			textParams:AddNumber("value", requiredValue)
			textParams:AddString("statName", GetLocalizedText("LocKey#22276"))
			textParams:AddString("statColor", "StatTypeColor."..EnumValueToString("gamedataStatType", EnumInt(gamedataStatType.TechnicalAbility)))
			inkTextRef.SetLocalizedTextScript(self.itemAttributeRequirementsText, "LocKey#77652", textParams)
		end
	end)
	
	--Set buffer size to N/A
	Override('CyberdeckTooltip', 'UpdateCyberdeckStats', function(self, wrappedMethod)
		wrappedMethod()
		if self.data.description == "LocKey#49555" then
			inkTextRef.SetText(self.cybderdeckBufferValue, "N/A")
		end
	end)
	
	--Show hacks
	Override('CyberdeckTooltip', 'GetCyberdeckDeviceQuickhacks;', function(self, wrappedMethod)
		
		
		if self.data.description == "LocKey#49555" then
			deviceHacks = {}
			i = 0
			objectActionType = ObjectActionType_Record:new()
			objectActions = {}
			result = {}
			tweakRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(InventoryItemData.GetID(self.data.inventoryItemData)))
			objectActions = tweakRecord:ObjectActions()
			i = 1
			while i <= table.getn(objectActions) do
			  objectActionType = objectActions[i]:ObjectActionType()
			  if IsDefined(objectActionType) then
				  table.insert(deviceHacks, objectActions[i])
			  end
			  i  = i+1
			end
			i = 1
			while i <= table.getn(deviceHacks) do
			  uiAction = deviceHacks[i]:ObjectActionUI()
				data = CyberdeckDeviceQuickhackData:new()
			  data.UIIcon = uiAction:CaptionIcon():TexturePartID()
			  data.ObjectActionRecord = deviceHacks[i]
			  table.insert(result, data)
			  i = i+1
			end
			return result
		end
		
		return wrappedMethod()
	
	end)

	--Descriptions
	Override('CyberdeckTooltip', 'UpdateDescription', function(self,wrappedMethod)
		if self.data.description == "LocKey#49555" then
				desc = ""
				localizedName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(self.data.itemID)):LocalizedName()
				for i in string.gmatch(localizedName, "%b{}") do
					desc = i
				end
				desc = string.sub(desc, 2, #desc-1)

			inkTextRef.SetText(self.descriptionText, desc);		
			inkWidgetRef.SetVisible(self.descriptionContainer, true)
			return
		end
		wrappedMethod()
	end)


	--Change top text from Cyberdeck
	--[[
	Override('CyberdeckTooltip', 'UpdateLayout', function(self, wrappedMethod)	
	widge = inkCompoundRef.GetWidget(self.topContainer, 0)
	widge:SetTranslation(0, 100)
	print(widge:GetText())
--inkTextRef.SetText(self.itemAttributeRequirementsText, "Fuck a oy")

		wrappedMethod()

	end)]]
	---------------DISABLE JACKING IN---------------------------------
	--[[Override('ScriptableDeviceComponentPS', 'HasCyberdeck', function(self, wrappedMethod)
		if Game.GetStatsSystem():GetStatValue(Game.GetPlayer():GetEntityID(), gamedataStatType.NPCAnimationTime) > 0 then
			return false
		end
		return wrappedMethod()
	end)]]
end

function createHealthMonitorBombAbility(recordName, explosion, numContinuedExplosions)

	--Base ability
	TweakDB:CloneRecord(recordName, "Ability.HasHealthMonitorBomb")
	TweakDB:SetFlat(recordName..".abilityPackage", recordName.."_inline1")
	
	TweakDB:CloneRecord(recordName.."_inline1", "Ability.HasHealthMonitorBomb_inline1")
	TweakDB:SetFlat(recordName.."_inline1.effectors", {recordName.."_inline3", recordName.."_inline5", recordName.."_inline7"})
	
	--Abilities
	TweakDB:CloneRecord(recordName.."_inline3", "Ability.HasHealthMonitorBomb_inline3")
	TweakDB:CloneRecord(recordName.."_inline5", "Ability.HasHealthMonitorBomb_inline5")
	TweakDB:CloneRecord(recordName.."_inline7", "Ability.HasHealthMonitorBomb_inline7")

	
	TweakDB:SetFlat(recordName.."_inline3.prereqRecord", "DCO.HealthMonitorBombMultiPrereq")
	TweakDB:SetFlat(recordName.."_inline5.prereqRecord", "DCO.HealthMonitorBombMultiPrereq")
	TweakDB:SetFlat(recordName.."_inline7.prereqRecord", "DCO.HealthMonitorBombMultiPrereq")
	
	TweakDB:SetFlat(recordName.."_inline3.effectorToApply", recordName.."_inline10")
	
	TweakDB:SetFlat(recordName.."_inline7.startOnUninitialize", false)
	TweakDB:SetFlat(recordName.."_inline7.vfxName", CName.new("status_electrocuted"))

	--Kaboom
	TweakDB:CloneRecord(recordName.."_inline10", "Effectors.SelfDestructEffect")
	TweakDB:SetFlat(recordName.."_inline10.attackRecord", explosion)
	TweakDB:SetFlat(recordName.."_inline10.prereqRecord", "Prereqs.AlwaysTruePrereq")

	
	--Make additional kabooms
	for i=1,numContinuedExplosions do
		num = 20 + i
		num2 = 30+i
		num3 = 40 +i
		explosion2 = ""
		
		if i%4 == 0 then
			explosion2 = "DCO.BombusExplosionEffect"
		elseif i%4 == 1 then
			explosion2 = "Attacks.EMPGrenade"
		elseif i%4 == 2 then
			explosion2 = "Attacks.IncendiaryGrenade"
		elseif i%4 == 3 then
			explosion2 = "Attacks.LightBiotechGrenade"
		end

		addToList(recordName.."_inline1.effectors", recordName.."_inline"..num)
		
		TweakDB:CloneRecord(recordName.."_inline"..num, recordName.."_inline3")
		TweakDB:SetFlat(recordName.."_inline"..num..".effectorToApply", recordName.."_inline"..num2)
		
		TweakDB:CloneRecord(recordName.."_inline"..num2, recordName.."_inline10")
		TweakDB:SetFlatNoUpdate(recordName.."_inline"..num2..".attackRecord", explosion2)
		TweakDB:SetFlat(recordName.."_inline"..num2..".prereqRecord", recordName.."_inline"..num3)
	
		--Time prereqs
		TweakDB:CreateRecord(recordName.."_inline"..num3, "gamedataIPrereq_Record")
		TweakDB:SetFlat(recordName.."_inline"..num3..".prereqClassName", "TemporalPrereq")
		TweakDB:SetFlat(recordName.."_inline"..num3..".duration", i*5, 'Float')
		TweakDB:SetFlat(recordName.."_inline"..num3..".randRange", 2, 'Float')
	end
	
--[[
	TweakDB:SetFlatNoUpdate("NPCAttacks.SelfDestructionBomb.effectName", "projectile_aoe")
	TweakDB:SetFlatNoUpdate("NPCAttacks.SelfDestructionBomb.effectTag", "thermal_round_charged")
	TweakDB:SetFlatNoUpdate("NPCAttacks.SelfDestructionBomb.range", 5)
	TweakDB:SetFlatNoUpdate("NPCAttacks.SelfDestructionBomb.statModifiers", {"DCO.SelfDestructDamage"})
	TweakDB:SetFlat("NPCAttacks.SelfDestructionBomb.damageType", "DamageTypes.Thermal")
	
	TweakDB:CloneRecord("DCO.SelfDestructDamage", "Character.NPC_Base_Curves_inline1")
	TweakDB:SetFlat("DCO.SelfDestructDamage.statType", "BaseStats.ThermalDamage")
	
	TweakDB:SetFlat("NPCAttacks.SelfDestructionBomb_inline1.statusEffect", "BaseStatusEffect.Burning")
	]]--
	
end
function createTechDeckEffectDescription(recordName, desc)
	TweakDB:CreateRecord(recordName, "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat(recordName..".UIData", recordName.."UIData")
	
	TweakDB:CreateRecord(recordName.."UIData", "gamedataGameplayLogicPackageUIData_Record")
	TweakDB:SetFlatNoUpdate(recordName.."UIData.iconPath", "ability_silenced")
	TweakDB:SetFlat(recordName.."UIData.localizedDescription", desc)
end

function createTechHack(recordName, actionName, displayName, captionPart, baseStatusEffect, duration, activationTime, cooldown, cost, statsList, gameplayTags, vfx, SEIcon)
	
	--Object action
	TweakDB:CreateRecord(recordName, "gamedataObjectAction_Record")
	TweakDB:SetFlatNoUpdate(recordName..".actionName", actionName)
	TweakDB:SetFlatNoUpdate(recordName..".instigatorPrereqs", {recordName.."CooldownCheck"})
	TweakDB:SetFlatNoUpdate(recordName..".activationTime", {recordName.."ActivationTime"})
	TweakDB:SetFlatNoUpdate(recordName..".objectActionType", "ObjectActionType.PuppetQuickHack")
	TweakDB:SetFlatNoUpdate(recordName..".interactionLayer", "remote")
	TweakDB:SetFlatNoUpdate(recordName..".priority", 3)
	TweakDB:SetFlatNoUpdate(recordName..".costs", {recordName.."Cost"})
	TweakDB:SetFlatNoUpdate(recordName..".rewards", {"RPGActionRewards.Engineering"})
	TweakDB:SetFlatNoUpdate(recordName..".hackCategory", "")
	TweakDB:SetFlatNoUpdate(recordName..".objectActionUI", recordName.."Interaction")
	TweakDB:SetFlatNoUpdate(recordName..".startEffects", {recordName.."CooldownEffect"})
	TweakDB:SetFlat(recordName..".completionEffects", {recordName.."Effect"})
	TweakDB:SetFlat(recordName..".isQuickHack", true)
	
	--Cost
	
	
	TweakDB:CreateRecord(recordName.."Cost", "gamedataStatPoolCost_Record")
	TweakDB:SetFlatNoUpdate(recordName.."Cost.costMods", {recordName.."CostStat", "DCO.TechHackCostReductionMod"})
	TweakDB:SetFlat(recordName.."Cost.statPool", "BaseStatPools.Memory")

	createConstantStatModifier(recordName.."CostStat", "Additive", "BaseStats.Memory", cost)
	
	--UI stuff

	TweakDB:CreateRecord(recordName.."Interaction", "gamedataInteractionBase_Record")
	TweakDB:SetFlatNoUpdate(recordName.."Interaction.action", "Choice1")
	TweakDB:SetFlatNoUpdate(recordName.."Interaction.caption", displayName)
	TweakDB:SetFlat(recordName.."Interaction.captionIcon", captionPart)

	
	--Activation time
	createConstantStatModifier(recordName.."ActivationTime", "Additive", "BaseStats.QuickHackUpload", activationTime)
	

	--Object action effect
	TweakDB:CloneRecord(recordName.."Effect", "QuickHack.SystemCollapseLvl3Hack_inline0")
	TweakDB:SetFlat(recordName.."Effect.statusEffect", recordName.."SE")
	
	--First make status effect w/ duration
	TweakDB:CloneRecord(recordName.."SE", "BaseStatusEffect.SeeThroughWalls")
	TweakDB:SetFlatNoUpdate(recordName.."SE.duration", recordName.."Duration")
	TweakDB:SetFlatNoUpdate(recordName.."SE.gameplayTags", gameplayTags)
	TweakDB:SetFlatNoUpdate(recordName.."SE.VFX", {vfx})
	TweakDB:SetFlatNoUpdate(recordName.."SE.uiData", recordName.."SEUIData")
	TweakDB:SetFlat(recordName.."SE.packages", {recordName.."Package"})

	--SE ui
	TweakDB:CreateRecord(recordName.."SEUIData", "gamedataStatusEffectUIData_Record")
	TweakDB:SetFlatNoUpdate(recordName.."SEUIData.displayName", "Repair")
	TweakDB:SetFlatNoUpdate(recordName.."SEUIData.priority", -9)
	TweakDB:SetFlat(recordName.."SEUIData.iconPath", SEIcon)
	
	--Package
	TweakDB:CreateRecord(recordName.."Package", "gamedataGameplayLogicPackage_Record")
	temp = {}
	for i,v in ipairs(statsList) do

		createConstantStatModifier(recordName..v[2], v[1], "BaseStats."..v[2], v[3])
		table.insert(temp, recordName..v[2])
	end
	table.insert(temp, "DCO.OctantArasakaTechHackArmor")
	TweakDB:SetFlat(recordName.."Package.stats", temp)

	--Techhack damage effector
	TweakDB:SetFlat(recordName.."Package.effectors", {"DCO.DroneHackDamageEffector"})

	--Duration
	TweakDB:CreateRecord(recordName.."Duration", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate(recordName.."Duration.statModsLimit", -1)
	TweakDB:SetFlat(recordName.."Duration.statModifiers", {recordName.."DurationStat"})
	createConstantStatModifier(recordName.."DurationStat", "Additive", "BaseStats.MaxDuration", duration)
	
	--Checking for cooldown
	
	--status effect
	TweakDB:CloneRecord(recordName.."Cooldown", "BaseStatusEffect.SystemCollapseCooldown")
	TweakDB:SetFlatNoUpdate(recordName.."Cooldown.duration", recordName.."CooldownDuration")
	TweakDB:SetFlatNoUpdate(recordName.."Cooldown.gameplayTags", {"Debuff"})
	TweakDB:SetFlat(recordName.."Cooldown.uiData", "") --recordName.."CooldownUIData")

	TweakDB:CreateRecord(recordName.."CooldownUIData", "gamedataStatusEffectUIData_Record")
	TweakDB:SetFlatNoUpdate(recordName.."CooldownUIData.displayName", "Tech Hack Cooldown")
	TweakDB:SetFlat(recordName.."CooldownUIData.iconPath", "SystemCollapse")
	

	--Duration
	TweakDB:CreateRecord(recordName.."CooldownDuration", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlatNoUpdate(recordName.."CooldownDuration.statModsLimit", -1)
	TweakDB:SetFlat(recordName.."CooldownDuration.statModifiers", {recordName.."CooldownDurationStat", "DCO.DroneNomadReductionDuration"})
	
	createConstantStatModifier(recordName.."CooldownDurationStat", "Additive", "BaseStats.MaxDuration", cooldown)
	
	--Object action effect to be applied in start effects
	TweakDB:CloneRecord(recordName.."CooldownEffect", "QuickHack.SystemCollapseHackBase_inline4")
	TweakDB:SetFlat(recordName.."CooldownEffect.statusEffect", recordName.."Cooldown")
	
	--CooldownCheck
	TweakDB:CloneRecord(recordName.."CooldownCheck", "QuickHack.SystemCollapseHackBase_inline0")
	TweakDB:SetFlat(recordName.."CooldownCheck.statusEffect", recordName.."Cooldown")
	

	
end
function createTechDeckMod(recordName, displayName, description, whiteDesc, slot, statsList, quality)

	--Base record
	TweakDB:CloneRecord(recordName, "Items.BerserkFragment1")
	TweakDB:SetFlatNoUpdate(recordName..".localizedName", "yyy{"..displayName.."}{"..description.."}")

	TweakDB:SetFlatNoUpdate(recordName..".placementSlots", {slot})
	TweakDB:SetFlatNoUpdate(recordName..".tags", {"itemPart", "Fragment", "DCOMod"})

	TweakDB:SetFlatNoUpdate(recordName..".quality", "Quality."..quality)
	TweakDB:SetFlat(recordName..".OnAttach", {})
	TweakDB:SetFlat(recordName..".OnEquip", {recordName.."Package"})


	
	TweakDB:SetFlat(recordName..".statModifiers", {})

--stats
	temp = {}
	for i,v in ipairs(statsList) do
		createConstantStatModifier(recordName.."_inline"..i, v[1], v[2], v[3])
		table.insert(temp, recordName.."_inline"..i)
	end	

	--Description
	TweakDB:CreateRecord(recordName.."Package", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlatNoUpdate(recordName.."Package.stats", temp)
	TweakDB:SetFlat(recordName.."Package.UIData", recordName.."PackageDesc")

	TweakDB:CreateRecord(recordName.."PackageDesc", "gamedataGameplayLogicPackageUIData_Record")
	TweakDB:SetFlat(recordName.."PackageDesc.localizedDescription", whiteDesc)



end
function createStatusEffectAbility(recordName, toClone, statusEffect, damageType)
	TweakDB:CloneRecord(recordName, toClone)
	TweakDB:SetFlat(recordName..".abilityPackage", recordName.."_inline0")
	
	TweakDB:CreateRecord(recordName.."_inline0", "gamedataGameplayLogicPackage_Record")
	TweakDB:SetFlat(recordName.."_inline0.effectors", {recordName.."_inline1"})
	
	TweakDB:CreateRecord(recordName.."_inline1", "gamedataApplyStatGroupEffector_Record")
	TweakDB:SetFlat(recordName.."_inline1.applicationTarget", "Weapon")
	TweakDB:SetFlat(recordName.."_inline1.effectorClassName", "ApplyStatGroupEffector")
	TweakDB:SetFlat(recordName.."_inline1.prereqRecord", recordName.."MultiPrereq")
	TweakDB:SetFlat(recordName.."_inline1.statGroup", recordName.."_inline3")

	TweakDB:CreateRecord(recordName.."_inline2", "gamedataStatPrereq_Record")
	TweakDB:SetFlat(recordName.."_inline2.comparisonType", "Greater")
	TweakDB:SetFlat(recordName.."_inline2.prereqClassName", "StatPrereq")
	TweakDB:SetFlat(recordName.."_inline2.statType", "CanUseCoolingSystem")
	TweakDB:SetFlat(recordName.."_inline2.valueToCheck", 0)

	TweakDB:CreateRecord(recordName.."_inline3", "gamedataStatModifierGroup_Record")
	TweakDB:SetFlat(recordName.."_inline3.statModsLimit", -1)
	TweakDB:SetFlat(recordName.."_inline3.statModifiers", {recordName.."_inline4", recordName.."_inline5"})
	
	createConstantStatModifier(recordName.."_inline4", "Additive", damageType, 1)
	createCombinedStatModifier(recordName.."_inline5", "Additive", "*", "Self", damageType, statusEffect, 25)

	TweakDB:CreateRecord(recordName.."MultiPrereq", "gamedataMultiPrereq_Record")
	TweakDB:SetFlat(recordName.."MultiPrereq.aggregationType", "AND")
	TweakDB:SetFlat(recordName.."MultiPrereq.nestedPrereqs", {--[["Prereqs.RangedWeaponHeldPrereq", ]]recordName.."_inline2"})
	TweakDB:SetFlat(recordName.."MultiPrereq.prereqClassName", "gameMultiPrereq")
	
end

function createDroneStatGroup(recordName, stats)
	TweakDB:CreateRecord(recordName, "gamedataStatModifierGroup_Record")
	built_stats = {}
	for i,v in ipairs(stats) do
		createCombinedStatModifier(recordName.."_inline"..i, v[1], "*", "Player", v[2], v[3], v[4])
		table.insert(built_stats, recordName.."_inline"..i)
	end
	TweakDB:SetFlatNoUpdate(recordName..".statModsLimit", -1)
	TweakDB:SetFlat(recordName..".statModifiers", built_stats)
end
function createIcon(recordName, icon, atlasname)
	TweakDB:CreateRecord("UIIcon."..icon, "gamedataUIIcon_Record")
	TweakDB:SetFlatNoUpdate("UIIcon."..icon..".atlasPartName", "icon_part")
	TweakDB:SetFlat("UIIcon."..icon..".atlasResourcePath", "base\\icon\\"..atlasname..".inkatlas")
	
	TweakDB:SetFlat(recordName..".iconPath", icon)
	TweakDB:SetFlat(recordName..".icon", "UIIcon."..icon)


end
function createTechDeck(recordName, displayName, localizedDescription, whiteDescriptionList, statList, quality, memory, techhacklist)
	TweakDB:CloneRecord(recordName, "Items.BiotechEpicMKIII")
	TweakDB:SetFlatNoUpdate(recordName..".localizedName", "yyy{"..displayName.."}{"..localizedDescription.."}")
	TweakDB:SetFlatNoUpdate(recordName..".localizedDescription", LocKey(49555ull)) --black lace description indicator
	TweakDB:SetFlatNoUpdate(recordName..".quality", "Quality."..quality)
	TweakDB:SetFlatNoUpdate(recordName..".blueprint", "DCO.TechDeckBlueprint")
	TweakDB:SetFlatNoUpdate(recordName..".objectActions", techhacklist)
	TweakDB:SetFlatNoUpdate(recordName..".displayName", LocKey(28142ull))
	
	if quality == "Legendary" then
		TweakDB:SetFlatNoUpdate(recordName..".statModifiers", {"Quality.IconicItem"})
	end
	onequiplist = whiteDescriptionList
	table.insert(onequiplist, recordName.."OnEquip")
	TweakDB:SetFlatNoUpdate(recordName..".OnEquip", onequiplist)
	TweakDB:SetFlatNoUpdate(recordName..".tags", {"Cyberware", "HideInBackpackUI", "Robot"})
	TweakDB:SetFlatNoUpdate(recordName..".cyberwareType", CName.new("Techdeck"))
	TweakDB:SetFlatNoUpdate(recordName..".equipPrereqs", {"DCO."..quality.."TechStatPrereq"})
	TweakDB:Update(recordName)
	
	--OnEquip
	TweakDB:CreateRecord(recordName.."OnEquip", "gamedataGameplayLogicPackage_Record")
	createConstantStatModifier(recordName.."_inline420", "Additive", "BaseStats.HasCyberdeck", 0)
	createConstantStatModifier(recordName.."_inline69", "Additive", "BaseStats.Memory", memory)
	
	built_stats = {recordName.."_inline420", recordName.."_inline69"}--, "DCO.QuickhackSpreadNumber", "DCO.QuickhackSpreadRange"}
	for i,v in ipairs(statList) do
		createConstantStatModifier(recordName.."__inline"..i, v[1], v[2], v[3])
		table.insert(built_stats, recordName.."__inline"..i)
	end
	
	
	TweakDB:SetFlat(recordName.."OnEquip.stats", built_stats)
	--[[TweakDB:SetFlat(recordName.."OnEquip.UIData", recordName.."OnEquipDescription")
	
	TweakDB:CreateRecord(recordName.."OnEquipDescription", "gamedataGameplayLogicPackageUIData_Record")
	TweakDB:SetFlatNoUpdate(recordName.."OnEquipDescription.localizedDescription", whiteDescription)
	TweakDB:SetFlat(recordName.."OnEquipDescription.iconPath", "ability_silenced")]]--

end
function createStat(recordName, baseStat)
	TweakDB:CloneRecord(recordName, baseStat)
	--TweakDB:SetFlat(recordName..".enumName", "")
end

return DCO:new()
