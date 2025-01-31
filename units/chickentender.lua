return { chickentender = {
  name                = [[Chicken Tender]],
  description         = [[Heavy Swarm Chicken]],
  acceleration        = 1.08,
  activateWhenBuilt   = true,
  brakeRate           = 1.23,
  builder             = false,
  buildPic            = [[chickena.png]],
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  category            = [[LAND SINK]],

  customParams        = {
      lesserchickenidrole = [[large]],
      metaleggsondeath = 13,
    outline_x = 235,
    outline_y = 235,
    outline_yoff = 25,
  },

  explodeAs           = [[NOWEAPON]],
  footprintX          = 4,
  footprintZ          = 4,
  health              = 2800,
  iconType            = [[chickena]],
  idleAutoHeal        = 20,
  idleTime            = 300,
  leaveTracks         = true,
  maxSlope            = 37,
  maxWaterDepth       = 5000,
  metalCost           = 0,
  energyCost          = 0,
  buildTime           = 350,
  movementClass       = [[AKBOT4]],
  noAutoFire          = false,
  noChaseCategory     = [[SHIP SWIM FLOAT TERRAFORM FIXEDWING SATELLITE GUNSHIP MINE]],
  objectName          = [[chickena.s3o]],
  power               = 420,
  reclaimable         = false,
  selfDestructAs      = [[NOWEAPON]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:blood_spray]],
      [[custom:blood_explode]],
      [[custom:dirt]],
    },

  },
  sightDistance       = 256,
  sonarDistance       = 256,
  speed               = 54,
  trackOffset         = 7,
  trackStrength       = 9,
  trackStretch        = 1,
  trackType           = [[ChickenTrack]],
  trackWidth          = 34,
  turnRate            = 967,
  upright             = false,
  workerTime          = 0,

  weapons             = {

    {
      def                = [[WEAPON]],
      mainDir            = [[0 0 1]],
      maxAngleDif        = 120,
      onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER SUB SHIP FIXEDWING GUNSHIP]],
    },

  },


  weaponDefs          = {
    WEAPON     = {
      name                    = [[Claws]],
      areaOfEffect            = 8,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 1700.1,
      },

      explosionGenerator      = [[custom:NONE]],
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 0,
      noSelfDamage            = true,
      range                   = 140,
      reloadtime              = 7,
      size                    = 0,
      soundHit                = [[chickens/chickenbig2]],
      soundStart              = [[chickens/chickenbig2]],
      targetborder            = 1,
      tolerance               = 5000,
      turret                  = true,
      waterWeapon             = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 1000,
    },

  },

} }
