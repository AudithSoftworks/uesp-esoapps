-- uespLogSalesData.lua -- by Dave Humphrey, dave@uesp.net
-- Code specific to the saving of guild sales data.
--
--	EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE
--	EVENT_TRADING_HOUSE_RESPONSE_RECEIVED
--	EVENT_PLAYER_ACTIVATED
--  EVENT_GUILD_SELF_JOINED_GUILD
--	EVENT_GUILD_SELF_LEFT_GUILD
--	EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE
--


uespLog.SALES_FIRSTSCAN_DELAYMS = 3000
uespLog.SALES_SCAN_DELAY = 1500
uespLog.NewGuildSales = 0
uespLog.SalesCurrentGuildIndex = 1
uespLog.SalesStartEventIndex = 1
uespLog.SalesScanCurrentLastTimestamp = -1
uespLog.SalesScanSingleGuild = false
uespLog.MAX_GUILD_INDEX = 5
uespLog.SalesCurrentListingData = {}
uespLog.SALES_MAX_LISTING_TIME = 30*86400
uespLog.GuildHistoryLastReceivedTimestamp = GetTimeStamp()
uespLog.IsSavingGuildSales = false
uespLog.SalesBadScanCount = 0
uespLog.GuildSalesLastListingTimestamp = 0

uespLog.SalesGuildSearchScanStarted = false
uespLog.SalesGuildSearchScanNumItems = 0
uespLog.SalesGuildSearchScanPage = 0
uespLog.SalesGuildSearchScanStartTime = 0
uespLog.SalesGuildSearchScanLastTimestamp = 0
uespLog.SalesGuildSearchScanFinish = false
uespLog.SalesGuildSearchScanFinishIndex = 0
uespLog.SalesGuildSearchScanAllGuilds = false 
uespLog.SalesGuildSearchScanGuildId = 1
uespLog.SalesGuildSearchScanGuildCount = 0

uespLog.SalesPrices = nil
uespLog.SalesPricesVersion = 0


function uespLog.LoadSalePriceData()

	if (uespLog.IsSalesShowPrices() and uespLog.InitSalesPrices ~= nil) then
		uespLog.InitSalesPrices()
	else
		uespLog.SalesPrices = nil
		uespLog.SalesPricesVersion = 0
	end
	
end


function uespLog.GetSalesDataConfig()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.salesData == nil) then
		uespLog.savedVars.settings.data.salesData = uespLog.DEFAULT_SETTINGS.salesData
	end
	
	return uespLog.savedVars.settings.data.salesData
end


function uespLog.SetSalesDataSave(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.salesData == nil) then
		uespLog.savedVars.settings.data.salesData = uespLog.DEFAULT_SETTINGS.salesData
	end
	
	uespLog.savedVars.settings.data.salesData.saveSales = flag
end


function uespLog.IsSalesDataSave()
	local salesConfig = uespLog.GetSalesDataConfig()
	return salesConfig.saveSales
end


function uespLog.SetSalesShowPrices(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.salesData == nil) then
		uespLog.savedVars.settings.data.salesData = uespLog.DEFAULT_SETTINGS.salesData
	end
	
	uespLog.savedVars.settings.data.salesData.showPrices = flag
	
	uespLog.LoadSalePriceData()
end


function uespLog.IsSalesShowPrices()
	local salesConfig = uespLog.GetSalesDataConfig()
	
	if (salesConfig.showPrices == nil) then
		salesConfig.showPrices = false
	end
	
	return salesConfig.showPrices
end


function uespLog.SetSalesShowTooltip(flag)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.salesData == nil) then
		uespLog.savedVars.settings.data.salesData = uespLog.DEFAULT_SETTINGS.salesData
	end
	
	uespLog.savedVars.settings.data.salesData.showTooltip = flag
end


function uespLog.IsSalesShowTooltip()
	local salesConfig = uespLog.GetSalesDataConfig()
	
	if (salesConfig.showTooltip == nil) then
		salesConfig.showTooltip = false
	end
	
	return salesConfig.showTooltip
end


function uespLog.SetSalesShowSaleType(value)

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.salesData == nil) then
		uespLog.savedVars.settings.data.salesData = uespLog.DEFAULT_SETTINGS.salesData
	end
	
	uespLog.savedVars.settings.data.salesData.showSaleType = value
end


function uespLog.GetSalesShowSaleType()

	if (uespLog.savedVars.settings == nil) then
		uespLog.savedVars.settings = uespLog.DEFAULT_SETTINGS
	end
	
	if (uespLog.savedVars.settings.data.showSaleType == nil) then
		uespLog.savedVars.settings.data.showSaleType = uespLog.DEFAULT_SETTINGS.salesData
	end
	
	if (uespLog.savedVars.settings.data.salesData.showSaleType == nil) then
		uespLog.savedVars.settings.data.salesData.showSaleType = "both"
	end
	
	return uespLog.savedVars.settings.data.salesData.showSaleType
end


function uespLog.OnActivateSalesData()

	if (uespLog.IsSavingGuildSales) then
		return
	end

	uespLog.IsSavingGuildSales = true
	zo_callLater(uespLog.SaveNewSalesData, uespLog.SALES_FIRSTSCAN_DELAYMS)
end


function uespLog.SaveNewSalesData()

	uespLog.NewGuildSales = 0
	uespLog.SalesCurrentGuildIndex = 1
	uespLog.SalesStartEventIndex = 1
	uespLog.SalesScanCurrentLastTimestamp = -1
	uespLog.SalesScanSingleGuild = false
	uespLog.SalesBadScanCount = 0

	if (not uespLog.IsSalesDataSave()) then
		uespLog.IsSavingGuildSales = false
		return
	end	
	
	uespLog.DebugExtraMsg("UESP: Looking for new guild sales data...")
		
	for i = 1, uespLog.MAX_GUILD_INDEX do
		uespLog.SaveGuildSummary(i)
	end
	
	uespLog.StartGuildSalesScan(1)
end


