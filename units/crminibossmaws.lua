return { crminibossmaws = {
    name                = [[Maws]],
    description         = [[Burrowing Rush Boss Chickenid]],
    acceleration        = 1.08,
    activateWhenBuilt   = true,
    brakeRate           = 1.23,
    builder             = false,
    buildPic            = [[chickenwurm.png]],
    canMove             = true,
    category            = [[LAND]],
    --explodeAs           = [[CHICKENWURM_DEATH]],
    footprintX          = 4,
    footprintZ          = 4,
    health              = 1000,
    iconType            = [[spidergeneric]],
    idleAutoHeal        = 20,
    idleTime            = 300,
    leaveTracks         = true,
    maxSlope            = 90,
    maxWaterDepth       = 5000,
    metalCost           = 0,
    energyCost          = 0,
    buildTime           = 350,
    movementClass       = [[ATKBOT3]],
    noAutoFire          = false,
    noChaseCategory     = [[SHIP FLOAT SWIM TERRAFORM FIXEDWING GUNSHIP SATELLITE STUPIDTARGET MINE]],
    objectName          = [[tube.s3o]],
    power               = 350,
    reclaimable         = false,
    script              = [[chickend.lua]],
    --selfDestructAs      = [[CHICKENWURM_DEATH]],
    sightDistance       = 384,
    sonarDistance       = 384,
    speed               = 125,
    --stealth             = true,
    turnRate            = 967,
    upright             = false,
    workerTime          = 0,
    collide             = false,

    sfxtypes            = {
        explosiongenerators = {
            [[custom:blood_spray]],
            [[custom:blood_explode]],
            [[custom:dirt]],
        },
    },

    customParams        = {
        bosschickenidrole = [[rush]],
        ismaws   = [[moving]],

        powereggsondeath  = 3,
        metaleggsondeath  = 18,

        outline_x         = 160,
        outline_y         = 160,
        outline_yoff      = 8,
    },  

    weapons             = {
    },

    weaponDefs          = {
    },
},
crminibossmaws_biting = {
    name                = [[Maws]],
    description         = [[Burrowing Rush Boss Chickenid]],
    acceleration        = 1.08,
    activateWhenBuilt   = true,
    brakeRate           = 1.23,
    builder             = false,
    buildPic            = [[chickenwurm.png]],
    canMove             = false,
    category            = [[LAND]],
    --explodeAs           = [[CHICKENWURM_DEATH]],
    footprintX          = 4,
    footprintZ          = 4,
    health              = 1000,
    iconType            = [[spidergeneric]],
    idleAutoHeal        = 20,
    idleTime            = 300,
    leaveTracks         = true,
    maxSlope            = 90,
    maxWaterDepth       = 5000,
    metalCost           = 0,
    energyCost          = 0,
    buildTime           = 350,
    movementClass       = [[ATKBOT3]],
    noAutoFire          = false,
    noChaseCategory     = [[SHIP FLOAT SWIM TERRAFORM FIXEDWING GUNSHIP SATELLITE STUPIDTARGET MINE]],
    objectName          = [[chickenwurm.s3o]],
    power               = 350,
    reclaimable         = false,
    script              = [[chickenwurm.lua]],
    --selfDestructAs      = [[CHICKENWURM_DEATH]],
    sightDistance       = 384,
    sonarDistance       = 384,
    --speed               = 54,
    --stealth             = true,
    turnRate            = 967,
    upright             = false,
    workerTime          = 0,

    sfxtypes            = {
        explosiongenerators = {
            [[custom:blood_spray]],
            [[custom:blood_explode]],
            [[custom:dirt]],
        },
    },

    customParams        = {
        ismaws       = [[biting]],
        outline_x         = 160,
        outline_y         = 160,
        outline_yoff      = 8,
    },  

    weapons             = {
    },

    weaponDefs          = {
    },
},
}
