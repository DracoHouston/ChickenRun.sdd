local Eggsecutives = {}

--------------------------------------------------------------------------------
--helpers
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
--universal weapons
--------------------------------------------------------------------------------

local gconstant = 120 / (30*30)

local weapon_nanitebomb = {
    name                    = [[Grizzly Co Nanite Bomb]],
    highTrajectory          = 2,
    accuracy                = 256,
    areaOfEffect            = 512,
    cegTag                  = [[beamweapon_muzzle_purple]],
    commandFire             = true,
    craterBoost             = 0,
    craterMult              = 0,    
    explosionGenerator      = [[custom:nanitebomb]],
    explosionSpeed          = 5,
    fireStarter             = 100,
    impulseBoost            = 0,
    myGravity               = gconstant,
    impulseFactor           = 0,
    interceptedByShieldType = 2,
    model                   = [[wep_b_fabby.s3o]],
    range                   = 450,
    reloadtime              = 25,
    smokeTrail              = true,
    soundHit                = [[weapon/aoe_aura2]],
    soundHitVolume          = 8,
    soundStart              = [[weapon/cannon/cannon_fire3]],
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 350,    

	customParams = {
        iseggsecutivedecision       = [[bombthrow]],
        eggsecutiveenergycost       = 75,
        eggsecutivewhiteframes      = 4,
		timeslow_damagefactor       = [[10]],
		timeslow_overslow_frames    = 2*30, --2 seconds before slow decays
		muzzleEffectFire            = [[custom:RAIDMUZZLE]],

		light_camera_height         = 2500,
		light_color                 = [[1.5 0.75 1.8]],
		light_radius                = 280,
		reaim_time                  = 1,
	},

	damage = {
        default = 210,
	},   
}

local weapon_eggthrow = {
    name                    = [[Grizzly Co Egg Yeeter]],
    highTrajectory          = 2,
    accuracy                = 256,
    --areaOfEffect            = 512,
    --cegTag                  = [[beamweapon_muzzle_purple]],
    commandFire             = true,
    craterBoost             = 0,
    craterMult              = 0,    
    explosionGenerator      = [[custom:eggdunkfx_spawner]],
    explosionSpeed          = 5,
    --fireStarter             = 100,
    myGravity               = gconstant,
    impulseBoost            = 0,
    impulseFactor           = 0,
    interceptedByShieldType = 0,
    model                   = [[chickeneggblue_huge.s3o]],
    range                   = 600,
    reloadtime              = 1/30,
    smokeTrail              = true,
    soundHit                = [[weapon/eggdrop]],
    soundHitVolume          = 8,
    soundStart              = [[weapon/cannon/cannon_fire3]],
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 350,    

	customParams = {
        iseggsecutivedecision       = [[eggthrow]],
        eggsecutiveenergycost       = 75,
        eggsecutivewhiteframes      = 4,
		muzzleEffectFire            = [[custom:RAIDMUZZLE]],
		light_camera_height         = 2500,
		light_color                 = [[1.5 0.75 1.8]],
		light_radius                = 280,
		reaim_time                  = 1,
	},

	damage = {
        default = 0,
	},   
}

local weapon_eggcannon = {
    name                    = [[Grizzly Co Egg Cannon]],
    highTrajectory          = 2,
    accuracy                = 256,
    areaOfEffect            = 256,
    myGravity               = gconstant,
    --cegTag                  = [[beamweapon_muzzle_purple]],
    commandFire             = true,
    craterBoost             = 0,
    craterMult              = 0,    
    explosionGenerator      = [[custom:eggdunkfx_spawner]],
    explosionSpeed          = 5,
    --fireStarter             = 100,
    impulseBoost            = 0,
    impulseFactor           = 0,
    interceptedByShieldType = 0,
    model                   = [[chickeneggblue_huge.s3o]],
    range                   = 600,
    reloadtime              = 1/30,
    smokeTrail              = true,
    soundHit                = [[weapon/eggdrop]],
    soundHitVolume          = 8,
    soundStart              = [[weapon/cannon/cannon_fire3]],
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 500,    

	customParams = {
        iseggsecutivedecision       = [[eggcannon]],
        eggsecutiveenergycost       = 0,
        eggsecutivewhiteframes      = 0,
		muzzleEffectFire            = [[custom:RAIDMUZZLE]],
		light_camera_height         = 2500,
		light_color                 = [[1.5 0.75 1.8]],
		light_radius                = 280,
		reaim_time                  = 1,
	},

	damage = {
        default = 1000,
	},   
}

--------------------------------------------------------------------------------
--main weapons
--------------------------------------------------------------------------------

local weapon_splattershot = {
    name                    = [[Splattershot]],
    accuracy                = 350,
    alphaDecay              = 0.7,
    areaOfEffect            = 96,
    burnblow                = true,
    burst                   = 3,
    burstrate               = 0.1,
    craterBoost             = 0.15,
    craterMult              = 0.3,
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

    customParams = {
        reaim_time = 1, -- noticeable twitching otherwise due to huge turnrates
        light_camera_height = 1600,
        light_color = [[0.8 0.76 0.38]],
        light_radius = 150,
        force_ignore_ground = [[1]],
    },

    damage = {
        default = 45,
        planes  = 45,
    },
}

