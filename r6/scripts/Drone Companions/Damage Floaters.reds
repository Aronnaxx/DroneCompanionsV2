@replaceMethod(DamageDigitsGameController)
  protected cb func OnDamageAdded(value: Variant) -> Bool {
    let controller: wref<DamageDigitLogicController>;
    let controllerFound: Bool;
    let damageInfo: DamageInfo;
    let damageListIndividual: array<DamageInfo>;
    let damageOverTime: Bool;
    let dotControllerFound: Bool;
    let entityDamageEntryList: array<DamageEntry>;
    let entityID: EntityID;
    let entityIDList: array<EntityID>;
    let k: Int32;
    let listPosition: Int32;
    let oneInstance: Bool;
    let showingBothSecondary: Bool;
    let damageList: array<DamageInfo> = FromVariant<array<DamageInfo>>(value);
    let showingBoth: Bool = this.m_showDigitsIndividual && this.m_showDigitsAccumulated && (Equals(this.m_damageDigitsStickingMode, IntEnum<gameuiDamageDigitsStickingMode>(0l)) || Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Both));
    let individualDigitsSticking: Bool = Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Individual) || Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Both);
    let accumulatedDigitsSticking: Bool = Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Accumulated) || Equals(this.m_damageDigitsStickingMode, gameuiDamageDigitsStickingMode.Both);
    let i: Int32 = 0;
    while i < ArraySize(damageList) {
      damageInfo = damageList[i];
      if Equals(this.m_realOwner, damageInfo.instigator) || (IsDefined(damageInfo.instigator as NPCPuppet) && (damageInfo.instigator as NPCPuppet).GetRecord().TagsContains(n"Robot")) {
        if this.ShowDamageFloater(damageInfo) {
          damageOverTime = this.IsDamageOverTime(damageInfo);
          if this.m_showDigitsAccumulated {
            if !EntityID.IsDefined(entityID) || entityID != damageInfo.entityHit.GetEntityID() {
              entityID = damageInfo.entityHit.GetEntityID();
              
			  //listPosition = ArrayFindFirst(entityIDList, entityID);
			  
			  let dcoi:Int32 = 0;
			  while dcoi<ArraySize(entityIDList){
				if Equals(entityID, entityIDList[i]){
					break;
				}
				dcoi+=1;
			  }
			  listPosition = dcoi;
			  
              if listPosition == -1 {
                listPosition = ArraySize(entityIDList);
                ArrayPush(entityIDList, entityID);
                ArrayGrow(entityDamageEntryList, 1);
              };
            };
            if damageOverTime && !accumulatedDigitsSticking {
              if entityDamageEntryList[listPosition].m_hasDamageOverTimeInfo {
                entityDamageEntryList[listPosition].m_damageOverTimeInfo.damageValue += damageInfo.damageValue;
                entityDamageEntryList[listPosition].m_damageOverTimeInfo.hitPosition += damageInfo.hitPosition;
                entityDamageEntryList[listPosition].m_damageOverTimeInfo.hitPosition *= 0.50;
                entityDamageEntryList[listPosition].m_oneDotInstance = false;
              } else {
                entityDamageEntryList[listPosition].m_damageOverTimeInfo = damageInfo;
                entityDamageEntryList[listPosition].m_hasDamageOverTimeInfo = true;
                entityDamageEntryList[listPosition].m_oneDotInstance = true;
              };
            } else {
              if entityDamageEntryList[listPosition].m_hasDamageInfo {
                entityDamageEntryList[listPosition].m_damageInfo.damageValue += damageInfo.damageValue;
                entityDamageEntryList[listPosition].m_damageInfo.hitPosition += damageInfo.hitPosition;
                entityDamageEntryList[listPosition].m_damageInfo.hitPosition *= 0.50;
                entityDamageEntryList[listPosition].m_oneInstance = false;
              } else {
                entityDamageEntryList[listPosition].m_damageInfo = damageInfo;
                entityDamageEntryList[listPosition].m_hasDamageInfo = true;
                entityDamageEntryList[listPosition].m_oneInstance = true;
              };
            };
          };
          if this.m_showDigitsIndividual {
            if this.m_showDigitsAccumulated {
              ArrayPush(damageListIndividual, damageInfo);
            } else {
              controller = this.m_digitsQueue.Dequeue() as DamageDigitLogicController;
              controller.Show(damageInfo, false, damageOverTime);
            };
          };
        };
      };
      i += 1;
    };
    if this.m_showDigitsAccumulated {
      i = 0;
      while i < ArraySize(entityIDList) {
        entityID = entityIDList[i];
        controllerFound = !entityDamageEntryList[i].m_hasDamageInfo;
        dotControllerFound = !entityDamageEntryList[i].m_hasDamageOverTimeInfo;
        k = 0;
        while k < this.m_maxAccumulatedVisible {
          if this.m_accumulatedControllerArray[k].m_used && this.m_accumulatedControllerArray[k].m_entityID == entityID {
            if entityDamageEntryList[i].m_hasDamageInfo && (!this.m_accumulatedControllerArray[k].m_isDamageOverTime || accumulatedDigitsSticking) {
              if !controllerFound {
                this.m_accumulatedControllerArray[k].m_controller.UpdateDamageInfo(entityDamageEntryList[i].m_damageInfo, showingBoth);
                entityDamageEntryList[i].m_oneInstance = false;
                controllerFound = true;
              };
            } else {
              if entityDamageEntryList[i].m_hasDamageOverTimeInfo && this.m_accumulatedControllerArray[k].m_isDamageOverTime {
                if !dotControllerFound {
                  this.m_accumulatedControllerArray[k].m_controller.UpdateDamageInfo(entityDamageEntryList[i].m_damageOverTimeInfo, this.m_showDigitsIndividual);
                  entityDamageEntryList[i].m_oneDotInstance = false;
                  dotControllerFound = true;
                };
              };
            };
            if this.m_accumulatedControllerArray[k].m_isDamageOverTime {
              entityDamageEntryList[i].m_hasDotAccumulator = true;
            };
          };
          k += 1;
        };
        if !controllerFound {
          oneInstance = entityDamageEntryList[i].m_oneInstance;
          k = 0;
          while k < this.m_maxAccumulatedVisible {
            if !this.m_accumulatedControllerArray[k].m_used {
              this.m_accumulatedControllerArray[k].m_used = true;
              this.m_accumulatedControllerArray[k].m_entityID = entityID;
              this.m_accumulatedControllerArray[k].m_isDamageOverTime = false;
              this.m_accumulatedControllerArray[k].m_controller.Show(entityDamageEntryList[i].m_damageInfo, showingBoth, oneInstance, false);
            } else {
              k += 1;
            };
          };
        };
        if !dotControllerFound {
          oneInstance = entityDamageEntryList[i].m_oneDotInstance;
          k = 0;
          while k < this.m_maxAccumulatedVisible {
            if !this.m_accumulatedControllerArray[k].m_used {
              this.m_accumulatedControllerArray[k].m_used = true;
              this.m_accumulatedControllerArray[k].m_entityID = entityID;
              this.m_accumulatedControllerArray[k].m_isDamageOverTime = true;
              this.m_accumulatedControllerArray[k].m_controller.Show(entityDamageEntryList[i].m_damageOverTimeInfo, this.m_showDigitsIndividual, oneInstance, true);
              entityDamageEntryList[i].m_hasDotAccumulator = true;
            } else {
              k += 1;
            };
          };
        };
        i += 1;
      };
    };
    if this.m_showDigitsIndividual && this.m_showDigitsAccumulated {
      i = 0;
      while i < ArraySize(damageListIndividual) {
        damageInfo = damageListIndividual[i];
        damageOverTime = this.IsDamageOverTime(damageInfo);
        if i == 0 || !EntityID.IsDefined(entityID) || entityID != damageInfo.entityHit.GetEntityID() {
          entityID = damageInfo.entityHit.GetEntityID();
          //listPosition = ArrayFindFirst(entityIDList, entityID);
		  			  
			  let dcoi:Int32 = 0;
			  while dcoi<ArraySize(entityIDList){
				if Equals(entityID, entityIDList[i]){
					break;
				}
				dcoi+=1;
			  }
			  listPosition = dcoi;
			  
        };
        if damageOverTime && !accumulatedDigitsSticking {
          oneInstance = entityDamageEntryList[listPosition].m_oneDotInstance;
        } else {
          oneInstance = entityDamageEntryList[listPosition].m_oneInstance;
        };
        if !oneInstance {
          if !showingBoth {
            showingBothSecondary = damageOverTime || entityDamageEntryList[listPosition].m_hasDotAccumulator && individualDigitsSticking;
          };
          controller = this.m_digitsQueue.Dequeue() as DamageDigitLogicController;
          controller.Show(damageInfo, showingBoth || showingBothSecondary, damageOverTime);
        };
        i += 1;
      };
    };
    this.WakeUp();
  }
