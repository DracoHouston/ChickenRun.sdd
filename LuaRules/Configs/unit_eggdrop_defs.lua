local EggNames = VFS.Include("LuaRules/Configs/chickenrun_eggnames.lua")

local EggDropDefs = { 
	EggDroppersDefs = {},

	MetalEggFeatureID = FeatureDefNames[EggNames.MetalEggName].id,
	PowerEggFeatureID = FeatureDefNames[EggNames.PowerEggName].id,
}

for k, v in pairs(UnitDefs) do
	local cp = v.customParams
	if (cp.powereggsondeath ~= nil) or (cp.metaleggsondeath ~= nil) then
		local deathpowereggs = 0
		local deathmetaleggs = 0
		if cp.powereggsondeath ~= nil then
			deathpowereggs = tonumber(cp.powereggsondeath)
		end
		if cp.metaleggsondeath ~= nil then
			deathmetaleggs = tonumber(cp.metaleggsondeath)
		end
		EggDropDefs.EggDroppersDefs[v.id] = {			
			PowerEggsOnDeath = deathpowereggs,
			MetalEggsOnDeath = deathmetaleggs,
		}
	end
end

return EggDropDefs
