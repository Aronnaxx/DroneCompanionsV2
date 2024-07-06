DCO = { 
    description = "DCO"
}
local Cron = require("Modules/utils/Cron.lua")
local MenuCron = require("Modules/utils/MenuCron.lua")
local GameUI = require("Modules/utils/GameUI.lua")
local config = require("Modules/utils/config.lua")

local inGame
local inMenu
local tempKeanuFastTravel = 0

function DCO:new()

	local dronesNeedReset = false
	local elevatorPlayerZ = -1
	local exitPos
	local octantAudio --= CName.new("dev_drone_octant_01")
	local wyvernAudio --= CName.new("dev_drone_wyvern_01")
	local griffinAudio --= CName.new("dev_drone_griffin_01")
	local bombusAudio --= CName.new("dev_drone_bombus_01")
	local prevPos--= Vector4:new()
	local QueueingSystemCollapse = false
	local smasherVec
	local smasherTeleportPos
	local startSavePause = false
	local checkCombat = true
	local checkingCombat = false
	local frameCheck = 0
	local frameLimit = 30
	
    registerForEvent("onInit", function() 
	prevPos = Vector4:new()
	smasherVec = ToVector4{ x = -1403.2731, y = 144.23668, z = -26.654015, w = 1 }
	smasherTeleportPos = ToVector4{ x = -1385.7981, y = 132.85963, z = -26.64801, w = 1 }
	
	dofile("modules/Language File.lua")
	print("DCO Language File loaded")
	dofile("modules/initVars.lua")
	print("DCO vars initialized")
	dofile("modules/Native Settings Integration.lua")
	print("DCO Native Settings Integration loaded")
	dofile("modules/Base Drones.lua")
	print("DCO Base Drones loaded")
	dofile("modules/Techdecks.lua")
	print("DCO Techdecks loaded")
	dofile("modules/Item Distribution.lua")
	print("DCO Item Distribution loaded")
	dofile("modules/Drone AI.lua")
	print("DCO Drone AI loaded")
	dofile("modules/Drone Spawning.lua")
	print("DCO Drone Spawning loaded")
	dofile("modules/Vehicle Mounting.lua")
	print("DCO Vehicle Mounting loaded")
	dofile("modules/Friendly Targetting.lua")
	print("DCO Friendly Targetting loaded")
	dofile("modules/functions.lua")
	print("DCO functions loaded")
	
	dofile("modules/Set Values.lua")
	print("DCO Set Values loaded")

	keanuWheezeMenuStuff()
	print("DCO Menu Crons Loaded!")

	print("DCO - Drone Companions fully loaded!")



		-----------------------------HANDLE ELEVATOR MOVEMENT----------------------------------

		--Exit positioning
		Observe('LiftDevice', 'OnAreaExit', function(self, trigger)

			Cron.After(0.2, function()
				exitPos = Game.GetPlayer():GetWorldPosition()
				exitPos.z = elevatorPlayerZ
			end)
			Cron.After(0.35, function()
				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					if not(v:GetNPCType() == gamedataNPCType.Mech) and TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not v:IsDead() then
							cmd = AITeleportCommand:new()
							cmd.position = exitPos
							cmd.doNavTest = false
							AIComponent.SendCommand(v, cmd)
							if (v:GetNPCType() == gamedataNPCType.Drone) and not(Game.GetPlayer():IsInCombat()) then
								v:QueueEvent(CreateForceRagdollEvent(CName.new("ForceRagdollTask")))
	
							end
							exitPos.x = exitPos.x + 0.2
					end
				end
			end)
		end)

    end)

