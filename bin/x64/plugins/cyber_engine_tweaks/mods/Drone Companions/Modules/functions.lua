SDO = { 
    description = "SDO"
}


function SDO:new()



	
	-------------------------CUSTOM NAMING--------------------------------------
	
	--Custom names
	Override('UIItemsHelper', 'GetItemName;Item_RecordgameItemData', function(itemRecord, itemData, wrappedMethod)
		localizedName = itemRecord:LocalizedName()
		if string.sub(localizedName,1 ,3) ~= "yyy" then
			return wrappedMethod(itemRecord, itemData)
		else
			indicator = 0
			for i in string.gmatch(localizedName, "%b{}") do
				indicator = #i
				desc = i
				break
			end
			desc = string.sub(desc, 2, #desc-1)

			if itemData:HasTag(CName.new("Recipe")) then
				return GetLocalizedText("Gameplay-Crafting-GenericRecipe")..desc--string.sub(localizedName,4 , indicator)
			end
			return desc--string.sub(localizedName,4 , indicator)
		end
	end)
  
	--Special case yayy
	Override('CraftingSystem', 'GetRecipeData', function(self, itemRecord, wrappedMethod)
		recipe = wrappedMethod(itemRecord)
		localizedName = itemRecord:LocalizedName()
		if string.sub(localizedName,1 ,3) ~= "yyy" then
			return recipe
		end
		indicator = 0
		desc = ""
		for i in string.gmatch(localizedName, "%b{}") do
			--indicator = #i
			desc = i
			break
		end
		desc = string.sub(desc, 2, #desc-1)
		recipe.label = desc--string.sub(localizedName,4 , indicator)
		return recipe
	end)
	
	
 
	--Custom descriptions
	Override('ItemTooltipCommonController', 'UpdateLayout', function(self, wrappedMethod)
		wrappedMethod()
		
		if self.data.description == ToCName{ hash_lo = 0xDEEA321B, hash_hi = 0x266B9698 --[[ LocKey#49555 --]] } then
				indicator = 0
				desc = ""
				localizedName = TweakDBInterface.GetItemRecord(self.data.itemTweakID):LocalizedName()
				for i in string.gmatch(localizedName, "%b{}") do
					--indicator = #i
					desc = i
				end
						desc = string.sub(desc, 2, #desc-1)

				--desc = string.sub(localizedName, indicator+6, #localizedName)
		    inkWidgetRef.SetVisible(self.descriptionWrapper, true)
			inkTextRef.SetText(self.descriptionText, desc)
			inkWidgetRef.SetVisible(self.backgroundContainer, self.data.displayContext ~= InventoryTooltipDisplayContext.Crafting)
		end
	end)
end


return SDO:new()
