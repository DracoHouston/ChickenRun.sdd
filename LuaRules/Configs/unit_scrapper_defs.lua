local function SecondsToFrames(t)
	return t * 30
end

local ScrapperDefs = { 
	Constants = {
		--WindUpTime = SecondsToFrames(2),
	},
	BackID = nil, 
	FrontID = nil,
	IsEggsecutive = {},
}

for k, v in pairs(UnitDefs) do
	local cp = v.customParams
	if (ScrapperDefs.BackID == nil) and (cp.isscrapper == "back") then
		ScrapperDefs.BackID = v.id
	end
	if (ScrapperDefs.FrontID == nil) and (cp.isscrapper == "front") then
		ScrapperDefs.FrontID = v.id
	end
	if cp.iseggsecutive == "1" then
		ScrapperDefs.IsEggsecutive[v.id] = true
	end
end

return ScrapperDefs
