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

local ChickenidPopCount = 0
local FryCount = 0
local NuggetCount = 0
local TenderCount = 0

local ChickenidsTeamID = nil

local TeamIDForEggsecutivesByWave = nil
local PlayerTeams = {}
local SharedMetalFactor = 1

local CurrentEggsecutives = { nil, nil, nil, nil }
local CurrentEggsecutiveSuite = nil
local CurrentEggsDunked = 0

local powereggradiussquared = 200 * 200
local metaleggradiussquared = 500 * 500

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

	
local spGetGroundHeight = Spring.GetGroundHeight
local spCreateUnit = Spring.CreateUnit
local spGetUnitPosition	= Spring.GetUnitPosition
local spGetFeaturePosition = Spring.GetFeaturePosition
local spDestroyFeature = Spring.DestroyFeature
local spAddTeamResource = Spring.AddTeamResource
local spSetTeamResource = Spring.SetTeamResource

--------------------------------------------------------------------------------
--helpers
--------------------------------------------------------------------------------

local function DistSq(x1, z1, x2, z2)
	return (x1 - x2)*(x1 - x2) + (z1 - z2)*(z1 - z2)
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

local function AdvancePhase(n)
	local phase = WaveTimers.CurrentPhase
	local phaseconstants = WaveDefs.Constants.WavePhases
	local currentwave = WaveTimers.CurrentWave
	if phase == phaseconstants.PreGame then
		Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " ENTERING GRACE")
		--spawn profreshionals and eggsecutive suite for wave 1
		WaveTimers.CurrentPhase = phaseconstants.InGrace
		GG.SetUnitInvincible(CurrentEggsecutiveSuite, true)
		_G.chickenRunEventArgs = {type="wavestart", wavenum = currentwave, wavetide = WaveDefs.TideLevels[currentwave], wavetype = WaveDefs.WaveTypes[currentwave], wavequota = WaveDefs.WaveQuotas[currentwave]}
		SendToUnsynced("ChickenRunEvent")
		_G.chickenRunEventArgs = nil
	elseif phase == phaseconstants.InGrace then
		--spawn initial chickens
		Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " LEAVING GRACE")
		WaveTimers.CurrentPhase = phaseconstants.InWave
		_G.chickenRunEventArgs = {type="wavephasestart", phase = WaveTimers.CurrentPhase}
		SendToUnsynced("ChickenRunEvent")
		_G.chickenRunEventArgs = nil
	elseif phase == phaseconstants.InWave then
		--call off chickens
		--set timers for next wave
		WaveTimers.CurrentSpawnInterval = 1
		WaveTimers.CurrentBossSpawnIndex = 1
		WaveTimers.NextWaveStart = n + WaveDefs.Constants.WaveTimes.PostWave
		WaveTimers.NextGraceEnd = WaveTimers.NextWaveStart + WaveDefs.Constants.WaveTimes.GracePeriod
		WaveTimers.NextWaveEnd = WaveTimers.NextGraceEnd + WaveDefs.Constants.WaveTimes.Duration
		WaveTimers.CurrentPhase = phaseconstants.PostWave
		ProfreshionalHasPowerEgg = { false, false, false, false }
		--destroy power eggs
		Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " ENTERING POSTWAVE")
		_G.chickenRunEventArgs = {type="wavephasestart", phase = WaveTimers.CurrentPhase}
		SendToUnsynced("ChickenRunEvent")
		_G.chickenRunEventArgs = nil
	elseif phase == phaseconstants.PostWave then
		--destroy metal eggs
		if currentwave == WaveDefs.Constants.MaxWaves then
			--show custom postgame stats widget that im totally going to make	
			Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " OVER AND SO IS MATCH")
			WaveTimers.CurrentPhase = phaseconstants.PostGame
		else
			--roll power eggs into cummulative egg bonus
			--revive any dead profreshionals
			--change ownership of kbuds and profreshionals
			--teleport everything to next spawn area by tide level
			--despawn old and spawn new eggsecutive suite
			WaveTimers.CurrentPhase = phaseconstants.InGrace
			WaveTimers.CurrentWave = WaveTimers.CurrentWave + 1
			Spring.Echo("CHICKEN RUN WAVE " .. currentwave .. " ENTERING GRACE")
			_G.chickenRunEventArgs = {type="wavestart", wavenum = currentwave, wavetide = WaveDefs.TideLevels[currentwave], wavetype = WaveDefs.WaveTypes[currentwave], quota = WaveDefs.WaveQuotas[currentwave]}
			SendToUnsynced("ChickenRunEvent")
			_G.chickenRunEventArgs = nil
		end
	end
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

local function SpawnMetalEggs(n, x, y, z)
	for i = 1, n do
		local rx, rz = math.random(-30, 30), math.random(-30, 30)
		local eggID = Spring.CreateFeature("chickenrunmetalegg", x+rx, y, z+rz, math.random(-32000, 32000))
		table.insert(MetalEggs, eggID)
	end
end

