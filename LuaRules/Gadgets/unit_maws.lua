--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Chicken Run - Maws",
		desc      = "Handles decision making for the Maws boss chickenid and performing their actions",
		author    = "DracoHouston",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

if gadgetHandler:IsSyncedCode() then

local MawsDefs = VFS.Include("LuaRules/Configs/unit_maws_defs.lua")

local ActiveMovingMaws = {}
local ActiveBitingMaws = {}
local ActiveEggsecutives = {}

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


local function DistSq(x1, z1, x2, z2)
	return (x1 - x2)*(x1 - x2) + (z1 - z2)*(z1 - z2)
end

local function GetMawsTarget(x, y, z)
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
	if MawsDefs.IsEggsecutive[unitDefID] then
		ActiveEggsecutives[unitID] = true
	elseif unitDefID == MawsDefs.MovingID then	
		GG.SetUnitInvincible(unitID, true)
		local x,y,z = spGetUnitPosition(unitID)
		local targeteggsecutive = GetMawsTarget(x, y, z)
		ActiveMovingMaws[unitID] = {
			CurrentBiting = nil,
			CurrentTarget = targeteggsecutive,
			TimeToBite = nil,
		}
	elseif unitDefID == MawsDefs.BitingID then
		ActiveBitingMaws[unitID] = {
			BurrowTime = spGetGameFrame() + MawsDefs.Constants.BiteTime
		}
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if MawsDefs.IsEggsecutive[unitDefID] then
		ActiveEggsecutives[unitID] = nil
	elseif unitDefID == MawsDefs.MovingID then	
		ActiveMovingMaws[unitID] = nil
	elseif unitDefID == MawsDefs.BitingID then
		for k, v in pairs(ActiveMovingMaws) do
			if v.CurrentBiting ~= nil then
				if v.CurrentBiting == unitID then
					spDestroyUnit(k, false, false)
					v.CurrentBiting = nil
					break
				end
			end
		end
		ActiveBitingMaws[unitID] = nil
	end
end

function gadget:GameFrame(n)
	local invalidmaws = {}
	local biteradius = MawsDefs.Constants.BiteRadius
	local halfbiteradius = biteradius / 2
	local winduptime = MawsDefs.Constants.WindUpTime
	for k, v in pairs(ActiveMovingMaws) do
		if spValidUnitID(k) then
			local mawsteam = spGetUnitTeam(k)
			local mawsAllyTeam = spGetUnitAllyTeam(k)
			local mx,my,mz = spGetUnitPosition(k)

			if (v.CurrentTarget == nil) or (not spValidUnitID(v.CurrentTarget)) then
				local newtarget = GetMawsTarget(mx, my, mz)
				v.CurrentTarget = newtarget
			end

			if spValidUnitID(v.CurrentTarget) then
				local tx,ty,tz = spGetUnitPosition(v.CurrentTarget)
				local distsquared = DistSq(mx, mz, tx, tz)

				if v.TimeToBite == nil then
					spClearUnitGoal(k)
					if distsquared <= MawsDefs.Constants.DistanceThresholdSquared then
						v.TimeToBite = n + winduptime
						--spSetUnitMoveGoal(k, mx, my, mz, 0)
						
					else
						--spClearUnitGoal(k)
						spSetUnitMoveGoal(k, tx, ty, tz, 0)
					end
				else
					if n >= v.TimeToBite then
						v.TimeToBite = nil
						v.CurrentBiting = spCreateUnit(MawsDefs.BitingID, mx,my,mz, 1, mawsteam, false, false)
						local units = spGetUnitsInCylinder(mx, mz, biteradius)
						for i=1,#units do
							local unitID = units[i]
							local unitAllyTeam = spGetUnitAllyTeam(unitID)
							if unitAllyTeam ~= mawsAllyTeam then
								spAddUnitDamageByTeam(unitID, 9999, 0, v.CurrentBiting, -1, mawsteam)
							end
						end
						
						local projectiles = spGetProjectilesInRectangle(mx-halfbiteradius,mz-halfbiteradius,mx+halfbiteradius,mz+halfbiteradius)
						for i=1,#projectiles do
							local projID = projectiles[i]
							local projAllyTeam = spGetProjectileAllyTeamID(projID)
							local projdef = spGetProjectileDefID(projID)
							local projteam = spGetProjectileTeamID(projID)
							local projowner = spGetProjectileOwnerID(projID)
							if (projAllyTeam ~= mawsAllyTeam) and MawsDefs.IsEggsecutiveBomb[projdef] then
								--kill maws here
								--spDestroyUnit(k, false, false, projowner)
								--spDestroyUnit(v.CurrentBiting, false, false, projowner)
								spAddUnitDamageByTeam(v.CurrentBiting, 9999, 0, projowner, -1, projteam)
							end
						end
					end
				end
			end
		else
			table.insert(invalidmaws, k)
		end
	end
	for i, v in ipairs(invalidmaws) do
		ActiveMovingMaws[v] = nil
	end
	for k, v in pairs(ActiveBitingMaws) do
		if spValidUnitID(k) then
			if v.BurrowTime <= n then
				for mk, mv in pairs(ActiveMovingMaws) do
					if mv.CurrentBiting ~= nil then
						if mv.CurrentBiting == k then
							mv.CurrentBiting = nil
							break
						end
					end
				end
				spDestroyUnit(k, false, true, k, true)
			end
		end
	end
end

end