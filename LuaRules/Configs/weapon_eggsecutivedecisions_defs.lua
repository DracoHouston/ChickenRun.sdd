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
	WhiteFrames - number of frames to pause energy regen after use
	Range - range value from weapon def
	Speed - projectile speed value from weapon def
	]]
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
Spring.Echo("doing scan for eggy weapons")
for k, v in pairs(WeaponDefs) do
	local cp = v.customParams
	if (cp.iseggsecutivedecision ~= nil) then
		local energycost = EggsecutiveDecisionsDefs.Constants.DefaultEnergyCost
		local whiteframes = EggsecutiveDecisionsDefs.Constants.DefaultWhiteFrames
		local weaponrange = 0
		local weaponspeed = 50
		if cp.eggsecutiveenergycost ~= nil then
			energycost = tonumber(cp.eggsecutiveenergycost)
		end
		if cp.eggsecutivewhiteframes ~= nil then
			whiteframes = tonumber(cp.eggsecutivewhiteframes)
		end
		if v.range ~= nil then
			weaponrange = tonumber(v.range)
			Spring.Echo("range " .. v.range .. " weaponrange " .. weaponrange)
		end
		if v.weaponvelocity ~= nil then
			weaponspeed = tonumber(v.weaponvelocity)
			Spring.Echo("weaponVelocity " .. v.weaponvelocity .. " weaponspeed " .. weaponspeed)
		end

		EggsecutiveDecisionsDefs.UniversalWeaponDefs[k] = {
			EnergyCost = energycost,
			WhiteFrames = whiteframes,
			Range = weaponrange,
			Speed = weaponspeed,
		}
		
		if (cp.iseggsecutivedecision == "bombthrow") and (EggsecutiveDecisionsDefs.BombThrowWeaponID == nil) then
		Spring.Echo("bomb throw found")
			EggsecutiveDecisionsDefs.BombThrowWeaponID = k
		end
		if (cp.iseggsecutivedecision == "eggthrow")  and (EggsecutiveDecisionsDefs.EggThrowWeaponID == nil) then
		Spring.Echo("egg throw found")
			EggsecutiveDecisionsDefs.EggThrowWeaponID = k
		end
		if (cp.iseggsecutivedecision == "eggcannon")  and (EggsecutiveDecisionsDefs.EggCannonWeaponID == nil) then
		Spring.Echo("egg cannon found")
			EggsecutiveDecisionsDefs.EggCannonWeaponID = k
		end
	end
end

Spring.Echo("done scan for eggy weapons")
return EggsecutiveDecisionsDefs
