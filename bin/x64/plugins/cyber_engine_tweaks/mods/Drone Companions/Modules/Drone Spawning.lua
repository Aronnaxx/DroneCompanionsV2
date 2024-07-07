R = { 
    description = "DCO"
}

local droneSaveData = {
		records = {},
		hp = {},
		position = {},
		statusEffects = {},
	}
local filename = "DCO/Drone Spawning"
function DCO:new()


	----------------------SAVING AND LOADING--------------------------
	

	GameSession.IdentifyAs('_dco_session_key')
	GameSession.StoreInDir('sessions')
	GameSession.Persist(droneSaveData)

	--Saving
	GameSession.OnSaveData(function(state)
		inc = 0
		for i,record in ipairs(Full_Drone_List) do
			entityList = Game.GetCompanionSystem():GetSpawnedEntities(TweakDBID.new(record))
			if table.getn(entityList) == 1 and droneAlive(entityList[1]) then
					
				inc = inc + 1
				entity = entityList[1]
				droneSaveData.records[inc] = record
				droneSaveData.hp[inc] = Game.GetStatPoolsSystem():GetStatPoolValue(entity:GetEntityID(), gamedataStatPoolType.Health)
				droneSaveData.position[inc] = entity:GetWorldPosition()
				debugPrint(filename, "saved an entity with hp "..droneSaveData.hp[inc])
				
				tempSEList = {}
				for _, SE in ipairs(Game.GetStatusEffectSystem():GetAppliedEffects(entity:GetEntityID())) do
					table.insert(tempSEList, SE:GetRecord():GetID())
				end
				droneSaveData.statusEffects[inc] = tempSEList
				debugPrint(filename, "saved status effects: "..table.getn(tempSEList))
			end
		end	
	end)
	
	--Loading
	GameSession.OnStart(function(state)
		startSavePause = true
		MenuCron.After(2, function()
		--Set player cars' seats back to empty
		playerVehicle = Game.GetMountedVehicle(Game.GetPlayer())
		if playerVehicle then
			playerVehicle.DCOBackLeftTaken = false
			playerVehicle.DCOBackRightTaken = false
			playerVehicle.DCOFrontRightTaken = false
		end
		
		--Need to store them in case someone saves really quickly after loading

		temphptable = {}
		tempSEtable = {}
		numDrones = table.getn(droneSaveData.records)
		
		--Double check they're all gone
		--[[
		for i,v in ipairs(Full_Drone_List) do
			CompanionSystem:DespawnSubcharacter(TweakDBID.new(v))
		end
		]]
		for i,record in ipairs(droneSaveData.records) do
			hp = droneSaveData.hp[i]

			position = droneSaveData.position[i]
			statusEffects = droneSaveData.statusEffects[i]
			
			temphptable[record] = hp
			tempSEtable[record] = statusEffects
			
			posv3 = Vector3:new()
			posv3.x = position.x
			posv3.y = position.y
			posv3.z = position.z
			

			--Initial spawn of character
			 Game.GetCompanionSystem():SpawnSubcharacterOnPosition(TweakDBID.new(record), posv3)

		end
		
		--Set them friendly again
		setFriendlyOnLoad(numDrones)	

		--adjust hp
		adjustHPOnLoad(numDrones, temphptable, Full_Drone_List)
		
		--Redo status effects and dismemberments
		SEAndDismemberOnLoad(numDrones, tempSEtable, Full_Drone_List)

		Cron.After(5, function()
			cleanDroneSaveData()
		end)
		debugPrint(filename, "fully loaded in the drones")
		end)
	end)
	

	-----------------------FAST TRAVEL LOGIC---------------------------
	local droneFastTravelData = {
		records = {},
		hp = {},
		statusEffects = {},
	}

	tempFastTravel = 0
	Observe('FastTravelSystem', 'OnLoadingScreenFinished', function(_, _)
		tempFastTravel = tempFastTravel + 1
		--print(tempFastTravel)
		--if tempFastTravel == 2 then --Happens twice
			Cron.After(5, function()
				--print("Attempted fast travel")
				--Need to store them in case someone saves really quickly after loading

				temphptable = {}
				tempSEtable = {}
				numDrones = table.getn(droneFastTravelData.records)
				
				for i,record in ipairs(droneFastTravelData.records) do
					hp = droneFastTravelData.hp[i]

					statusEffects = droneFastTravelData.statusEffects[i]
					position = Game.GetPlayer():GetWorldPosition()
					
					temphptable[record] = hp
					tempSEtable[record] = statusEffects
					
					posv3 = Vector3:new()
					posv3.x = position.x - 0.5
					posv3.y = position.y
					posv3.z = position.z
					

					--Initial spawn of character
					--if  Permanent_Mechs or not has_value(Mech_List, record) then
						Game.GetCompanionSystem():SpawnSubcharacterOnPosition(TweakDBID.new(record), posv3)
					--end
				end
				
				
				--Set them friendly again
				setFriendlyOnLoad(numDrones)	

				--adjust hp
				adjustHPOnLoad(numDrones, temphptable, Full_Drone_List)
				
				--Redo status effects and dismemberments
				SEAndDismemberOnLoad(numDrones, tempSEtable, Full_Drone_List)

				droneFastTravelData.records = {}
				droneFastTravelData.hp = {}
				droneFastTravelData.statusEffects = {}
				debugPrint(filename, "fast travelled the drones")
			end)
			tempFastTravel = 0
		--end

	end)
	
	
	--Save them before, and then despawn them
	Observe('FastTravelSystem', 'SetFastTravelStarted', function()
		inc = 0
		for i,record in ipairs(Full_Drone_List) do
			entityList = Game.GetCompanionSystem():GetSpawnedEntities(TweakDBID.new(record))
			if table.getn(entityList) == 1 and droneAlive(entityList[1]) then
					
				inc = inc + 1
				entity = entityList[1]
				droneFastTravelData.records[inc] = record
				droneFastTravelData.hp[inc] = Game.GetStatPoolsSystem():GetStatPoolValue(entity:GetEntityID(), gamedataStatPoolType.Health)
				
				tempSEList = {}
				for _, SE in ipairs(Game.GetStatusEffectSystem():GetAppliedEffects(entity:GetEntityID())) do
					table.insert(tempSEList, SE:GetRecord():GetID())
				end
				droneFastTravelData.statusEffects[inc] = tempSEList
				
				Game.GetCompanionSystem():DespawnSubcharacter(TweakDBID.new(record))
			end
		end	
	end)


	------------------------DRONE SPAWNING-----------------------------

	canCraftDrone = true
	tempDroneCountIncrement = 0
	canDespawn = true
	tempMechIncrement = {0}
	Mech_TDB = {}
	for i,v in ipairs(Mech_List) do
		table.insert(Mech_TDB, TweakDBID.new(v))
	end
	
	--Used for disabling free crafting of drones
	RemoveFreeCraftingStat = gameConstantStatModifierData:new()
	RemoveFreeCraftingStat.value = 0
	RemoveFreeCraftingStat.statType = gamedataStatType.CraftingMaterialRetrieveChance
	RemoveFreeCraftingStat.modifierType = gameStatModifierType.Multiplier

	--Logic for spawning the drone as a follower after crafting
	Override('CraftingLogicController' ,'CraftItem', function(self, selectedRecipe, amount, wrappedMethod)
	
		--Remove free crafting of drones
		if has_value(drones_list, selectedRecipe.label) then
			statsObjID = StatsObjectID:new()
	 		statsObjID = Game.GetPlayer():GetEntityID()
			Game.GetStatsSystem():AddModifier(statsObjID, RemoveFreeCraftingStat)
			
		end
		
		--Run the initial method
		wrappedMethod(selectedRecipe, amount)

		--If we're crafting one of our drones
		if has_value(drones_list, selectedRecipe.label) then

			
			--Fix issue with attempting to craft two immediately
			tempDroneCountIncrement = 1
			MenuCron.After(0.5, function()
				tempDroneCountIncrement = 0
				--Remove stat that prevented free crafting of drones
				statsObjID = StatsObjectID:new()
				statsObjID = Game.GetPlayer():GetEntityID()
				Game.GetStatsSystem():RemoveModifier(statsObjID, RemoveFreeCraftingStat)
			end)

			--Spawn the drone
			local heading = Game.GetPlayer():GetWorldForward() 
			local offsetDir = ToVector3{heading.x, heading.y, heading.z} 
			offsetDir.x = heading.x 
			offsetDir.y = heading.y 
			offsetDir.z = heading.z 

			local recordEnt = {}
			local droneDistances = {}
			--Spawn the appropriate guy
			for i=1,DroneRecords do
				recordEnt[1] = TweakDBID.new(drone_records[selectedRecipe.label]..i)
				local entityList = Game.GetCompanionSystem():GetSpawnedEntities(recordEnt[1])
				
				if table.getn(entityList) == 0 then
					Game.GetCompanionSystem():DespawnSubcharacter(recordEnt[1])
					local entitySpec = DynamicEntitySpec.new()
					entitySpec.recordID = recordEnt[1]
					entitySpec.position = offsetDir
					entitySpec.orientation = Game.GetPlayer():GetWorldOrientation()
					entitySpec.tags = { "DCO_Drone" }
					Game.GetDynamicEntitySystem():CreateEntity(entitySpec)
					prev_spawn = recordEnt[1]
					break
				else
					if not droneAlive(entityList[1]) then
						table.insert(droneDistances, Vector4.Distance(Game.GetPlayer():GetWorldPosition(), entityList[1]:GetWorldPosition()))
					else
						table.insert(droneDistances, -1)
					end
				end
				
				--If we didn't despawn enough dead ones through distance, find the farthest away, and despawn that one
				if i == DroneRecords then
					local longestDist = -1
					local longestDistIndex = 1
					for a,b in ipairs(droneDistances) do
						if b > longestDist then
							longestDistIndex = a
							longestDist = b
						end
					end
					recordEnt[1] = TweakDBID.new(drone_records[selectedRecipe.label]..longestDistIndex)
					Game.GetCompanionSystem():DespawnSubcharacter(recordEnt[1])
					local entitySpec = DynamicEntitySpec.new()
					entitySpec.recordID = recordEnt[1]
					entitySpec.position = offsetDir
					entitySpec.orientation = Game.GetPlayer():GetWorldOrientation()
					entitySpec.tags = { "DCO_Drone" }
					Game.GetDynamicEntitySystem():CreateEntity(entitySpec)
					prev_spawn = recordEnt[1]
				end
				
			end
			
			if has_value(Mech_TDB, recordEnt[1]) then
			
				tempMechIncrement[1] = 1
				MenuCron.After(0.5, function()
					tempMechIncrement[1] = 0
				end)
			end
			

			--We use cron bc entitylist would give us 0 immediately after
			MenuCron.After(Friendly_Time, function()
				setSubcharactersFriendly()
				

			end)
		end

	end)

	-----------------CRAFTING UI-------------------------
	Override('ItemFilterToggleController', 'GetLabelKey', function(self, wrappedMethod)
		str = wrappedMethod()
		if str == "Lockey#45229" then
			str = Crafting_Tab_String
		end
		return str
	end)
	
	Override('ItemFilterCategories', 'GetIcon;ItemFilterCategory', function(filterType, wrappedMethod)
		
		if filterType == ItemFilterCategory.Cyberware then
			return "UIIcon.DCOCraftingIcon"
		end
		return wrappedMethod(filterType)
	end)
	
	TweakDB:CreateRecord("UIIcon.DCOCraftingIcon", "gamedataUIIcon_Record")
	TweakDB:SetFlatNoUpdate("UIIcon.DCOCraftingIcon.atlasPartName", "icon_part")
	TweakDB:SetFlat("UIIcon.DCOCraftingIcon.atlasResourcePath", "base\\icon\\dcocraftingicon_atlas.inkatlas")
	
	------------------LIMIT CRAFTING----------------------
	

	--Error text
	Override('CraftingLogicController', 'SetPerkNotification', function(self, wrappedMethod)
	
  
		wrappedMethod()
		
		
		--If we can't craft the quality or if it's a quickhack, then our code isn't needed
		canCraftQuality, quality = self.craftingSystem:CanCraftGivenQuality(InventoryItemData.GetGameItemData(self.selectedItemData))
		if not canCraftQuality or InventoryItemData.GetGameItemData(self.selectedItemData):GetItemType() == gamedataItemType.Prt_Program then
			return
		end

		if not self.craftingSystem:CanItemBeCrafted(self.selectedItemGameData)then

			itemTDB = ItemID.GetTDBID(self.selectedItemGameData:GetID())

			if has_value(possible_tdb, itemTDB) then

			statsObjID = StatsObjectID:new()
			statsObjID = Game.GetPlayer():GetEntityID()
			droneLimit = Game.GetStatsSystem():GetStatValue(statsObjID, gamedataStatType.NPCAnimationTime)
			mechspawned = false
			--SES = Game.GetStatusEffectSystem()
			
			for i,v in ipairs(Mech_List) do
				spawnedMech = Game.GetCompanionSystem():GetSpawnedEntities(TweakDBID.new(v)) 
				if  table.getn(spawnedMech)> 0 and droneAlive(spawnedMech[1]) then
					mechspawned = true
				end
			end

			aliveDrones = tempDroneCountIncrement
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if droneAlive(v) and TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) then
					aliveDrones = aliveDrones + 1
				end
			end
				--debugPrint(filename, aliveDrones)
				errortext = ""
				if droneLimit == 0 then
					errortext = No_TechDeck_String
				elseif combatDisabled() then
					errortext =  Combat_Disabled_String
				elseif (itemTDB == mechmilitech_tdb or itemTDB == mecharasaka_tdb or itemTDB == mechncpd_tdb)
				and (tempMechIncrement[1] == 1 or mechspawned) then
					errortext = Mech_Active_String
				elseif aliveDrones >= droneLimit then
					errortext =  Maximum_Drones_String
				elseif playerInVehicle() then
					errortext = Exit_Vehicle_String
				elseif sceneTier3OrAbove() then
					errortext = V_Busy_String
				elseif LiftDevice.IsPlayerInsideElevator() then
					errortext = Exit_Elevator_String
				end
				inkWidgetRef.SetVisible(self.perkNotificationContainer, true)
				inkTextRef.SetText(self.perkNotificationText, errortext)
				self.notificationType = UIMenuNotificationType.CraftingNoPerks

			end
		end

	end)

	
	--Makes it red
	Override('CraftingSystem', 'CanItemBeCrafted;Item_Record', function(self, itemRecord, wrappedMethod)
		
		--debugPrint(filename, Game.GetNavigationSystem():IsOnGround(Game.GetPlayer(), 20))
		item_tdb = itemRecord:GetID()
		if has_value(possible_tdb, item_tdb) then
			playerPos = Game.GetPlayer():GetWorldPosition()
			--Despawn far away ones
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) then
					pos = v:GetWorldPosition()
					myDist = math.sqrt((playerPos.x - pos.x)^2 + (playerPos.y - pos.y)^2 + (playerPos.z - pos.z)^2)
					if myDist>200 then
						Game.GetCompanionSystem():DespawnSubcharacter(v:GetRecordID())
						debugPrint(filename, "despawned far away guy")
					end
				end
			end	
		
			--Check crafting conditions
			statsObjID = StatsObjectID:new()
			statsObjID = Game.GetPlayer():GetEntityID()
			droneLimit = Game.GetStatsSystem():GetStatValue(statsObjID, gamedataStatType.NPCAnimationTime)
			
			--Check for some story conditions
			--SES = Game.GetStatusEffectSystem()
			if combatDisabled() then
				return false
			end
			
			if sceneTier3OrAbove() then
				return false
			end
			
			if playerInVehicle() then
				return false
			end
			
			if LiftDevice.IsPlayerInsideElevator() then
				return false
			end
			
			deadDrones = 0
			activeDrones = tempDroneCountIncrement
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do

				if droneAlive(v) and TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) then
					activeDrones = activeDrones + 1
				end
			end
			activeDrones = activeDrones - deadDrones
			
			if activeDrones>= droneLimit then
					return false
			end

			
			--Enable spawning of only one mech
			if item_tdb == mechmilitech_tdb or item_tdb == mecharasaka_tdb or item_tdb == mechncpd_tdb then
				if tempMechIncrement[1] == 1 then
					return false
				end
				for i,v in ipairs(Mech_List) do
					entList = Game.GetCompanionSystem():GetSpawnedEntities(TweakDBID.new(v))
					if table.getn(entList)>0 and droneAlive(entList[1]) then
						return false
					end
				end
			end
			
		end
		return wrappedMethod(itemRecord)
		
	end)
	
	--Add to function to check if we've already spawned the corresponding drone of that item
	Override('CraftingSystem', 'CanItemBeCrafted', function(self, itemData, wrappedMethod)
	
		--If it's one of our fake items
		item_tdb = ItemID.GetTDBID(itemData:GetID())
		if has_value(possible_tdb, item_tdb) then
			--Fix issue with being able to craft two immediately
			
			--[[
			if not canCraftDrone then
				return false
			end
			]]--
			

			statsObjID = StatsObjectID:new()
			statsObjID = Game.GetPlayer():GetEntityID()
			droneLimit = Game.GetStatsSystem():GetStatValue(statsObjID, gamedataStatType.NPCAnimationTime)
			--activeDrones = tempDroneCountIncrement + table.getn(Game.GetCompanionSystem():GetSpawnedEntities())
			
			--Check for some story conditions
			--SES = Game.GetStatusEffectSystem()
			if combatDisabled() then
				return false
			end
			
			if sceneTier3OrAbove() then
				return false
			end
			--Check if we're in a vehicle
			if playerInVehicle() then
				return false
			end
			
			if LiftDevice.IsPlayerInsideElevator() then
				return false
			end
			
			deadDrones = 0
			activeDrones = tempDroneCountIncrement
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if droneAlive(v) and TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) then
					activeDrones = activeDrones + 1
				end
			end
			activeDrones = activeDrones - deadDrones
			if activeDrones>= droneLimit then
				return false
			end
			

			--Enable spawning of only one mech
			if item_tdb == mechmilitech_tdb or item_tdb == mecharasaka_tdb or item_tdb == mechncpd_tdb then
				if tempMechIncrement[1] == 1 then
					return false
				end
				for i,v in ipairs(Mech_List) do
					entList = Game.GetCompanionSystem():GetSpawnedEntities(TweakDBID.new(v))
					if table.getn(entList)>0 and droneAlive(entList[1])	then
						return false
					end
				end
			end

			
		end
		

		return wrappedMethod(itemData)
	
	end)
	

	---------------------------MAKE OUR STATUS EFFECT FOR AI----------------
	TweakDB:CreateRecord("DCO.RobotSE", "gamedataStatusEffect_Record")
	TweakDB:SetFlatNoUpdate("DCO.RobotSE.duration", "BaseStats.InfiniteDuration")
	TweakDB:SetFlat("DCO.RobotSE.statusEffectType", "BaseStatusEffectTypes.Misc")

	TweakDB:CreateRecord("DCO.IsDCO", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.IsDCO.statusEffect", "DCO.RobotSE")
	TweakDB:SetFlatNoUpdate("DCO.IsDCO.invert", false)
	TweakDB:SetFlat("DCO.IsDCO.target", "AIActionTarget.Owner")

	TweakDB:CreateRecord("DCO.IsNotDCO", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.IsNotDCO.statusEffect", "DCO.RobotSE")
	TweakDB:SetFlatNoUpdate("DCO.IsNotDCO.invert", true)
	TweakDB:SetFlat("DCO.IsNotDCO.target", "AIActionTarget.Owner")



end

function droneAlive(drone)
	return not drone:IsIncapacitated()
	
	--return not drone:IsDead() and drone:IsAlive() --[[and drone:IsActive() and not ScriptedPuppet.IsUnconscious(drone) and not ScriptedPuppet.IsDefeated(drone)]] and not Game.GetStatusEffectSystem():HasStatusEffect(drone:GetEntityID(), TweakDBID.new("BaseStatusEffect.SystemCollapse"))
end
function createSEForAI(name)
	TweakDB:CreateRecord("DCO.RobotSE", "gamedataStatusEffect_Record")
	TweakDB:SetFlatNoUpdate("DCO.RobotSE.duration", "BaseStats.InfiniteDuration")
	TweakDB:SetFlat("DCO.RobotSE.statusEffectType", "BaseStatusEffectTypes.Misc")

	TweakDB:CreateRecord("DCO.IsDCO", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.IsDCO.statusEffect", "DCO.RobotSE")
	TweakDB:SetFlatNoUpdate("DCO.IsDCO.invert", false)
	TweakDB:SetFlat("DCO.IsDCO.target", "AIActionTarget.Owner")

	TweakDB:CreateRecord("DCO.IsNotDCO", "gamedataAIStatusEffectCond_Record")
	TweakDB:SetFlatNoUpdate("DCO.IsNotDCO.statusEffect", "DCO.RobotSE")
	TweakDB:SetFlatNoUpdate("DCO.IsNotDCO.invert", true)
	TweakDB:SetFlat("DCO.IsNotDCO.target", "AIActionTarget.Owner")
end
function sceneTier3OrAbove()
	local blackboardDefs = Game.GetAllBlackboardDefs()
	local blackboardPSM = Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), blackboardDefs.PlayerStateMachine)
	local tier = blackboardPSM:GetInt(blackboardDefs.PlayerStateMachine.SceneTier)
	return tier>2
end
function combatDisabled()
	bbdefs = GetAllBlackboardDefs()
	--bbsys = Game.GetBlackboardSystem()
	if Game.GetStatusEffectSystem():HasStatusEffectWithTag(Game.GetPlayer():GetEntityID(), CName.new("NoCrafting"))
	or Game.GetStatusEffectSystem():HasStatusEffectWithTag(Game.GetPlayer():GetEntityID(), CName.new("NoJump")) 
	or Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), bbdefs.PlayerStateMachine):GetInt(bbdefs.PlayerStateMachine.Zones) == 2 or Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), bbdefs.PlayerStateMachine):GetBool(bbdefs.PlayerStateMachine.SceneSafeForced)
	or StatusEffectSystem.ObjectHasStatusEffectWithTag(Game.GetPlayer(), CName.new("NoCombat"))
	or Game.GetPlayer():GetPlayerStateMachineBlackboard():GetInt(bbdefs.PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.ForceEmptyHands) then
		return true
	end
	return false
