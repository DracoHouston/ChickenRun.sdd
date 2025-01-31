--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Chicken Run - Wave Manager",
		desc      = "Main manager for Chicken Run mode, responsible for setting up and resolving waves",
		author    = "DracoHouston",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

if gadgetHandler:IsSyncedCode() then

include("LuaRules/Configs/constants.lua")

--------------------------------------------------------------------------------
--locals
--------------------------------------------------------------------------------

local WaveDefs = VFS.Include ("LuaRules/Configs/chickenrun_wave_defs.lua")

local ActiveBosses = {}
local ActiveChickenids = {}

local PendingBosses = {}
local PendingLessers = {}

local MetalEggs = {}
local PowerEggs = {}
local CurrentEggs = {}

local ChickenidPopCount = 0
local FryCount = 0
local NuggetCount = 0
local TenderCount = 0

local ChickenidsTeamID = nil

local TeamIDForEggsecutivesByWave = nil
local PlayerTeams = {}
local SharedMetalFactor = 1

local CurrentEggsecutives = { nil, nil, nil, nil }
local CurrentEggsecutiveSuites = { nil, nil, nil, nil }
local CurrentEggBasket = nil
local CurrentEggsDunked = 0

local powereggradiussquared = 100 * 100
local dunkradiussquared = 200 * 200
local reviveradiussquared = 125 * 125
local metaleggradiussquared = 250 * 250

local ProfreshionalHasPowerEgg = { false, false, false, false }

local WaveTimers = { 
	CurrentWave = 1,
	CurrentPhase = WaveDefs.Constants.WavePhases.PreGame,
	CurrentSpawnInterval = 1,
	CurrentBossSpawnIndex = 1,
	NextSubwaveTime = 0,
	NextWaveStart = 0, 
	NextGraceEnd = WaveDefs.Constants.WaveTimes.GracePeriod, 
	NextWaveEnd = WaveDefs.Constants.WaveTimes.GracePeriod + WaveDefs.Constants.WaveTimes.Duration }

local spGetUnitRulesParam	= Spring.GetUnitRulesParam
local spSetUnitRulesParam	= Spring.SetUnitRulesParam
local spGetGroundHeight		= Spring.GetGroundHeight
local spCreateUnit			= Spring.CreateUnit
local spDestroyUnit			= Spring.DestroyUnit
local spGetUnitPosition		= Spring.GetUnitPosition
local spGetUnitRadius		= Spring.GetUnitRadius
local spGetFeaturePosition	= Spring.GetFeaturePosition
local spDestroyFeature		= Spring.DestroyFeature
local spAddTeamResource		= Spring.AddTeamResource
local spSetTeamResource		= Spring.SetTeamResource
local spSpawnCEG			= Spring.SpawnCEG;
local spKillTeam			= Spring.KillTeam
local spGameOver			= Spring.GameOver
local spGiveOrderToUnit		= Spring.GiveOrderToUnit
local spInsertUnitCmdDesc   = Spring.InsertUnitCmdDesc

local CEG_DUNK = [[eggdunkfx_spawner]];
local CMD_FIGHT				= CMD.FIGHT
local CMD_ATTACK			= CMD.ATTACK
local CMD_STOP				= CMD.STOP
local CMD_MANUALFIRE		= CMD.MANUALFIRE

--------------------------------------------------------------------------------
--helpers
--------------------------------------------------------------------------------

local function DistSq(x1, z1, x2, z2)
	return (x1 - x2)*(x1 - x2) + (z1 - z2)*(z1 - z2)
end

local function GetEggsecutiveSuitePositionForWave()
	local tidelevel = WaveDefs.TideLevels[WaveTimers.CurrentWave]
	local tidelevelconstants = WaveDefs.Constants.TideLevels
	if tidelevel == tidelevelconstants.Low then
		return WaveDefs.EggBasketsByTide.Low
	elseif tidelevel == tidelevelconstants.Mid then
		return WaveDefs.EggBasketsByTide.Mid
	elseif tidelevel == tidelevelconstants.High then
		return WaveDefs.EggBasketsByTide.High
	end
