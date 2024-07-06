R = { 
    description = "DCO"
}

function DCO:new()

	--Stop them from getting in vehicle
	TweakDB:CloneRecord("DCO.AndroidOrHuman", "Condition.Human")
	TweakDB:SetFlat("DCO.AndroidOrHuman.allowedNPCTypes", {"NPCType.Android", "NPCType.Human"})
	
	TweakDB:CloneRecord("DCO.NotMechAI", "Condition.Human")
	TweakDB:SetFlat("DCO.NotMechAI.allowedNPCTypes", {"NPCType.Android", "NPCType.Human", "NPCType.Drone"})
	
	addToList("Condition.EnterVehicleAICondition.AND", "DCO.AndroidOrHuman")
	
	--Fix Beast having technically 4 seats
	TweakDB:SetFlat(TweakDB:GetFlat("Vehicle.v_standard3_thorton_mackinaw_ncu_player.vehDataPackage")..'.boneNames', {"seat_front_left", "seat_front_right"})
	TweakDB:SetFlat(TweakDB:GetFlat("Vehicle.v_standard3_thorton_mackinaw_ncu_player.vehDataPackage")..'.vehSeatSet', "Vehicle.Vehicle2SeatSetDefault")
	
	--Can enter in back seats when someone is in front
	TweakDB:SetFlat("Condition.FollowerDrivingVehicle.freeSlots", {})
	

	--[[
	Vehicle_Mounting_Disabled = false --used for vehicle mounting
	Resetting_Vehicle_Mounting = false
	Override('AISubActionMountVehicle_Record_Implementation', 'MountVehicle;ScriptExecutionContextAISubActionMountVehicle_Record', function(a,b, wrappedMethod)
		if Vehicle_Mounting_Disabled then
			if not Resetting_Vehicle_Mounting then
				Resetting_Vehicle_Mounting = true
				Cron.After(0.5, function()
					Vehicle_Mounting_Disabled = false
					Resetting_Vehicle_Mounting = false
				end)
			end
		else
			wrappedMethod(a,b)
		end
	end)
	]]
	--Fix two seaters, then prevent them getting into one slot. Also handle some special cases
	
	doTwoSeaterFixCheck = true
	Observe('AISubActionMountVehicle_Record_Implementation', 'MountVehicle;ScriptExecutionContextAISubActionMountVehicle_Record', function(_, _)

		if not doTwoSeaterFixCheck then
			return
		end
		doTwoSeaterFixCheck = false
		
		--We also update the player's vehicle to fix two seaters seating AI
		vehicleID = Game.GetMountingFacility():GetMountingInfoSingleWithIds(Game.GetPlayer():GetEntityID(), _, _).parentId
		vehicle = VehicleObject:new()
		vehicle = Game.FindEntityByID(vehicleID)

		
		if vehicleID == nil then
		
		else
			--Use cron because thats around how long it takes for v to get in vehicle
			
			Cron.After(3.5, function()
				doTwoSeaterFixCheck = true
				fixSeat = true
				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					companionVehicleID = Game.GetMountingFacility():GetMountingInfoSingleWithIds(v:GetEntityID(), _, _).parentId
					cfor = v:GetWorldForward()
					playerfor = Game.GetPlayer():GetWorldForward()
					angle = Vector4.GetAngleBetween(cfor, playerfor)
					if Vector4.GetAngleBetween(cfor, playerfor) <0.1 then
						fixSeat = false
						break
					end

				end
				if fixSeat then
					vehicle.DCOFrontRightTaken = false
				end
			end)
		end
	end)
	
	--[[
	Override('MinigameGenerationRuleScalingPrograms', 'DefineLength', function(self, combinedPowerLevel, bufferSize, numPrograms)
		return 8
	end)

	Override('MinigameGenerationRule', 'SetBufferSize', function(self, buffer)
		print("setting buffer size")
		self.bufferSize = 15
		print("set buffer size")
	end)
	
	Override('NetworkInkGameController', 'PlayGame', function(self, wrappedMethod)
		print("setting dimension")
		wrappedMethod()
		self.dimension = 15
		print("set dimension")
	end)
	
	for i,v in ipairs(TweakDB:GetRecords('gamedataMinigame_Def_Record')) do
		TweakDB:SetFlat(v:GetID()..'.gridSize', 8)
		TweakDB:SetFlat(v:GetID()..'.bufferSize', 8)
		TweakDB:SetFlat(v:GetID()..'.defaultTrap', "MinigameTraps.SquadAlert")
		TweakDB:SetFlat(v:GetID()..'.noTraps', false)
		TweakDB:SetFlat(v:GetID()..'.trapsProbability', 8)

	end
	
	for i,v in ipairs(TweakDB:GetRecords('gamedataHackingMiniGame_Record')) do
		TweakDB:SetFlat(v:GetID()..'.hasHiddenCells', true)
		TweakDB:SetFlat(v:GetID()..'.hasEnemyNetrunner', true)
		TweakDB:SetFlat(v:GetID()..'.hiddenCellsProbability', 10)
		TweakDB:SetFlat(v:GetID()..'.enemyNetrunnerLevel', 1)
		TweakDB:SetFlat(v:GetID()..'.enemyNetrunnerLevel', 1)

	end
	
	for i,v in ipairs(TweakDB:GetRecords('gamedataMiniGame_Trap_Record')) do
		TweakDB:SetFlat(v:GetID()..'.spawnProbability', 0.5)
	end

	for i,v in ipairs(TweakDB:GetRecords('gamedataTrap_Record')) do
		TweakDB:SetFlat(v:GetID()..'.probability', 0.5)
	end	]]
	--------------------IMPLEMENT MULTIPLE MOUNTING FUNCTION (PARTLY IN REDSCRIPT)----------------
	--[[
	Override('AISubActionMountVehicle_Record_Implementation', 'DCOMountOtherVehicle;ScriptExecutionContextVehicleObject', function(context, vehicle)
	
		if not IsDefined(vehicle) or vehicle:IsDestroyed() then
			return false
		end
		if vehicle.DCOFrontLeftTaken then
			return false
		end

		owner = ScriptExecutionContext.GetOwner(context)
		md = MountEventData:new() 
		md.slotName = CName.new("trunk") 
		md.mountParentEntityId = vehicle:GetEntityID() 
		md.isInstant = true 
		md.ignoreHLS = true 
		evt = MountAIEvent:new() 
		evt.name = CName.new("Mount") 
		evt.data = md 
		owner:QueueEvent(evt) 
		
		vehicle.DCOFrontLeftTaken = true
		vehicle.DCOFrontRightTaken = true
		vehicle.DCOBackLeftTaken = true
		vehicle.DCOBackRightTaken = true
		
		cmd = AIVehicleFollowCommand:new() 
		cmd.target = Game.GetPlayer() 
		cmd.stopWhenTargetReached = false 
		cmd.distanceMin = 8 
		cmd.distanceMax = 15 
		cmd.useTraffic = false 
		cmd.needDriver = true 
		evt = AICommandEvent:new() 
		evt.command = cmd 
		--vehicle:QueueEvent(evt) 

		return true
	end)]]
end


return DCO:new()
