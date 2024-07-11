return { crminibossfishstick = {
  name                = [[Fish Stick]],
  description         = [[Flying Hazard Ranged Boss Chickenid]],
  activateWhenBuilt   = true,
  acceleration        = 0.8,
  brakeRate           = 0.32,
  builder             = false,
  buildPic            = [[chicken_pigeon.png]],
  canFly              = true,
  canGuard            = true,
  canLand             = true,
  canMove             = true,
  canPatrol           = true,
  canSubmerge         = false,
  category            = [[FIXEDWING]],
  collide             = false,
  cruiseAltitude      = 200,

  customParams        = {
    bosschickenidrole = [[ranged]],
    powereggsondeath = 3,
      metaleggsondeath = 15,
  },

  explodeAs           = [[NOWEAPON]],
  floater             = true,
  footprintX          = 1,
  footprintZ          = 1,
  health              = 150,
  iconType            = [[scoutplane]],
  idleAutoHeal        = 20,
  idleTime            = 300,
  maxSlope            = 18,
  metalCost           = 0,
  energyCost          = 0,
  buildTime           = 50,
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM FIXEDWING SATELLITE STUPIDTARGET]],
  objectName          = [[chicken_pigeon.s3o]],
  power               = 50,
  reclaimable         = false,
  selfDestructAs      = [[NOWEAPON]],
  script              = "chicken_pigeon.lua",

  sfxtypes            = {

    explosiongenerators = {
      [[custom:blood_spray]],
      [[custom:blood_explode]],
      [[custom:dirt]],
    },

  },
  sightDistance       = 512,
  sonarDistance       = 512,
  speed               = 300,
  turnRate            = 6000,
  workerTime          = 0,

  weapons             = {

    {
      def                = [[BOGUS_BOMB]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },


    {
      def                = [[SPORES]],
      badTargetCategory  = [[SWIM LAND SHIP HOVER]],
      mainDir            = [[0 0 1]],
      maxAngleDif        = 120,
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

  },


  weaponDefs          = {

    BOGUS_BOMB = {
      name                    = [[BogusBomb]],
      areaOfEffect            = 80,
      burst                   = 1,
      burstrate               = 1,
      commandfire             = true,
      craterBoost             = 0,
      craterMult              = 0,

      customParams            = {
        bogus = 1,
      },

      damage                  = {
        default = 0,
      },

      edgeEffectiveness       = 0,
      explosionGenerator      = [[custom:NONE]],
      impulseBoost            = 0,
      impulseFactor           = 0,
      interceptedByShieldType = 1,
      model                   = [[]],
      myGravity               = 1000,
      noSelfDamage            = true,
      range                   = 10,
      reloadtime              = 2,
      weaponType              = [[AircraftBomb]],
    },


    SPORES     = {
      name                    = [[Spores]],
      areaOfEffect            = 24,
      avoidFriendly           = false,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,
      
      customParams            = {
        light_radius = 0,
      },
      
      damage                  = {
        default = 75,
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
      model                   = [[chickeneggpink.s3o]],
      range                   = 600,
      reloadtime              = 4,
      smokeTrail              = true,
      startVelocity           = 100,
      texture1                = [[]],
      texture2                = [[sporetrail]],
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
