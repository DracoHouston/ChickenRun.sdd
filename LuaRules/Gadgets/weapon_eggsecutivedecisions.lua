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

local ThrowEggCmdDesc = {
	id      = CMD_EGGTHROW,
	type    = CMDTYPE.ICON_MAP,
	name    = 'Egg Throw',
	cursor  = 'Unload', 
	action  = 'eggthrow',
	tooltip = 'Throw Egg: Toss egg, ideally towards the egg basket. Hit egg basket directly to deposit the egg from range.',
}

local ThrowBombCmdDesc = {
	id      = CMD_BOMBTHROW,
	type    = CMDTYPE.ICON_MAP,
	name    = 'Nanite Bomb',
	cursor  = 'ManualFire', 
	action  = 'bombthrow',
	tooltip = "Throw Nanite Bomb: Arms on contact, explodes after " .. NaniteBombArmTime .. " seconds. Repairs Eggsecutives, KBuds and Gushers. Damages and slows Chickenids. Edible for Maws and Mudmouth. Hazardous to Flyfish launchers.",
}

local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spGetUnitPosition = Spring.GetUnitPosition
local spSpawnProjectile = Spring.SpawnProjectile
local spSetUnitMoveGoal = Spring.SetUnitMoveGoal
local spGetUnitDefID = Spring.GetUnitDefID
local spGetProjectilePosition = Spring.GetProjectilePosition

local goalSet = {}
local EggsecutiveDecisionsDefs = VFS.Include("LuaRules/Configs/weapon_eggsecutivedecisions_defs.lua")
local EggsecutiveDefs = EggsecutiveDecisionsDefs.EggsecutiveDefs
local UniversalWeaponDefs = EggsecutiveDecisionsDefs.UniversalWeaponDefs
local BombThrowWeaponID = EggsecutiveDecisionsDefs.BombThrowWeaponID
local EggThrowWeaponID = EggsecutiveDecisionsDefs.EggThrowWeaponID
local EggCannonWeaponID = EggsecutiveDecisionsDefs.EggCannonWeaponID
local BombThrowRange = UniversalWeaponDefs[BombThrowWeaponID].Range
local BombThrowRangeSquared = BombThrowRange*BombThrowRange
local EggThrowRange = UniversalWeaponDefs[EggThrowWeaponID].Range
local EggThrowRangeSquared = EggThrowRange*EggThrowRange
local EggCannonRange = UniversalWeaponDefs[EggCannonWeaponID].Range
local EggCannonRangeSquared = EggCannonRange*EggCannonRange
local BombThrowCost = UniversalWeaponDefs[BombThrowWeaponID].EnergyCost
local EggThrowCost = UniversalWeaponDefs[EggThrowWeaponID].EnergyCost
local EggCannonCost = UniversalWeaponDefs[EggCannonWeaponID].EnergyCost
local BombThrowWhiteFrames = UniversalWeaponDefs[BombThrowWeaponID].WhiteFrames
local EggThrowWhiteFrames = UniversalWeaponDefs[EggThrowWeaponID].WhiteFrames
local EggCannonWhiteFrames = UniversalWeaponDefs[EggCannonWeaponID].WhiteFrames
local BombThrowSpeed = UniversalWeaponDefs[BombThrowWeaponID].Speed
local EggThrowSpeed = UniversalWeaponDefs[EggThrowWeaponID].Speed
local EggCannonSpeed = UniversalWeaponDefs[EggCannonWeaponID].Speed
local CurrentEggsecutives = {}

local gconstant = 120 / (30*30)

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

local function pitchyawtonormal(pitch, yaw)
	local CP, SP, CY, SY;
	SP = math.sin(pitch);
	CP = math.cos(pitch)
	SY = math.sin(yaw)
	CY = math.cos(yaw)
	return {CP * CY, SP, CP * SY };
end

local function GetDist2Sqr(a, b)
	local x, z = (a[1] - b[1]), (a[3] - b[3])
	return (x*x + z*z)
end

local function GetDist2(a, b)
	return math.sqrt(GetDist2Sqr(a, b))
end

local function GetDir2(a, b)
	local c = {a[1] - b[1], 0, a[3] - b[3]}
	return NormalizeVector3(c)
end