--local shouldPause
registerForEvent("onUpdate", function(deltaTime)

	MenuCron.Update(deltaTime)
	
	if startSavePause then
		MenuCron.After(1, function()
			startSavePause = false
		end)
	end
	
	if (not inMenu) and inGame and not startSavePause then		
		Cron.Update(deltaTime)
		
		
		--Handle teleporting androids and drones w/ you when in an elevator
		if LiftDevice.IsPlayerInsideElevator() then
			--blackboardSystem = Game.GetBlackboardSystem()
			blackboard = Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine)
			elevator = FromVariant(blackboard:GetVariant(GetAllBlackboardDefs().PlayerStateMachine.CurrentElevator))
			if elevator then
				--Use player's z value, elevator's x and y to keep them in the elevator
				playerPos = Game.GetPlayer():GetWorldPosition()
				elevatorPos = elevator:GetWorldPosition()
				
				--Return if hanako's elevator
				if elevatorPos == ToVector4{ x = -1794.691, y = -535.8872, z = 10.113861, w = 1 } then
					return
				end
				
				pos = Vector4:new()
				pos.x = elevatorPos.x
				pos.y = elevatorPos.y
				pos.z = playerPos.z
				
				pos.x = pos.x - 1
				pos.y = pos.y + 0.5
				
				--check if we moving up or down and adjust teleport speed accordingly
				temp = pos.z
				if elevatorPlayerZ> pos.z then --moving downards
					pos.z = pos.z - (elevatorPlayerZ-pos.z) * 30
				elseif elevatorPlayerZ<pos.z then --moving upwards
					pos.z = pos.z + (pos.z - elevatorPlayerZ) * 30
				end
				elevatorPlayerZ = temp
			end
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if not(v:GetNPCType() == gamedataNPCType.Mech) and TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not v:IsDead() then
						cmd = AITeleportCommand:new()
						cmd.position = pos
						cmd.doNavTest = false
						AIComponent.SendCommand(v, cmd)
						pos.x = pos.x + 1
				end
			end
		end
		
		
		--Handle drone position when in vehicles

		--If we're not in  vehicle, check if we need to be reset

		
		if not Game.GetMountedVehicle(Game.GetPlayer()) then
			if dronesNeedReset then
				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					if v:GetNPCType() == gamedataNPCType.Drone and TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not v:IsDead() then
						pos = v:GetWorldPosition()
						pos.z = prevPos.z
						cmd = AITeleportCommand:new()
						cmd.position = pos
						cmd.doNavTest = false
						AIComponent.SendCommand(v, cmd)
						
						--Fixes drone pause bug
						if not(Game.GetPlayer():IsInCombat()) then
							v:QueueEvent(CreateForceRagdollEvent(CName.new("ForceRagdollTask")))
						end
						--v:QueueEvent(CreateDisableRagdollEvent(CName.new("ForceRagdollTask")))
					end
				end
				
				--Use cron bc all drones need to move downwards
				Cron.After(0.1, function()
					dronesNeedReset = false
				end)
			end
		else

			
			--Dont follow during quests
			if not (Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine):GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier) >1) then

			
				dronesNeedReset = true

				pos = Game.GetPlayer():GetWorldPosition()
				tempx = pos.x
				tempy = pos.y
				tempz = pos.z
				pos.x = pos.x + (pos.x - prevPos.x) * 5
				pos.y = pos.y + (pos.y - prevPos.y) * 5
				prevPos.x = tempx
				prevPos.y = tempy
				prevPos.z = tempz
				pos.z = pos.z + 2
				pos.x = pos.x - 10

				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do

					if v:GetNPCType() == gamedataNPCType.Drone and TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and not v:IsDead() then

						
						pos.x = pos.x + 5
						cmd = AITeleportCommand:new()
						cmd.position = pos
						cmd.doNavTest = false

						AIComponent.SendCommand(v, cmd)
			
					end
				end
			end
		end
		
		frameCheck = frameCheck + 1
		if not (frameCheck == frameLimit) then
			return
		end
		frameCheck = 0


		--Handle respawning when they're dead
		for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
			if v:GetRecord():TagsContains(CName.new("Robot")) and v:IsAlive() and (v:IsDead() or not v:IsActive()) then
				id = v:GetRecordID()
				pos = v:GetWorldPosition()
				Game.GetCompanionSystem():DespawnSubcharacter(id)
				Game.GetCompanionSystem():SpawnSubcharacterOnPosition(id, Vector4.Vector4To3(pos))
				Cron.After(0.5, function()
					setSubcharactersFriendly()
				end)
			end
		end
		
		
		--Handle Smasher teleport
		if Vector4.Distance(Game.GetPlayer():GetWorldPosition(), smasherVec) < 0.5 then
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if v:GetRecord():TagsContains(CName.new("Robot")) then
					cmd = AITeleportCommand:new()
					cmd.position = smasherTeleportPos
					cmd.doNavTest = false
					AIComponent.SendCommand(v, cmd)
				end
			end
		end
		

		
		--Set the attitude back to player if they ever stop for some reason
		for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
			if v:GetRecord():TagsContains(CName.new("Robot")) and droneAlive(v) then 
			--Make sure they are always on the player's attitude group
				v:GetAttitudeAgent():SetAttitudeGroup(CName.new("player"))
				v:GetAttitudeAgent():SetAttitudeTowards(Game.GetPlayer():GetAttitudeAgent(), EAIAttitude.AIA_Friendly)
				
				
				for a,b in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					if b:GetRecord():TagsContains(CName.new("Robot")) and droneAlive(b) then 
						v:GetAttitudeAgent():SetAttitudeTowards(b:GetAttitudeAgent(), EAIAttitude.AIA_Friendly)
					end
				end
			end
		end
		
		--Handle despawning far away drones as well as turning off nearby ones when swapping techdeck
		if not QueueingSystemCollapse then
			QueueingSystemCollapse = true
			aliveDrones = 0
			playerPos = Game.GetPlayer():GetWorldPosition()
			for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
				if TweakDBInterface.GetCharacterRecord(v:GetRecordID()):TagsContains(CName.new("Robot")) and droneAlive(v) then
					--Far away from player
					pos = v:GetWorldPosition()
					myDist = math.sqrt((playerPos.x - pos.x)^2 + (playerPos.y - pos.y)^2 + (playerPos.z - pos.z)^2)
					--If we have too many drones out, ie swapped from a techdeck
					statsObjID = StatsObjectID:new()
					statsObjID = Game.GetPlayer():GetEntityID()
					droneLimit = Game.GetStatsSystem():GetStatValue(statsObjID,	gamedataStatType.NPCAnimationTime)
					aliveDrones = aliveDrones + 1

					vertDist = math.abs(playerPos.z - pos.z)
					if aliveDrones > droneLimit then
						StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("BaseStatusEffect.SystemCollapse"))
					elseif myDist>200 then
						QueueDespawn(v)
					end
				end
			end
			Cron.After(10.01, function()
				QueueingSystemCollapse = false
			end)
		end
		
		--Handle in combat status effect prereq
		if checkCombat then
			checkCombat = false
			if Game.GetPlayer():IsInCombat() then
				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					if droneAlive(v) then
						StatusEffectHelper.ApplyStatusEffect(v, TweakDBID.new("DCO.InCombatSE"))
					end
				end
			else
				for i,v in ipairs(Game.GetCompanionSystem():GetSpawnedEntities()) do
					StatusEffectHelper.RemoveStatusEffect(v, TweakDBID.new("DCO.InCombatSE"))
				end				
			end
		else
			if not checkingCombat then
				checkingCombat = true
				Cron.After(1, function()
					checkCombat = true
					checkingCombat = false
				end)
			end
		end
	end