local weapon_blaster = {
    name                    = [[Blaster]],
    areaOfEffect            = 256,
    avoidFeature            = true,
    avoidFriendly           = true,
    burnblow                = true,
    craterBoost             = 0,
    craterMult              = 0,      
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

    customParams = {
        lups_explodelife    = 1.0,
        lups_explodespeed   = 0.4,
        light_radius        = 120
    },

    damage = {
        default = 200,
    },
}

local weapon_undercoverbrella = {
    name                    = [[Undercover Brella]],
    alphaDecay              = 0.3,
    areaOfEffect            = 32,
    burnBlow                = true,
    burst                   = 3,
    burstRate               = 0.033,
    coreThickness           = 0.5,
    craterBoost             = 0,
    craterMult              = 0,
    explosionGenerator      = [[custom:ARCHPLOSION]],
    fireStarter             = 50,
    heightMod               = 1,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    interceptedByShieldType = 1,
    projectiles             = 3,
    range                   = 264,
    reloadtime              = 0.8,
    separation              = 1.2,
    size                    = 2,
    sizeDecay               = 0,
    rgbColor                = [[1 1 0]],
    soundHit                = [[impacts/shotgun_impactv5]],
    soundStart              = [[weapon/shotgun_firev4]],
    soundStartVolume        = 0.5,
    soundTrigger            = true,
    sprayangle              = 1500,
    stages                  = 20,
    tolerance               = 10000,
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 880,

    customParams = {
        light_camera_height = 2000,
        light_color         = [[0.3 0.3 0.05]],
        light_radius        = 50,
    },

    damage = {
        default = 23,
    },
}

local weapon_heavysplatling = {
    name                    = [[Heavy Splatling]],
    accuracy                = 2300,
    alphaDecay              = 0.7,
    areaOfEffect            = 96,
    avoidFeature            = false,
    burnblow                = true,
    craterBoost             = 0.15,
    craterMult              = 0.3,
    edgeEffectiveness       = 0.5,
    explosionGenerator      = [[custom:EMG_HIT_HE]],
    firestarter             = 70,
    impulseBoost            = 0,
    impulseFactor           = 0.4,
    intensity               = 0.7,
    interceptedByShieldType = 1,
    noSelfDamage            = true,
    range                   = 410,
    reloadtime              = 0.1,
    rgbColor                = [[1 0.95 0.4]],
    separation              = 1.5,
    soundHit                = [[weapon/cannon/emg_hit]],
    soundStart              = [[weapon/heavy_emg]],
    soundStartVolume        = 0.5,
    stages                  = 10,
    turret                  = true,
    weaponType              = [[Cannon]],
    weaponVelocity          = 550,

    customparams = {
        light_color         = [[0.8 0.76 0.38]],
        light_radius        = 180,
        proximity_priority  = 5, -- Don't use this unless required as it causes O(N^2) seperation checks per slow update.
    },

    damage = {
        default = 45,
    },
}

--------------------------------------------------------------------------------
--defaults
--------------------------------------------------------------------------------

local EggsecutiveDefault = {
    acceleration            = 0.75,
    activateWhenBuilt       = true,
    autoHeal                = 100,
    brakeRate               = 2.7,
    builder                 = false,    
    buildPic                = [[commrecon.png]],
    --canManualFire           = true,
    canGuard                = true,
    canMove                 = true,
    canPatrol               = true,
    category                = [[LAND]],
    collisionVolumeOffsets  = [[0 0 0]],
    collisionVolumeScales   = [[45 50 45]],
    collisionVolumeType     = [[CylY]],
    corpse                  = [[DEAD]],
    energyStorage           = 0,
    explodeAs               = [[ESTOR_BUILDINGEX]],
    footprintX              = 2,
    footprintZ              = 2,
    health                  = 1650,
    iconType                = [[commander1]],
    leaveTracks             = true,
    maxSlope                = 36,
    maxWaterDepth           = 5000,
    metalCost               = 1200,
    metalStorage            = 0,
    movementClass           = [[AKBOT2]],
    noChaseCategory         = [[TERRAFORM SATELLITE FIXEDWING GUNSHIP HOVER SHIP SWIM SUB LAND FLOAT SINK TURRET]],
    objectName              = [[commrecon.s3o]],
    script                  = [[commrecon.lua]],
    selfDestructAs          = [[ESTOR_BUILDINGEX]],   
    showNanoSpray           = false,
    showPlayerName          = true,
    sightEmitHeight         = 40,
    sightDistance           = 500,
    sonarDistance           = 300,
    trackOffset             = 0,
    trackStrength           = 8,
    trackStretch            = 1,
    trackType               = [[ComTrack]],
    trackWidth              = 22,
    turnRate                = 1620,
    upright                 = true,
    workerTime              = 0,
    highTrajectory          = 2,     

    sfxtypes = {
        explosiongenerators = {
            [[custom:NONE]],
            [[custom:NONE]],
            [[custom:RAIDMUZZLE]],
            [[custom:NONE]],
            [[custom:VINDIBACK]],
            [[custom:FLASH64]],
        },
    },    

    customParams = {
        --manualfire_desc             = [[Fire Special Weapon: Throw Nanite Bomb.]],
        iseggsecutive               = 1,
        eggsecutiveenergypool       = 100,
        eggsecutiveenergyperframe   = 2, --50 frames to regen from empty to full or 1.66~ seconds
        canjump                     = 1,
        jump_range                  = 400,
        jump_speed                  = 8,
        jump_reload                 = 1,
        jump_from_midair            = 1,
        soundok                     = [[heavy_bot_move]],
        soundselect                 = [[bot_select]],
        soundok_vol                 = [[0.58]],
        soundselect_vol             = [[0.5]],
        soundbuild                  = [[builder_start]],
        aimposoffset                = [[0 10 0]],
    },    

    weapons = {  
        --[3] = {
        --    def                = [[NANITE_BOMB]],
        --    badTargetCategory  = [[FIXEDWING]],
        --    onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
        --},
    },

    weaponDefs = {
        NANITE_BOMB = weapon_nanitebomb,
        EGG_THROW = weapon_eggthrow,
        EGG_CANNON = weapon_eggcannon,
    },
    featureDefs = {
        DEAD = {
            blocking    = true,
            featureDead = [[HEAP]],
            footprintX  = 2,
            footprintZ  = 2,
            object      = [[commrecon_dead.s3o]],
        },

        HEAP = {
            blocking    = false,
            footprintX  = 2,
            footprintZ  = 2,
            object      = [[debris2x2c.s3o]],
        },
    },
}

