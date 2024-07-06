@wrapMethod(DamageSystem)
  private final func Process(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
		if IsDefined(hitEvent.attackData.GetInstigator() as ScriptedPuppet) && IsDefined(hitEvent.target as ScriptedPuppet){
			if ((hitEvent.attackData.GetInstigator() as ScriptedPuppet).GetRecord().TagsContains(n"Robot")
			&&  (hitEvent.target as ScriptedPuppet).GetRecord().TagsContains(n"Robot"))
			
			||((hitEvent.attackData.GetInstigator() as ScriptedPuppet).IsPlayer()
			&&  (hitEvent.target as ScriptedPuppet).GetRecord().TagsContains(n"Robot"))
			
			
			||((hitEvent.attackData.GetInstigator() as ScriptedPuppet).GetRecord().TagsContains(n"Robot")
			&&  (hitEvent.target as ScriptedPuppet).IsPlayer())
			
			{
				return;
			}
		}
		wrappedMethod(hitEvent, cache);

	}