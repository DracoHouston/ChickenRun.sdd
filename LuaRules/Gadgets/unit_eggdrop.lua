--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Chicken Run - Egg Dropper",
		desc      = "Creates any metal and power eggs for Chicken Run enemies on death",
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

local EggDropDefs = VFS.Include ("LuaRules/Configs/unit_eggdrop_defs.lua")

local PowerEggFeatureID = EggDropDefs.PowerEggFeatureID
local MetalEggFeatureID = EggDropDefs.MetalEggFeatureID

local spGetUnitPosition		= Spring.GetUnitPosition
local spCreateFeature		= Spring.CreateFeature

--------------------------------------------------------------------------------
--helpers
--------------------------------------------------------------------------------

local function SpawnMetalEggs(n, x, y, z)
	for i = 1, n do
		local rx, rz = math.random(-30, 30), math.random(-30, 30)
		local eggID = spCreateFeature(MetalEggFeatureID, x+rx, y, z+rz, math.random(-32000, 32000))
	end
end

local function SpawnPowerEggs(n, x, y, z)
	for i = 1, n do
		local rx, rz = math.random(-30, 30), math.random(-30, 30)
		local eggID = spCreateFeature(PowerEggFeatureID, x+rx, y, z+rz, math.random(-32000, 32000))
	end
end

--------------------------------------------------------------------------------
--gadget interface
--------------------------------------------------------------------------------

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	local def = EggDropDefs.EggDroppersDefs[unitDefID]
	if def ~= nil then
		local x, y, z = spGetUnitPosition(unitID)
		if def.PowerEggsOnDeath ~= nil then
			SpawnPowerEggs(def.PowerEggsOnDeath, x, y, z)
		end
		if def.MetalEggsOnDeath ~= nil then
			SpawnMetalEggs(def.MetalEggsOnDeath, x, y, z)
		end
	end
end

end