end

local function GetPlayerSpawnPositionsForWave()
	local tidelevel = WaveDefs.TideLevels[WaveTimers.CurrentWave]
	local tidelevelconstants = WaveDefs.Constants.TideLevels
	if tidelevel == tidelevelconstants.Low then
		return WaveDefs.PlayerSpawnsByTide.Low
	elseif tidelevel == tidelevelconstants.Mid then
		return WaveDefs.PlayerSpawnsByTide.Mid
	elseif tidelevel == tidelevelconstants.High then
		return WaveDefs.PlayerSpawnsByTide.High
	end
end

local function GetStaticSpawnPositionsForWave()
	local tidelevel = WaveDefs.TideLevels[WaveTimers.CurrentWave]
	local tidelevelconstants = WaveDefs.Constants.TideLevels
	if tidelevel == tidelevelconstants.Low then
		return WaveDefs.StaticSpawnsByTide.Low
	elseif tidelevel == tidelevelconstants.Mid then
		return WaveDefs.StaticSpawnsByTide.Mid
	elseif tidelevel == tidelevelconstants.High then
		return WaveDefs.StaticSpawnsByTide.High
	end
end

local function ShouldAdvancePhase(f)
	local phase = WaveTimers.CurrentPhase
	local phaseconstants = WaveDefs.Constants.WavePhases
	if phase == phaseconstants.PreGame then
		if WaveTimers.NextWaveStart <= f then
			return true
		end
	elseif phase == phaseconstants.InGrace then
		if WaveTimers.NextGraceEnd <= f then
			return true
		end
	elseif phase == phaseconstants.InWave then
		if WaveTimers.NextWaveEnd <= f then
			return true
		end
	elseif phase == phaseconstants.PostWave then
		if WaveTimers.NextWaveStart <= f then
			return true
		end
	elseif phase == phaseconstants.PostGame then
		return false
	end
end

local function SpawnDunkFX(n)	
	local _,_,_,x,y,z = spGetUnitPosition(CurrentEggBasket, true);
	local r = spGetUnitRadius(CurrentEggBasket);
	if r then
		for i = 1, n do
			spSpawnCEG( CEG_DUNK,
				x,y,z,
				0,0,0,
				2+(r/3), 2+(r/3)
			)
			GG.PlayFogHiddenSound("EggDunk", 1, x, y, z)
		end
	end
end

local function DestroyPowerEggs()
	local theseeggs = CurrentEggs[WaveDefs.PowerEggFeatureID] or {}
	for k, v in pairs(theseeggs) do
		spDestroyFeature(v)
	end
end

local function DestroyMetalEggs()
	local theseeggs = CurrentEggs[WaveDefs.MetalEggFeatureID] or {}
	for k, v in pairs(theseeggs) do
		spDestroyFeature(v)
	end
end

local function RemoveUnitsForNewWave()
	PendingBosses = {}
	PendingLessers = {}
	for i, v in ipairs(ActiveBosses) do
		spDestroyUnit(v, false, true, v, true)
	end
	for i, v in ipairs(ActiveChickenids) do
		spDestroyUnit(v, false, true, v, true)
	end
	ActiveBosses = {}
	ActiveChickenids = {}
	for i = 1, 4 do
		if CurrentEggsecutives[i] ~= nil then
			local uid = CurrentEggsecutives[i]
			spDestroyUnit(uid, false, true, uid, true)
			CurrentEggsecutives[i] = nil
		end
		if CurrentEggsecutiveSuites[i] ~= nil then
			local uid = CurrentEggsecutiveSuites[i]
			spDestroyUnit(uid, false, true, uid, true)
			CurrentEggsecutiveSuites[i] = nil
		end
	end
	
	if CurrentEggBasket ~= nil then
		spDestroyUnit(CurrentEggBasket, false, true, CurrentEggBasket, true)
		CurrentEggBasket = nil
	end