end)

end
function QueueDespawn(drone)
	Cron.After(10, function()
		playerPos = Game.GetPlayer():GetWorldPosition()
		pos = drone:GetWorldPosition()
		myDist = math.sqrt((playerPos.x - pos.x)^2 + (playerPos.y - pos.y)^2 + (playerPos.z - pos.z)^2)	
		if myDist>200 then
			
			--Recycling.
			--Half loot regularly, full loot during quest despawns
			ingdata = CraftingSystem.GetInstance():GetItemCraftingCost(TweakDBInterface.GetItemRecord(TweakDBID.new(TweakDB:GetFlat(drone:GetRecordID()..'.DCOItem'))))
			
				
			full_loot = sceneTier2OrAbove()
			quant_mult = 0.5
			if full_loot then
				quant_mult = 1
			end
			for i,v in ipairs(ingdata) do
				Game.GetTransactionSystem():GiveItemByTDBID(Game.GetPlayer(), v.id:GetID(), math.ceil(v.quantity * quant_mult))
			end
			Game.GetCompanionSystem():DespawnSubcharacter(TweakDBID.new(drone:GetRecordID()))

		end
	end)
end
--A lesson in how to credit people
function keanuWheezeMenuStuff()


		inFastTravel = false
		
        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
			inMenu = isInMenu
        end)

        GameUI.OnSessionStart(function()
            inGame = true
        end)

        GameUI.OnSessionEnd(function()
            inGame = false
        end)

        GameUI.OnPhotoModeOpen(function()
            inMenu = true
        end)

		GameUI.OnPhotoModeClose(function()
            inMenu = false
        end)
		GameUI.IsLoading(function()
			inMenu = true
		end)
		--[[
		Observe('FastTravelSystem', 'SetFastTravelStarted', function()
			print("started")
			inFastTravel = true
			inMenu = true
		end)	
		Observe('FastTravelSystem', 'OnLoadingScreenFinished', function(_, _)
		tempKeanuFastTravel = tempKeanuFastTravel + 1
			if tempKeanuFastTravel == 2 then --happens once when bar fills, again when game comes back
				inMenu = false
				print("finished")
				tempKeanuFastTravel = 0
				inFastTravel = false
			end
		end)
		]]
        inGame = not GameUI.IsDetached() -- Required to check if ingame after reloading all mods
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
function sceneTier2OrAbove()
	local blackboardDefs = Game.GetAllBlackboardDefs() 
	local blackboardPSM = Game.GetBlackboardSystem():GetLocalInstanced(Game.GetPlayer():GetEntityID(), blackboardDefs.PlayerStateMachine) 
	local tier = blackboardPSM:GetInt(blackboardDefs.PlayerStateMachine.SceneTier) 
	return tier>1 
end
return DCO:new()
