local EggNames = VFS.Include("LuaRules/Configs/chickenrun_eggnames.lua")

local EggVacuumDefs = { 
	Constants = { 
		MetalEggReclaim = 10,
		MetalStorage = 10000,
		EnergyStorage = 10000,
		PowerEggRadiusSquared = 100 * 100,
		MetalEggRadiusSquared = 250 * 250,
	},
	IsEggsecutiveSuite = {},
	IsEggsecutive = {},
	
	MetalEggFeatureID = FeatureDefNames[EggNames.MetalEggName].id,
	PowerEggFeatureID = FeatureDefNames[EggNames.PowerEggName].id,
}

--local modoptions = Spring.GetModOptions() or {}

for k, v in pairs(UnitDefs) do
	local cp = v.customParams
	if (cp.iseggsecutivesuite == "1") then
		EggVacuumDefs.IsEggsecutiveSuite[v.id] = true
	elseif (cp.iseggsecutive == "1") then
		EggVacuumDefs.IsEggsecutive[v.id] = true
	end
end

return EggVacuumDefs