end

local function SpawnForNewWave()
	local currentwave = WaveTimers.CurrentWave
	local eggsuitepos = GetEggsecutiveSuitePositionForWave()
	local playerspawns = GetPlayerSpawnPositionsForWave()
	local profreshionals = WaveDefs.EggsecutiveSlotsByWave[currentwave]
	local eggsecutiveteams = TeamIDForEggsecutivesByWave[currentwave]
	for i = 1, 4 do
		local pos = playerspawns[i]
		local x = pos.x
		local z = pos.z
		local y = spGetGroundHeight(x,z)
		local suiteid = spCreateUnit(WaveDefs.EggsecutiveDefs[profreshionals[i]].EggsecutiveSuite, x, y, z, 1, eggsecutiveteams[i], false, false)
		local eggsecutiveid = spCreateUnit(profreshionals[i], x, y, z, 1, eggsecutiveteams[i], false, false)
		CurrentEggsecutives[i] = eggsecutiveid
		CurrentEggsecutiveSuites[i] = suiteid		
		GG.SetUnitInvincible(suiteid, true)
	end
	
	local x = eggsuitepos.x
	local z = eggsuitepos.z
	local y = spGetGroundHeight(x,z)
	local unitID = spCreateUnit(WaveDefs.EggBasket.Active, x, y, z, 1, PlayerTeams[1], false, false)
	CurrentEggBasket = unitID
	GG.SetUnitInvincible(CurrentEggBasket, true)
end

local function EnqueueSpawnLesserChickenids()
--todo: chickenid unit defs need a spawns per pop stat so chicken frys can spawn in 3s for 1 pop
--generate max intervals possible amount of indexes of static spawns array in wave defs, 13 rolls, hazard invariant, do it while rolling the tide levels
--consider spawnboxes like startbox to give the game an area to cram spawns into, rather than radiate out from a point.
end

local function EnqueueSpawnBossChickenids()
	--Spring.Echo("ENQUEUE BOSS CALLED")	
	--Spring.Echo("CURRENT WAVE IS " .. WaveTimers.CurrentWave)
	local currentwave = WaveTimers.CurrentWave
	local currentspawninterval = WaveTimers.CurrentSpawnInterval
	local bossesthisinterval = WaveDefs.BossesPerSpawnInterval[currentwave][currentspawninterval]
	
	local spawnidx = WaveDefs.StaticSpawnsPerSpawnInterval[currentwave][currentspawninterval]
	local wavespawns = GetStaticSpawnPositionsForWave()
	local spawnthisinterval = wavespawns[spawnidx]
	local x = spawnthisinterval.x
	local z = spawnthisinterval.z
	local y = spGetGroundHeight(x,z)
	local wavebosses = WaveDefs.WaveBosses[currentwave]
	if bossesthisinterval ~= nil and bossesthisinterval > 0 then
		for i = 1, bossesthisinterval do
			table.insert(PendingBosses, { ID = wavebosses[WaveTimers.CurrentBossSpawnIndex], Spawn = {X = x, Y = y, Z = z}})
			WaveTimers.CurrentBossSpawnIndex = WaveTimers.CurrentBossSpawnIndex + 1
		end
	end
end

local function ProcessSpawnQueue()
	while #ActiveBosses < WaveDefs.Constants.MaxBosses and #PendingBosses > 0 do
		local bossdefid = PendingBosses[1].ID
		local bossspawn = PendingBosses[1].Spawn
		local unitID = spCreateUnit(bossdefid, bossspawn.X, bossspawn.Y, bossspawn.Z, 1, ChickenidsTeamID, false, false)
		--Spring.Echo("SPAWNING BOSS " .. unitID)
		table.insert(ActiveBosses, unitID)
		table.remove(PendingBosses, 1)
	end
	--while ChickenidPopCount < WaveDefs.Constants.MaxEnemies and #PendingLessers > 0 do
	--end
