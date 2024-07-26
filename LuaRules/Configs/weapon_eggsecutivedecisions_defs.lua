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
	BombArmedWeaponID = nil,
	BombExplodingWeaponID = nil,
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
--Spring.Echo("doing scan for eggy weapons")
for k, v in pairs(WeaponDefs) do
	local cp = v.customParams
	if (cp.iseggsecutivedecision ~= nil) then
		local energycost = EggsecutiveDecisionsDefs.Constants.DefaultEnergyCost
		local whiteframes = EggsecutiveDecisionsDefs.Constants.DefaultWhiteFrames
		local weaponrange = 0
		local weaponspeed = 900 / 30
		local armtime = 0
		if cp.eggsecutiveenergycost ~= nil then
			energycost = tonumber(cp.eggsecutiveenergycost)
		end
		if cp.eggsecutivewhiteframes ~= nil then
			whiteframes = tonumber(cp.eggsecutivewhiteframes)
		end
		if cp.bombthrowarmtime ~= nil then
			armtime = tonumber(cp.bombthrowarmtime)
		end
		if v.range ~= nil then
			weaponrange = tonumber(v.range)
			--Spring.Echo("range " .. v.range .. " weaponrange " .. weaponrange)
		end
		if v.weaponvelocity ~= nil then
			weaponspeed = tonumber(v.weaponvelocity)
			--Spring.Echo("weaponvelocity " .. v.weaponvelocity .. " weaponspeed " .. weaponspeed)
		end
		if v.projectilespeed ~= nil then
			weaponspeed = tonumber(v.projectilespeed)
			--Spring.Echo("projectilespeed " .. v.projectilespeed .. " weaponspeed " .. weaponspeed)
		end

		EggsecutiveDecisionsDefs.UniversalWeaponDefs[k] = {
			EnergyCost = energycost,
			WhiteFrames = whiteframes,
			Range = weaponrange,
			Speed = weaponspeed,
			ArmTime = armtime,
		}
		
		if (cp.iseggsecutivedecision == "bombthrow") and (EggsecutiveDecisionsDefs.BombThrowWeaponID == nil) then
			EggsecutiveDecisionsDefs.BombThrowWeaponID = k
		elseif (cp.iseggsecutivedecision == "bombarmed")  and (EggsecutiveDecisionsDefs.BombArmedWeaponID == nil) then
			EggsecutiveDecisionsDefs.BombArmedWeaponID = k
		elseif (cp.iseggsecutivedecision == "bombexploding")  and (EggsecutiveDecisionsDefs.BombExplodingWeaponID == nil) then
			EggsecutiveDecisionsDefs.BombExplodingWeaponID = k
		elseif (cp.iseggsecutivedecision == "eggthrow")  and (EggsecutiveDecisionsDefs.EggThrowWeaponID == nil) then
			EggsecutiveDecisionsDefs.EggThrowWeaponID = k
		elseif (cp.iseggsecutivedecision == "eggcannon")  and (EggsecutiveDecisionsDefs.EggCannonWeaponID == nil) then
			EggsecutiveDecisionsDefs.EggCannonWeaponID = k
		end
	end
end

--Spring.Echo("done scan for eggy weapons")
return EggsecutiveDecisionsDefs