end
function playerInVehicle()
	if Game.FindEntityByID(Game.GetMountingFacility():GetMountingInfoSingleWithObjects(Game.GetPlayer()).parentId) then
			return true
	end
	return false
end
function cleanDroneSaveData()
	droneSaveData.records = {}
	droneSaveData.hp = {}
	droneSaveData.position = {}
	droneSaveData.statusEffects = {}
	debugPrint(filename, "cleaned drone save data")
end
function SEAndDismemberOnLoad(droneCount, SEtable, Full_Drone_List)
	MenuCron.After(Friendly_Time, function()
		for i,record in ipairs(Full_Drone_List) do
			entityList = Game.GetCompanionSystem():GetSpawnedEntities(TweakDBID.new(record))
			if table.getn(entityList) == 1 then
				entity = entityList[1]
				
				--Apply status effects, and dismember or destroy weakspots as needed
				for a, SE in ipairs(SEtable[record]) do
					StatusEffectHelper.ApplyStatusEffect(entity, SE)

					if SE == TweakDBID.new("BaseStatusEffect.DismemberedArmRight") then
						DismembermentComponent.RequestDismemberment(entity, gameDismBodyPart.RIGHT_ARM, gameDismWoundType.CLEAN)
					elseif SE == TweakDBID.new("BaseStatusEffect.DismemberedArmLeft") then
						DismembermentComponent.RequestDismemberment(entity, gameDismBodyPart.LEFT_ARM, gameDismWoundType.CLEAN)
					elseif SE == TweakDBID.new("BaseStatusEffect.DismemberedLegLeft") then
						DismembermentComponent.RequestDismemberment(entity, gameDismBodyPart.LEFT_LEG, gameDismWoundType.CLEAN)
					elseif SE == TweakDBID.new("BaseStatusEffect.DismemberedLegRight") then
						DismembermentComponent.RequestDismemberment(entity, gameDismBodyPart.RIGHT_LEG, gameDismWoundType.CLEAN)
					elseif SE == TweakDBID.new("BaseStatusEffect.AndroidHeadRemovedBlind") then
						DismembermentComponent.RequestDismemberment(entity, gameDismBodyPart.HEAD, gameDismWoundType.CLEAN)
					
					elseif SE == TweakDBID.new("Minotaur.RightArmDestroyed") then
						for f, weakspot in ipairs(entity:GetWeakspotComponent():GetWeakspots()) do
							if weakspot:GetRecord():GetID() == TweakDBID.new("Weakspots.Mech_Weapon_Right_Weakspot") then
								ScriptedWeakspotObject.Kill(weakspot)
							end
						end
					elseif SE == TweakDBID.new("Minotaur.LeftArmDestroyed") then
						for f, weakspot in ipairs(entity:GetWeakspotComponent():GetWeakspots()) do
		
							if weakspot:GetRecord():GetID() == TweakDBID.new("Weakspots.Mech_Weapon_Left_Weakspot") then
								ScriptedWeakspotObject.Kill(weakspot)
								
							end
						end	
					end
				end
				
				debugPrint(filename, "dismembered a guy")
			end
		end
	end)
	