end

local function TickSpawns(n)
	if WaveTimers.NextSubwaveTime <= n then
		EnqueueSpawnBossChickenids()
		EnqueueSpawnLesserChickenids()
		ProcessSpawnQueue()
		WaveTimers.NextSubwaveTime = WaveTimers.NextSubwaveTime + WaveDefs.SpawnIntervalTime
		WaveTimers.CurrentSpawnInterval = WaveTimers.CurrentSpawnInterval + 1
	end
end

local function CheckTeamWipe()	
	return false
end

local function EndGameWithWipe()
	spGameOver({ChickenidsTeamID})
end

local function EndGameWithTimeout()	
	spGameOver({ChickenidsTeamID})
end

local function EndGameWithVictory()
	spGameOver(PlayerTeams)
end

local function TickEggs()
	local profreshpositions = {}
	
	local suitex, suitey, suitez

	if CurrentEggBasket ~= nil then
		suitex, suitey, suitez = spGetUnitPosition(CurrentEggBasket)
	end

	for i = 1, #CurrentEggsecutives do
		local uid = CurrentEggsecutives[i]
		local profreshx, profreshy, profreshz = spGetUnitPosition(uid)
		if profreshx ~= nil and profreshy ~= nil and profreshz ~= nil then	
			table.insert(profreshpositions, {x = profreshx, y = profreshy, z = profreshz, id = uid })
		end
	end
	
	local powereggsdunkedthisframe = 0
	
	for profreshi = 1, #profreshpositions do
		local profreshpos = profreshpositions[profreshi]
		local profreshx = profreshpos.x
		local profreshy = profreshpos.y
		local profreshz = profreshpos.z
		local profreshid = profreshpos.id

		local haspoweregg = spGetUnitRulesParam(profreshid, "HoldingPowerEgg") or 0
		if haspoweregg == 1 then
			local distsquared = DistSq(profreshx, profreshz, suitex, suitez)
			if distsquared <= dunkradiussquared then	
				spSetUnitRulesParam(profreshid, "HoldingPowerEgg", 0)
				powereggsdunkedthisframe = powereggsdunkedthisframe + 1
			end
		end
	end
	
	CurrentEggsDunked = CurrentEggsDunked + powereggsdunkedthisframe
	SpawnDunkFX(powereggsdunkedthisframe)

	_G.chickenRunEventArgs = {type="eggsdunked", eggs = powereggsdunkedthisframe}
	SendToUnsynced("ChickenRunEvent")
	_G.chickenRunEventArgs = nil
end

