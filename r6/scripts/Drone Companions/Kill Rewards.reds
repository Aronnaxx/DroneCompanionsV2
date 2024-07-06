//Change killer to be player if it was one of our companions
@wrapMethod(GameObject)
 public final func FindAndRewardKiller(killType: gameKillType, opt instigator: wref<GameObject>) -> Void {
 

	if IsDefined(instigator as NPCPuppet){
		if (instigator as NPCPuppet).GetRecord().TagsContains(n"Robot"){
			instigator= GetPlayer(this.GetGame());
		}
	}
	
	let i:Int32 = 0;		
	while i < ArraySize(this.m_receivedDamageHistory) {
		if IsDefined(this.m_receivedDamageHistory[i].source as NPCPuppet){
			if (this.m_receivedDamageHistory[i].source as NPCPuppet).GetRecord().TagsContains(n"Robot"){
				this.m_receivedDamageHistory[i].source = GetPlayer(this.GetGame());
			}
		}
		i+=1;
	}
	
	wrappedMethod(killType, instigator);
  }