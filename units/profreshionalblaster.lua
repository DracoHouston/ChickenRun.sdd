return { profreshionalblaster = {
  name                = [[Blaster]],
  description         = [[Airburst Profreshional]],
  acceleration        = 0.75,
  activateWhenBuilt   = true,
  autoHeal            = 100,
  brakeRate           = 2.7,
 -- buildDistance       = 128,
  builder             = false,

 -- buildoptions        = {
--  },

  buildPic            = [[commrecon.png]],
  canManualFire          = true,
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  category            = [[LAND]],
  collisionVolumeOffsets = [[0 0 0]],
  collisionVolumeScales  = [[45 50 45]],
  collisionVolumeType    = [[CylY]],
  corpse              = [[DEAD]],

  customParams        = {
    manualfire_desc = [[Fire Special Weapon: Throw Nanite Bomb.]],
    isprofreshional    = 1,
    eggsecutivesuite   = [[eggsecutivesuite_blaster]],
    canjump            = 1,
    jump_range         = 400,
    jump_speed         = 8,
    jump_reload        = 1,
    jump_from_midair   = 1,
    statsname = [[profreshblaster]],
    soundok = [[heavy_bot_move]],
    soundselect = [[bot_select]],
    soundok_vol = [[0.58]],
    soundselect_vol = [[0.5]],
    soundbuild = [[builder_start]],
    aimposoffset   = [[0 10 0]],
  },

  energyMake          = 0,
  energyStorage       = 0,
  explodeAs           = [[ESTOR_BUILDINGEX]],
  footprintX          = 2,
  footprintZ          = 2,
  health              = 1650,
  iconType            = [[commander1]],
  leaveTracks         = true,
  maxSlope            = 36,
  maxWaterDepth       = 5000,
  metalCost           = 1200,
  metalMake           = 0,
  metalStorage        = 0,
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
      [[custom:sonic]],
      [[custom:nanitebomb]],
    },

  },

  showNanoSpray       = false,
  showPlayerName      = true,
  sightEmitHeight     = 40,
  sightDistance       = 500,
  sonarDistance       = 300,
  speed               = 80,
  trackOffset         = 0,
  trackStrength       = 8,
  trackStretch        = 1,
  trackType           = [[ComTrack]],
  trackWidth          = 22,
  turnRate            = 1620,
  upright             = true,
  workerTime          = 0,
  highTrajectory      = 2,

  weapons             = {
  
    [5] = {
      def                = [[PROFRESHBLASTER]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
  
    [3] = {
      def                = [[NANITE_BOMB]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

  },


  weaponDefs          = {

    PROFRESHBLASTER         = {
      name                    = [[Blaster]],
      areaOfEffect            = 256,
      avoidFeature            = true,
      avoidFriendly           = true,
      burnblow                = true,
      craterBoost             = 0,
      craterMult              = 0,

      customParams            = {
       -- force_ignore_ground = [[1]],
        lups_explodelife = 1.0,
        lups_explodespeed = 0.4,
        light_radius = 120
      },

      damage                  = {
        default = 200,
      },
      
      cegTag                  = [[sonicarcher]],
      cylinderTargeting       = 1,
      explosionGenerator      = [[custom:sonic]],
      edgeEffectiveness       = 0.5,
      fireStarter             = 150,
      impulseBoost            = 100,
      impulseFactor           = 0.5,
      interceptedByShieldType = 1,
      myGravity               = 0.01,
      noSelfDamage            = true,
      range                   = 450,
      reloadtime              = 1,
      size                    = 50,
      sizeDecay               = 0.2,
      soundStart              = [[weapon/sonicgun2]],
      soundHit                = [[weapon/sonicgun_hit]],
      soundStartVolume        = 6,
      soundHitVolume          = 10,
      stages                  = 1,
      texture1                = [[sonic_glow2]],
      texture2                = [[null]],
      texture3                = [[null]],
      rgbColor                = {0.2, 0.6, 0.8},
      turret                  = true,
      weaponType              = [[Cannon]],
      weaponVelocity          = 580,
      waterweapon             = true,
      duration                = 0.15,
    },
    NANITE_BOMB = {
        name                    = [[Grizzly Co Nanite Bomb]],
        highTrajectory          = 2,
        accuracy                = 256,
	    areaOfEffect            = 512,
	    cegTag                  = [[beamweapon_muzzle_purple]],
	    commandFire             = true,
	    craterBoost             = 0,
	    craterMult              = 0,

	    customParams            = {
		    --is_unit_weapon = 1,
		    --slot = [[3]],
		    timeslow_damagefactor = [[10]],
		    timeslow_overslow_frames = 2*30, --2 seconds before slow decays
		    muzzleEffectFire = [[custom:RAIDMUZZLE]],
		    --manualfire = 1,
		    --nofriendlyfire = "needs hax",

		    light_camera_height = 2500,
		    light_color = [[1.5 0.75 1.8]],
		    light_radius = 280,
		    reaim_time = 1,
	    },

	    damage                  = {
		    default = 210,
	    },
    
        explosionGenerator      = [[custom:nanitebomb]],
	    explosionSpeed          = 5,
	    fireStarter             = 100,
	    impulseBoost            = 0,
	    impulseFactor           = 0,
	    interceptedByShieldType = 2,
	    model                   = [[wep_b_fabby.s3o]],
	    range                   = 450,
	    reloadtime              = 25,
	    smokeTrail              = true,
        soundHit                = [[weapon/aoe_aura2]],
	    soundHitVolume          = 8,
	    soundStart              = [[weapon/cannon/cannon_fire3]],
	    --startVelocity           = 350,
	    --trajectoryHeight        = 0.3,
	    turret                  = true,
	    weaponType              = [[Cannon]],
	    weaponVelocity          = 350,
       
    },
  },


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