local function AdvancePhase(n)
	local phase = WaveTimers.CurrentPhase
	local phaseconstants = WaveDefs.Constants.WavePhases
	local currentwave = WaveTimers.CurrentWave
	if phase == phaseconstants.PreGame then
		Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " ENTERING GRACE")
		--spawn profreshionals and eggsecutive suite for wave 1
		SpawnForNewWave()
		WaveTimers.CurrentPhase = phaseconstants.InGrace
		_G.chickenRunEventArgs = {type="wavestart", wavenum = currentwave, wavetide = WaveDefs.TideLevels[currentwave], wavetype = WaveDefs.WaveTypes[currentwave], wavequota = WaveDefs.WaveQuotas[currentwave]}
		SendToUnsynced("ChickenRunEvent")
		_G.chickenRunEventArgs = nil
	elseif phase == phaseconstants.InGrace then
		Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " LEAVING GRACE")
		WaveTimers.CurrentPhase = phaseconstants.InWave
		TickSpawns(n)
		_G.chickenRunEventArgs = {type="wavephasestart", phase = WaveTimers.CurrentPhase}
		SendToUnsynced("ChickenRunEvent")
		_G.chickenRunEventArgs = nil
	elseif phase == phaseconstants.InWave then
		--call off chickens
		--set timers for next wave
		ProfreshionalHasPowerEgg = { false, false, false, false }
		DestroyPowerEggs()
		if CurrentEggsDunked < WaveDefs.WaveQuotas[currentwave] then
			EndGameWithTimeout()
		end
		CurrentEggsDunked = 0
		WaveTimers.CurrentSpawnInterval = 1
		WaveTimers.CurrentBossSpawnIndex = 1
		WaveTimers.NextWaveStart = n + WaveDefs.Constants.WaveTimes.PostWave
		WaveTimers.NextGraceEnd = WaveTimers.NextWaveStart + WaveDefs.Constants.WaveTimes.GracePeriod
		WaveTimers.NextWaveEnd = WaveTimers.NextGraceEnd + WaveDefs.Constants.WaveTimes.Duration
		WaveTimers.CurrentPhase = phaseconstants.PostWave
		Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " ENTERING POSTWAVE")
		_G.chickenRunEventArgs = {type="wavephasestart", phase = WaveTimers.CurrentPhase}
		SendToUnsynced("ChickenRunEvent")
		_G.chickenRunEventArgs = nil
	elseif phase == phaseconstants.PostWave then
		DestroyMetalEggs()
		if currentwave == WaveDefs.Constants.MaxWaves then
			--show custom postgame stats widget that im totally going to make	
			Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " OVER AND SO IS MATCH")
			WaveTimers.CurrentPhase = phaseconstants.PostGame
			EndGameWithVictory()
		else
			--roll power eggs into cummulative egg bonus
			--revive any dead profreshionals
			--change ownership of kbuds and profreshionals
			--teleport everything to next spawn area by tide level
			--despawn old and spawn new eggsecutive suite
			WaveTimers.CurrentPhase = phaseconstants.InGrace
			WaveTimers.CurrentWave = WaveTimers.CurrentWave + 1
			currentwave = WaveTimers.CurrentWave
			Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " ENTERING GRACE")
			RemoveUnitsForNewWave()
			SpawnForNewWave()
			_G.chickenRunEventArgs = {type="wavestart", wavenum = currentwave, wavetide = WaveDefs.TideLevels[currentwave], wavetype = WaveDefs.WaveTypes[currentwave], wavequota = WaveDefs.WaveQuotas[currentwave]}
			SendToUnsynced("ChickenRunEvent")
			_G.chickenRunEventArgs = nil
		end
	end
end

--------------------------------------------------------------------------------
--gadget interface
--------------------------------------------------------------------------------

function gadget:FeatureCreated(featureID)
	local featuredef = Spring.GetFeatureDefID(featureID)
	
		--Spring.Echo("feature made " .. featureID .. " defid " .. featuredef )
	if (featuredef == WaveDefs.MetalEggFeatureID) or (featuredef == WaveDefs.PowerEggFeatureID) then
		if CurrentEggs[featuredef] == nil then
			CurrentEggs[featuredef] = {}
		end
		--Spring.Echo("egg made " .. featureID)
		table.insert(CurrentEggs[featuredef], featureID)
	end
end

