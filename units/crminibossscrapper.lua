return { crminibossscrapper = {
  name                = [[Scrapper]],
  description         = [[Protected Rush Boss Chickenid]],
  acceleration        = 1.08,
  activateWhenBuilt   = true,
  brakeRate           = 1.23,
  builder             = false,
  buildPic            = [[chicken_shield.png]],
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  category            = [[LAND]],

  customParams        = {
    bosschickenidrole = [[rush]],
    powereggsondeath = 3,
      metaleggsondeath = 16,
    shield_emit_height = 26,
    shield_emit_offset = 0,

    outline_x = 145,
    outline_y = 145,
    outline_yoff = 27.5,
  },

  explodeAs           = [[NOWEAPON]],
  footprintX          = 4,
  footprintZ          = 4,
  health              = 1000,
  iconType            = [[walkershield]],
  idleAutoHeal        = 20,
  idleTime            = 300,
  leaveTracks         = true,
  maxSlope            = 37,
  maxWaterDepth       = 5000,
  metalCost           = 0,
  energyCost          = 0,
  buildTime           = 1200,
  movementClass       = [[BHOVER5]],
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE GUNSHIP SUB]],
  objectName          = [[chicken_shield.s3o]],
  power               = 350,
  reclaimable         = false,
  selfDestructAs      = [[NOWEAPON]],
  script = [[chicken_shield.cob]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:blood_spray]],
      [[custom:blood_explode]],
      [[custom:dirt]],
    },

  },
  sightDistance       = 512,
  sonarDistance       = 512,
  speed               = 54,
  trackOffset         = 7,
  trackStrength       = 9,
  trackStretch        = 1,
  trackType           = [[ChickenTrack]],
  trackWidth          = 34,
  turnRate            = 967,
  upright             = false,
  waterline           = 26,
  workerTime          = 0,

  weapons             = {

    {
      def                = [[FAKE_WEAPON]],
      onlyTargetCategory = [[SWIM LAND SINK TURRET FLOAT SHIP HOVER]],
    },


    {
      def = [[SHIELD]],
    },


    {
      def                = [[AEROSPORES]],
      onlyTargetCategory = [[FIXEDWING GUNSHIP]],
    },

  },


  weaponDefs          = {

    AEROSPORES  = {
      name                    = [[Anti-Air Spores]],
      areaOfEffect            = 24,
      avoidFriendly           = false,
      burst                   = 3,
      burstrate               = 0.2,
      canAttackGround         = false,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,
      
      customParams            = {
        light_radius = 0,
      },
      
      damage                  = {
        default = 60,
        planes  = 60,
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
      model                   = [[chickeneggblue.s3o]],
      noSelfDamage            = true,
      range                   = 700,
      reloadtime              = 2.5,
      smokeTrail              = true,
      startVelocity           = 100,
      texture1                = [[]],
      texture2                = [[sporetrailblue]],
      tolerance               = 10000,
      tracks                  = true,
      turnRate                = 24000,
      turret                  = true,
      waterweapon             = true,
      weaponAcceleration      = 100,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 500,
      wobble                  = 32000,
    },


    FAKE_WEAPON = {
      name                    = [[Fake]],
      areaOfEffect            = 8,
      avoidFriendly           = false,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 0.01,
        planes  = 0.01,
      },

      explosionGenerator      = [[custom:NONE]],
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 1,
      noSelfDamage            = true,
      range                   = 420,
      reloadtime              = 10,
      size                    = 0,
      soundHit                = [[]],
      soundStart              = [[]],
      targetborder            = 1,
      tolerance               = 5000,
      turret                  = true,
      waterWeapon             = false,
      weaponType              = [[Cannon]],
      weaponVelocity          = 500,
    },


    SHIELD      = {
      name                    = [[Shield]],
      craterMult              = 0,

      damage                  = {
        default = 10,
      },

      exteriorShield          = true,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      shieldAlpha             = 0.15,
      shieldBadColor          = [[1.0 1 0.1 1]],
      shieldGoodColor         = [[0.1 1.0 0.1 1]],
      shieldInterceptType     = 3,
      shieldPower             = 750,
      shieldPowerRegen        = 75,
      shieldPowerRegenEnergy  = 0,
      shieldRadius            = 50,
      shieldRepulser          = false,
      smartShield             = true,
      visibleShield           = false,
      visibleShieldRepulse    = false,
      --texture1                = [[wakelarge]],
      --visibleShield           = true,
      --visibleShieldHitFrames  = 30,
      --visibleShieldRepulse    = false,
      weaponType              = [[Shield]],
    },

  },

} }