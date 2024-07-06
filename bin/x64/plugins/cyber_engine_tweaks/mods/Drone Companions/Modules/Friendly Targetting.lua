R = { 
    description = "DCO"
}

function DCO:new()


	---------------------CUSTOM MAPPINS-----------------------------
	
	--Also handled in redscript
	
	mmvec = Vector2:new()
	mmvec.X = 0.3
	mmvec.Y = 0.3
	
	--Mappin color
	r = 0
	g = 1.5
	b = 0
	a = 1
	
	TweakDB:SetFlat("DCO.MappinRed", r, 'Float')
	TweakDB:SetFlat("DCO.MappinGreen", g, 'Float')
	TweakDB:SetFlat("DCO.MappinBlue", b, 'Float')
	TweakDB:SetFlat("DCO.MappinAlpha", a, 'Float')

	local mappinColor = HDRColor:new()
	mappinColor.Red = r
	mappinColor.Green = g
	mappinColor.Blue = b
	mappinColor.Alpha = a
	
	--Needs to be updated again bc friendly set changes mappin
	Observe('BaseMinimapMappinController', 'Update', function(self)
		robot = self.stealthMappin:GetGameObject()
		if IsDefined(robot:GetRecord()) and robot:GetRecord():TagsContains(CName.new("Robot")) then
			inkImageRef.SetAtlasResource(self.iconWidget, self:DCOFindArchetypeResource())
			inkImageRef.SetTexturePart(self.iconWidget, self:DCOFindArchetypeName())
			inkWidgetRef.SetScale(self.iconWidget, mmvec)
			inkWidgetRef.SetTintColor(self.iconWidget, mappinColor)
		end
	end)


	------------------ENABLE FRIENDLY HACKS-------------------------

	
	Override('ScriptedPuppetPS', 'IsQuickHacksExposed', function(self, wrappedMethod)
		if TweakDBInterface.GetCharacterRecord(self:GetOwnerEntity():GetRecordID()):TagsContains(CName.new("Robot")) then
			return true
		end
		--[[
		elseif (Game.GetStatsSystem():GetStatValue(Game.GetPlayer():GetEntityID(), gamedataStatType.NPCAnimationTime) > 0 and Game.GetStatsSystem():GetStatValue(Game.GetPlayer():GetEntityID(), gamedataStatType. then
			return false
		end		]]
		return wrappedMethod()
	end)
	
	Override('ScriptedPuppet', 'IsQuickHackAble', function(self, wrappedMethod)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) and not (GetMountedVehicle(self)) then
			return true
		end
		--[[
		elseif Game.GetStatsSystem():GetStatValue(Game.GetPlayer():GetEntityID(), gamedataStatType.NPCAnimationTime) > 0 then
			return false
		end]]
		return wrappedMethod()
	end)
		
	
	------------------------ENABLE HEALTHBARS AND ICONS-------------------------------
	
	
	Override('NameplateVisualsLogicController', 'SetAttitudeColors', function(self, owner, incomingData, wrappedMethod)
		wrappedMethod(owner, incomingData)
		
			if owner and TweakDBInterface.GetCharacterRecord(owner:GetRecordID()):TagsContains(CName.new("Robot"))then
			  inkWidgetRef.SetState(self.bigLevelText, CName.new("Friendly"))
			  inkWidgetRef.SetState(self.bigIconArt, CName.new("Friendly"))
			  inkWidgetRef.SetState(self.civilianIcon, CName.new("Friendly"))
			  inkWidgetRef.SetState(self.rareStars, CName.new("Friendly"))
			  inkWidgetRef.SetState(self.eliteStars, CName.new("Friendly"))
			  inkWidgetRef.SetState(self.nameTextMain,CName.new("Friendly"))
			  inkWidgetRef.SetState(self.hardEnemy, CName.new("Friendly"))
		  end
	  end)
	
	

	
	--Makes companion health bars visible
	Override('NameplateVisualsLogicController', 'UpdateHealthbarVisibility', function(self, wrappedMethod)
		wrappedMethod()
		if self.cachedPuppet and TweakDBInterface.GetCharacterRecord(self.cachedPuppet:GetRecordID()):TagsContains(CName.new("Robot")) and not self.npcIsAggressive then
			inkWidgetRef.SetVisible(self.healthbarWidget, true)
		end
	end)
	
	--Green health bar
	Override('NameplateVisualsLogicController', 'UpdateHealthbarColor', function(self, isHostile, wrappedMethod)
		if self.cachedPuppet and TweakDBInterface.GetCharacterRecord(self.cachedPuppet:GetRecordID()):TagsContains(CName.new("Robot")) and not self.npcIsAggressive then
			inkWidgetRef.SetState(self.healthbarWidget, CName.new("Friendly"))
			inkWidgetRef.SetState(self.healthBarFull, CName.new("Friendly"))
		else
			wrappedMethod(isHostile)
		end
	end)
	

	--Enable healthbars for friendlies from a distance
	Override('NpcNameplateGameController', 'HelperCheckDistance', function(self, entity, wrappedMethod)
		if TweakDBInterface.GetCharacterRecord(entity:GetRecordID()):TagsContains(CName.new("Robot")) then
			return true
		end
		return wrappedMethod(entity)
	end)
	


	
	--Set archetype icons to green
	Override('StealthMappinController', 'UpdateNameplateIcon', function(self, wrappedMethod)
		wrappedMethod()
		if TweakDBInterface.GetCharacterRecord(self.ownerObject:GetRecordID()):TagsContains(CName.new("Robot")) then
		    inkWidgetRef.SetState(self.levelIcon, CName.new("ThreatLow"))
		end
	end)
	
	--Keep er goin
	Override('StealthMappinController', 'ShouldDisableMappin', function(self, wrappedMethod)
		if not IsDefined(self.ownerObject) then
			return true
		elseif TweakDBInterface.GetCharacterRecord(self.ownerObject:GetRecordID()):TagsContains(CName.new("Robot")) then
			return false	
		end
		return wrappedMethod()
	end)
	


	--Make our mappin look cooler
	
	Override('StealthMappinController', 'UpdateArchetypeTexture', function(self, wrappedMethod)
		wrappedMethod()
		if TweakDBInterface.GetCharacterRecord(self.ownerObject:GetRecordID()):TagsContains(CName.new("Robot")) then
			vec = Vector2:new()
			vec.x = 200
			vec.y = 100
			inkWidgetRef.SetSize(self.frame, vec)
			
			
		end
	end)
	
	--Set tag to be green
	Override('StealthMappinController', 'UpdateObjectMarkerVisibility', function(self, canHaveObjectMarker, objectMarkerVisible, wrappedMethod)
		wrappedMethod(canHaveObjectMarker, objectMarkerVisible)
		if TweakDBInterface.GetCharacterRecord(self.ownerObject:GetRecordID()):TagsContains(CName.new("Robot")) then
			inkWidgetRef.SetState(self.objectMarker, CName.new("Friendly"))
			self.mappin:UpdateObjectMarkerVisibility(canHaveObjectMarker, objectMarkerVisible)
		end
	end)
	
	----------------------ENABLE TAGGING AND AIMING AT--------------------------------
	
	--[[
	Override('ScriptedPuppet', 'CanBeTagged', function(self, wrappedMethod)
		if TweakDBInterface.GetCharacterRecord(self:GetRecordID()):TagsContains(CName.new("Robot")) then
			return true
		end

		return wrappedMethod()
	end)
	]]
	
	
	Override('PlayerPuppet', 'UpdateLookAtObject', function(self, target, wrappedMethod)
		wrappedMethod(target)
			if not IsDefined(target) then
				return
			end
			id = target:GetRecord():GetID()
			if id == TweakDBID.new("Weakspots.Mech_Weapon_Left_Weakspot") or id == TweakDBID.new("Weakspots.Mech_Weapon_Right_Weakspot") or TweakDBInterface.GetCharacterRecord(id):TagsContains(CName.new("Robot")) then
				self.isAimingAtFriendly = false
				return
			end

	end)
	
end


return DCO:new()
