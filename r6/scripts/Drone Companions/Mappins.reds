@addMethod(MinimapStealthMappinController)
public func DCOFindArchetypeResource() -> ResRef {
    let npcPuppet: wref<NPCPuppet> = this.m_stealthMappin.GetGameObject() as NPCPuppet;
	let audio: CName = npcPuppet.GetRecord().AudioResourceName();
	let archetype: gamedataArchetypeType = npcPuppet.GetRecord().ArchetypeData().Type().Type();
	let npcType = npcPuppet.GetNPCType();
	
	return ResRef.FromString(TweakDBInterface.GetString(npcPuppet.GetRecordID() + t".DCOAtlasResource", ""));
	
	//return ResRef.FromString("base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas");
}
@addMethod(MinimapStealthMappinController)
public func DCOFindArchetypeName() -> CName {
	if true {
		return n"icon_part";
	}
    let npcPuppet: wref<NPCPuppet> = this.m_stealthMappin.GetGameObject() as NPCPuppet;
	let audio: CName = npcPuppet.GetRecord().AudioResourceName();
	let archetype: gamedataArchetypeType = npcPuppet.GetRecord().ArchetypeData().Type().Type();
	let npcType = npcPuppet.GetNPCType();
	
	//return ResRef.FromString(TweakDBInterface.GetString(npcPuppet.GetRecordID() + t".DCOAtlasResource", ""));
	
	//return ResRef.FromString("base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas");
	
	switch npcType{
		case gamedataNPCType.Mech:
			return n"archetype_mech";
		case gamedataNPCType.Drone:
			switch audio{
				case n"dev_drone_bombus_01":
				case n"dev_drone_griffin_01":
				case n"dev_drone_wyvern_01":
					return n"archetype_drone";
				case n"dev_drone_octant_01":
					return n"archetype_heavy_drone";
			}
		case gamedataNPCType.Android:
			switch archetype {
				case gamedataArchetypeType.FastMeleeT3:
				case gamedataArchetypeType.FastMeleeT2:
				case gamedataArchetypeType.HeavyMeleeT3:
				case gamedataArchetypeType.HeavyMeleeT2:
				case gamedataArchetypeType.GenericMeleeT2:
				case gamedataArchetypeType.GenericMeleeT1:
				case gamedataArchetypeType.AndroidMeleeT2:
				case gamedataArchetypeType.AndroidMeleeT1:
					return n"archetype_melee";
				case gamedataArchetypeType.FastRangedT3:
				case gamedataArchetypeType.FastRangedT2:
				case gamedataArchetypeType.GenericRangedT3:
				case gamedataArchetypeType.GenericRangedT2:
				case gamedataArchetypeType.GenericRangedT1:
				case gamedataArchetypeType.FriendlyGenericRangedT3:
				case gamedataArchetypeType.AndroidRangedT2:
					return n"archetype_ranged";
				case gamedataArchetypeType.FastShotgunnerT3:
				case gamedataArchetypeType.FastShotgunnerT2:
				case gamedataArchetypeType.ShotgunnerT3:
				case gamedataArchetypeType.ShotgunnerT2:
					return n"archetype_shotgun";
				case gamedataArchetypeType.FastSniperT3:
				case gamedataArchetypeType.SniperT2:
					return n"archetype_sniper";
				case gamedataArchetypeType.HeavyRangedT3:
				case gamedataArchetypeType.HeavyRangedT2:					
				case gamedataArchetypeType.TechieT3:
				case gamedataArchetypeType.TechieT2:		
					return n"archetype_heavy";
				case gamedataArchetypeType.NetrunnerT3:
				case gamedataArchetypeType.NetrunnerT2:
				case gamedataArchetypeType.NetrunnerT1:			
					return n"archetype_netrunner";
			}
		}
		return n"";
}
@wrapMethod(MinimapStealthMappinController)
  protected func Intro() -> Void {
  	let myPuppet: wref<NPCPuppet> = this.m_stealthMappin.GetGameObject() as NPCPuppet;
	if IsDefined(myPuppet) && myPuppet.GetRecord().TagsContains(n"Robot"){
	
    let npcPuppet: wref<NPCPuppet>;
    this.m_stealthMappin = this.GetMappin() as StealthMappin;
    let gameObject: wref<GameObject> = this.m_stealthMappin.GetGameObject();
    this.m_iconWidgetGlitch = inkWidgetRef.Get(this.iconWidget);
    this.m_visionConeWidgetGlitch = inkWidgetRef.Get(this.visionConeWidget);
    this.m_clampArrowWidgetGlitch = inkWidgetRef.Get(this.clampArrowWidget);
    if gameObject != null {
      this.m_isPrevention = gameObject.IsPrevention();
      this.m_isDevice = gameObject.IsDevice();
      this.m_isCamera = gameObject.IsDevice() && gameObject.IsSensor() && !gameObject.IsTurret();
      this.m_isTurret = gameObject.IsTurret();
      this.m_isNetrunner = this.m_stealthMappin.IsNetrunner();
      this.m_policeChasePrototypeEnabled = GameInstance.GetPreventionSpawnSystem(gameObject.GetGame()).IsPreventionVehiclePrototypeEnabled();
      if this.m_isPrevention && this.m_policeChasePrototypeEnabled {
        npcPuppet = gameObject as NPCPuppet;
        if IsDefined(npcPuppet) {
          this.m_puppetStateBlackboard = npcPuppet.GetPuppetStateBlackboard();
          if IsDefined(this.m_puppetStateBlackboard) {
            this.m_isInVehicleStance = this.IsVehicleStance(IntEnum<gamedataNPCStanceState>(this.m_puppetStateBlackboard.GetInt(GetAllBlackboardDefs().PuppetState.Stance)));
            this.m_stanceStateCb = this.m_puppetStateBlackboard.RegisterListenerInt(GetAllBlackboardDefs().PuppetState.Stance, this, n"OnStanceStateChanged");
          };
        };
      };
    };
    this.m_isCrowdNPC = this.m_stealthMappin.IsCrowdNPC();
    if this.m_isCrowdNPC && !this.m_stealthMappin.IsAggressive() || gameObject != null && !gameObject.IsDevice() && !this.m_stealthMappin.IsAggressive() && NotEquals(this.m_stealthMappin.GetAttitudeTowardsPlayer(), EAIAttitude.AIA_Friendly) {
      this.m_defaultOpacity = 0.50;
    } else {
      this.m_defaultOpacity = 1.00;
    };
    this.m_root.SetOpacity(this.m_defaultOpacity);
    this.m_defaultConeOpacity = 0.80;
    this.m_detectingConeOpacity = 1.00;
    this.m_wasCompanion = ScriptedPuppet.IsPlayerCompanion(gameObject);
    if this.m_wasCompanion {
      inkImageRef.SetTexturePart(this.iconWidget, n"friendly_ally15");
	  
	   npcPuppet = gameObject as NPCPuppet;
        if IsDefined(npcPuppet) && npcPuppet.GetRecord().TagsContains(n"Robot"){
			//LogChannel(n"DEBUG", "One of our guys");
					
					inkImageRef.SetAtlasResource(this.iconWidget, this.DCOFindArchetypeResource());
					inkImageRef.SetTexturePart(this.iconWidget, this.DCOFindArchetypeName());
					//r"base\\icon\\androidranged_atlas.inkatlas");
			//inkImageRef.SetTexturePart(this.iconWidget, n"icon_part");
			inkWidgetRef.SetScale(this.iconWidget, new Vector2(0.3, 0.3));
			
			let tempColor: HDRColor = inkWidgetRef.GetTintColor(this.iconWidget);
			tempColor.Red = TweakDBInterface.GetFloat(t"DCO.MappinRed", tempColor.Red);
			tempColor.Green = TweakDBInterface.GetFloat(t"DCO.MappinGreen", tempColor.Green);
			tempColor.Blue = TweakDBInterface.GetFloat(t"DCO.MappinBlue", tempColor.Blue);
			tempColor.Alpha = TweakDBInterface.GetFloat(t"DCO.MappinAlpha", tempColor.Alpha);
			inkWidgetRef.SetTintColor(this.iconWidget, tempColor);

		}
    } else {
      if this.m_isCamera {
        inkImageRef.SetTexturePart(this.iconWidget, n"cameraMappin");
        inkImageRef.SetTexturePart(this.visionConeWidget, n"camera_cone");
      };
    };
    inkWidgetRef.SetOpacity(this.visionConeWidget, this.m_defaultConeOpacity);
    if this.m_isNetrunner {
      this.m_iconWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", true);
      this.m_visionConeWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", true);
      this.m_clampArrowWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", true);
    };
    this.m_wasAlive = true;
    this.m_cautious = false;
    this.m_lockLootQuality = false;
    super.Intro();
	} else{
		wrappedMethod();
	}
  }
  
