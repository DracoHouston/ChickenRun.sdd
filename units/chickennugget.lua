return { chickennugget = {
  name                = [[Chicken Nugget]],
  description         = [[Medium Swarm Chicken]],
  acceleration        = 1.08,
  activateWhenBuilt   = true,
  brakeRate           = 1.23,
  builder             = false,
  buildPic            = [[chicken.png]],
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  category            = [[LAND SINK SMALL]],

  customParams        = {
      lesserchickenidrole = [[medium]],
      metaleggsondeath = 6,
    outline_x = 70,
    outline_y = 70,
    outline_yoff = 15,
  },

  explodeAs           = [[NOWEAPON]],
  footprintX          = 2,
  footprintZ          = 2,
  health              = 270,
  iconType            = [[chicken]],
  idleAutoHeal        = 20,
  idleTime            = 300,
  leaveTracks         = true,
  maxSlope            = 36,
  metalCost           = 0,
  energyCost          = 0,
  buildTime           = 25,
  movementClass       = [[AKBOT2]],
  noAutoFire          = false,
  noChaseCategory     = [[SHIP FLOAT SWIM TERRAFORM FIXEDWING SATELLITE GUNSHIP]],
  objectName          = [[chicken.s3o]],
  power               = 100,
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
  speed               = 87,
  trackOffset         = 0,
  trackStrength       = 8,
  trackStretch        = 1,
  trackType           = [[ChickenTrack]],
  trackWidth          = 18,
  turnRate            = 967,
  upright             = false,
  workerTime          = 0,

  weapons             = {

    {
      def                = [[WEAPON]],
      mainDir            = [[0 0 1]],
      maxAngleDif        = 120,
      onlyTargetCategory = [[SWIM LAND SUB SINK TURRET FLOAT SHIP HOVER FIXEDWING GUNSHIP]],
    },

  },


  weaponDefs          = {

    WEAPON = {
      name                    = [[Claws]],
      avoidFeature            = false,
      avoidFriendly           = false,
      collideFeature          = false,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 80,
        planes  = 80,
      },

      explosionGenerator      = [[custom:NONE]],
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 0,
      range                   = 80,
      reloadtime              = 1.2,
      size                    = 0,
      soundHit                = [[chickens/chickenbig2]],
      soundStart              = [[chickens/chicken]],
      targetborder            = 1,
      tolerance               = 5000,
      turret                  = true,
      waterWeapon             = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 500,
    },

  },

} }