function uespLog.StartGuildSalesScan(guildIndex)

	if (guildIndex > uespLog.MAX_GUILD_INDEX) then
	
		if (uespLog.NewGuildSales > 0) then
			uespLog.Msg("UESP: Found and saved "..tostring(uespLog.NewGuildSales).." new guild sales!")
		else
			uespLog.DebugMsg("UESP: Found no new guild sales since last save!")
		end
		
		uespLog.IsSavingGuildSales = false
		return false
	end
		
	uespLog.DebugExtraMsg("UESP: Starting sales history scan for guild #"..tostring(guildIndex))
	
	local guildId = GetGuildId(guildIndex)
	local requested = RequestGuildHistoryCategoryNewest(guildId, GUILD_HISTORY_STORE)
	uespLog.GuildHistoryLastReceivedTimestamp = GetTimeStamp()
	
	uespLog.SalesStartEventIndex = 1
	uespLog.SalesCurrentGuildIndex = guildIndex
	uespLog.SalesScanCurrentLastTimestamp = -1
	uespLog.SalesBadScanCount = 0
	
	zo_callLater(function() uespLog.ScanGuildSales(guildIndex) end, uespLog.SALES_SCAN_DELAY)
	
	return true
end


function uespLog.StartGuildSalesScanMore(guildIndex)
	local guildId = GetGuildId(guildIndex)
	local hasMore = DoesGuildHistoryCategoryHaveMoreEvents(guildId, GUILD_HISTORY_STORE)
		
	if (not hasMore) then
	
		if (uespLog.SalesScanSingleGuild) then
			uespLog.SalesScanSingleGuild = false
		else
			uespLog.StartGuildSalesScan(guildIndex + 1)
		end
		
		return true
	end
	
	uespLog.SalesStartEventIndex = GetNumGuildEvents(guildId, GUILD_HISTORY_STORE)
	uespLog.SalesCurrentGuildIndex = guildIndex
	
	uespLog.DebugExtraMsg("UESP: Loading more sales history for guild #"..tostring(guildIndex)..", starting at event #"..tostring(uespLog.SalesStartEventIndex))
	
	uespLog.GuildHistoryLastReceivedTimestamp = GetTimeStamp()
	local requested = RequestGuildHistoryCategoryOlder(guildId, GUILD_HISTORY_STORE)
			
	zo_callLater(function() uespLog.ScanGuildSales(guildIndex) end, uespLog.SALES_SCAN_DELAY)
	
	return true
end


function uespLog.ScanGuildSales(guildIndex)
	local salesConfig = uespLog.GetSalesDataConfig()
	local guildConfig = salesConfig[guildIndex]
	local lastTimestamp = salesConfig.lastTimestamp
	local guildId = GetGuildId(guildIndex)
	local requested = false
	local currentTimestamp = uespLog.GuildHistoryLastReceivedTimestamp
	local numEvents = GetNumGuildEvents(guildId, GUILD_HISTORY_STORE)
	
	if (uespLog.SalesStartEventIndex >= numEvents and numEvents > 0) then
		uespLog.SalesBadScanCount = uespLog.SalesBadScanCount + 1
		uespLog.DebugExtraMsg("UESP: Bad guild sale scan "..guildIndex..":"..uespLog.SalesBadScanCount)
		
		if (uespLog.SalesBadScanCount > 10) then
			uespLog.StartGuildSalesScan(guildIndex + 1)
			return false
		end
		
		uespLog.StartGuildSalesScanMore(guildIndex)	
		return false
	end
	
	if (guildConfig.lastTimestamp < lastTimestamp) then
		lastTimestamp = guildConfig.lastTimestamp
	end
	
	if (uespLog.SalesScanCurrentLastTimestamp >= 0) then
		lastTimestamp = uespLog.SalesScanCurrentLastTimestamp
	else
		guildConfig.lastTimestamp = currentTimestamp
		salesConfig.lastTimestamp = currentTimestamp
		uespLog.SalesScanCurrentLastTimestamp = lastTimestamp
	end
	
	uespLog.DebugExtraMsg("UESP: Scanning sales history for guild #"..tostring(guildIndex)..", up to timestamp "..lastTimestamp)
	
	local scanMore = uespLog.ScanGuildSales_Loop(guildId, currentTimestamp, lastTimestamp)
	
	if (scanMore) then
		uespLog.StartGuildSalesScanMore(guildIndex)
	elseif (uespLog.SalesScanSingleGuild) then
		uespLog.SalesScanSingleGuild = false
	else
		uespLog.StartGuildSalesScan(guildIndex + 1)
	end
	
	return true
end


function uespLog.ScanGuildSales_Loop(guildId, currentTimestamp, lastTimestamp)
	local numEvents = GetNumGuildEvents(guildId, GUILD_HISTORY_STORE)
	
	if (numEvents <= 0) then
		return false
	end
	
	for eventIndex = uespLog.SalesStartEventIndex, numEvents do
		local eventType, seconds = GetGuildEventInfo(guildId, GUILD_HISTORY_STORE, eventIndex)
		local eventTimestamp = currentTimestamp - seconds
		
		if (eventTimestamp < lastTimestamp) then
			return false
		end
		
		if (eventType == GUILD_EVENT_ITEM_SOLD) then
			uespLog.SaveGuildPurchase(guildId, eventIndex)
			uespLog.NewGuildSales = uespLog.NewGuildSales + 1
		end
	end
	
	return true
end


function uespLog.SaveGuildSummary(guildIndex)
	local salesConfig = uespLog.GetSalesDataConfig()
	local logData = {}
	
	logData.event = "GuildSummary"
	logData.guildIndex = guildIndex
	logData.guildId = GetGuildId(guildIndex)
	
	if (logData.guildId <= 0) then
		return
	end
	
	logData.name = GetGuildName(logData.guildId)
	logData.founded = GetGuildFoundedDate(logData.guildId)
	logData.numMembers, logData.numOnline, logData.leader = GetGuildInfo(logData.guildId)
	--logData.description = GetGuildDescription(logData.guildId)
	--logData.motd = GetGuildMotD(logData.guildId)
	logData.kiosk = GetGuildOwnedKioskInfo(logData.guildId)
	logData.server = GetWorldName()
	
	salesConfig[guildIndex].guildName = logData.name
	salesConfig[guildIndex].guildId = logData.guildId
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.GetItemLinkRequiredEffectiveLevel(itemLink)
	local reqLevel = GetItemLinkRequiredLevel(itemLink)
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	
	if (reqCP > 0) then
		return 50 + math.floor(reqCP/10)
	end
	
	return reqLevel
