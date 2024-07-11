return { profreshionalshooter = {
  name                = [[Splattershot]],
  description         = [[SMG Profreshional]],
  acceleration        = 0.75,
  activateWhenBuilt   = true,
  autoHeal            = 100,
  brakeRate           = 2.7,
  --buildDistance       = 128,
  builder            = false,

 -- buildoptions        = {
 -- },

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
    eggsecutivesuite   = [[eggsecutivesuite_splattershot]],
    canjump            = 1,
    jump_range         = 400,
    jump_speed         = 8,
    jump_reload        = 1,
    jump_from_midair   = 1,
    statsname = [[profreshshooter]],
    soundok = [[heavy_bot_move]],
    soundselect = [[bot_select]],
    soundok_vol = [[0.58]],
    soundselect_vol = [[0.5]],
    soundbuild = [[builder_start]],
    aimposoffset   = [[0 10 0]],
  },

  --energyMake          = 6,
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
  --metalMake           = 4,
  metalStorage        = 0,
  movementClass       = [[AKBOT2]],
  noChaseCategory     = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET]],
  objectName          = [[commrecon.s3o]],
  script              = [[commrecon.lua]],
  selfDestructAs      = [[ESTOR_BUILDINGEX]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:RAIDMUZZLE]],
      [[custom:NONE]],
      [[custom:VINDIBACK]],
      [[custom:FLASH64]],
      [[custom:WARMUZZLE]],
      [[custom:emg_shells_l]],
      [[custom:nanitebomb]],
      [[custom:EMG_HIT_HE]],
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

weapons                = {

    [5] = {
      def                = [[SPLATTERSHOT]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },
  
    [3] = {
      def                = [[NANITE_BOMB]],
      badTargetCategory  = [[FIXEDWING]],
      onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

  },

weaponDefs = {
    SPLATTERSHOT = {
        name                    = [[Splattershot]],
        accuracy                = 350,
        alphaDecay              = 0.7,
        areaOfEffect            = 96,
        burnblow                = true,
        burst                   = 3,
        burstrate               = 0.1,
        craterBoost             = 0.15,
        craterMult              = 0.3,

        customParams        = {
            reaim_time = 1, -- noticeable twitching otherwise due to huge turnrates
            light_camera_height = 1600,
            light_color = [[0.8 0.76 0.38]],
            light_radius = 150,
            force_ignore_ground = [[1]],
        },

        damage                  = {
        default = 45,
        planes  = 45,
        },

        edgeEffectiveness       = 0.5,
        explosionGenerator      = [[custom:EMG_HIT_HE]],
        firestarter             = 70,
        impulseBoost            = 0,
        impulseFactor           = 0.4,
        intensity               = 0.7,
        interceptedByShieldType = 1,
        noSelfDamage            = true,
        range                   = 600,
        reloadtime              = 0.5,
        rgbColor                = [[1 0.95 0.4]],
        separation              = 1.5,
        soundHit                = [[weapon/cannon/emg_hit]],
        soundStart              = [[weapon/heavy_emg]],
        stages                  = 10,
        turret                  = true,
        weaponType              = [[Cannon]],
        weaponVelocity          = 580,
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
