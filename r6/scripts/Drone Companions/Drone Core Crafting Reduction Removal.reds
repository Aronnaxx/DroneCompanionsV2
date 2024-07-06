@wrapMethod(CraftingSystem) 
 public final const func GetItemCraftingCost(record: wref<Item_Record>, craftingData: array<wref<RecipeElement_Record>>) -> array<IngredientData> {
    let baseIngredients: array<IngredientData>;
    let expectedQuality: gamedataQuality;
    let modifiedQuantity: Int32;
    let tempStat: Float;
	let reducedBy: Int32=0;
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
    let i: Int32 = 0;
    while i < ArraySize(craftingData) {
      ArrayPush(baseIngredients, this.CreateIngredientData(craftingData[i]));
      i += 1;
    };
    tempStat = statsSystem.GetStatValue(Cast<StatsObjectID>(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.CraftingCostReduction);
    if tempStat > 0.00 {
      i = 0;
      while i < ArraySize(baseIngredients) {
        if baseIngredients[i].quantity > 1 {
			if Equals(baseIngredients[i].id.GetID(), t"DCO.DroneCore") {
				reducedBy = baseIngredients[i].quantity - CeilF(Cast<Float>(baseIngredients[i].quantity) * (1.00 - tempStat));
			}
        };
        i += 1;
      };
    };
	
	baseIngredients = wrappedMethod(record, craftingData);
	
    if tempStat > 0.00 {
      i = 0;
      while i < ArraySize(baseIngredients) {
        if baseIngredients[i].quantity > 1 {
			if Equals(baseIngredients[i].id.GetID(), t"DCO.DroneCore") {
				baseIngredients[i].quantity += reducedBy;
			}
        };
        i += 1;
      };
    };
	
    return baseIngredients;
  }
 