local function GetDir3(a, b)
	local c = {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
	return NormalizeVector3(c)
end

local function multiplyvector3(vec, num)
	return {vec[1] * num, vec[2] * num, vec[3] * num}
end

local function dotvector3(a, b) 
	return (a[1] * b[1]) + (a[2] * b[2]) + (a[3] * b[3])
end

local upvector = { 0.0, 1.0, 0.0 }

local function GetYeetVelocity(frompos, topos, velocity)
	Spring.Echo("get yeet velocity from x " .. frompos[1] .. " y " .. frompos[2] .. " z " .. frompos[3] .. "to x " .. topos[1] .. " y " .. topos[2] .. " z " .. topos[3] .. " at velocity " .. velocity)
	--local innerequation = (GetDist2(topos,frompos) * gconstant) / (velocity * velocity)
	--Spring.Echo("innerequation " .. innerequation)
	--local afterrad = math.rad(innerequation)
	--Spring.Echo("afterrad " .. afterrad)
	--local afterasin = math.asin(afterrad)
	--Spring.Echo("afterasin " .. afterasin)
	--local pitch = 0.5 * (afterasin)
	
	
	--local velocitysquared = velocity ^ 2
	--local velocitycubed = velocity ^ 4
	--local distsquared = GetDist2Sqr(topos,frompos)
	--Spring.Echo("velocitycubed " .. velocitycubed)
	--Spring.Echo("velocitysquared " .. velocitysquared)
	--local heightdiff = topos[2] - frompos[2]
	--Spring.Echo("dist " .. heightdiff)
	--local dist = math.sqrt(distsquared)
	--Spring.Echo("dist " .. dist)
	--Spring.Echo("distsquared " .. distsquared)
	--local thingy = (velocitycubed - gconstant) * ((gconstant * distsquared) + (2 * (heightdiff * velocitysquared))  )  
	--Spring.Echo("thingy " .. thingy)
	--local innerequation = (velocitysquared - math.sqrt(   thingy    )) / (gconstant * dist)
	--Spring.Echo("innerequation " .. innerequation)
	--local pitch = math.atan(math.rad(innerequation))
	local dir = GetDir3(topos, frompos)
	local safedot = dotvector3(dir, upvector)
	if safedot > 1.0 then
		safedot = 1.0
	end
	if safedot < -1.0 then
		safedot = -1.0
	end
	local pitch = math.asin(safedot)
	Spring.Echo("pitch " .. pitch)
	--local dir = GetDir2(topos, frompos)
	local yaw = math.atan2(dir[3], dir[1])-- + math.rad(180)
	Spring.Echo("yaw " .. yaw)
	local yeetvector = pitchyawtonormal(pitch, yaw)
	Spring.Echo("yeet vector x" .. yeetvector[1] .. " y " .. yeetvector[2] .. " z " .. yeetvector[3])
	local yeetvelocity = multiplyvector3(yeetvector, velocity)
	Spring.Echo("yeet velocity x" .. yeetvelocity[1] .. " y " .. yeetvelocity[2] .. " z " .. yeetvelocity[3])
	return yeetvelocity
end

local function Approach(unitID, cmdParams, range)
	spSetUnitMoveGoal(unitID, cmdParams[1],cmdParams[2],cmdParams[3], range)
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if not proID then
		return
	end
	Spring.Echo("ProjectileCreated called" .. proID)
end

function gadget:ProjectileDestroyed(proID, proOwnerID)
	if not proID then
		return
	end
	
	local x, y, z = spGetProjectilePosition(proID)
	
	local eggID = Spring.CreateFeature("chickenrunpoweregg", x, y, z, math.random(-32000, 32000))
	Spring.Echo("ProjectileDestroyed called" .. proID)
end

function gadget:AllowCommand_GetWantedCommand()
	return {[CMD_EGGTHROW] = true, [CMD_BOMBTHROW] = true}
end

function gadget:AllowCommand_GetWantedUnitDefID()
	return true
end

function gadget:AllowCommand(unitID, unitDefID, teamID,cmdID, cmdParams, cmdOptions)
	if cmdID == CMD.INSERT and cmdParams[2] == CMD_JUMP then
		return gadget:AllowCommand(unitID, unitDefID, teamID, CMD_JUMP, {cmdParams[4], cmdParams[5], cmdParams[6]}, cmdParams[3])
	end
	local eggsecutives = EggsecutiveDefs
	if not eggsecutives[unitDefID] then
		if cmdID == CMD_EGGTHROW or cmdID == CMD_BOMBTHROW then
			return false
		end
		return true
	end
		
	if (cmdID == CMD_EGGTHROW or cmdID == CMD_BOMBTHROW) and cmdParams[3] then
		return true
	end
	if goalSet[unitID] then
		goalSet[unitID] = nil
	end
	return true -- allowed
end

function gadget:CommandFallback(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions) -- Only calls for custom commands
	--Spring.Echo("eggy cmd fallback")
	local eggsecutivedef = EggsecutiveDefs[unitDefID]
	if eggsecutivedef == nil then	
		--Spring.Echo("not eggy unit")
		return false
	end

	if (cmdID ~= CMD_EGGTHROW) and (cmdID ~= CMD_BOMBTHROW) then
		--Spring.Echo("not eggy order. cmd is " .. cmdID .. " vs eggthrow " .. CMD_EGGTHROW .. " or bombthrow " .. CMD_BOMBTHROW)	
		return false
	end

	if (not Spring.ValidUnitID(unitID)) or (not cmdParams[3]) then
		--Spring.Echo("eggy unit and order that isnt positional OR unit is dead")
		return true, true
	end
	
	local _,_,_,x, y, z = spGetUnitPosition(unitID, true)
	local distSqr = GetDist2Sqr({x, y, z}, cmdParams)
	local rangesquared = 0
	local cost = 0
	local whiteframes = 0
	local currentenergy = spGetUnitRulesParam(unitID, "EggsecutiveEnergy")
	local weapontouse = nil
	local muzzlevelocity = 0
	local projectileParams = {}
	projectileParams.pos = {x, y, z}
	projectileParams.owner = unitID
	projectileParams.team = teamID
	projectileParams.gravity = -gconstant
	if cmdID == CMD_EGGTHROW then
		--Spring.Echo("its egg throw")
		rangesquared = EggThrowRangeSquared
		cost = EggThrowCost
		whiteframes = EggThrowWhiteFrames
		weapontouse = EggThrowWeaponID
		muzzlevelocity = EggThrowSpeed
	elseif cmdID == CMD_BOMBTHROW then
		--Spring.Echo("its bomb throw")
		rangesquared = BombThrowRangeSquared
		cost = BombThrowCost
		whiteframes = BombThrowWhiteFrames
		weapontouse = BombThrowWeaponID
		muzzlevelocity = BombThrowSpeed
	end
	if (distSqr < rangesquared) then
	--Spring.Echo("in range")
		if (currentenergy >= cost) and spGetUnitRulesParam(unitID,"disarmed") ~= 1 then
			Spring.Echo("firing")
			--currentenergy = currentenergy - cost
			spSetUnitRulesParam(unitID, "EggsecutiveEnergy", currentenergy - cost)
			projectileParams.speed = GetYeetVelocity({x, y, z}, cmdParams, muzzlevelocity)
			--projectileParams.speed = {0,300,0}
			local projectileid = spSpawnProjectile(weapontouse, projectileParams)
			if (projectileid ~= nil) then Spring.Echo("new projectile id " .. projectileid) else Spring.Echo("new projectile id is nil!") end
			return true, true -- command was used and finished. remove it
		else
			Spring.Echo("cant afford to egg")
			return true, false -- command was used but don't remove it
		end
	else
		--Spring.Echo("not in range")
		if not goalSet[unitID] then
		--	Spring.Echo("set goal")
			Approach(unitID, cmdParams, range)
			goalSet[unitID] = true
		end
	end

	return true, false -- command was used but don't remove it
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	local eggsecutivedef = EggsecutiveDefs[unitDefID]
	if eggsecutivedef ~= nil then
		spSetUnitRulesParam(unitID, "EggsecutiveEnergy", eggsecutivedef.EnergyPool)
		spSetUnitRulesParam(unitID, "EggsecutiveEnergyPerFrame", eggsecutivedef.EnergyPerFrame)		
		spInsertUnitCmdDesc(unitID, ThrowBombCmdDesc)
		spInsertUnitCmdDesc(unitID, ThrowEggCmdDesc)
		table.insert(CurrentEggsecutives, unitID)
		return
	end
	
end

function gadget:GameFrame(n)
	for k, v in pairs(CurrentEggsecutives) do
		local defid = spGetUnitDefID(v)
		if defid ~= nil then
			local eggsecutivedef = EggsecutiveDefs[defid]
			local currentenergy = spGetUnitRulesParam(v, "EggsecutiveEnergy")
			if currentenergy < eggsecutivedef.EnergyPool then
				local newenergy = currentenergy + eggsecutivedef.EnergyPerFrame
				if newenergy > eggsecutivedef.EnergyPool then
					newenergy = eggsecutivedef.EnergyPool
				end
				spSetUnitRulesParam(v, "EggsecutiveEnergy", newenergy)
			end
		end
	end
end

function gadget:Initialize()
	Spring.SetCustomCommandDrawData(CMD_EGGTHROW, "EggThrow", {1, 1, 0, 0.7})
	Spring.AssignMouseCursor("EggThrow", "cursorunload", true, true)
	gadgetHandler:RegisterCMDID(CMD_EGGTHROW)
	for _, unitID in pairs(Spring.GetAllUnits()) do
		gadget:UnitCreated(unitID, Spring.GetUnitDefID(unitID))
	end
	for weaponDefID, _ in pairs(UniversalWeaponDefs) do
		Script.SetWatchWeapon(weaponDefID, true)
	end
end

end