@wrapMethod(MinimapStealthMappinController)
  protected func Update() -> Void {
  
	let myPuppet: wref<NPCPuppet> = this.m_stealthMappin.GetGameObject() as NPCPuppet;
	if IsDefined(myPuppet) && myPuppet.GetRecord().TagsContains(n"Robot"){
     let npcPuppet: wref<NPCPuppet>;
    let gameDevice: wref<Device>;
    let hasItems: Bool;
    let isOnSameFloor: Bool;
    let shouldShowMappin: Bool;
    let shouldShowVisionCone: Bool;
    let gameObject: wref<GameObject> = this.m_stealthMappin.GetGameObject();
    this.m_isAlive = this.m_stealthMappin.IsAlive();
    let isTagged: Bool = this.m_stealthMappin.IsTagged();
    let hasBeenSeen: Bool = this.m_stealthMappin.HasBeenSeen();
    let isCompanion: Bool = gameObject != null && ScriptedPuppet.IsPlayerCompanion(gameObject);
    let attitude: EAIAttitude = this.m_stealthMappin.GetAttitudeTowardsPlayer();
    let vertRelation: gamemappinsVerticalPositioning = this.GetVerticalRelationToPlayer();
    let shotAttempts: Uint32 = this.m_stealthMappin.GetNumberOfShotAttempts();
    this.m_highLevelState = this.m_stealthMappin.GetHighLevelState();
    let isHighlighted: Bool = this.m_stealthMappin.IsHighlighted();
    this.m_isSquadInCombat = this.m_stealthMappin.IsSquadInCombat();
    let canSeePlayer: Bool = this.m_stealthMappin.CanSeePlayer();
    this.m_detectionAboveZero = this.m_stealthMappin.GetDetectionProgress() > 0.00;
    let wasDetectionAboveZero: Bool = this.m_stealthMappin.WasDetectionAboveZero();
    let numberOfCombatantsAboveZero: Bool = this.m_stealthMappin.GetNumberOfCombatants() > 0u;
    let isUsingSenseCone: Bool = this.m_stealthMappin.IsUsingSenseCone();
    this.m_isHacking = this.m_stealthMappin.HasHackingStatusEffect();
    if this.m_isDevice {
      this.m_isAggressive = NotEquals(attitude, EAIAttitude.AIA_Friendly);
      if this.m_isAggressive {
        gameDevice = gameObject as Device;
        if IsDefined(gameDevice) {
          isUsingSenseCone = gameDevice.GetDevicePS().IsON();
        };
        if this.m_isCamera && numberOfCombatantsAboveZero {
          canSeePlayer = false;
          isUsingSenseCone = false;
        } else {
          if this.m_isTurret {
            isUsingSenseCone = isUsingSenseCone && (Equals(attitude, EAIAttitude.AIA_Hostile) || !this.m_isPrevention);
            if !isUsingSenseCone {
              this.m_isSquadInCombat = false;
            };
          };
        };
        if Equals(this.m_stealthMappin.GetStealthAwarenessState(), gameEnemyStealthAwarenessState.Combat) {
          this.m_isSquadInCombat = true;
        };
      };
    } else {
      this.m_isAggressive = this.m_stealthMappin.IsAggressive() && NotEquals(attitude, EAIAttitude.AIA_Friendly);
    };
    if !this.m_cautious {
      if !this.m_isDevice && NotEquals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) && NotEquals(this.m_highLevelState, gamedataNPCHighLevelState.Any) && !this.m_isSquadInCombat && this.m_isAlive && this.m_isAggressive {
        this.m_cautious = true;
        this.PulseContinuous(true);
      };
    } else {
      if Equals(this.m_highLevelState, gamedataNPCHighLevelState.Relaxed) || Equals(this.m_highLevelState, gamedataNPCHighLevelState.Any) || this.m_isSquadInCombat || !this.m_isAlive {
        this.m_cautious = false;
        this.PulseContinuous(false);
      };
    };
    if this.m_hasBeenLooted || this.m_stealthMappin.IsHiddenByQuestOnMinimap() {
      shouldShowMappin = false;
    } else {
      if this.m_isPrevention && this.m_policeChasePrototypeEnabled {
        shouldShowMappin = !this.m_isInVehicleStance;
      } else {
        if this.m_isDevice && !this.m_isAggressive {
          shouldShowMappin = false;
        } else {
          if !IsMultiplayer() {
            shouldShowMappin = hasBeenSeen || !this.m_isAlive || isCompanion || wasDetectionAboveZero || isHighlighted || isTagged;
          } else {
            shouldShowMappin = (isCompanion || wasDetectionAboveZero || isHighlighted) && this.m_isAlive;
          };
        };
      };
    };
    this.SetForceHide(!shouldShowMappin);
	
    if shouldShowMappin {
      if !this.m_isAlive {
        if this.m_wasAlive {
          if !this.m_isCamera {
            inkImageRef.SetTexturePart(this.iconWidget, n"enemy_icon_4");
            inkWidgetRef.SetScale(this.iconWidget, new Vector2(0.75, 0.75));
          };
          this.m_defaultOpacity = MinF(this.m_defaultOpacity, 0.50);
          this.m_wasAlive = false;
        };
        hasItems = this.m_stealthMappin.HasItems();
        if !hasItems || this.m_isDevice {
          this.FadeOut();
        };
      } else {
        if isCompanion && !this.m_wasCompanion {
          inkImageRef.SetTexturePart(this.iconWidget, n"friendly_ally15");
		  	   npcPuppet = gameObject as NPCPuppet;
        if IsDefined(npcPuppet) && npcPuppet.GetRecord().TagsContains(n"Robot"){
			//LogChannel(n"DEBUG", "One of our guys update");
			inkImageRef.SetAtlasResource(this.iconWidget, this.DCOFindArchetypeResource());
			inkImageRef.SetTexturePart(this.iconWidget, this.DCOFindArchetypeName());

			//inkImageRef.SetTexturePart(this.iconWidget, n"icon_part");
			inkWidgetRef.SetScale(this.iconWidget, new Vector2(0.3, 0.3));
						
			let tempColor: HDRColor = inkWidgetRef.GetTintColor(this.iconWidget);
			tempColor.Red = TweakDBInterface.GetFloat(t"DCO.MappinRed", tempColor.Red);
			tempColor.Green = TweakDBInterface.GetFloat(t"DCO.MappinGreen", tempColor.Green);
			tempColor.Blue = TweakDBInterface.GetFloat(t"DCO.MappinBlue", tempColor.Blue);
			tempColor.Alpha = TweakDBInterface.GetFloat(t"DCO.MappinAlpha", tempColor.Alpha);

			inkWidgetRef.SetTintColor(this.iconWidget, tempColor);
		}
        } else {
          if NotEquals(this.m_isTagged, isTagged) && !this.m_isCamera {
            if isTagged {
              inkImageRef.SetTexturePart(this.iconWidget, n"enemyMappinTagged");
            } else {
              inkImageRef.SetTexturePart(this.iconWidget, n"enemyMappin");
            };
          };
        };
      };
      this.m_isTagged = isTagged;
      if this.m_isSquadInCombat && !this.m_wasSquadInCombat || this.m_numberOfShotAttempts != shotAttempts {
        this.m_numberOfShotAttempts = shotAttempts;
        this.Pulse(2);
      };
      isOnSameFloor = Equals(vertRelation, gamemappinsVerticalPositioning.Same);
      this.m_adjustedOpacity = isOnSameFloor ? this.m_defaultOpacity : 0.30 * this.m_defaultOpacity;
      shouldShowVisionCone = this.m_isAlive && isUsingSenseCone && this.m_isAggressive;
      if NotEquals(this.m_shouldShowVisionCone, shouldShowVisionCone) {
        this.m_shouldShowVisionCone = shouldShowVisionCone;
        this.m_stealthMappin.UpdateSenseConeAvailable(this.m_shouldShowVisionCone);
        if this.m_shouldShowVisionCone {
          this.m_stealthMappin.UpdateSenseCone();
        };
      };
      if this.m_shouldShowVisionCone {
        if NotEquals(canSeePlayer, this.m_couldSeePlayer) || this.m_isSquadInCombat && !this.m_wasSquadInCombat {
          if canSeePlayer && !this.m_isSquadInCombat {
            inkWidgetRef.SetOpacity(this.visionConeWidget, this.m_detectingConeOpacity);
            inkWidgetRef.SetScale(this.visionConeWidget, new Vector2(1.50, 1.50));
          } else {
            inkWidgetRef.SetOpacity(this.visionConeWidget, this.m_defaultConeOpacity);
            inkWidgetRef.SetScale(this.visionConeWidget, new Vector2(1.00, 1.00));
          };
          this.m_couldSeePlayer = canSeePlayer;
        };
      };
      inkWidgetRef.SetVisible(this.visionConeWidget, this.m_shouldShowVisionCone);
      if !this.m_wasVisible {
        if IsDefined(this.m_showAnim) {
          this.m_showAnim.Stop();
        };
        this.m_showAnim = this.PlayLibraryAnimation(n"Show");
      };
    };
    if this.m_isNetrunner {
      if !this.m_isAlive {
        this.m_iconWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", false);
        this.m_visionConeWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", false);
        this.m_clampArrowWidgetGlitch.SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", false);
      } else {
        if this.m_isHacking {
          this.m_iconWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.70);
          this.m_visionConeWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.80);
          this.m_clampArrowWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.20);
        } else {
          this.m_iconWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.05);
          this.m_visionConeWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.05);
          this.m_clampArrowWidgetGlitch.SetEffectParamValue(inkEffectType.Glitch, n"Glitch_0", n"intensity", 0.05);
        };
      };
    };
    if !this.m_lockLootQuality {
      this.m_highestLootQuality = this.m_stealthMappin.GetHighestLootQuality();
    };
    this.m_attitudeState = this.GetStateForAttitude(attitude, canSeePlayer);
    this.m_stealthMappin.SetVisibleOnMinimap(shouldShowMappin);
    this.m_stealthMappin.SetIsPulsing(this.m_pulsing);
    this.m_clampingAvailable = this.m_isTagged || this.m_isAggressive && (this.m_isSquadInCombat || this.m_detectionAboveZero);
    this.OverrideClamp(this.m_clampingAvailable);
    this.m_wasCompanion = isCompanion;
    this.m_wasSquadInCombat = this.m_isSquadInCombat;
    this.m_wasVisible = shouldShowMappin;
    super.Update();
	
	} else {
		wrappedMethod();
	}
 
  }