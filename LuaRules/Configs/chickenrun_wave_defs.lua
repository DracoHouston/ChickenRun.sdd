local function GetSeed()
	local mapOpts = Spring.GetMapOptions()
	if mapOpts and mapOpts.seed and tonumber(mapOpts.seed) ~= 0 then
		return tonumber(mapOpts.seed)
	end
	
	local modOpts = Spring.GetModOptions()
	if modOpts and modOpts.mapgen_seed and tonumber(modOpts.mapgen_seed) ~= 0 then
		return tonumber(modOpts.mapgen_seed)
	end
	
	return math.random(1, 10000000)
end

local function SecondsToFrames(t)
	return t * 30
end

include("LuaRules/Configs/constants.lua")

--WaveDefs fields declared here so I can stop having to look for them
local WaveDefs = { 
	Constants = { 
		MaxWaves = 4, 
		MaxEnemies = 100, 
		MaxBosses = 15,
		MetalEggReclaim = 10,
		MetalStorage = 10000 + HIDDEN_STORAGE,
		EnergyStorage = 10000 + HIDDEN_STORAGE,
		MaxBossesByRole = { Artillery = 6, Skirmish = 9, Rush = 15 },
		WavePhases = { PreGame = 0, InGrace = 1, InWave = 2, PostWave = 3, PostGame = 4 },
		WaveTimes = { GracePeriod = SecondsToFrames(30), Duration = SecondsToFrames(150), PostWave = SecondsToFrames(10) },
		WaveTypes = { Normal = 1, Glowflies = 2, TenderCharge = 3, Mothership = 4, Gushers = 5, Fog = 6, Grillers = 7, Tornado = 8, XtraWave = 9 }, 
		TideLevels = { Low = 1, Mid = 2, High = 3 },
	},
	--[[subfields:
	Low - table of low tide position
		x - world x coord
		z - world z coord
	Mid - table of mid tide position
		x - world x coord
		z - world z coord
	High - table of high tide position
		x - world x coord
		z - world z coord]]
	EggBasketsByTide = nil,
	StaticSpawnsByTide = nil,
	PlayerSpawnsByTide = nil,
	HazardLevel = nil,
	StandardTrashIDs = nil,
	TenderChargeTrashIDs = nil,
	GrillersTrashIDs = nil,
	GlowfliesTrashIDs = nil,
	EggBasket = {Active = nil, Inactive = nil},
	Eggception = nil,
	MetalEggFeatureID = nil,
	PowerEggFeatureID = nil,
	PlayerSlotInitialOrder = nil,
	EggsecutiveSlotsByWave = { {nil, nil, nil, nil}, {nil, nil, nil, nil}, {nil, nil, nil, nil}, {nil, nil, nil, nil} },
	--[[subfields:
	EggsecutiveSuite - id for associated eggsecutive suite]]
	EggsecutiveDefs = {},
	--[[subfields:
	MetalEggsOnDeath - number of metal eggs to drop on death]]
	LesserDefs = {},
	--[[subfields:
	PowerEggsOnDeath - number of power eggs to drop on death
	MetalEggsOnDeath - number of metal eggs to drop on death]]
	BossDefs = {},
	WaveTypes = { 0, 0, 0, 0 },
	TideLevels = { 0, 0, 0, 0 },
	QueenID = nil,
	QueenDef = nil,
	WaveBosses = {{},{},{},{}},
	WaveQuotas = {0,0,0,0},
	BossesPerSpawnInterval = nil,
	StaticSpawnsPerSpawnInterval = {},
	SpawnIntervalTime = nil,
}

WaveDefs.WaveTypes[4] = WaveDefs.Constants.WaveTypes.XtraWave

