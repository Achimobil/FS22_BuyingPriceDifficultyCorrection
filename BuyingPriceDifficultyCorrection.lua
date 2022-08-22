--[[
Copyright (C) Achimobil, 2022

Author: Achimobil
Date: 25.03.2022
Version: 0.1.0.0

Contact:
https://discord.gg/Va7JNnEkcW

History:
V 0.1.0.0 @ 25.03.2022 - First Release

Important:
No copy and use in own mods allowed.
]]

BuyingPriceDifficultyCorrection = {}

BuyingPriceDifficultyCorrection.metadata = {
    title = "BuyingPriceDifficultyCorrection",
    notes = "Correct the wrong buying prices shown and change the buying prices based on difficulty level like the selling prices",
    author = "Achimobil",
    info = "No copy and use in own mods allowed."
};
BuyingPriceDifficultyCorrection.modDir = g_currentModDirectory;


--- Original from Source 1.3.0.0
function BuyingPriceDifficultyCorrection:getEffectiveFillTypePrice(_, fillTypeIndex)
	local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)
	local pricePerLiter = self.fillTypePricesScale[fillTypeIndex] * fillType.pricePerLiter * EconomyManager.getPriceMultiplier()

	return pricePerLiter
end
BuyingStation.getEffectiveFillTypePrice = Utils.overwrittenFunction(BuyingStation.getEffectiveFillTypePrice, BuyingPriceDifficultyCorrection.getEffectiveFillTypePrice)