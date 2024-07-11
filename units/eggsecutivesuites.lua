-- $Id$

local EggsecutiveSuites = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local DefaultEggsecutiveSuite = {
  --name                          = [[Gunship Plate]],
    description = [[KBud Dispensor]],
  --buildDistance                 = Shared.FACTORY_PLATE_RANGE,
  --builder                       = false,
  buildingGroundDecalDecaySpeed = 30,
  buildingGroundDecalSizeX      = 8,
  buildingGroundDecalSizeY      = 8,
  buildingGroundDecalType       = [[plategunship_aoplane.dds]],

  buildPic                      = [[plategunship.png]],
  canMove                       = false,
  canPatrol                     = false,
  category                      = [[FLOAT UNARMED]],
  collide                       = false,
  collisionVolumeOffsets        = [[0 0 0]],
  collisionVolumeScales         = [[74 74 74]],
  collisionVolumeType           = [[ellipsoid]],
  selectionVolumeOffsets        = [[0 15 0]],
  selectionVolumeScales         = [[70 40 70]],
  selectionVolumeType           = [[box]],
  corpse                        = [[DEAD]],

  customParams                  = {
    iseggsecutivesuite = [[1]],
    aimposoffset       = [[0 10 0]],
    --landflystate       = [[0]],
    --factory_land_state = 0,
    --sortName           = [[3]],
    modelradius        = [[43]],
    default_spacing    = 4,
    --child_of_factory   = [[factorygunship]],
    buggeroff_offset   = 0,

    outline_x = 165,
    outline_y = 165,
    outline_yoff = 27.5,
  },

  explodeAs                     = [[FAC_PLATEEX]],
  footprintX                    = 5,
  footprintZ                    = 5,
  health                        = 1000,
  iconType                      = [[padgunship]],
  maxSlope                      = 15,
  metalCost                     = 10,
  moveState                     = 1,
  noAutoFire                    = false,
  objectName                    = [[plate_gunship.s3o]],
  script                        = [[plategunship.lua]],
  selfDestructAs                = [[FAC_PLATEEX]],
  showNanoSpray                 = false,
  sightDistance                 = 100,
  useBuildingGroundDecal        = true,
  waterline                     = 0,
  --workerTime                    = Shared.FACTORY_BUILDPOWER,
  yardMap                       = [[yoooy ooooo ooooo ooooo yoooy]],

  featureDefs                   = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 5,
      footprintZ       = 5,
      object           = [[plate_gunship_dead.s3o]],
    },


    HEAP  = {
      blocking         = false,
      footprintX       = 5,
      footprintZ       = 5,
      object           = [[debris4x4c.s3o]],
    },

  },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local type  = type
local pairs = pairs
local function CopyTable(outtable,intable)
  for i,v in pairs(intable) do
    if (type(v)=='table') then
      if (type(outtable[i])~='table') then outtable[i] = {} end
      CopyTable(outtable[i],v)
    else
      outtable[i] = v
    end
  end
end
local function MergeTable(table1,table2)
  local ret = {}
  CopyTable(ret,table2)
  CopyTable(ret,table1)
  return ret
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

EggsecutiveSuites.eggsecutivesuite_splattershot = MergeTable(DefaultEggsecutiveSuite, {
    name = [[Eggsecutive Suite (Splattershot)]],
    customParams = {    
        kbuds = [[kbudbandit kbudreaver kbuddjinn kbudminotaur]],
    },
})

EggsecutiveSuites.eggsecutivesuite_blaster = MergeTable(DefaultEggsecutiveSuite, {
    name = [[Eggsecutive Suite (Blaster)]],
    customParams = {    
        kbuds = [[kbudpyro kbudoutlaw kbudronin kbudplaceholder]],
    },
})

EggsecutiveSuites.eggsecutivesuite_undercoverbrella = MergeTable(DefaultEggsecutiveSuite, {
    name = [[Eggsecutive Suite (Undercover Brella)]],
    customParams = {    
        kbuds = [[kbudthug kbudscallop kbudbuoy kbudaspis]],
    },
})

EggsecutiveSuites.eggsecutivesuite_heavysplatling = MergeTable(DefaultEggsecutiveSuite, {
    name = [[Eggsecutive Suite (Heavy Splatling)]],
    customParams = {    
        kbuds = [[kbudknight kbudlance kbudiris kbudphantom]],
    },
})

return lowerkeys( EggsecutiveSuites )

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
