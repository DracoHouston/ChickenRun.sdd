--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Chicken Run - Egg Vacuum",
		desc      = "Does proximity pickup of eggs in Chicken Run and distributes it to Eggsecutive Suites",
		author    = "DracoHouston",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

if gadgetHandler:IsSyncedCode() then

--------------------------------------------------------------------------------
--locals
--------------------------------------------------------------------------------

local EggVacuumDefs = VFS.Include ("LuaRules/Configs/unit_eggvacuum_defs.lua")

local CurrentEggs = {}
local CurrentEggsecutives = {}
local CurrentEggsecutiveSuites = {}

local spGetUnitRulesParam	= Spring.GetUnitRulesParam
local spSetUnitRulesParam	= Spring.SetUnitRulesParam
local spGetUnitPosition		= Spring.GetUnitPosition
local spGetFeaturePosition	= Spring.GetFeaturePosition
local spGetFeatureDefID		= Spring.GetFeatureDefID
local spDestroyFeature		= Spring.DestroyFeature


--------------------------------------------------------------------------------
--helpers
--------------------------------------------------------------------------------

local function DistSq(x1, z1, x2, z2)
	return (x1 - x2)*(x1 - x2) + (z1 - z2)*(z1 - z2)
end

local function MakePos(x,y,z,id)
	return {X = x, Y = y, Z = z, ID = id }
end

local function BreakPos(t)
	return t.X, t.Y, t.Z, t.ID
end

local function TickEggs()
	local eggsecutivepositions = {}
	local metaleggpositions = {}
	local powereggpositions = {}
	local totalmetalreclaim = 0
	local powereggradiussquared = EggVacuumDefs.Constants.PowerEggRadiusSquared
	local metaleggradiussquared = EggVacuumDefs.Constants.MetalEggRadiusSquared
	local metalstoragemax = EggVacuumDefs.Constants.MetalStorage

	for k, v in pairs(CurrentEggsecutives) do
		local id = k
		local x, y, z = spGetUnitPosition(id)
		if x ~= nil and y ~= nil and z ~= nil then	
			table.insert(eggsecutivepositions, MakePos(x,y,z,id))
		end
	end
		
	local activemetaleggs = CurrentEggs[EggVacuumDefs.MetalEggFeatureID] or {}
	local activepowereggs = CurrentEggs[EggVacuumDefs.PowerEggFeatureID] or {}

	for k, v in pairs(activemetaleggs) do
		local id = k
		local x, y, z = spGetFeaturePosition(id)
		if x ~= nil and y ~= nil and z ~= nil then
			table.insert(metaleggpositions, MakePos(x,y,z,id))
		end
	end

	for k, v in pairs(activepowereggs) do
		local id = k
		local x, y, z = spGetFeaturePosition(id)
		if x ~= nil and y ~= nil and z ~= nil then
			table.insert(powereggpositions, MakePos(x,y,z,id))
		end
	end

	local reclaimperegg = EggVacuumDefs.Constants.MetalEggReclaim
	local metaleggsreclaimed = {}
	local powereggsreclaimed = {}
	
	for eggsecutivei = 1, #eggsecutivepositions do
		local eggsecutivepos = eggsecutivepositions[eggsecutivei]
		local eggsecutivex, eggsecutivey, eggsecutivez, eggsecutiveid = BreakPos(eggsecutivepos)

		for eggi = 1, #metaleggpositions do
			local eggpos = metaleggpositions[eggi]
			local eggx, eggy, eggz, eggid = BreakPos(eggpos)
			local distsquared = DistSq(eggsecutivex, eggsecutivez, eggx, eggz)
			if distsquared <= metaleggradiussquared then
				if metaleggsreclaimed[eggid] == nil then
					metaleggsreclaimed[eggid] = eggsecutiveid
					totalmetalreclaim = totalmetalreclaim + reclaimperegg
				end
			end
		end
		local haspoweregg = spGetUnitRulesParam(eggsecutiveid, "HoldingPowerEgg") or 0
		if haspoweregg == 0 then
			for eggi = 1, #powereggpositions do
				local eggpos = powereggpositions[eggi]
				local eggx, eggy, eggz, eggid = BreakPos(eggpos)
				local distsquared = DistSq(eggsecutivex, eggsecutivez, eggx, eggz)
				if distsquared <= powereggradiussquared then
					if powereggsreclaimed[eggid] == nil then
						powereggsreclaimed[eggid] = eggsecutiveid
						spSetUnitRulesParam(eggsecutiveid, "HoldingPowerEgg", 1)
						break
					end
				end
			end
		end
	end

	for k, v in pairs(metaleggsreclaimed) do
		spDestroyFeature(k)	
	end

	for k, v in pairs(powereggsreclaimed) do
		spDestroyFeature(k)
	end

	if totalmetalreclaim > 0 then
		for k, v in pairs(CurrentEggsecutiveSuites) do
			local suitemetal = spGetUnitRulesParam(k, "SuiteMetal") or 0
			if suitemetal < metalstoragemax then
				local newmetal = suitemetal + totalmetalreclaim
				if newmetal > metalstoragemax then
					newmetal = metalstoragemax
				end
				spSetUnitRulesParam(k, "SuiteMetal", newmetal)
			end
		end
	end
end

--------------------------------------------------------------------------------
--gadget interface
--------------------------------------------------------------------------------

function gadget:FeatureCreated(featureID)
	local featuredef = spGetFeatureDefID(featureID)
	--Spring.Echo("feature made")
	if (featuredef == EggVacuumDefs.MetalEggFeatureID) or (featuredef == EggVacuumDefs.PowerEggFeatureID) then
		--Spring.Echo("its an egg")
		CurrentEggs[featuredef] = CurrentEggs[featuredef] or {}
		CurrentEggs[featuredef][featureID] = true
	end
end

function gadget:FeatureDestroyed(featureID)
	local featuredef = spGetFeatureDefID(featureID)
	if (featuredef == EggVacuumDefs.MetalEggFeatureID) or (featuredef == EggVacuumDefs.PowerEggFeatureID) then
		local theseeggs = CurrentEggs[featuredef]
		if theseeggs ~= nil then
			if theseeggs[featureID] ~= nil then
				theseeggs[featureID] = nil
			end
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if EggVacuumDefs.IsEggsecutive[unitDefID] then
		CurrentEggsecutives[unitID] = true
	elseif EggVacuumDefs.IsEggsecutiveSuite[unitDefID] then
		CurrentEggsecutiveSuites[unitID] = true
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if EggVacuumDefs.IsEggsecutive[unitDefID] then
		CurrentEggsecutives[unitID] = nil
	elseif EggVacuumDefs.IsEggsecutiveSuite[unitDefID] then
		CurrentEggsecutiveSuites[unitID] = nil
	end
end

function gadget:GameFrame(n)
	if n % 10 == 0 then
		TickEggs()
	end
end

end
