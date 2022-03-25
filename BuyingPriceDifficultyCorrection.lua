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

--- Original from Source 1.3.0.0
function BuyingPriceDifficultyCorrection:populateCellForItemInSection(_, list, section, index, cell)
	if list == self.productList then
		local fillTypeDesc = self.fillTypes[index]

		cell:getAttribute("icon"):setImageFilename(fillTypeDesc.hudOverlayFilename)
		cell:getAttribute("title"):setText(fillTypeDesc.title)

		local usedStorages = {}
		local localLiters = self:getStorageFillLevel(fillTypeDesc, true, usedStorages)
		local foreignLiters = self:getStorageFillLevel(fillTypeDesc, false, usedStorages)

		if localLiters < 0 and foreignLiters < 0 then
			cell:getAttribute("storage"):setText("-")
		else
			cell:getAttribute("storage"):setText(self.l10n:formatVolume(math.max(localLiters, 0) + math.max(foreignLiters, 0)))
		end
	else
		local station = self.currentStations[index]
		local fillTypeDesc = self.fillTypes[self.productList.selectedIndex]
		local hasHotspot = station.owningPlaceable:getHotspot(1) ~= nil

		cell:getAttribute("hotspot"):setVisible(hasHotspot)

		if hasHotspot then
			local isTagActive = g_currentMission.currentMapTargetHotspot ~= nil and station.owningPlaceable:getHotspot(1) == g_currentMission.currentMapTargetHotspot

			cell:getAttribute("hotspot"):applyProfile(isTagActive and "ingameMenuPriceItemHotspotActive" or "ingameMenuPriceItemHotspot")
		end

		cell:getAttribute("title"):setText(station.uiName)

		local price = tostring(station:getEffectiveFillTypePrice(fillTypeDesc.index))

		cell:getAttribute("price"):setVisible(station.uiIsSelling)
		cell:getAttribute("buyPrice"):setVisible(not station.uiIsSelling)

		if station.uiIsSelling then
			cell:getAttribute("price"):setValue(price * 1000)

			local priceTrend = station:getCurrentPricingTrend(fillTypeDesc.index)
			local profile = "ingameMenuPriceArrow"

			if priceTrend ~= nil then
				if Utils.isBitSet(priceTrend, SellingStation.PRICE_GREAT_DEMAND) then
					profile = "ingameMenuPriceArrowGreatDemand"
				elseif Utils.isBitSet(priceTrend, SellingStation.PRICE_CLIMBING) then
					profile = "ingameMenuPriceArrowClimbing"
				elseif Utils.isBitSet(priceTrend, SellingStation.PRICE_FALLING) then
					profile = "ingameMenuPriceArrowFalling"
				end
			end

			cell:getAttribute("priceTrend"):applyProfile(profile)
		else
			cell:getAttribute("buyPrice"):setValue(price * 1000)
			cell:getAttribute("priceTrend"):applyProfile("ingameMenuPriceArrow")
		end
	end
end
InGameMenuPricesFrame.populateCellForItemInSection = Utils.overwrittenFunction(InGameMenuPricesFrame.populateCellForItemInSection, BuyingPriceDifficultyCorrection.populateCellForItemInSection)