--------------------------------------------------------------------------------
--weight classes
--------------------------------------------------------------------------------

local EggsecutiveLight = MergeTable(EggsecutiveDefault, {
    speed = 110,
})

local EggsecutiveMid = MergeTable(EggsecutiveDefault, {
    speed = 90,
})

local EggsecutiveHeavy = MergeTable(EggsecutiveDefault, {
    speed = 70,
})

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Eggsecutives.eggsecutive_splattershot = MergeTable(EggsecutiveLight, {
    name        = [[Splattershot]],
    description = [[SMG Eggsecutive]],

    customParams = {    
        eggsecutivesuite = [[eggsecutivesuite_splattershot]],
    },

    weapons = {
        [5] = {
            def                = [[EGGSECUTIVE_SPLATTERSHOT]],
            badTargetCategory  = [[FIXEDWING]],
            onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
        },
    },

    weaponDefs = {
        EGGSECUTIVE_SPLATTERSHOT = weapon_splattershot,
    },
})

Eggsecutives.eggsecutive_blaster = MergeTable(EggsecutiveMid, {
    name        = [[Blaster]],
    description = [[Sonic Airburst Eggsecutive]], 

    customParams = {    
        eggsecutivesuite = [[eggsecutivesuite_blaster]],
    },

    weapons = {
        [5] = {
            def                = [[EGGSECUTIVE_BLASTER]],
            badTargetCategory  = [[FIXEDWING]],
            onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
        },
    },

    weaponDefs = {
        EGGSECUTIVE_BLASTER = weapon_blaster,
    },
})

Eggsecutives.eggsecutive_undercoverbrella = MergeTable(EggsecutiveLight, {
    name        = [[Undercover Brella]],
    description = [[Autofire Scattershot Eggsecutive]],

    customParams = {    
        eggsecutivesuite = [[eggsecutivesuite_undercoverbrella]],
    },

    weapons = {
        [5] = {
            def                = [[EGGSECUTIVE_UNDERCOVERBRELLA]],
            badTargetCategory  = [[FIXEDWING]],
            onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
        },
    },

    weaponDefs = {
        EGGSECUTIVE_UNDERCOVERBRELLA = weapon_undercoverbrella,
    },
})

Eggsecutives.eggsecutive_heavysplatling = MergeTable(EggsecutiveHeavy, {
    name        = [[Heavy Splatling]],
    description = [[HMG Eggsecutive]],
    customParams = {    
        eggsecutivesuite = [[eggsecutivesuite_heavysplatling]],
        --todo: make an eggsecutive LUS with heat support based on commrecon one
        --heat_per_shot  = 0.035, -- Heat is always a number between 0 and 1
        --heat_decay     = 1/6, -- Per second
        --heat_max_slow  = 0.5,
        --heat_initial   = 0,
    },

    weapons = {
        [5] = {
            def                = [[EGGSECUTIVE_HEAVYSPLATLING]],
            badTargetCategory  = [[FIXEDWING]],
            onlyTargetCategory = [[FIXEDWING LAND SINK TURRET SHIP SWIM FLOAT GUNSHIP HOVER]],
        },
    },

    weaponDefs = {
        EGGSECUTIVE_HEAVYSPLATLING = weapon_heavysplatling,
    },
})

return Eggsecutives

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
