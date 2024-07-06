@replaceMethod(RPGManager)
public final static func GetPlayerQuickHackListWithQuality(player: wref<PlayerPuppet>) -> array<PlayerQuickhackData> {
    let actions: array<wref<ObjectAction_Record>>;
    let i: Int32;
    let i1: Int32;
    let itemRecord: wref<Item_Record>;
    let parts: array<SPartSlots>;
    let quickhackData: PlayerQuickhackData;
    let quickhackDataEmpty: PlayerQuickhackData;
    let systemReplacementID: ItemID;
    let quickhackDataArray: array<PlayerQuickhackData> = player.GetCachedQuickHackList();
    if ArraySize(quickhackDataArray) > 0 {
      return quickhackDataArray;
    };
	
	let deckIDs: array<ItemID> = EquipmentSystem.GetItemsInArea(player, gamedataEquipmentArea.SystemReplacementCW);
	let myint: Int32 = 0;
	
	while myint < ArraySize(deckIDs) {
		//systemReplacementID = EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
		systemReplacementID = deckIDs[myint];
		itemRecord = RPGManager.GetItemRecord(systemReplacementID);
		if EquipmentSystem.IsCyberdeckEquipped(player) {
		  itemRecord.ObjectActions(actions);
		  i = 0;
		  while i < ArraySize(actions) {
			quickhackData = quickhackDataEmpty;
			quickhackData.actionRecord = actions[i];
			quickhackData.quality = itemRecord.Quality().Value();
			ArrayPush(quickhackDataArray, quickhackData);
			i += 1;
		  };
		  parts = ItemModificationSystem.GetAllSlots(player, systemReplacementID);
		  i = 0;
		  while i < ArraySize(parts) {
			ArrayClear(actions);
			itemRecord = RPGManager.GetItemRecord(parts[i].installedPart);
			if IsDefined(itemRecord) {
			  itemRecord.ObjectActions(actions);
			  i1 = 0;
			  while i1 < ArraySize(actions) {
				if Equals(actions[i1].ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) || Equals(actions[i1].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) {
				  quickhackData = quickhackDataEmpty;
				  quickhackData.actionRecord = actions[i1];
				  quickhackData.quality = itemRecord.Quality().Value();
				  ArrayPush(quickhackDataArray, quickhackData);
				};
				i1 += 1;
			  };
			};
			i += 1;
		  };
		};
		ArrayClear(actions);
		itemRecord = RPGManager.GetItemRecord(EquipmentSystem.GetData(player).GetActiveItem(gamedataEquipmentArea.Splinter));
		if IsDefined(itemRecord) {
		  itemRecord.ObjectActions(actions);
		  i = 0;
		  while i < ArraySize(actions) {
			if Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.DeviceQuickHack) || Equals(actions[i].ObjectActionType().Type(), gamedataObjectActionType.PuppetQuickHack) {
			  quickhackData = quickhackDataEmpty;
			  quickhackData.actionRecord = actions[i];
			  ArrayPush(quickhackDataArray, quickhackData);
			};
			i += 1;
		  };
		};
	
		myint+=1;
	}
    RPGManager.RemoveDuplicatedHacks(quickhackDataArray);
    PlayerPuppet.ChacheQuickHackList(player, quickhackDataArray);
    return quickhackDataArray;
  }