end


function uespLog.SaveGuildPurchase(guildId, eventIndex)
	local eventType, seconds, seller, buyer, qnt, itemLink, gold, taxes = GetGuildEventInfo(guildId, GUILD_HISTORY_STORE, eventIndex)
	local eventId = GetGuildEventId(guildId, GUILD_HISTORY_STORE, eventIndex)
	local logData = {}
	local currentTimestamp = GetTimeStamp()
	
	logData.event = "GuildSale"
	logData.type = eventType
	logData.saleTimestamp = tostring(currentTimestamp - seconds)
	logData.eventId = Id64ToString(eventId)
	logData.seller = seller
	logData.buyer = buyer
	logData.qnt = qnt
	logData.gold = gold
	logData.taxes = taxes
	logData.server = GetWorldName()
	logData.guild = GetGuildName(guildId)
	logData.itemLink = itemLink
	logData.trait = GetItemLinkTraitInfo(logData.itemLink)
	logData.quality = GetItemLinkQuality(logData.itemLink)
	logData.level = uespLog.GetItemLinkRequiredEffectiveLevel(logData.itemLink)
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.ResetNewSalesDataTimestamps()
	local salesConfig = uespLog.GetSalesDataConfig()
	
	salesConfig.lastTimestamp = 0
	
	for i = 1, 5 do
		salesConfig[i].lastTimestamp = 0
	end
end


function uespLog.ResetLastListingSalesDataTimestamps(guildName)
	local salesConfig = uespLog.GetSalesDataConfig()
		
	if (guildName == nil or guildName == "" or guildName:lower() == "all") then
		salesConfig.guildListTimes = {}
		uespLog.Msg("Reset the last scan timestamps for all listings in all guilds!")
	elseif (guildName:lower() == "current") then
		local _, realGuildName = GetCurrentTradingHouseGuildDetails()		
		
		if (realGuildName ~= nil and realGuildName ~= "") then
			salesConfig.guildListTimes[realGuildName] = 0
			uespLog.Msg("Reset the last scan timestamp for all listings in '"..tostring(realGuildName).."'!")
		else
			uespLog.Msg("You need to be at a guild trader to reset the current guild listings!")
		end
	else
		salesConfig.guildListTimes[guildName] = 0
		uespLog.Msg("Reset the last scan timestamp for all listings in '"..tostring(guildName).."'!")
	end
	
end


function uespLog.OnJoinedGuild (event, guildId, guildName)

	if (not uespLog.IsSalesDataSave()) then
		return
	end

	for i = 1, uespLog.MAX_GUILD_INDEX do
		local id = GetGuildId(i)
		
		if (id == guildId) then
			uespLog.SaveGuildSummary(i)
			uespLog.SalesScanSingleGuild = true
			uespLog.StartGuildSalesScan(i)
			return
		end
	end
	
end


function uespLog.OnLeftGuild (event, guildId, guildName)
	local salesConfig = uespLog.GetSalesDataConfig()
	local oldGuildIndex = -1

	if (not uespLog.IsSalesDataSave()) then
		return
	end
	
	for i = 1, uespLog.MAX_GUILD_INDEX do
		
		if (salesConfig[i].guildName == guildName) then
			uespLog.DeleteGuildSalesData(i)
			return
		end
	end
end


function uespLog.DeleteGuildSalesData(guildIndex)
	local salesConfig = uespLog.GetSalesDataConfig()

	for i = guildIndex, uespLog.MAX_GUILD_INDEX - 1 do
		salesConfig[i] = salesConfig[i + 1]
	end
	
	salesConfig[uespLog.MAX_GUILD_INDEX - 1] = 
	{
		["guildName"] = "",
		["guildId"] = 0,
		["lastTimestamp"] = 0,
	}

end


function uespLog.OnTradingHouseSearchResultsReceived (eventCode, guildId, numItemsOnPage, currentPage, hasMorePages)

	if (uespLog.IsSalesDataSave()) then
		uespLog.SaveTradingHouseSalesData(guildId, numItemsOnPage, currentPage)
		
		if (uespLog.SalesGuildSearchScanStarted) then
			uespLog.OnGuildSearchScanItemsReceived(guildId, numItemsOnPage, currentPage, hasMorePages)
		end
		
	end

end


function uespLog.SaveTradingHouseSalesData(guildId, numItemsOnPage, currentPage)
	local currentTimestamp = GetTimeStamp()
	local logData = {}
		
	logData.event = "GuildSaleSearchInfo"
	logData.guildId, logData.name = GetCurrentTradingHouseGuildDetails()
	logData.server = GetWorldName()	
	logData.zone = uespLog.lastTargetData.zone
	logData.lastTarget = uespLog.lastTargetData.name
	logData.kiosk = GetGuildOwnedKioskInfo(guildId)
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
	
	if (numItemsOnPage == 0) then
		return
	end

	if (not uespLog.SalesGuildSearchScanStarted) then
		uespLog.DebugMsg("UESP: Saving "..tostring(numItemsOnPage).." sales from "..logData.name.."...")
	end

	for i = 1, numItemsOnPage do
		local saveResult = uespLog.SaveTradingHouseSalesItem(guildId, i, currentTimestamp, nil, true)
		
		if (not saveResult) then
			uespLog.SalesGuildSearchScanFinishIndex = numItemsOnPage - i + 1
			--uespLog.DebugMsg("Stopped saving items at index "..tostring(i).."!")
			return
		end
	end
	
end


function uespLog.SaveTradingHouseSalesItem(guildId, itemIndex, currentTimestamp, extraData, checkScan)
	local logData = {}
	
	logData.event = "GuildSaleSearchEntry"
	logData.guildId, logData.guild = GetCurrentTradingHouseGuildDetails()
	logData.server = GetWorldName()
	logData.icon, logData.item, logData.quality, logData.qnt, logData.seller, logData.timeRemaining, logData.price, logData.currency = GetTradingHouseSearchResultItemInfo(itemIndex)
	logData.itemLink = GetTradingHouseSearchResultItemLink(itemIndex)
	logData.trait = GetItemLinkTraitInfo(logData.itemLink)
	logData.quality = GetItemLinkQuality(logData.itemLink)
	logData.level = uespLog.GetItemLinkRequiredEffectiveLevel(logData.itemLink)
	local listTimestamp = currentTimestamp + logData.timeRemaining - uespLog.SALES_MAX_LISTING_TIME
	logData.listTimestamp = tostring(listTimestamp)
	
	if (checkScan and uespLog.SalesGuildSearchScanStarted and listTimestamp < uespLog.SalesGuildSearchScanLastTimestamp) then
		uespLog.SalesGuildSearchScanFinish = true
		return false
	end
	
	logData.timeRemaining = nil
	logData.stack = nil
	logData.currency = nil
	
	if (logData.itemLink == "") then
		return true
	end
		
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData(), extraData)
	return true
