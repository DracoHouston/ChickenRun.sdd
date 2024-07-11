return { crminibossdrizzler = {
  name                = [[Drizzler]],
  description         = [[Acid Storm Ranged Boss Chickenid]],
  acceleration        = 1.08,
  activateWhenBuilt   = true,
  brakeRate           = 1.23,
  builder             = false,
  buildPic            = [[chickenc.png]],
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  category            = [[LAND SINK]],

  customParams        = {
    bosschickenidrole = [[ranged]],
    powereggsondeath = 3,
      metaleggsondeath = 21,
    outline_x = 130,
    outline_y = 130,
    outline_yoff = 30,
  },

  explodeAs           = [[NOWEAPON]],
  footprintX          = 3,
  footprintZ          = 3,
  health              = 1000,
  iconType            = [[chickenc]],
  idleAutoHeal        = 20,
  idleTime            = 300,
  leaveTracks         = true,
  maxSlope            = 72,
  maxWaterDepth       = 22,
  metalCost           = 0,
  energyCost          = 0,
  buildTime           = 520,
  movementClass       = [[ATKBOT3]],
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP STUPIDTARGET]],
  objectName          = [[chickenc.s3o]],
  power               = 520,
  reclaimable         = false,
  selfDestructAs      = [[NOWEAPON]],  
  script                 = [[chickenc.cob]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:blood_spray]],
      [[custom:blood_explode]],
      [[custom:dirt]],
    },

  },
  sightDistance       = 512,
  sonarDistance       = 512,
  speed               = 66,
  trackOffset         = 0.5,
  trackStrength       = 9,
  trackStretch        = 1,
  trackType           = [[ChickenTrackPointy]],
  trackWidth          = 70,
  turninplace         = 0,
  turnRate            = 967,
  upright             = false,
  workerTime          = 0,

  weapons             = {

    {
      def                = [[WEAPON]],
      mainDir            = [[0 0 1]],
      maxAngleDif        = 120,
      onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT GUNSHIP SHIP HOVER]],
    },

  },


  weaponDefs          = {

    WEAPON = {
      name                    = [[Blob]],
      areaOfEffect            = 128,
      burst                   = 4,
      burstrate               = 0.033,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 140,
      },

      explosionGenerator      = [[custom:green_goo]],
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      intensity               = 0.7,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 400,
      reloadtime              = 3,
      rgbColor                = [[0.2 0.6 0]],
      size                    = 8,
      sizeDecay               = 0,
      soundHit                = [[chickens/acid_hit]],
      soundStart              = [[chickens/acid_fire]],
      sprayAngle              = 1024,
      tolerance               = 5000,
      turret                  = true,
      weaponType              = [[Cannon]],
      waterWeapon             = true,
      weaponVelocity          = 400,
    },

  },

} }
