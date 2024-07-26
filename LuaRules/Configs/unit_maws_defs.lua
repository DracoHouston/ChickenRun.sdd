local function SecondsToFrames(t)
	return t * 30
end

local MawsDefs = { 
	Constants = {
		WindUpTime = SecondsToFrames(2),
		BiteTime = SecondsToFrames(2),
		DistanceThresholdSquared = 50 * 50,		
		BiteRadius = 100,
	},
	MovingID = nil, 
	BitingID = nil,
	IsEggsecutive = {},
	IsEggsecutiveBomb = {},
}

for k, v in pairs(UnitDefs) do
	local cp = v.customParams
	if (MawsDefs.MovingID == nil) and (cp.ismaws == "moving") then
		MawsDefs.MovingID = v.id
	end
	if (MawsDefs.BitingID == nil) and (cp.ismaws == "biting") then
		MawsDefs.BitingID = v.id
	end
	if cp.iseggsecutive == "1" then
		MawsDefs.IsEggsecutive[v.id] = true
	end
end

for k, v in pairs(WeaponDefs) do
	local cp = v.customParams
	
	if (cp.iseggsecutivedecision == "bombthrow") or (cp.iseggsecutivedecision == "bombarmed") or (cp.iseggsecutivedecision == "bombexploding") then
		MawsDefs.IsEggsecutiveBomb[v.id] = true
	end
end

return MawsDefs
