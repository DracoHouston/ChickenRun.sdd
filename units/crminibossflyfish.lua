return { crminibossflyfish = {
  name                = [[Flyfish]],
  description         = [[MRLS Artillery Boss Chickenid]],
  acceleration        = 1.2,
  activateWhenBuilt   = true,
  airHoverFactor      = 0,
  brakeRate           = 0.8,
  builder             = false,
  buildPic            = [[chicken_roc.png]],
  canFly              = true,
  canGuard            = true,
  canLand             = true,
  canMove             = true,
  canPatrol           = true,
  canSubmerge         = false,
  category            = [[GUNSHIP]],
  collide             = false,
  cruiseAltitude      = 150,

  customParams        = {
    outline_x = 180,
    outline_y = 180,
    outline_yoff = 17.5,
    bosschickenidrole = [[artillery]],
    powereggsondeath = 3,
      metaleggsondeath = 18,
  },

  explodeAs           = [[NOWEAPON]],
  floater             = true,
  footprintX          = 2,
  footprintZ          = 2,
  health              = 1000,
  hoverattack         = true,
  iconType            = [[heavygunship]],
  idleAutoHeal        = 20,
  idleTime            = 300,
  leaveTracks         = true,
  maneuverleashlength = [[64000]],
  maxSlope            = 36,
  metalCost           = 0,
  energyCost          = 0,
  buildTime           = 1250,
  minCloakDistance    = 250,
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP STUPIDTARGET MINE]],
  objectName          = [[chicken_roc.s3o]],
  power               = 1250,
  reclaimable         = false,
  script              = [[chicken_roc.lua]],
  selfDestructAs      = [[NOWEAPON]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:blood_spray]],
      [[custom:blood_explode]],
      [[custom:dirt]],
    },

  },
  sightDistance       = 750,
  sonarDistance       = 750,
  speed               = 90,
  turnRate            = 1350,
  workerTime          = 0,

  weapons             = {

    {
      def                = [[GOO]],
      badTargetCategory  = [[GUNSHIP]],
      mainDir            = [[0 0 1]],
      maxAngleDif        = 120,
      onlyTargetCategory = [[LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

    {
      def                = [[AEROSPORES]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP]],
    },


    {
      def                = [[AEROSPORES]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP]],
    },

  },


  weaponDefs          = {

  
    GOO          = {
      name                    = [[Blob]],
      areaOfEffect            = 96,
      burst                   = 6,
      burstrate               = 0.033,
      craterBoost             = 0,
      craterMult              = 0,
            
            customParams            = {
        light_radius = 0,
      },

      damage                  = {
        default = 100,
      },

      explosionGenerator      = [[custom:green_goo]],
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      intensity               = 0.7,
      interceptedByShieldType = 1,
      proximityPriority       = -4,
      range                   = 500,
      reloadtime              = 8,
      rgbColor                = [[0.2 0.6 0]],
      size                    = 8,
      sizeDecay               = 0,
      soundHit                = [[chickens/acid_hit]],
      soundStart              = [[chickens/acid_fire]],
      sprayAngle              = 1200,
      tolerance               = 5000,
      turret                  = true,
      weaponType              = [[Cannon]],
      waterweapon             = true,
      weaponVelocity          = 350,
    },

    AEROSPORES = {
      name                    = [[Anti-Air Spores]],
      areaOfEffect            = 24,
      avoidFriendly           = false,
      burst                   = 4,
      burstrate               = 0.2,
      canAttackGround          = false,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,
      
      customParams            = {
        light_radius = 0,
      },
      
      damage                  = {
        default = 80,
        planes  = 80,
      },

      dance                   = 60,
      explosionGenerator      = [[custom:NONE]],
      fireStarter             = 0,
      fixedlauncher           = 1,
      flightTime              = 5,
      groundbounce            = 1,
      heightmod               = 0.5,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 2,
      metalpershot            = 0,
      model                   = [[chickeneggblue.s3o]],
      range                   = 500,
      reloadtime              = 5,
      smokeTrail              = true,
      startVelocity           = 100,
      texture1                = [[]],
      texture2                = [[sporetrailblue]],
      tolerance               = 10000,
      tracks                  = true,
      turnRate                = 24000,
      turret                  = true,
      waterWeapon             = true,
      weaponAcceleration      = 100,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 500,
      wobble                  = 32000,
    },
  },

} }