end
function adjustHPOnLoad(droneCount, hptable, Full_Drone_List)
	--local CompanionSystem = Game.GetCompanionSystem()
	
	MenuCron.After(Friendly_Time, function()
		for i,record in ipairs(Full_Drone_List) do
			entityList = Game.GetCompanionSystem():GetSpawnedEntities(TweakDBID.new(record))
			if table.getn(entityList) == 1 then
				entity = entityList[1]
				Game.GetStatPoolsSystem():RequestSettingStatPoolValue(entity:GetEntityID(), gamedataStatPoolType.Health, hptable[record], entity)
				debugPrint(filename, "HP: "..hptable[record].." RECORD:"..record)
			end
		end
	end)
	
end
function setFriendlyOnLoad(droneCount, count)

	MenuCron.After(Friendly_Time, function()
		setSubcharactersFriendly()
	end)

end
function setSubcharactersFriendly()

	entitylist = Game.GetCompanionSystem():GetSpawnedEntities()
	for i,v in ipairs(entitylist) do
		if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not (Game.GetStatusEffectSystem():HasStatusEffect(v:GetEntityID(), TweakDBID.new("DCO.RobotSE"))) then

			
			role = v:GetAIControllerComponent():GetAIRole()
			if role then
				--print("ON ROLE CLEARED")
				--role:OnRoleCleared(v)
			end
			--print(Game.GetStatsSystem():GetStatValue(v:GetEntityID(), gamedataStatType.PowerLevel))
			newRole = AIFollowerRole.new()
			newRole.followerRef = Game.CreateEntityReference("#player", {})
			v:GetAttitudeAgent():SetAttitudeGroup(CName.new("player"))
			newRole.attitudeGroupName = CName.new("player")
			v.isPlayerCompanionCached = true
			v.isPlayerCompanionCachedTimeStamp = 0
			v:GetAIControllerComponent():SetAIRole(newRole)
			--v:GetAIControllerComponent():OnAttach()
			--v.movePolicies:Toggle(true)
			
			--Set to same level as player
			v.NPCManager:ScaleToPlayer()
			
			--Add our status effect for ai checks
			StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("DCO.RobotSE"))
	
		end
	end
end



return DCO:new()