local configname = "mapconfig/map_chickenrun_layout.lua"
local mapConfig = VFS.FileExists(configname) and VFS.Include(configname) or false
if mapConfig then
	if mapConfig.EggBaskets ~= nil and mapConfig.EggBaskets.Low ~= nil and mapConfig.EggBaskets.Mid ~= nil and mapConfig.EggBaskets.High ~= nil then
		WaveDefs.EggBasketsByTide = mapConfig.EggBaskets
	else
		Spring.Echo("CHICKEN RUN INIT ERROR, MISSING EGGSECUTIVE SUITE LOCATIONS")
		return nil
	end
	if mapConfig.StaticSpawns ~= nil and mapConfig.StaticSpawns.Low ~= nil and mapConfig.StaticSpawns.Mid ~= nil and mapConfig.StaticSpawns.High ~= nil then
		WaveDefs.StaticSpawnsByTide = mapConfig.StaticSpawns
	else
		Spring.Echo("CHICKEN RUN INIT ERROR, MISSING STATIC SPAWN LOCATIONS")
		return nil
	end
	if mapConfig.PlayerSpawns ~= nil and mapConfig.PlayerSpawns.Low ~= nil and mapConfig.PlayerSpawns.Mid ~= nil and mapConfig.PlayerSpawns.High ~= nil then
		WaveDefs.PlayerSpawnsByTide = mapConfig.PlayerSpawns
	else
		Spring.Echo("CHICKEN RUN INIT ERROR, MISSING PLAYER SPAWN LOCATIONS")
		return nil
	end
else
	Spring.Echo("CHICKEN RUN INIT ERROR, MISSING MAP CONFIG")
	return nil
end

local modoptions = Spring.GetModOptions() or {}

if modoptions.chickenrunhazardlevel ~= nil then
	local safehazardlevel = tonumber(modoptions.chickenrunhazardlevel)
	if safehazardlevel > 333 then
		safehazardlevel = 333
	elseif safehazardlevel < 0 then
		safehazardlevel = 0
	end
	WaveDefs.HazardLevel = safehazardlevel
else
	--default to equivalent of profreshional+0 rank in salmon run (start of medium difficulties)
	Spring.Echo("CHICKEN RUN INIT WARNING, NO HAZARD LEVEL, DEFAULTING TO 80")
	WaveDefs.HazardLevel = 80
end

--this difficulty system is NINTENDO HARD. basically a lookup table of magic constants, all numbers here are arbitrary
--SpawnIntervalTime sets frames between enqueueing spawns
--for each interval between 150 and 0 there needs to be a number of bosses in that interval
--every interval spawns one pack of lessers, 0 boss intervals only spawn a lessers pack
--WaveQuota sets array of 3 numbers for egg quota per wave
--note: at max hazard level we get a spawn rate that requires 13 spawn intervals, which gives us the most intervals possible per wave.
local hazardlevel = WaveDefs.HazardLevel
if hazardlevel == 333 then
	WaveDefs.BossesPerSpawnInterval = {	
		{ 3, 3, 3, 3, 3, 3, 3, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(12)
	WaveDefs.WaveQuotas = { 30, 32, 35 }
elseif hazardlevel >= 321 then
	WaveDefs.BossesPerSpawnInterval = {	
		{ 3, 3, 3, 3, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 4, 4, 4, 4, 4, 4, 4, 5, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 29, 31, 34 }
elseif hazardlevel >= 320 then
	WaveDefs.BossesPerSpawnInterval = {	
		{ 3, 3, 3, 3, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 4, 4, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 29, 31, 34 }
elseif hazardlevel >= 309 then
	WaveDefs.BossesPerSpawnInterval = {	
		{ 3, 3, 3, 3, 3, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 4, 4, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 29, 31, 34 }
elseif hazardlevel >= 306 then
	WaveDefs.BossesPerSpawnInterval = {	
		{ 3, 3, 3, 3, 3, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 4, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 29, 31, 34 }
elseif hazardlevel >= 299 then
	WaveDefs.BossesPerSpawnInterval = {	
		{ 3, 3, 3, 3, 3, 3, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 4, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 29, 31, 33 }
elseif hazardlevel >= 296 then
	WaveDefs.BossesPerSpawnInterval = {	
		{ 3, 3, 3, 3, 3, 3, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 4, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 28, 30, 33 }
elseif hazardlevel >= 293 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 28, 30, 33 }
elseif hazardlevel >= 285 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 3, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 28, 30, 33 }
elseif hazardlevel >= 279 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 3, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 28, 30, 33 }
elseif hazardlevel >= 272 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 3, 3, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 28, 30, 32 }
elseif hazardlevel >= 266 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 3, 3, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 4, 4, 1, 0, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 4, 1, 0, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(13.5)
	WaveDefs.WaveQuotas = { 28, 30, 32 }
elseif hazardlevel >= 260 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 1, 0, 0 }, 
		{ 4, 4, 4, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 27, 29, 32 }
elseif hazardlevel >= 253 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 1, 0, 0 }, 
		{ 3, 4, 4, 4, 4, 4, 4, 1, 0 ,0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 27, 29, 32 }
elseif hazardlevel >= 248 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 1, 0, 0 }, 
		{ 3, 4, 4, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 27, 29, 31 }
elseif hazardlevel >= 240 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 27, 29, 31 }
elseif hazardlevel >= 236 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 4, 1, 0 ,0 }, 
		{ 3, 3, 4, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 27, 29, 31 }
