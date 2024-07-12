return { unhandledeggception = {
  name                = [[Unhandled Eggception]],
  description         = [[Help Them!]],
  acceleration        = 0.75,
  activateWhenBuilt   = true,
  --autoHeal            = 5,
  brakeRate           = 2.7,
  --buildDistance       = 128,
  --builder             = true,

  buildoptions        = {
  },

  buildPic            = [[commrecon.png]],
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  category            = [[LAND]],
  collisionVolumeOffsets = [[0 0 0]],
  collisionVolumeScales  = [[45 50 45]],
  collisionVolumeType    = [[CylY]],
  corpse              = [[DEAD]],

  customParams        = {
    iseggception  = 1,
    canjump            = 1,
    jump_range         = 400,
    jump_speed         = 6,
    jump_reload        = 1,
    jump_from_midair   = 1,
    --statsname = [[unprofresh]],
    soundok = [[heavy_bot_move]],
    soundselect = [[bot_select]],
    soundok_vol = [[0.58]],
    soundselect_vol = [[0.5]],
    soundbuild = [[builder_start]],
    aimposoffset   = [[0 10 0]],
  },

 -- energyMake          = 0,
 -- energyStorage       = 0,
  explodeAs           = [[ESTOR_BUILDINGEX]],
  footprintX          = 2,
  footprintZ          = 2,
  health              = 100,
  iconType            = [[commander1]],
  leaveTracks         = true,
  maxSlope            = 36,
  maxWaterDepth       = 5000,
  metalCost           = 1200,
 -- metalMake           = 0,
--  metalStorage        = 0,
  movementClass       = [[AKBOT2]],
  noChaseCategory     = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET]],
  objectName          = [[commrecon.s3o]],
  script              = [[commrecon.lua]],
  selfDestructAs      = [[ESTOR_BUILDINGEX]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:NONE]],
      [[custom:NONE]],
      [[custom:RAIDMUZZLE]],
      [[custom:NONE]],
      [[custom:VINDIBACK]],
      [[custom:FLASH64]],
    },

  },

  showNanoSpray       = false,
  showPlayerName      = true,
  sightEmitHeight     = 40,
  sightDistance       = 500,
  sonarDistance       = 300,
  speed               = 60,
  trackOffset         = 0,
  trackStrength       = 8,
  trackStretch        = 1,
  trackType           = [[ComTrack]],
  trackWidth          = 22,
  turnRate            = 1620,
  upright             = true,
 -- workerTime          = 10,

  --weapons             = {
  --},


  --weaponDefs          = {
--
  --},


  featureDefs         = {

    DEAD      = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[commrecon_dead.s3o]],
    },


    HEAP      = {
      blocking         = false,
      footprintX       = 2,
      footprintZ       = 2,
      object           = [[debris2x2c.s3o]],
    },

  },

} }
