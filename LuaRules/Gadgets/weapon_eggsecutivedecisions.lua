--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Chicken Run - Eggsecutive Decisions",
		desc      = "Handles nanite bombs and egg throws in chicken run, and eggsecutive energy generally.",
		author    = "DracoHouston",
		date      = "2024",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true
	}
end

if gadgetHandler:IsSyncedCode() then

local ChickenRunCMD = VFS.Include("LuaRules/Configs/chickenrun_cmds.lua")

local CMD_EGGTHROW = ChickenRunCMD.EGGTHROW
local CMD_BOMBTHROW = ChickenRunCMD.BOMBTHROW
local NaniteBombArmTime = 2
local NaniteBombArmFrames = NaniteBombArmTime * 30

local EggThrowCmdDesc = {
	id      = CMD_EGGTHROW,
	type    = CMDTYPE.ICON_MAP,
	name    = 'Egg Throw',
	cursor  = 'Unload', 
	action  = 'eggthrow',
	tooltip = 'Throw Egg: Toss egg, ideally towards the egg basket. Hit egg basket directly to deposit the egg from range.',
}

local EggThrowCmdDesc = {
	id      = CMD_BOMBTHROW,
	type    = CMDTYPE.ICON_MAP,
	name    = 'Nanite Bomb',
	cursor  = 'ManualFire', 
	action  = 'bombthrow',
	tooltip = "Throw Nanite Bomb: Arms on contact, explodes after " .. NaniteBombArmTime .. " seconds. Repairs Eggsecutives, KBuds and Gushers. Damages and slows Chickenids. Edible for Maws and Mudmouth. Hazardous to Flyfish launchers.",
}

local IsYeeting = {}
local EggsecutiveDecisionsDefs = VFS.Include("LuaRules/Configs/weapon_eggsecutivedecisions_defs.lua")
local NaniteBombWeaponID = nil
local EggThrowWeaponID = nil
local EggCannonWeaponID = nil

function gadget:AllowCommand_GetWantedCommand()
	return {[CMD_EGGTHROW] = true, [CMD_BOMBTHROW] = true}
end

function gadget:AllowCommand_GetWantedUnitDefID()
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID,cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_ATTACK and nukeDefs[unitDefID] then
		broadcastNuke(unitID, cmdParams)
	end
	return true  -- command was not used
end

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions) -- Only calls for custom commands
	local eggsecutivedef = EggsecutiveDecisionsDefs[unitDefID]
	if eggsecutivedef == nil then	
		return false
	end

	if (cmdID ~= CMD_EGGTHROW) or (cmdID ~= CMD_BOMBTHROW) then
		return false
	end

	if (not Spring.ValidUnitID(unitID)) or (not cmdParams[3]) then
		return true, true
	end
	
	local x, y, z = spGetUnitPosition(unitID)
	local distSqr = GetDist2Sqr({x, y, z}, cmdParams)
	local jumpDef = jumpDefs[unitDefID]
	local range   = jumpDef.range

	if (distSqr < (range*range)) then
		if (Spring.GetUnitRulesParam(unitID, "jumpReload") >= 1) and Spring.GetUnitRulesParam(unitID,"disarmed") ~= 1 then
			local coords = table.concat(cmdParams)
			local currFrame = spGetGameFrame()
			for allCoords, oldStuff in pairs(jumps) do
				if currFrame-oldStuff[2] > 150 then
					jumps[allCoords] = nil --empty jump table (used for randomization) after 5 second. Use case: If infinite wave of unit has same jump coordinate then jump coordinate won't get infinitely random
				end
			end
			if (not jumps[coords]) or jumpDefs[unitDefID].JumpSpreadException then
				local didJump, removeCommand = Jump(unitID, cmdParams, cmdParams)
				if not didJump then
					return true, removeCommand -- command was used
				end
				jumps[coords] = {1, currFrame} --memorize coordinate so that next unit can choose different landing site
				return true, false -- command was used but don't remove it (unit have not finish jump yet)
			else
				local r = landBoxSize*jumps[coords][1]^0.5/2
				local randpos = {
					cmdParams[1] + random(-r, r),
					cmdParams[2],
					cmdParams[3] + random(-r, r)}
				local didJump, removeCommand = Jump(unitID, randpos, cmdParams)
				if not didJump then
					return true, removeCommand -- command was used
				end
				jumps[coords][1] = jumps[coords][1] + 1
				return true, false -- command was used but don't remove it(unit have not finish jump yet)
			end
		end
	else
		if not goalSet[unitID] then
			Approach(unitID, cmdParams, range)
			goalSet[unitID] = true
		end
	end

	return true, false -- command was used but don't remove it
end

end