elseif hazardlevel >= 233 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 27, 29, 31 }
elseif hazardlevel >= 226 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 26, 28, 31 }
elseif hazardlevel >= 224 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 26, 28, 30 }
elseif hazardlevel >= 213 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 1, 0 ,0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 26, 28, 30 }
elseif hazardlevel == 212 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 3, 1 ,0 ,0 }, 
		{ 3, 3, 3, 3, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 26, 28, 30 }
elseif hazardlevel >= 200 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(15)
	WaveDefs.WaveQuotas = { 26, 28, 30 }
elseif hazardlevel >= 191 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 1, 0 ,0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 25, 27, 29 }
elseif hazardlevel >= 190 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 25, 26, 28 }
elseif hazardlevel >= 189 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 1, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 24, 26, 28 }
elseif hazardlevel >= 182 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 24, 26, 28 }
elseif hazardlevel >= 180 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 24, 25, 27 }
elseif hazardlevel >= 177 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 3, 3, 3, 3, 3 ,1 ,0, 0 }, 
		{ 3, 3, 3, 3, 3, 4 ,1 ,0, 0 }, 
		{ 3, 3, 3, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 23, 25, 27 }
elseif hazardlevel >= 172 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 23, 25, 27 }
elseif hazardlevel >= 170 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 23, 24, 26 }
elseif hazardlevel >= 167 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 3, 1, 0 ,0 }, 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 22, 24, 26 }
elseif hazardlevel >= 164 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 22, 24, 26 }
elseif hazardlevel >= 160 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 22, 23, 25 }
elseif hazardlevel >= 156 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 21, 23, 25 }
elseif hazardlevel >= 154 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 3, 3, 1, 0, 0 }, 
		{ 2, 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 21, 23, 25 }
elseif hazardlevel >= 150 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 3, 3, 1, 0, 0 }, 
		{ 2, 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 3, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(18)
	WaveDefs.WaveQuotas = { 21, 22, 24 }
elseif hazardlevel >= 146 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 20, 22, 24 }
elseif hazardlevel >= 144 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 1, 0, 0 }, 
		{ 3, 3, 4, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 20, 21, 23 }
elseif hazardlevel >= 140 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 20, 21, 23 }
elseif hazardlevel >= 136 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 19, 21, 23 }
elseif hazardlevel >= 133 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 4, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 19, 20, 22 }
elseif hazardlevel >= 130 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 20, 21, 23 }
elseif hazardlevel >= 127 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 19, 20, 22 }
elseif hazardlevel >= 122 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 4, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 18, 20, 22 }
elseif hazardlevel >= 120 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 3, 1, 0, 0 }, 
		{ 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 18, 19, 21 }
elseif hazardlevel >= 118 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 3, 1, 0, 0 }, 
		{ 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 17, 19, 21 }
elseif hazardlevel >= 111 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 3, 1, 0 ,0 }, 
		{ 2, 2, 3, 3, 3, 1, 0, 0 }, 
		{ 3, 3, 3, 3, 3, 1, 0 ,0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 17, 18, 20 }
elseif hazardlevel >= 110 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 2, 1, 0, 0 }, 
		{ 2, 2, 2, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 17, 18, 20 }
elseif hazardlevel >= 109 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 2, 1, 0, 0 }, 
		{ 2, 2, 2, 3, 3, 1, 0, 0 }, 
		{ 2, 3, 3, 3, 3, 1, 0, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 16, 18, 20 }
