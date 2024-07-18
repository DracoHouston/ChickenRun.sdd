local function SecondsToFrames(t)
	return t * 30
end

local EggsecutiveDecisionsDefs = { 
	Constants = {
		DefaultEnergyPool = 100,
		DefaultEnergyPerFrame = 2,
		DefaultEnergyCost = 75,
		DefaultWhiteFrames = 4,
	},
	BombThrowWeaponID = nil,
	EggThrowWeaponID = nil,
	EggCannonWeaponID = nil,
	--[[subfields:
	EnergyPool - number for the max of the energy pool for this eggsecutive
	EnergyPerFrame - number for the energy this eggsecutive gains per frame, outside White Frames]]
	EggsecutiveDefs = {},
	--[[subfields:
	EnergyCost - number for the cost in energy for firing this weapon
	WhiteFrames - number of frames to pause energy regen after use]]
	UniversalWeaponDefs = {},
}

for k, v in pairs(UnitDefs) do
	local cp = v.customParams
	if (cp.iseggsecutive == "1") then
		local energypool = EggsecutiveDecisionsDefs.Constants.DefaultEnergyPool
		local energyregen = EggsecutiveDecisionsDefs.Constants.DefaultEnergyPerFrame
		if cp.eggsecutiveenergypool ~= nil then
			energypool = tonumber(cp.eggsecutiveenergypool)
		end
		if cp.eggsecutiveenergyperframe ~= nil then
			energyregen = tonumber(cp.eggsecutiveenergyperframe)
		end
		EggsecutiveDecisionsDefs.EggsecutiveDefs[k] = {
			EnergyPool = energypool,
			EnergyPerFrame = energyregen,
		}
	end
end

for k, v in pairs(WeaponDefs) do
	local cp = v.customParams
	if (cp.iseggsecutivedecision ~= nil) then
		local energycost = EggsecutiveDecisionsDefs.Constants.DefaultEnergyCost
		local whiteframes = EggsecutiveDecisionsDefs.Constants.DefaultWhiteFrames
		if cp.eggsecutiveenergycost ~= nil then
			energycost = tonumber(cp.eggsecutiveenergycost)
		end
		if cp.eggsecutivewhiteframes ~= nil then
			whiteframes = tonumber(cp.eggsecutivewhiteframes)
		end
		EggsecutiveDecisionsDefs.UniversalWeaponDefs[k] = {
			EnergyCost = energycost,
			WhiteFrames = whiteframes,
		}
		if (cp.iseggsecutivedecision == "bombthrow") and (BombThrowWeaponID == nil) then
			BombThrowWeaponID = k
		end
		if (cp.iseggsecutivedecision == "eggthrow")  and (EggThrowWeaponID == nil) then
			EggThrowWeaponID = k
		end
		if (cp.iseggsecutivedecision == "eggcannon")  and (EggCannonWeaponID == nil) then
			EggCannonWeaponID = k
		end
	end
end

return EggsecutiveDecisionsDefs