end


function uespLog.OnTradingHouseError(event, errorCode)
	uespLog.DebugExtraMsg("OnTradingHouseError " .. tostring(errorCode))
end


function uespLog.OnTradingHouseResponseReceived(event, responseType, result)
	--TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING
	--TRADING_HOUSE_RESULT_PURCHASE_PENDING
	--TRADING_HOUSE_RESULT_POST_PENDING
	--TRADING_HOUSE_RESULT_LISTINGS_PENDING
	
	uespLog.DebugExtraMsg("UESP: OnTradingHouseResponseReceived "..tostring(responseType).. " - "..tostring(result))
	
	if (result ~= TRADING_HOUSE_RESULT_SUCCESS) then
		return
	end
		
	if (responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING) then
		uespLog.GuildSalesLastListingTimestamp = GetTimeStamp()
		uespLog.OnTradingHouseListingUpdate()
	elseif (responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING) then
		uespLog.OnTradingHouseListingCancel()
	elseif (responseType == TRADING_HOUSE_RESULT_POST_PENDING) then
		uespLog.OnTradingHouseListingNew()
	end
	
end


function uespLog.OnTradingHouseListingNew()

	if (uespLog.IsSalesDataSave()) then
		local numListings = GetNumTradingHouseListings()
		
		if (numListings == 0) then
			RequestTradingHouseListings()
			return
		end
		
		--uespLog.SaveTradingHouseListingData()
		uespLog.SaveTradingHouseListingNewData()
	end
	
end


function uespLog.OnTradingHouseListingCancel()

	if (uespLog.IsSalesDataSave()) then
		uespLog.SaveTradingHouseListingCancelData()
	end
end


function uespLog.OnTradingHouseListingUpdate()

	if (uespLog.IsSalesDataSave()) then
		uespLog.SaveTradingHouseListingData()
	end
	
end


