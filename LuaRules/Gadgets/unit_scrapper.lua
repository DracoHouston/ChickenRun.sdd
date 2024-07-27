--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Chicken Run - Scrapper",
		desc      = "Handles decision making for the Scrapper boss chickenid and performing their actions",
		author    = "DracoHouston",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

if gadgetHandler:IsSyncedCode() then

local ScrapperDefs = VFS.Include("LuaRules/Configs/unit_scrapper_defs.lua")

local ActiveFrontScrappers = {}
local ActiveBackScrappers = {}
local ActiveEggsecutives = {}

local CMD_MOVE = CMD.MOVE

local spGetGameFrame				= Spring.GetGameFrame
local spGetUnitPosition				= Spring.GetUnitPosition
local spCreateUnit					= Spring.CreateUnit
local spDestroyUnit					= Spring.DestroyUnit
local spValidUnitID					= Spring.ValidUnitID
local spSetUnitMoveGoal				= Spring.SetUnitMoveGoal
local spClearUnitGoal				= Spring.ClearUnitGoal
local spGetUnitTeam					= Spring.GetUnitTeam
local spGetProjectileTeamID			= Spring.GetProjectileTeamID
local spGetUnitsInCylinder			= Spring.GetUnitsInCylinder
local spGetProjectilesInRectangle	= Spring.GetProjectilesInRectangle
local spGetUnitAllyTeam				= Spring.GetUnitAllyTeam
local spGetProjectileAllyTeamID		= Spring.GetProjectileAllyTeamID
local spAddUnitDamageByTeam			= Spring.AddUnitDamageByTeam
local spGetProjectileOwnerID		= Spring.GetProjectileOwnerID
local spGetProjectileDefID			= Spring.GetProjectileDefID
local spUnitAttach					= Spring.UnitAttach
local spGetUnitRotation				= Spring.GetUnitRotation
local spSetUnitRotation				= Spring.SetUnitRotation
local spGiveOrderToUnit 			= Spring.GiveOrderToUnit
local spUnitFinishCommand			= Spring.UnitFinishCommand

local function InvSqrt(val)
	local valsqrt = math.sqrt(val)
	if valsqrt <= 0 then
		return 0
	else
		return 1 / valsqrt
	end
end

local function NormalizeVector3(vec)
	local x = vec[1]
	local y = vec[2]
	local z = vec[3]
	local SquareSum = x * x + y * y + z * z;
	if SquareSum == 1 then
		return {x, y, z};
	elseif SquareSum < 0.00000001 then
		return {0,0,0};
	end
	local Scale = InvSqrt(SquareSum);

	return {x * Scale, y * Scale, z * Scale};
end

local function GetDir3(a, b)
	local c = {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
	return NormalizeVector3(c)
end

local function DistSq(x1, z1, x2, z2)
	return (x1 - x2)*(x1 - x2) + (z1 - z2)*(z1 - z2)
end

local function GetNearestEggsecutive(x, y, z)
	local closesteggsecutive = nil
	local closestsdistsquared = nil 
	for k, v in pairs(ActiveEggsecutives) do
		local ex,ey,ez = spGetUnitPosition(k)
		local distsquared = DistSq(x, z, ex, ez)
		if (closestsdistsquared == nil) or (distsquared < closestsdistsquared) then
			closestsdistsquared = distsquared
			closesteggsecutive = k
		end
	end
	return closesteggsecutive
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if ScrapperDefs.IsEggsecutive[unitDefID] then
		ActiveEggsecutives[unitID] = true
	elseif unitDefID == ScrapperDefs.FrontID then
		ActiveFrontScrappers[unitID] = { 
			RegenDelayTime = spGetGameFrame(),
		}
	elseif unitDefID == ScrapperDefs.BackID then
		local x,y,z = spGetUnitPosition(unitID)
		local targeteggsecutive = GetNearestEggsecutive(x, y, z)
		local frontunitid = spCreateUnit(ScrapperDefs.FrontID, x,y,z, 1, unitTeam, false, false)
		ActiveBackScrappers[unitID] = {
			CurrentTarget = targeteggsecutive,
			Mobile = true,
			Stunned = false,
			FrontUnit = frontunitid,
		}
		spUnitAttach(unitID, frontunitid, 1)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if ScrapperDefs.IsEggsecutive[unitDefID] then
		ActiveEggsecutives[unitID] = nil
	elseif unitDefID == ScrapperDefs.FrontID then	
		ActiveFrontScrappers[unitID] = nil
	elseif unitDefID == ScrapperDefs.BackID then
		ActiveBackScrappers[unitID] = nil
	end
end

function gadget:GameFrame(n)
	--for k, v in pairs(ActiveFrontScrappers) do
	--	
	--end
	for k, v in pairs(ActiveBackScrappers) do
		if spValidUnitID(k) then
			if (v.CurrentTarget ~= nil) and (spValidUnitID(v.CurrentTarget)) then
				local tx,ty,tz = spGetUnitPosition(v.CurrentTarget)
				--spClearUnitGoal(k)
				if v.Mobile == true then
					if n%30 == 0 then
						spGiveOrderToUnit(k, CMD.MOVE, {tx, ty, tz}, 0, 0)
					end
					--spSetUnitMoveGoal(k, tx, ty, tz, 0)
				elseif v.Stunned == false then
					local p, y, r = spGetUnitRotation()
					local dir = GetDir3(topos, frompos)
					local yaw = math.atan2(dir[3], dir[1])
					spSetUnitRotation(k, yaw, p, r)
				end
			else
				local x,y,z = spGetUnitPosition(k)
				v.CurrentTarget = GetNearestEggsecutive(x, y, z)
			end
		end
	end
end

end