local function SpawnPowerEggs(n, x, y, z)
--Spring.Echo("SPAWNING POWER EGGS " .. n .. " x " .. x .. "y " .. y .. "z " .. z)
	for i = 1, n do
		local rx, rz = math.random(-30, 30), math.random(-30, 30)
		local eggID = Spring.CreateFeature("chickenrunpoweregg", x+rx, y, z+rz, math.random(-32000, 32000))
		table.insert(PowerEggs, eggID)
		--Spring.Echo("SPAWNED EGG " .. eggID)
	end
end

local function TickEggs()
	Spring.Echo("Tick Eggs starting")
	local profreshpositions = {}
	local metaleggpositions = {}
	local powereggpositions = {}
	local totalmetalreclaim = 0
	
	local suitex, suitey, suitez

	if CurrentEggsecutiveSuite ~= nil then
		suitex, suitey, suitez = spGetUnitPosition(CurrentEggsecutiveSuite)
	end

	for i = 1, #CurrentEggsecutives do
		local uid = CurrentEggsecutives[i]
		local profreshx, profreshy, profreshz = spGetUnitPosition(uid)
		table.insert(profreshpositions, {x = profreshx, y = profreshy, z = profreshz, id = uid })
		Spring.Echo("profresh " .. i .. " x " .. profreshx ..  " y " .. profreshy .. " z " .. profreshz .. " id " .. uid)
	end
		
	for i = 1, #MetalEggs do
		local uid = MetalEggs[i]
		local eggx, eggy, eggz = spGetFeaturePosition(uid)
		if eggx == nil or eggy == nil or eggz == nil then
			Spring.Echo("metal egg " .. i .. " id " .. uid .. "has a nil position!!!!")
		else
			Spring.Echo("metal egg " .. i .. " x " .. eggx .. " y " .. eggy .. " z " .. eggz .. " id " .. uid)			
			table.insert(metaleggpositions, {x = eggx, y = eggy, z = eggz, id = uid })
		end
	end

	for i = 1, #PowerEggs do
		local uid = PowerEggs[i]
		local eggx, eggy, eggz = spGetFeaturePosition(uid)
		if eggx == nil or eggy == nil or eggz == nil then
			Spring.Echo("power egg " .. i .. " id " .. uid .. "has a nil position!!!!")
		else
			Spring.Echo("power egg " .. i .. " x " .. eggx .. " y " .. eggy .. " z " .. eggz .. " id " .. uid)
			table.insert(powereggpositions, {x = eggx, y = eggy, z = eggz, id = uid })
		end
	end

	local reclaimperegg = WaveDefs.Constants.MetalEggReclaim
	local metaleggstokeep = {}
	local metaleggsreclaimed = {}
	local powereggstokeep = {}			
	local powereggsreclaimed = {}
	local powereggsdunkedthisframe = 0
	
	Spring.Echo("metal egg threshold squared " .. metaleggradiussquared)
	for profreshi = 1, #profreshpositions do
		local profreshpos = profreshpositions[profreshi]
		local profreshx = profreshpos.x
		local profreshy = profreshpos.y
		local profreshz = profreshpos.z
		local profreshid = profreshpos.id

		for eggi = 1, #metaleggpositions do
			local eggpos = metaleggpositions[eggi]
			local eggx = eggpos.x
			local eggy = eggpos.y
			local eggz = eggpos.z
			local eggid = eggpos.id
			local distsquared = DistSq(profreshx, profreshz, eggx, eggz)
			Spring.Echo("profresh " .. profreshid .. " to metal egg " .. eggid .. "distance squared " .. distsquared)
			if distsquared <= metaleggradiussquared then
			--	Spring.Echo("keeping metal egg")
			--	table.insert(metaleggstokeep, eggid)
			--else
				Spring.Echo("attempting to reclaim metal egg")
				if metaleggsreclaimed[eggid] == nil then
					Spring.Echo("reclaimed")
					metaleggsreclaimed[eggid] = profreshid
					totalmetalreclaim = totalmetalreclaim + reclaimperegg
				end
			end
		end

		if ProfreshionalHasPowerEgg[profreshi] == false then
			for eggi = 1, #powereggpositions do
				local eggpos = powereggpositions[eggi]
				local eggx = eggpos.x
				local eggy = eggpos.y
				local eggz = eggpos.z
				local eggid = eggpos.id
				local distsquared = DistSq(profreshx, profreshz, eggx, eggz)
				if distsquared <= powereggradiussquared then
					--table.insert(powereggstokeep, eggid)
				--else
					if powereggsreclaimed[eggid] == nil then
						powereggsreclaimed[eggid] = profreshid
						ProfreshionalHasPowerEgg[profreshi] = true
						break
					end
				end
			end
		else
			local distsquared = DistSq(profreshx, profreshz, suitex, suitez)
			if distsquared <= powereggradiussquared then	
				ProfreshionalHasPowerEgg[profreshi] = false
				--CurrentEggsDunked = CurrentEggsDunked + 1
				powereggsdunkedthisframe = powereggsdunkedthisframe + 1
			end
		end
	end

	local metalperplayer = totalmetalreclaim * SharedMetalFactor
	Spring.Echo("metal per player " .. metalperplayer .. " total " .. totalmetalreclaim .. " shared metal factor " .. SharedMetalFactor)

	for i = 1, #MetalEggs do
		local uid = MetalEggs[i]
		if metaleggsreclaimed[uid] == nil then
			table.insert(metaleggstokeep, uid)
		end
	end

	for i = 1, #PowerEggs do
		local uid = PowerEggs[i]
		if powereggsreclaimed[uid] == nil then
			table.insert(powereggstokeep, uid)
		end
	end

	for k, v in pairs(metaleggsreclaimed) do
		spDestroyFeature(k)
		Spring.Echo("destroying metal egg " .. k)
		--todo: award to this team the credit			
	end

	for k, v in pairs(powereggsreclaimed) do
		spDestroyFeature(k)
		Spring.Echo("destroying power egg " .. k)
		--todo: award to this team the credit			
	end

	if metalperplayer > 0 then
		for i, t in ipairs(PlayerTeams) do
			spAddTeamResource( t, "metal", metalperplayer )
		end
	end

	for k, v in pairs(powereggsreclaimed) do
		spDestroyFeature(k)
	end
	
	CurrentEggsDunked = CurrentEggsDunked + powereggsdunkedthisframe

	_G.chickenRunEventArgs = {type="eggsdunked", eggs = powereggsdunkedthisframe}
	SendToUnsynced("ChickenRunEvent")
	_G.chickenRunEventArgs = nil

	MetalEggs = metaleggstokeep
	PowerEggs = powereggstokeep
