
@wrapMethod(AIActionTarget)
private final static func BossThreatCalculation(owner: wref<ScriptedPuppet>, ownerPos: Vector4, targetTrackerComponent: ref<TargetTrackerComponent>, newTargetObject: wref<GameObject>, threat: wref<GameObject>, timeSinceTargetChange: Float, currentTime: Float, out threatValue: Float) -> Void {
 	wrappedMethod(owner, ownerPos, targetTrackerComponent, newTargetObject, threat, timeSinceTargetChange, currentTime, threatValue);
	let SES: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(owner.GetGame());

	//Targeting drones by type
	let threatID: TweakDBID = (threat as NPCPuppet).GetRecord().GetID();
	if TweakDBInterface.GetCharacterRecord(threatID).TagsContains(n"Robot"){
		let threatType: gamedataNPCType =(threat as NPCPuppet).GetNPCType();
		let ownerArchetype = TweakDBInterface.GetCharacterRecord((owner as NPCPuppet).GetRecord().GetID()).ArchetypeData().Type();
		/*switch threatID {
			case t"DCO.Tier1Bombus1":
			case t"DCO.Tier1Bombus2":
			case t"DCO.Tier1Bombus3":
			threatValue*=0.15;
		}*/
		switch threatType {
			case gamedataNPCType.Drone:
				threatValue*=1.5;
				break;
			case gamedataNPCType.Android:
				threatValue*=1.5;
				break;
			case gamedataNPCType.Mech:
				threatValue*=1.5;
				break;
		}
		
		//Drones with low health more likely to be attacked.
		let targetHP: Float = GameInstance.GetStatPoolsSystem(owner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(threat.GetEntityID()), gamedataStatPoolType.Health, true);
		
		let playerHP: Float = GameInstance.GetStatPoolsSystem(owner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(GetPlayer(owner.GetGame()).GetEntityID()), gamedataStatPoolType.Health, true);
		
		if playerHP>40.0{
			threatValue*= 2.0 - (targetHP)/100.0;
		}
		//Cloaked drones not really targeted
		let threadEntID: EntityID = threat.GetEntityID();
		if SES.HasStatusEffect(threadEntID, t"DCO.DroneCloakSE") || SES.HasStatusEffect(threadEntID, t"DCO.DroneCloakSESpread") || SES.HasStatusEffect(threadEntID, t"DCO.DroneCloakOnHitSE"){
			threatValue*=0.25;
		}
		
		//Drones closer to enemy more likely to be attacked
		let distToTarget: Float;
		let distToPlayer: Float;
		distToPlayer = Vector4.Distance(GetPlayer(owner.GetGame()).GetWorldPosition(), owner.GetWorldPosition());
		if distToPlayer>5.0 {
			distToTarget = Vector4.Distance(owner.GetWorldPosition(), threat.GetWorldPosition());
			if distToTarget>30.0 {
				distToTarget = 30.0;
			}
			threatValue*= 1.5 - distToTarget/60.0;
		}
		
		
		//Disable targetting drones in boxing matches.
		if StatusEffectSystem.ObjectHasStatusEffectWithTag(GetPlayer(owner.GetGame()), n"FistFight") {
			threatValue = 0;
		}

	}
}
@wrapMethod(AIActionTarget)
  private final static func RegularThreatCalculation(owner: wref<ScriptedPuppet>, ownerPos: Vector4, targetTrackerComponent: ref<TargetTrackerComponent>, newTargetObject: wref<GameObject>, threat: wref<GameObject>, timeSinceTargetChange: Float, currentTime: Float, out threatValue: Float) -> Void {
  
 	wrappedMethod(owner, ownerPos, targetTrackerComponent, newTargetObject, threat, timeSinceTargetChange, currentTime, threatValue);
	let SES: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(owner.GetGame());

	if !IsDefined(threat) || !IsDefined(owner){
		return;
	}
	//Tagged enemies are much more likely to be attacked
	if TweakDBInterface.GetCharacterRecord((owner as NPCPuppet).GetRecord().GetID()).TagsContains(n"Robot"){
		if threat.IsTaggedinFocusMode(){
			threatValue*=10.0;
		};
		
		//Enemies closer to player more likely to be attacked
		let distToPlayer: Float;
		distToPlayer = Vector4.Distance(GetPlayer(owner.GetGame()).GetWorldPosition(), threat.GetWorldPosition());
		if distToPlayer>30.0 {
			distToPlayer = 30.0;
		}
		threatValue*= 1.5 - distToPlayer/60.0;
		
		//Enemies with low health more likely to be attacked.
		let targetHP: Float = GameInstance.GetStatPoolsSystem(owner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(threat.GetEntityID()), gamedataStatPoolType.Health, true);
		
		threatValue*= 1.5 - (targetHP*0.5)/100.0;
		
		let threadEntID: EntityID = threat.GetEntityID();

		//Android netrunners target switching so they dont just upload quickhacks on one npc
		let archetypeType: gamedataArchetypeType = TweakDBInterface.GetCharacterRecord((owner as NPCPuppet).GetRecord().GetID()).ArchetypeData().Type().Type();
		if Equals(archetypeType, gamedataArchetypeType.NetrunnerT3){
		
			if SES.HasStatusEffect(threadEntID, t"BaseStatusEffect.Madness"){
				threatValue*=0.5;
			}
			if SES.HasStatusEffect(threadEntID, t"DCO.AndroidContagionSE"){
				threatValue*=0.5;
			}
			if SES.HasStatusEffect(threadEntID, t"DCO.AndroidOverheatSE"){
				threatValue*=0.5;
			}
			if SES.HasStatusEffect(threadEntID, t"DCO.AndroidOverloadSE"){
				threatValue*=0.5;
			}
			if SES.HasStatusEffect(threadEntID, t"DCO.AndroidCrippleSE"){
				threatValue*=0.5;
			}
			if SES.HasStatusEffect(threadEntID, t"DCO.AndroidBlindSE"){
				threatValue*=0.5;
			}
			if SES.HasStatusEffect(threadEntID, t"BaseStatusEffect.WeaponMalfunction"){
				threatValue*=0.5;
			}
			// //Netrunners have mega useful hacks against robots
			// if ScriptedPuppet.IsMechanical(threat as NPCPuppet){
			// 	threatValue*=5.0;
			// }

		};
		

	}
	
	
	//Targeting drones by type
		let threatID: TweakDBID = (threat as NPCPuppet).GetRecord().GetID();
	if TweakDBInterface.GetCharacterRecord(threatID).TagsContains(n"Robot"){
		
		let threatType: gamedataNPCType =(threat as NPCPuppet).GetNPCType();
		let ownerArchetype: gamedataArchetypeType = TweakDBInterface.GetCharacterRecord((owner as NPCPuppet).GetRecord().GetID()).ArchetypeData().Type().Type();
		/*switch threatID {
			case t"DCO.Tier1Bombus1":
			case t"DCO.Tier1Bombus2":
			case t"DCO.Tier1Bombus3":
			threatValue*=0.5;
		}*/

		//Octants more likely to be targetted
		if Equals(TweakDBInterface.GetCharacterRecord(threatID).AudioResourceName(), (n"dev_drone_octant_01")){
			//threatValue*=1.3;
		}
		switch threatType {
			case gamedataNPCType.Drone:
				switch ownerArchetype{
					case gamedataArchetypeType.FastSniperT3:
					case gamedataArchetypeType.NetrunnerT1:
					case gamedataArchetypeType.NetrunnerT2:
					case gamedataArchetypeType.NetrunnerT3:
					case gamedataArchetypeType.SniperT2:
						threatValue*=0.5;
					break;
				}
				threatValue*=0.7;
				break;
			case gamedataNPCType.Android:
				switch ownerArchetype{
					case gamedataArchetypeType.FastSniperT3:
					case gamedataArchetypeType.NetrunnerT1:
					case gamedataArchetypeType.NetrunnerT2:
					case gamedataArchetypeType.NetrunnerT3:
					case gamedataArchetypeType.SniperT2:
						threatValue*=0.5;
					break;
				}
				threatValue*=1.2;
				break;
			case gamedataNPCType.Mech:
				switch ownerArchetype{
					case gamedataArchetypeType.FastMeleeT2:
					case gamedataArchetypeType.FastMeleeT3:
					case gamedataArchetypeType.FastShotgunnerT2:
					case gamedataArchetypeType.FastShotgunnerT3:
					case gamedataArchetypeType.FastSniperT3:
					case gamedataArchetypeType.GenericMeleeT1:
					case gamedataArchetypeType.GenericMeleeT2:
					case gamedataArchetypeType.HeavyMeleeT2:
					case gamedataArchetypeType.HeavyMeleeT2:
					case gamedataArchetypeType.NetrunnerT1:
					case gamedataArchetypeType.NetrunnerT2:
					case gamedataArchetypeType.NetrunnerT3:
					case gamedataArchetypeType.ShotgunnerT2:
					case gamedataArchetypeType.ShotgunnerT3:
					case gamedataArchetypeType.SniperT2:
						threatValue*=0.3;
					break;
						threatValue*=2.0;
				}
				break;
		}
		
		//Cloaked drones not really targeted
		let threadEntID: EntityID = threat.GetEntityID();
		if SES.HasStatusEffect(threadEntID, t"DCO.DroneCloakSE") || SES.HasStatusEffect(threadEntID, t"DCO.DroneCloakSESpread") || SES.HasStatusEffect(threadEntID, t"DCO.DroneCloakOnHitSE"){
			threatValue*=0.25;
		}
		
		//Drones with low health more likely to be attacked, but only if player's hp is high.
		let targetHP: Float = GameInstance.GetStatPoolsSystem(owner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(threat.GetEntityID()), gamedataStatPoolType.Health, true);
		
		let playerHP: Float = GameInstance.GetStatPoolsSystem(owner.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(GetPlayer(owner.GetGame()).GetEntityID()), gamedataStatPoolType.Health, true);
		
		if playerHP>40.0{
			threatValue*= 2.0 - (targetHP)/100.0;
		}
		
		//Drones closer to enemy more likely to be attacked
		let distToTarget: Float;
		let distToPlayer: Float;
		distToPlayer = Vector4.Distance(GetPlayer(owner.GetGame()).GetWorldPosition(), owner.GetWorldPosition());
		if distToPlayer>5.0 {
			distToTarget = Vector4.Distance(owner.GetWorldPosition(), threat.GetWorldPosition());
			if distToTarget>30.0 {
				distToTarget = 30.0;
			}
			threatValue*= 1.5 - distToTarget/60.0;
		}
		
		
		//Disable targetting drones in boxing matches.
		if StatusEffectSystem.ObjectHasStatusEffectWithTag(GetPlayer(owner.GetGame()), n"FistFight") {
			threatValue = 0;
		}
	}
	
  }