elseif hazardlevel >= 100 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 2, 1, 0, 0 }, 
		{ 2, 2, 2, 3, 3, 1, 0 ,0 }, 
		{ 2, 3, 3, 3, 3, 1, 0 ,0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(21.375)
	WaveDefs.WaveQuotas = { 16, 17, 19 }
elseif hazardlevel >= 93 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 1, 0 }, 
		{ 2, 3, 3, 3, 1, 0 }, 
		{ 3, 3, 3, 4, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(27)
	WaveDefs.WaveQuotas = { 15, 18, 20 }
elseif hazardlevel >= 90 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 3, 1, 0 }, 
		{ 2, 3, 3, 3, 1, 0 }, 
		{ 3, 3, 3, 4, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(27)
	WaveDefs.WaveQuotas = { 14, 15, 17 }
elseif hazardlevel >= 86 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 1, 0 }, 
		{ 2, 2, 3, 3, 1, 0 }, 
		{ 3, 3, 3, 3, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(27)
	WaveDefs.WaveQuotas = { 14, 15, 17 }
elseif hazardlevel >= 80 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 2, 2, 2, 2, 1, 0 }, 
		{ 2, 2, 3, 3, 1, 0 }, 
		{ 3, 3, 3, 3, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(27)
	WaveDefs.WaveQuotas = { 13, 14, 16 }
elseif hazardlevel >= 70 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 2, 2, 2, 1, 0 }, 
		{ 2, 2, 2, 3, 1, 0 }, 
		{ 2, 3, 3, 3, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(27)
	WaveDefs.WaveQuotas = { 12, 13, 15 }
elseif hazardlevel >= 60 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 1, 2, 2, 1, 0 }, 
		{ 2, 2, 2, 2, 1, 0 }, 
		{ 2, 2, 3, 3, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(27)
	WaveDefs.WaveQuotas = { 11, 12, 14 }
elseif hazardlevel >= 50 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 2, 2, 1, 0 }, 
		{ 2, 2, 3, 1, 0 }, 
		{ 3, 3, 3, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(36)
	WaveDefs.WaveQuotas = { 10, 11, 13 }
elseif hazardlevel >= 40 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 2, 2, 1, 0 }, 
		{ 2, 2, 2, 1, 0 }, 
		{ 2, 3, 3, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(36)
	WaveDefs.WaveQuotas = { 9, 10, 12 }
elseif hazardlevel >= 30 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 1, 2, 1, 0 }, 
		{ 1, 2, 2, 1, 0 }, 
		{ 2, 2, 3, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(36)
	WaveDefs.WaveQuotas = { 8, 9, 11 }
elseif hazardlevel >= 20 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 1, 2, 1, 0 }, 
		{ 1, 2, 2, 1, 0 }, 
		{ 2, 2, 2, 1, 0 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(36)
	WaveDefs.WaveQuotas = { 8, 9, 10 }
elseif hazardlevel >= 16 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 2, 1 }, 
		{ 2, 2, 1 }, 
		{ 2, 3, 1 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(54)
	WaveDefs.WaveQuotas = { 7, 8, 9 }
elseif hazardlevel >= 14 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 2, 1 }, 
		{ 1, 2, 1 }, 
		{ 2, 2, 1 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(54)
	WaveDefs.WaveQuotas = { 6, 7, 8 }
elseif hazardlevel >= 12 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 1, 1 }, 
		{ 1, 2, 1 }, 
		{ 2, 2, 1 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(54)
	WaveDefs.WaveQuotas = { 6, 7, 8 }
elseif hazardlevel >= 8 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 1, 1 }, 
		{ 1, 1, 1 }, 
		{ 1, 2, 1 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(54)
	WaveDefs.WaveQuotas = { 5, 6, 7 }
elseif hazardlevel >= 4 then
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 1, 1 }, 
		{ 1, 1, 1 }, 
		{ 1, 1, 1 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(54)
	WaveDefs.WaveQuotas = { 4, 5, 6 }
else
	WaveDefs.BossesPerSpawnInterval = { 
		{ 1, 1, 1 }, 
		{ 1, 1, 1 }, 
		{ 1, 1, 1 } }
	WaveDefs.SpawnIntervalTime = SecondsToFrames(54)
	WaveDefs.WaveQuotas = { 3, 4, 5 }
end

local profreshionalsbyname = {}
local kbudsbyname = {}
local lesserchickenidsbyrole = {}
local lesserchickenidsbyname = {}
local bosschickenidsbyrole = {}
local bosschickenidsbyname = {}
local kbuddefaults = {}
local kbuddefaultids = {}
local kbuddefaultdefs = {}
local profresharray = {}
local profreshnodupesarray = {}
--local unprofreshname = nil
--local unprofreshid = nil
--local unprofreshdef = nil
--local eggsecutivesuitename = nil
--local eggsecutivesuiteid = nil
--local eggsecutivesuitedef = nil

for k, v in pairs(FeatureDefs) do
	local cp = v.customParams
	if (cp.ischickenrunegg ~= nil) then
		Spring.Echo("ischickenrunegg found " .. cp.ischickenrunegg)
	end
	if (WaveDefs.MetalEggFeatureID == nil) and (cp.ischickenrunegg == "metal") then
		WaveDefs.MetalEggFeatureID = k
	elseif (WaveDefs.PowerEggFeatureID == nil) and (cp.ischickenrunegg == "power") then
		WaveDefs.PowerEggFeatureID = k
	end
end

for k, v in pairs(UnitDefNames) do
	local cp = v.customParams
	if (cp.iskbud == "1") then
		--Spring.Echo("CHICKEN RUN DEBUG: FOUND KBUD: " .. k)
		kbudsbyname[k] = v
		if (#kbuddefaults < 4) then 
			table.insert(kbuddefaults, k) 
			table.insert(kbuddefaultdefs, v)
			table.insert(kbuddefaultids, v.id) 
		end
	elseif cp.iseggsecutive == "1" then
		profreshionalsbyname[k] = v
		--Spring.Echo("CHICKEN RUN DEBUG: FOUND PROFRESHIONAL: " .. k)
	elseif cp.lesserchickenidrole ~= nil then
		lesserchickenidsbyrole[cp.lesserchickenidrole] = v
		lesserchickenidsbyname[k] = v
		local deathmetaleggs = 0
		if cp.metaleggsondeath ~= nil then
			deathmetaleggs = tonumber(cp.metaleggsondeath)
		end
		WaveDefs.LesserDefs[v.id] = {
			MetalEggsOnDeath = deathmetaleggs
		}
		--Spring.Echo("CHICKEN RUN DEBUG: FOUND LESSER CHICKENID: " .. k)
	elseif cp.bosschickenidrole ~= nil then
		local rolebosses = bosschickenidsbyrole[cp.bosschickenidrole]
		if rolebosses == nil then
			bosschickenidsbyrole[cp.bosschickenidrole] = {}
			rolebosses = bosschickenidsbyrole[cp.bosschickenidrole]
		end
		table.insert(rolebosses, v)		
		bosschickenidsbyname[k] = v
		local deathpowereggs = 0
		local deathmetaleggs = 0
		if cp.powereggsondeath ~= nil then
			deathpowereggs = tonumber(cp.powereggsondeath)
		end
		if cp.metaleggsondeath ~= nil then
			deathmetaleggs = tonumber(cp.metaleggsondeath)
		end
		WaveDefs.BossDefs[v.id] = {			
			PowerEggsOnDeath = deathpowereggs,
			MetalEggsOnDeath = deathmetaleggs
		}
		--Spring.Echo("CHICKEN RUN DEBUG: FOUND BOSS: " .. k)
	elseif cp.iseggception == "1" and WaveDefs.Eggception == nil then
		WaveDefs.Eggception = v.id
		--Spring.Echo("CHICKEN RUN DEBUG: FOUND UNPROFRESHIONAL: " .. k)
	elseif cp.iseggbasket == "1" and WaveDefs.EggBasket.Active == nil then
		WaveDefs.EggBasket.Active = v.id
		--Spring.Echo("CHICKEN RUN DEBUG: FOUND EggBasket: " .. k)
	elseif cp.iseggbasket == "2" and WaveDefs.EggBasket.Inactive == nil then
		WaveDefs.EggBasket.Inactive = v.id
		--Spring.Echo("CHICKEN RUN DEBUG: FOUND EggBasket: " .. k)
	end
end

for k, ud in pairs(profreshionalsbyname) do
	local cp = ud.customParams
	--[[local mykbuds = {}
	if cp.kbuds ~= nil then
		local str = cp.kbuds
		for word in string.gmatch(str, "%S+") do
			table.insert(mykbuds, word)
		end
	else 	
		mykbuds = kbuddefaults
	end
	local mykbudids = {}
	local mykbudsarevalid = true
	for i = 1, #mykbuds do
		local littlebuddy = kbudsbyname[mykbuds[i] ]
		if littlebuddy ~= nil then
			table.insert(mykbudids, littlebuddy.id)
		else
			mykbudsarevalid = false
			break
		end
	end
	if not mykbudsarevalid then
		mykbuds = kbuddefaults
		mykbudids = kbuddefaultids
	end]]
	WaveDefs.EggsecutiveDefs[ud.id] = {
		EggsecutiveSuite = cp.eggsecutivesuite
	}
	table.insert(profresharray, ud.id)
	table.insert(profreshnodupesarray, ud.id)
end

local smallfry = lesserchickenidsbyrole["small"].id
local nuggy = lesserchickenidsbyrole["medium"].id
local tendy = lesserchickenidsbyrole["large"].id

local standardtrash = {smallfry, smallfry, smallfry, nuggy, nuggy, tendy, smallfry, smallfry, nuggy, nuggy, tendy}
local tenderchargetrash = {tendy}
local grillerstrash = {smallfry}
local glowfliestrash = {nuggy}

WaveDefs.StandardTrashIDs = standardtrash
WaveDefs.TenderChargeTrashIDs = tenderchargetrash
WaveDefs.GrillersTrashIDs = grillerstrash
WaveDefs.GlowfliesTrashIDs = glowfliestrash
--WaveDefs.EggBasket = { ID = eggsecutivesuiteid, Name = eggsecutivesuitename, Def = eggsecutivesuitedef }
--WaveDefs.Unprofessional = { ID = unprofreshid, Name = unprofreshname, Def = unprofreshdef } 

math.randomseed(GetSeed())

--randomize initial slot order
local remainingslotorders = {1,2,3,4}
local initialslotorder = {0,0,0,0}
for i = 1, 3 do
	local slotroll = math.random(1, #remainingslotorders)
	initialslotorder[i] = remainingslotorders[slotroll]
	table.remove(remainingslotorders, slotroll)
end
initialslotorder[4] = remainingslotorders[1]

WaveDefs.PlayerSlotInitialOrder = initialslotorder
--init slots from mod options
local slots = {}
if (not modoptions.chickenrunsetslot1) then
	Spring.Echo("CHICKEN RUN INIT WARNING MISSING SET SLOT ONE OPTION, DEFAULTING TO RANDOMNODUPES!")
	slots[1] = "randomstartnodupes"
else
	slots[1] = modoptions.chickenrunsetslot1
end

if (not modoptions.chickenrunsetslot2) then
	Spring.Echo("CHICKEN RUN INIT WARNING MISSING SET SLOT TWO OPTION, DEFAULTING TO RANDOMNODUPES!")
	slots[2] = "randomstartnodupes"
else
	slots[2] = modoptions.chickenrunsetslot2
end

if (not modoptions.chickenrunsetslot3) then
	Spring.Echo("CHICKEN RUN INIT WARNING MISSING SET SLOT THREE OPTION, DEFAULTING TO RANDOMNODUPES!")
	slots[3] = "randomstartnodupes"
else
	slots[3] = modoptions.chickenrunsetslot3
end

if (not modoptions.chickenrunsetslot4) then
	Spring.Echo("CHICKEN RUN INIT WARNING MISSING SET SLOT FOUR OPTION, DEFAULTING TO RANDOMNODUPES!")
	slots[4] = "randomstartnodupes"
else
	slots[4] = modoptions.chickenrunsetslot4
end

local profreshcount = #profresharray
--[[to keep the chicken spawns from depending on the set slot mod options we pull out max numbers needed for this
first is 4 indexes of the nodupes array, max going down as the array will be shrinking]]
--awful, just awful :(
local randomnodupes = {}
if profreshcount > 4 then
	randomnodupes = {math.random(1, profreshcount), math.random(1, profreshcount - 1), math.random(1, profreshcount - 2), math.random(1, profreshcount - 3) }
elseif profreshcount == 4 then
	randomnodupes = {math.random(1, profreshcount), math.random(1, profreshcount - 1), math.random(1, profreshcount - 2), 1 }
	local consumethisroll = math.random()
elseif profreshcount == 3 then
--this sucks btw, you need to keep count of how many slots have the setting and then drop it back to random start working backwards if profresh count > random no dupes count
	if slots[4] == "randomstartnodupes" then
		slots[4] = "randomstart"
	end
	randomnodupes = {math.random(1, profreshcount), math.random(1, profreshcount - 1), 1, 1 }
	local consumethisroll = {math.random(), math.random()}
elseif profreshcount == 2 then
	for i = 3, #slots do
		if slots[i] == "randomstartnodupes" then
			slots[i] = "randomstart"
		end
	end
	randomnodupes = {math.random(1, profreshcount), 1, 1, 1 }
	local consumethisroll = {math.random(), math.random(), math.random()}
elseif profreshcount == 1 then
	for i = 1, #slots do
		if slots[i] == "randomstartnodupes" then
			slots[i] = "randomstart"
		end
	end
	local consumethisroll = {math.random(), math.random(), math.random(), math.random()}
	randomnodupes = {1, 1, 1, 1 }
else
	Spring.Echo("CHICKEN RUN WAVE INIT ERROR! NO PROFRESHIONALS")
	return nil
end

local nodupesidx = 1

for i = 1, #slots do
	--as above, 1 per wave for each of the 4 slots, next 16 numbers are consumed by this
	local waveone = math.random(1, profreshcount)
	local wavetwo = math.random(1, profreshcount)
	local wavethree = math.random(1, profreshcount)
	local wavefour = math.random(1, profreshcount)
	if (slots[i] == "randomstartnodupes") then
		local randidx = randomnodupes[nodupesidx]
		--set this slot to this profreshional for every wave
		WaveDefs.EggsecutiveSlotsByWave[1][i] = profreshnodupesarray[randidx]
		WaveDefs.EggsecutiveSlotsByWave[2][i] = profreshnodupesarray[randidx]
		WaveDefs.EggsecutiveSlotsByWave[3][i] = profreshnodupesarray[randidx]
		WaveDefs.EggsecutiveSlotsByWave[4][i] = profreshnodupesarray[randidx]
		table.remove(profreshnodupesarray, randidx)
		nodupesidx = nodupesidx + 1
	elseif (slots[i] == "randomstart") then
		--use wave 1's random index for all waves
		WaveDefs.EggsecutiveSlotsByWave[1][i] = profresharray[waveone]
		WaveDefs.EggsecutiveSlotsByWave[2][i] = profresharray[waveone]
		WaveDefs.EggsecutiveSlotsByWave[3][i] = profresharray[waveone]
		WaveDefs.EggsecutiveSlotsByWave[4][i] = profresharray[waveone]
	elseif (slots[i] == "randomeverywave") then
		WaveDefs.EggsecutiveSlotsByWave[1][i] = profresharray[waveone]
		WaveDefs.EggsecutiveSlotsByWave[2][i] = profresharray[wavetwo]
		WaveDefs.EggsecutiveSlotsByWave[3][i] = profresharray[wavethree]
		WaveDefs.EggsecutiveSlotsByWave[4][i] = profresharray[wavefour]
	elseif (slots[i] ~= nil) then
		local slotprofreshional = profreshionalsbyname[slots[i]]
		if (slotprofreshional ~= nil) then
			local slotprofreshionalid = slotprofreshional.id
			WaveDefs.EggsecutiveSlotsByWave[1][i] = slotprofreshionalid
			WaveDefs.EggsecutiveSlotsByWave[2][i] = slotprofreshionalid
			WaveDefs.EggsecutiveSlotsByWave[3][i] = slotprofreshionalid
			WaveDefs.EggsecutiveSlotsByWave[4][i] = slotprofreshionalid
		else
			--fall back to random start
			WaveDefs.EggsecutiveSlotsByWave[1][i] = profresharray[waveone]
			WaveDefs.EggsecutiveSlotsByWave[2][i] = profresharray[waveone]
			WaveDefs.EggsecutiveSlotsByWave[3][i] = profresharray[waveone]
			WaveDefs.EggsecutiveSlotsByWave[4][i] = profresharray[waveone]
		end
	end
end

local normaltidetype = 1
local neverlowtidetype = 2
local alwayslowtidetype = 3

--20% high 20% low 60% mid for normal waves and fog, mothership
local hightidethreshold = 0.8
local lowtidethreshold = 0.6
--25% chance of high, 75% chance of mid on glowflies, grillers, gushers
local otherhightidethreshold = 0.75
--note tendy charge, tornado are both always low tide!
--Known Occurances chances, there is a 75% chance at a normal wave, 4.1666666666~% chance of each special wave
--we roll it as a 24 sided die that is normal if it rolls 18 or less
local grillersroll = 24
local fogroll = 23
local gushersroll = 22
local mothershiproll = 21
local tendychargeroll = 20
local glowfliesroll = 19
local tornadoroll = 18

local waves = 3

local glowfliesindex = 2
local tendychargeindex = 3
local mothershipindex = 4

for waveidx = 1, waves do
	local knownoccuranceroll = math.random(1,24)

	local tideleveltype = nil
	local tidelevelroll = math.random()

	if knownoccuranceroll == grillersroll then
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.Grillers
		tideleveltype = neverlowtidetype
	elseif knownoccuranceroll == fogroll then
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.Fog
		tideleveltype = normaltidetype		
	elseif knownoccuranceroll == gushersroll then
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.Gushers
		tideleveltype = neverlowtidetype
	elseif knownoccuranceroll == mothershiproll then
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.Mothership
		tideleveltype = normaltidetype
	elseif knownoccuranceroll == tendychargeroll then
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.TenderCharge
		tideleveltype = alwayslowtidetype
	elseif knownoccuranceroll == glowfliesroll then
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.Glowflies
		tideleveltype = neverlowtidetype
	elseif knownoccuranceroll == tornadoroll then
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.Tornado
		tideleveltype = alwayslowtidetype
	else
		WaveDefs.WaveTypes[waveidx] = WaveDefs.Constants.WaveTypes.Normal
		tideleveltype = normaltidetype		
	end

	if tideleveltype == normaltidetype then
		if tidelevelroll >= hightidethreshold then
			WaveDefs.TideLevels[waveidx] = WaveDefs.Constants.TideLevels.High
		elseif tidelevelroll >= lowtidethreshold then
			WaveDefs.TideLevels[waveidx] = WaveDefs.Constants.TideLevels.Low
		else
			WaveDefs.TideLevels[waveidx] = WaveDefs.Constants.TideLevels.Mid
		end
	elseif tideleveltype == neverlowtidetype then
		if tidelevelroll >= otherhightidethreshold then
			WaveDefs.TideLevels[waveidx] = WaveDefs.Constants.TideLevels.High
		else
			WaveDefs.TideLevels[waveidx] = WaveDefs.Constants.TideLevels.Mid
		end
	else
		WaveDefs.TideLevels[waveidx] = WaveDefs.Constants.TideLevels.Low
	end	
end
--Xtra Wave always has same tide level as wave 3
WaveDefs.TideLevels[4] = WaveDefs.TideLevels[3]

for i = 1, 4 do
	local staticspawncount = nil
	if WaveDefs.TideLevels[i] == WaveDefs.Constants.TideLevels.Mid then
		staticspawncount = #WaveDefs.StaticSpawnsByTide.Mid
	elseif WaveDefs.TideLevels[i] == WaveDefs.Constants.TideLevels.High then
		staticspawncount = #WaveDefs.StaticSpawnsByTide.High
	elseif WaveDefs.TideLevels[i] == WaveDefs.Constants.TideLevels.Low then
		staticspawncount = #WaveDefs.StaticSpawnsByTide.Low
	end
	--13 rolls for max possible spawn intervals (max hazard wave 3/4)
	table.insert(WaveDefs.StaticSpawnsPerSpawnInterval, { math.random(1, staticspawncount), math.random(1, staticspawncount), math.random(1, staticspawncount), 
		math.random(1, staticspawncount), math.random(1, staticspawncount), math.random(1, staticspawncount), 
		math.random(1, staticspawncount), math.random(1, staticspawncount), math.random(1, staticspawncount), 
		math.random(1, staticspawncount), math.random(1, staticspawncount), math.random(1, staticspawncount), math.random(1, staticspawncount) })
end

local artybosses = bosschickenidsbyrole["artillery"]
local rangedbosses = bosschickenidsbyrole["ranged"]
local rushbosses = bosschickenidsbyrole["rush"]
local queenbosses = bosschickenidsbyrole["queen"]
local artybosscount = #artybosses
local rangedbosscount = #rangedbosses
local rushbosscount = #rushbosses
local queenbosscount = #queenbosses
local artillerythreshold = 0.85
local rangedthreshold = 0.55
local maxbossesperwave = 35

local queenroll = math.random(1, queenbosscount)
local xtrawaves = waves + 1
WaveDefs.QueenID = queenbosses[queenroll].id
WaveDefs.QueenDef = queenbosses[queenroll]

for waveidx = 1, xtrawaves do
	local wavebosses = WaveDefs.WaveBosses[waveidx]
	for bossidx = 1, maxbossesperwave do
		local roleroll = math.random()
		if roleroll >= artillerythreshold then		
			local bossroll = math.random(1, artybosscount)
			table.insert(wavebosses, artybosses[bossroll].id)
		elseif roleroll >= rangedthreshold then
			local bossroll = math.random(1, rangedbosscount)
			table.insert(wavebosses, rangedbosses[bossroll].id)
		else
			local bossroll = math.random(1, rushbosscount)
			table.insert(wavebosses, rushbosses[bossroll].id)
		end
	end
end

return WaveDefs