end

--------------------------------------------------------------------------------
--gadget interface
--------------------------------------------------------------------------------

function gadget:UnitCreated(unitID, unitDefID, unitTeam)

end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	--Spring.Echo("UNIT DESTROYED " .. unitID)
	local idxtoremove = nil
	local x, y, z = spGetUnitPosition(unitID)
	for i, uid in ipairs(ActiveBosses) do
		--Spring.Echo("LOOKING THROUGH BOSSES " .. uid .. " " .. i)
		if uid == unitID then
			--Spring.Echo("FOUND IT")
			idxtoremove = i
			break
		end
	end
	--Spring.Echo("STOPPED LOOKING")
	if idxtoremove ~= nil then
		--Spring.Echo("WE GOT A HIT EARLIER")
		table.remove(ActiveBosses, idxtoremove)
		local bossdef = WaveDefs.BossDefs[unitDefID]
		if bossdef ~= nil then
			--Spring.Echo("BOSS DEF ISNT NIL")
			if bossdef.PowerEggsOnDeath ~= nil then
			--Spring.Echo("POWER EGGS ISNT NIL IT IS " .. bossdef.PowerEggsOnDeath)
				SpawnPowerEggs(bossdef.PowerEggsOnDeath, x, y, z)
			end
			if bossdef.MetalEggsOnDeath ~= nil then
				SpawnMetalEggs(bossdef.MetalEggsOnDeath, x, y, z)
			end
		end
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
		local chickendef = WaveDefs.LesserDefs[unitDefID]
		if chickendef ~= nil and chickendef.MetalEggsOnDeath ~= nil then
			--spawn metal eggs
				SpawnMetalEggs(chickendef.MetalEggsOnDeath, x, y, z)
		end
		return
	end
end

function gadget:GameFrame(n)
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
		spSetTeamResource(t, "es", 500 + HIDDEN_STORAGE)		
		spSetTeamResource(t, "energy", 500)
	end
end

function gadget:Initialize()
	Spring.Echo("CHICKEN RUN INITIALIZING")
	if WaveDefs == nil then
		Spring.Echo("CHICKEN RUN SHUTTING DOWN, FAILED INITIALIZATION")
		gadgetHandler:RemoveGadget()
		return
	end

	local eggsuitepos = GetEggsecutiveSuitePositionForWave()
	local playerspawns = GetPlayerSpawnPositionsForWave()
	local profreshionals = WaveDefs.EggsecutiveSlotsByWave[1]
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
	
	for i = 1, 4 do
		local pos = playerspawns[i]
		local x = pos.x
		local z = pos.z
		local y = spGetGroundHeight(x,z)
		local unitID = spCreateUnit(profreshionals[i], x, y, z, 1, teamidsforprofreshionals[1][i], false, false)
		CurrentEggsecutives[i] = unitID
	end
	
	--local unitID = GG.SpawnPregameStructure(WaveDefs.EggBasket.ID, teamID, eggsuitepos, true, false)
	--local pos = eggsuitepos
	local x = eggsuitepos.x
	local z = eggsuitepos.z
	local y = spGetGroundHeight(x,z)
	local unitID = spCreateUnit(WaveDefs.EggBasket.Active, x, y, z, 1, teamID, false, false)
	CurrentEggsecutiveSuite = unitID
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