function gadget:FeatureDestroyed(featureID)
	local featuredef = Spring.GetFeatureDefID(featureID)
	if (featuredef == WaveDefs.MetalEggFeatureID) or (featuredef == WaveDefs.PowerEggFeatureID) then
		local theseeggs = CurrentEggs[featuredef]
		if theseeggs ~= nil then
			local idxtoremove = nil
			for i, v in ipairs(theseeggs) do
				if v == featureID then
					idxtoremove = i
					break
				end
			end
			if idxtoremove ~= nil then
				--Spring.Echo("egg removed " .. featureID)
				table.remove(theseeggs, idxtoremove)
			end
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	--local bossdef = WaveDefs.BossDefs[unitDefID]
	--if bossdef ~= nil then
	--	local targetID = CurrentEggsecutives[1]
	--	if (targetID) then
	--		--local tx, ty, tz = spGetUnitPosition(targetID)
	--		spGiveOrderToUnit(unitID, CMD_ATTACK, targetID, 0)
	--		return
	--	end
	--end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	local idxtoremove = nil
	local x, y, z = spGetUnitPosition(unitID)
	for i, uid in ipairs(ActiveBosses) do
		if uid == unitID then
			idxtoremove = i
			break
		end
	end
	if idxtoremove ~= nil then
		table.remove(ActiveBosses, idxtoremove)
		return
	end
	for i, uid in ipairs(ActiveChickenids) do
		if uid == unitID then
			idxtoremove = i
			break
		end
	end
	if idxtoremove ~= nil then
		table.remove(ActiveChickenids, idxtoremove)
		return
	end
end

function gadget:GameFrame(n)
	if CheckTeamWipe() then
		EndGameWithWipe()
	end
	if ShouldAdvancePhase(n) then
		AdvancePhase(n)
	else
		if WaveTimers.CurrentPhase == WaveDefs.Constants.WavePhases.InWave then
			TickSpawns(n)
		end
	end
	if n % 8 == 0 then
		TickEggs()
	end
end

function gadget:GameStart()
	for i, t in ipairs(PlayerTeams) do
		spSetTeamResource(t, "ms", WaveDefs.Constants.MetalStorage)		
		spSetTeamResource(t, "metal", 0)
		spSetTeamResource(t, "es", WaveDefs.Constants.EnergyStorage)		
		spSetTeamResource(t, "energy", 0)
	end
end

function gadget:Initialize()
	Spring.Echo("CHICKEN RUN INITIALIZING")
	if WaveDefs == nil then
		Spring.Echo("CHICKEN RUN SHUTTING DOWN, FAILED INITIALIZATION")
		gadgetHandler:RemoveGadget()
		return
	end

	PlayerTeams = Spring.GetTeamList(0)
	local enemies = Spring.GetTeamList(1)
	ChickenidsTeamID = enemies[1]
	local playercount = #PlayerTeams
	local teamidsforprofreshionals = {}
	local teamID = PlayerTeams[1]
	SharedMetalFactor = 4 / playercount	

	if playercount > 1 then
		if playercount == 4 then
			local allplayers = {teamID, PlayerTeams[2], PlayerTeams[3], PlayerTeams[4]}
			local maxwaves = WaveDefs.Constants.MaxWaves
			for i = 1, maxwaves do
				local waveslots = {0,0,0,0}
				for p = 1, 4 do
					local idx = WaveDefs.PlayerSlotInitialOrder[p] + (i - 1)
					if idx > 4 then
						idx = idx - 4
					end
					waveslots[p] = allplayers[idx]
				end
				table.insert(teamidsforprofreshionals, waveslots)
			end	
		end
		--elseif playercount == 3 then
		--elseif playercount == 2 then
	else
		--solo game, player 1 gets all every wave
		teamidsforprofreshionals = {{teamID,teamID,teamID,teamID}, {teamID,teamID,teamID,teamID}, {teamID,teamID,teamID,teamID}, {teamID,teamID,teamID,teamID}}
	end
	
	TeamIDForEggsecutivesByWave = teamidsforprofreshionals
end

else

--------------------------------------------------------------------------------
--UNSYNCED!
--------------------------------------------------------------------------------


function WrapChickenRunEventToLuaUI()
	--Spring.Echo("Chicken Run Event Wrap got called")
	if (Script.LuaUI('ChickenRunEvent')) then
		local chickenRunEventArgs = {}
		for k, v in pairs(SYNCED.chickenRunEventArgs) do
			chickenRunEventArgs[k] = v
		end
		Script.LuaUI.ChickenRunEvent(chickenRunEventArgs)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction('ChickenRunEvent', WrapChickenRunEventToLuaUI)
end

end