function uespLog.SaveTradingHouseListingCancelData()
	local newListingData = uespLog.MakeSalesListingData()
	local cancelledListings = uespLog.FindMissingListingData(uespLog.SalesCurrentListingData, newListingData)
	
	if (#cancelledListings <= 0) then
		return
	end
	
	uespLog.DebugMsg("UESP: Saving "..tostring(#cancelledListings).." cancelled guild listings...")
	
	for i = 1, #cancelledListings do
		uespLog.SaveTradingHouseListingDataItem("GuildSaleListingEntry::Cancel", uespLog.SalesCurrentListingData[cancelledListings[i]])
	end	
	
	uespLog.SalesCurrentListingData = newListingData
end


function uespLog.SaveTradingHouseListingNewData()
	local newListingData = uespLog.MakeSalesListingData()
	local newListings = uespLog.FindMissingListingData(newListingData, uespLog.SalesCurrentListingData)
	
	if (#newListings <= 0) then
		return
	end
	
	uespLog.DebugMsg("UESP: Saving "..tostring(#newListings).." new guild listings ...")
	
	for i = 1, #newListings do
		uespLog.SaveTradingHouseListingDataItem("GuildSaleListingEntry::Cancel", uespLog.SalesCurrentListingData[newListings[i]])
	end	
	
	uespLog.SalesCurrentListingData = newListingData
end


function uespLog.SaveTradingHouseListingDataItem(eventName, listingData)
	local logData = {}
	
	if (listingData == nil or listingData.itemLink == nil or listingData.itemLink == "") then
		return
	end
		
	logData.event = eventName
	logData.guildId, logData.guild = GetCurrentTradingHouseGuildDetails()
	logData.server = GetWorldName()
	logData.qnt = listingData.qnt
	logData.seller = listingData.seller
	logData.item = listingData.name
	logData.quality = listingData.quality
	logData.price = listingData.price
	logData.itemLink = listingData.itemLink
	logData.trait = GetItemLinkTraitInfo(logData.itemLink)
	logData.quality = GetItemLinkQuality(logData.itemLink)
	logData.level = uespLog.GetItemLinkRequiredEffectiveLevel(logData.itemLink)
	logData.listTimestamp = tostring(listingData.listTimestamp)
			
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.MakeSalesListingId(listing)
	return tostring(listing.listTimestamp) .. "-" .. tostring(listing.itemLink) .. "-" .. tostring(listing.qnt) .. "-"..tostring(listing.price)
end


function uespLog.FindMissingListingData(oldListing, newListing)
	local itemMap = {}
	local missingListing = {}
	
	for i = 1, #oldListing do
		local listing = oldListing[i]
		local id = uespLog.MakeSalesListingId(listing)
		
		itemMap[id] = 
		{
			["value"] = 1,
			["index"] = i,
		}
	end
	
	for i = 1, #newListing do
		local listing = newListing[i]
		local id = uespLog.MakeSalesListingId(listing)
		
		if (itemMap[id] ~= nil) then
			itemMap[id]["value"] = 0
		end
	end
	
	for id, data in pairs(itemMap) do
	
		if (data.value > 0) then
			missingListing[#missingListing + 1] = data.index
		end
	end
		
	return missingListing
end


function uespLog.MakeSalesListingData()
	local numListings = GetNumTradingHouseListings()
	local data = {}
	local currentTimestamp = uespLog.GuildSalesLastListingTimestamp
	
	for i = 1, numListings do
		local icon, name, quality, qnt, seller, timeRemaining, price = GetTradingHouseListingItemInfo(i)
		local itemLink = GetTradingHouseListingItemLink(i)
	
		data[i] = 
		{
			["listTimestamp"] = currentTimestamp + timeRemaining - uespLog.SALES_MAX_LISTING_TIME,
			["itemLink"] = itemLink,
			["qnt"] = qnt,
			["price"] = price,	
			["name"] = name,		
			["quality"] = quality,	
			["seller"] = seller,
		}
	end
	
	return data
end


function uespLog.SaveTradingHouseListingData()
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
	local logData = {}
	local numListings = GetNumTradingHouseListings()
	local currentTimestamp = uespLog.GuildSalesLastListingTimestamp
	
	uespLog.SalesCurrentListingData = {}

	if (guildName == "" or numListings <= 0) then
		return
	end
	
	uespLog.DebugMsg("UESP: Saving "..tostring(numListings).." guild listings...")
	
	logData.event = "GuildSaleListingInfo"
	logData.guildId = guildId
	logData.name = guildName
	logData.server = GetWorldName()	
	logData.zone = uespLog.lastTargetData.zone
	logData.lastTarget = uespLog.lastTargetData.name
	logData.kiosk = GetGuildOwnedKioskInfo(guildId)
	
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())

	for i = 1, numListings do
		uespLog.SaveTradingHouseListingItem(i, currentTimestamp)
	end
	
	uespLog.SalesCurrentListingData = uespLog.MakeSalesListingData()
end


function uespLog.SaveTradingHouseListingItem(itemIndex, currentTimestamp)
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
	local logData = {}
		
	logData.event = "GuildSaleListingEntry"
	logData.guildId = guildId
	logData.guild = guildName
	logData.server = GetWorldName()
	logData.icon, logData.item, logData.quality, logData.qnt, logData.seller, logData.timeRemaining, logData.price = GetTradingHouseListingItemInfo(itemIndex)
	logData.itemLink = GetTradingHouseListingItemLink(itemIndex)
	logData.trait = GetItemLinkTraitInfo(logData.itemLink)
	logData.quality = GetItemLinkQuality(logData.itemLink)
	logData.level = uespLog.GetItemLinkRequiredEffectiveLevel(logData.itemLink)
	logData.listTimestamp = tostring(currentTimestamp + logData.timeRemaining - uespLog.SALES_MAX_LISTING_TIME)
	
	logData.timeRemaining = nil
	logData.stack = nil
	
	if (logData.itemLink == "") then
		return
	end
			
	uespLog.AppendDataToLog("all", logData, uespLog.GetTimeData())
end


function uespLog.OnGuildHistoryResponseReceived(event)
	--uespLog.DebugExtraMsg("UESP: OnGuildHistoryResponseReceived")
	uespLog.GuildHistoryLastReceivedTimestamp = GetTimeStamp()
end


function uespLog.OnTradingHouseConfirmPurchase(event, pendingPurchaseIndex)
	local extraData = {}
	local currentTimestamp = GetTimeStamp()
	
	uespLog.DebugExtraMsg("UESP: OnTradingHouseConfirmPurchase "..tostring(pendingPurchaseIndex))
	
	extraData.purchase = 1
	extraData.buyer = GetDisplayName()
	extraData.saleTimestamp = tostring(currentTimestamp)

	uespLog.SaveTradingHouseSalesItem(GetSelectedTradingHouseGuildId(), pendingPurchaseIndex, currentTimestamp, extraData)
end


function uespLog.StartGuildSearchSalesScanAll()
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
	local numTradeGuilds = GetNumTradingHouseGuilds()
	
	if (uespLog.SalesGuildSearchScanStarted) then
		uespLog.Msg("Guild listing scan is already in progress...")
		return
	end
	
	if (GetNumTradingHouseGuilds() == 0) then
		uespLog.Msg("You must be in a guild store in order to start a listing scan!")
		return
	end
	
	if (numTradeGuilds == 1) then
		uespLog.StartGuildSearchSalesScan()
		return
	end
		
	uespLog.SalesGuildSearchScanGuildCount = numTradeGuilds
	uespLog.SalesGuildSearchScanAllGuilds = true
	uespLog.SalesGuildSearchScanGuildId = 0
	
	uespLog.StartGuildSearchSalesScanNextGuild()
end


function uespLog.StartGuildSearchSalesScanNextGuild()
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
		
	uespLog.SalesGuildSearchScanGuildId = uespLog.SalesGuildSearchScanGuildId + 1
	uespLog.SalesGuildSearchScanStarted = false
		
	if (uespLog.SalesGuildSearchScanGuildId > uespLog.SalesGuildSearchScanGuildCount) then
		uespLog.SalesGuildSearchScanAllGuilds = false
		uespLog.Msg("Finished scanning listings from all guilds!")
		return
	end
	
	if (guildId ~= uespLog.SalesGuildSearchScanGuildId) then
	
		if (not SelectTradingHouseGuildId(uespLog.SalesGuildSearchScanGuildId)) then
			uespLog.SalesGuildSearchScanAllGuilds = false
			uespLog.Msg("Error: Failed to select guild ID "..tostring(uespLog.SalesGuildSearchScanGuildId).." for listing scan!")
			return
		end
	end
	
	uespLog.StartGuildSearchSalesScan()
end



function uespLog.StartGuildSearchSalesScanPage(startPage)
	local pageNum = tonumber(startPage)
	
	if (pageNum == nil) then
		uespLog.Msg("Error: Page number '"..tostring(startPage).."' is not a valid number!")
		return
	end
	
	uespLog.StartGuildSearchSalesScan(pageNum)
end


function uespLog.StartGuildSearchSalesScan(startPage)

	if (startPage == nil) then
		startPage = 0
	end

	if (uespLog.SalesGuildSearchScanStarted) then
		uespLog.Msg("Guild listing scan is already in progress...")
		return
	end
	
	if (GetNumTradingHouseGuilds() == 0) then
		uespLog.Msg("You must be on a guild trader in order to start a listing scan!")
		return
	end
	
	local guildId, guildName = GetCurrentTradingHouseGuildDetails()
	
	uespLog.SalesGuildSearchScanStarted = true
	uespLog.SalesGuildSearchScanNumItems = 0
	uespLog.SalesGuildSearchScanStartTime = GetTimeStamp()
	uespLog.SalesGuildSearchScanLastTimestamp = 0
	uespLog.SalesGuildSearchScanFinishIndex = 0
	uespLog.SalesGuildSearchScanNumItems = 0
	uespLog.SalesGuildSearchScanPage = startPage
	uespLog.SalesGuildSearchScanFinish = false
	uespLog.Msg("Starting guild listing scan for "..tostring(guildName).."...do not leave trader until it is finished.")
	
	local salesConfig = uespLog.GetSalesDataConfig()
		
	if (salesConfig.guildListTimes[guildName] == nil) then
		uespLog.SalesGuildSearchScanLastTimestamp = 0
	else
		uespLog.SalesGuildSearchScanLastTimestamp = salesConfig.guildListTimes[guildName]
	end
		
	uespLog.SalesGuildSearchScanListTimestamp = GetTimeStamp()
		
	ClearAllTradingHouseSearchTerms()
	ExecuteTradingHouseSearch(startPage, TRADING_HOUSE_SORT_EXPIRY_TIME, false)
end


function uespLog.StopGuildSearchSalesScan()

	if (not uespLog.SalesGuildSearchScanStarted) then
		uespLog.Msg("Guild listing scan has been stopped!")
	end
	
	uespLog.SalesGuildSearchScanStarted = false
end


function uespLog.OnGuildSearchScanItemsReceived(guildId, numItemsOnPage, currentPage, hasMorePages)
	local _, guildName = GetCurrentTradingHouseGuildDetails()
	
	uespLog.SalesGuildSearchScanPage = uespLog.SalesGuildSearchScanPage + 1
	uespLog.SalesGuildSearchScanNumItems = uespLog.SalesGuildSearchScanNumItems + numItemsOnPage - uespLog.SalesGuildSearchScanFinishIndex
	uespLog.SalesGuildSearchScanFinishIndex = 0

	if (not hasMorePages or uespLog.SalesGuildSearchScanFinish) then
		local deltaTime = GetTimeStamp() - uespLog.SalesGuildSearchScanStartTime
		uespLog.Msg("Finished guild listing scan for "..tostring(guildName).."! "..uespLog.SalesGuildSearchScanNumItems.." items in "..tostring(uespLog.SalesGuildSearchScanPage-1).." pages scanned in "..tostring(deltaTime).." secs.")	
		uespLog.SalesGuildSearchScanStarted = false
		
		local salesConfig = uespLog.GetSalesDataConfig()
		salesConfig.guildListTimes[guildName] = uespLog.SalesGuildSearchScanListTimestamp
		
		if (uespLog.SalesGuildSearchScanAllGuilds) then
			zo_callLater(uespLog.StartGuildSearchSalesScanNextGuild, GetTradingHouseCooldownRemaining() + 400)	
		end
		
		return
	end
		
	zo_callLater(uespLog.DoNextGuildListingScan, GetTradingHouseCooldownRemaining() + 400)	
	
	uespLog.DebugMsg("Scanning "..tostring(guildName)..": Logged "..numItemsOnPage.." items on page "..uespLog.SalesGuildSearchScanPage..".")	
end


function uespLog.DoNextGuildListingScan()

	if (GetNumTradingHouseGuilds() == 0) then
		uespLog.Msg("Scan Aborted! You must be on a guild trader in order to perform a listing scan.")
		uespLog.SalesGuildSearchScanStarted = false
		return
	end
	
	ExecuteTradingHouseSearch(uespLog.SalesGuildSearchScanPage, TRADING_HOUSE_SORT_EXPIRY_TIME, false)
end


function uespLog.SalesPriceToChatRowControl(rowControl)
	local itemLink = uespLog.GetItemLinkRowControl(rowControl)

	if (itemLink == nil) then
		return
	end
	
	uespLog.SalesPriceToChat(itemLink)
end

	
function uespLog.AddStatsPopupTooltip() 

	PopupTooltip:GetOwningWindow():SetDrawTier(ZO_Menus:GetDrawTier() - 1)
 	--PopupTooltip:SetHandler("OnMouseUp", MasterMerchant.ThisItem)

	if (not uespLog.IsSalesShowPrices() or not uespLog.IsSalesShowTooltip()) then
		return
	end
		
	if (PopupTooltip.lastLink == nil) then
		return 
	end 
	
	if (uespLog.ActiveTooltipItemLink and uespLog.ActiveTooltipItemLink == PopupTooltip.lastLink) then 
		return
	end

	if (uespLog.activeTip ~= PopupTooltip.lastLink) then
		
		if (PopupTooltip.uespTextPool) then
			PopupTooltip.uespTextPool:ReleaseAllObjects()
		end
		
		PopupTooltip.uespText = nil
	end
	
	uespLog.ActiveTooltipItemLink = PopupTooltip.lastLink

	uespLog.AddSalesPricetoTooltip(PopupTooltip.lastLink, PopupTooltip)
end


function uespLog.RemoveStatsPopupTooltip()
	uespLog.ActiveTooltipItemLink = nil
	
	if (PopupTooltip.uespTextPool) then
		PopupTooltip.uespTextPool:ReleaseAllObjects()
	end
	
	PopupTooltip.uespText = nil
end


function uespLog.GetItemLinkFromItemTooltip() 
	local skMoc = moc()
	local itemLink = nil
	local mocParent = skMoc:GetParent():GetName()
	
	if mocParent == 'ZO_StoreWindowListContents' then 
		itemLink = GetStoreItemLink(skMoc.index)
	elseif mocParent == 'ZO_BuyBackListContents' then 
		itemLink = GetBuybackItemLink(skMoc.index)
	elseif mocParent == 'ZO_TradingHousePostedItemsListContents' then
		local mocData = skMoc.dataEntry.data
		itemLink = GetTradingHouseListingItemLink(mocData.slotIndex)
	elseif mocParent == 'ZO_TradingHouseItemPaneSearchResultsContents' then
		local rData = skMoc.dataEntry and skMoc.dataEntry.data or nil
		
		if not rData or rData.timeRemaining == 0 then return end
		itemLink = GetTradingHouseSearchResultItemLink(rData.slotIndex)

	elseif mocParent == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
		if skMoc.slotIndex and skMoc.bagId then itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex) end
  
	elseif 	mocParent == 'ZO_PlayerInventoryBackpackContents' or
			mocParent == 'ZO_PlayerInventoryListContents' or
			mocParent == 'ZO_CraftBagListContents' or
			mocParent == 'ZO_QuickSlotListContents' or
			mocParent == 'ZO_PlayerBankBackpackContents' or
			mocParent == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
			mocParent == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
			mocParent == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
			mocParent == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
			mocParent == 'ZO_GuildBankBackpackContents' then
			
		if skMoc and skMoc.dataEntry then
            local rData = skMoc.dataEntry.data
            itemLink = GetItemLink(rData.bagId, rData.slotIndex)
		end
  
	elseif mocParent == 'ZO_Character' then 
		itemLink = GetItemLink(skMoc.bagId, skMoc.slotIndex)
	elseif mocParent == 'ZO_LootAlphaContainerListContents' then 
		itemLink = GetLootItemLink(skMoc.dataEntry.data.lootId)
	elseif mocParent == 'ZO_MailInboxMessageAttachments' then 
		itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), skMoc.id, LINK_STYLE_DEFAULT)
	elseif mocParent == 'ZO_MailSendAttachments' then 
		itemLink = GetMailQueuedAttachmentLink(skMoc.id, LINK_STYLE_DEFAULT)
    end
  
  return itemLink
end
 
 
function uespLog.AddStatsItemTooltip() 
	local currentControl = moc()
	
	if (not uespLog.IsSalesShowPrices() or not uespLog.IsSalesShowTooltip()) then
		return
	end
	
	if (not currentControl or not currentControl:GetParent()) then
		return
	end
	
	if (currentControl == uespLog.CurrentTooltipControl) then 
		return 
	end
	
	local itemLink = uespLog.GetItemLinkFromItemTooltip()

	if (itemLink == nil) then
		return
	end
	
    if (uespLog.CurrentTooltipControl ~= currentControl) then
	
		if (ItemTooltip.uespTextPool) then
			ItemTooltip.uespTextPool:ReleaseAllObjects()
		end
		
		ItemTooltip.uespText = nil
    end

    uespLog.CurrentTooltipControl = currentControl
    uespLog.AddSalesPricetoTooltip(itemLink, ItemTooltip)
end
	
	
function uespLog.RemoveStatsItemTooltip() 
	uespLog.ItemTooltipControl = nil 
	
	if (ItemTooltip.uespTextPool) then
		ItemTooltip.uespTextPool:ReleaseAllObjects()
	end
	
	ItemTooltip.uespPriceText = nil
end


function uespLog.AddSalesPricetoTooltip(itemLink, tooltip)
	local msg = uespLog.GetSalesPriceTip(itemLink, false)
	
    if (not uespLog.IsSalesShowPrices() or not uespLog.IsSalesShowTooltip()) then
		return
	end
	
	if (not tooltip.uespTextPool) then
		tooltip.uespTextPool = ZO_ControlPool:New('UespTooltipSalesLabel', tooltip, 'UespText')
	end

	if (not tooltip.uespText) then
		--tooltip:AddVerticalPadding(5)
		--ZO_Tooltip_AddDivider(tooltip)
		--tooltip:AddVerticalPadding(5)   
		tooltip.uespText = tooltip.uespTextPool:AcquireObject()
		tooltip:AddControl(tooltip.uespText)
		tooltip.uespText:SetAnchor(CENTER)   
	end

	if (tooltip.uespText) then
		tooltip.uespText:SetText(msg)
		tooltip.uespText:SetColor(1,1,1,1)
	end
	
end


function uespLog.GetSalesPriceTip(itemLink, isChat)
	local prices = uespLog.FindSalesPrice(itemLink)
	local newItemLink = itemLink:gsub("|H0:", "|H1:")
	
	if (prices == nil) then
		if (isChat) then
			return "UESP has no price data for "..tostring(newItemLink)
		else
			return ""
		end
	end
	
	local price = prices.price
	local countSold = prices.countSold
	local countListed = prices.countListed
	local itemCount = prices.items
	
	if (uespLog.GetSalesShowSaleType() == "list") then
		price = prices.priceListed
		countSold = 0
		countListed = prices.countListed
		itemCount = prices.itemsListed
	elseif (uespLog.GetSalesShowSaleType() == "sold") then
		price = prices.priceSold
		countSold = prices.countSold
		countListed = 0
		itemCount = prices.itemsSold
	end
	
	if (countSold + countListed == 0) then
		if (isChat) then
			return "UESP has no price data for "..tostring(newItemLink)
		else
			return ""
		end
	end
			
	local msg = "UESP price ("
	
	if (countSold > 0) then
		msg = msg .. tostring(countSold).." sold"
	end
	
	if (countListed > 0) then
		if (countSold > 0) then
			msg = msg .. ", "
		end
		
		msg = msg .. tostring(countListed).." listed"
	end
	
	if (itemCount > countSold + countListed) then
		msg = msg .. ", "..tostring(itemCount).." items"
	end
	
	msg = msg .. "): " .. tostring(price)
	
	if (isChat) then
		msg = msg .. " gp for "..tostring(newItemLink)
	else
		msg = msg .. "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
	end
	
	return msg
end


function uespLog.SalesPriceToChat(itemLink)
	local msg = uespLog.GetSalesPriceTip(itemLink, true)
	
	--uespLog.Msg(msg)
	
	local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
    if (not ChatEditControl:HasFocus()) then StartChatInput() end
    ChatEditControl:InsertText(msg)
end


function uespLog.FindSalesPrice(itemLink)
	local _, _, itemId,  internalSubType, internalLevel, data = uespLog.ParseLinkID(itemLink)
	
	itemId = tonumber(itemId)
	
	local levelData = uespLog.SalesPrices[itemId]
	
	if (levelData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No ItemID Data")
		return nil
	end
	
	local quality = GetItemLinkQuality(itemLink)
	local trait = GetItemLinkTraitInfo(itemLink)
	local level = GetItemLinkRequiredLevel(itemLink)
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	
	if (reqCP > 0) then
		level = 50 + math.floor(reqCP/10)
	end
	
	local _, potionValue = data:match("(.*):(.-)")
	potionValue = tonumber(potionValue)
	
	if (potionValue == nil) then
		potionValue = 0
	end
		
	local qualityData = levelData[level]
	
	if (qualityData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Level Data")
		return nil
	end
	
	local traitData = qualityData[quality]
	
	if (traitData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Quality Data")
		return nil
	end
	
	local potionData = traitData[trait]
	
	if (potionData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Trait Data")
		return nil
	end
	
	local salesData = potionData[potionValue]
	
	if (salesData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Potion Data")
		return nil
	end
	
	if (uespLog.SalesPricesVersion == nil or uespLog.SalesPricesVersion > 1) then
		return nil
	end
	
	local result = {}
	
	result.price = salesData[1]
	result.priceSold = salesData[2]
	result.priceListed = salesData[3]
	result.countSold = salesData[4]
	result.countListed = salesData[5]
	result.itemsSold = salesData[6]
	result.itemsListed = salesData[7]
	result.count = result.countSold + result.countListed
	result.items = result.itemsSold + result.itemsListed
	result.itemLink = itemLink
	
	return result
end


function uespLog.SalesCommand (cmd)
	local cmds, firstCmd = uespLog.SplitCommands(cmd)
	
	if (firstCmd == "on") then
		uespLog.SetSalesDataSave(true)
		uespLog.Msg("Guild sales data logging is now ON!")
	elseif (firstCmd == "off") then
		uespLog.SetSalesDataSave(false)
		uespLog.Msg("Guild sales data logging is now OFF!")
	elseif (firstCmd == "price" or firstCmd == "prices") then
		local secondCmd = string.lower(cmds[2])
		
		if (secondCmd == "on") then
			uespLog.SetSalesShowPrices(true)
			uespLog.Msg("UESP sale price data is now ON!")
		elseif (secondCmd == "off") then
			uespLog.SetSalesShowPrices(false)
			uespLog.Msg("UESP sale price data is now OFF!")
		else
			uespLog.Msg("UESP sale price data is currently "..uespLog.BoolToOnOff(uespLog.IsSalesShowPrices()))
		end		
		
	elseif (firstCmd == "tooltip" or firstCmd == "tooltips") then
		local secondCmd = string.lower(cmds[2])
		
		if (secondCmd == "on") then
			uespLog.SetSalesShowTooltip(true)
			uespLog.Msg("UESP sale price item tooltips are now ON!")
		elseif (secondCmd == "off") then
			uespLog.SetSalesShowTooltip(false)
			uespLog.Msg("UESP sale price item tooltips are now OFF!")
		else
			uespLog.Msg("UESP sale price item tooltips are currently "..uespLog.BoolToOnOff(uespLog.IsSalesShowTooltip()))
		end		
		
	elseif (firstCmd == "scan") then
	
		if (cmds[2] == nil) then
			uespLog.StartGuildSearchSalesScanAll()
		else
			local page = tonumber(cmds[2]) or 1
			uespLog.StartGuildSearchSalesScanPage(page - 1)
		end
		
	elseif (firstCmd == "saletype") then
		local secondCmd = string.lower(cmds[2])
		
		if (secondCmd == "both" or secondCmd == "all") then
			uespLog.SetSalesShowSaleType("both")
			uespLog.Msg("UESP sale prices now display both listed and sold data!")
		elseif (secondCmd == "listed" or secondCmd == "list") then
			uespLog.SetSalesShowSaleType("list")
			uespLog.Msg("UESP sale prices now display only list data!")
		elseif (secondCmd == "sold") then
			uespLog.SetSalesShowSaleType("sold")
			uespLog.Msg("UESP sale prices now display only sold data!")
		else
			uespLog.Msg("UESP sale price display is currently using "..uespLog.GetSalesShowSaleType().." data!")
		end		
		
	elseif (firstCmd == "stop") then
		uespLog.StopGuildSearchSalesScan()
	elseif (firstCmd == "scanall") then
		uespLog.StartGuildSearchSalesScanAll()		
	elseif (firstCmd == "resetall") then
		uespLog.ResetNewSalesDataTimestamps()
		uespLog.ResetLastListingSalesDataTimestamps()
		uespLog.Msg("Reset the last scan timestamps for all sales/listing in all guilds!")
	elseif (firstCmd == "resetlist") then
		local guildName = uespLog.implodeOrder(cmds, " ", 2)
		
		if (guildName == "") then
			uespLog.Msg("Missing guild name to reset or 'all' for all guilds!")
			return
		end
		
		uespLog.ResetLastListingSalesDataTimestamps(guildName)
		
	elseif (firstCmd == "resetsold") then
		uespLog.ResetNewSalesDataTimestamps()
		uespLog.Msg("Reset the last scan timestamps for all sales in all guilds on account!")
	else
		uespLog.Msg("Logs various guild sales data:")
		uespLog.Msg(".       /uespsales [on||off]     Turns logging on/off")
		uespLog.Msg(".       /uespsales prices [on||off]     Enables/disables all uesp price usage")
		uespLog.Msg(".       /uespsales tooltip [on||off]     Turns price item tooltip display on/off")
		uespLog.Msg(".       /uespsales saletype [both||list||sold]     Sets type of sale price average to display")
		uespLog.Msg(".       /uespsales scan          Scans all guild store listings")
		uespLog.Msg(".       /uespsales scan [page]   Scans the current guild store listing at the given page")
		uespLog.Msg(".       /uespsales stop          Stops the current listing scan")
		uespLog.Msg(".       /uespsales resetall         Reset the sales and listing scan timestamps")
		uespLog.Msg(".       /uespsales resetsold         Reset the sales scan timestamps")
		uespLog.Msg(".       /uespsales resetlist all     Reset the listing timestamps for all guilds")
		uespLog.Msg(".       /uespsales resetlist current Reset the listing timestamps for the current guild trader")
		uespLog.Msg(".       /uespsales resetlist [name]  Reset the listing timestamps for that guild")
		uespLog.Msg("Guild sales data logging is currently "..uespLog.BoolToOnOff(uespLog.GetSalesDataConfig().saveSales)..".")
		uespLog.Msg("Sale price data usage is currently "..uespLog.BoolToOnOff(uespLog.IsSalesShowPrices()))
		uespLog.Msg("Sale price item tooltips are currently "..uespLog.BoolToOnOff(uespLog.IsSalesShowTooltip()))
	end		
	
end


SLASH_COMMANDS["/uespsales"] = uespLog.SalesCommand



