return { chickenfry = {
  name                  = [[Chicken Fry]],
  description           = [[Light Swarm Chicken]],
  acceleration          = 18,
  activateWhenBuilt     = true,
  brakeRate             = 1.23,
  builder               = false,
  buildPic              = [[chicken_dodo.png]],
  canGuard              = true,
  canMove               = true,
  canPatrol             = true,
  category              = [[LAND SINK]],

  customParams          = {
      lesserchickenidrole = [[small]],
      metaleggsondeath = 3,
  },

  explodeAs             = [[DODO_DEATH]],
  footprintX            = 2,
  footprintZ            = 2,
  health                = 200,
  iconType              = [[chickendodo]],
  idleAutoHeal          = 20,
  idleTime              = 300,
  kamikaze              = true,
  kamikazeDistance      = 80,
  leaveTracks           = true,
  maxSlope              = 36,
  metalCost             = 0,
  energyCost            = 0,
  buildTime             = 170,
  movementClass         = [[AKBOT2]],
  movestate             = 2,
  noAutoFire            = false,
  noChaseCategory       = [[SHIP SWIM FLOAT FIXEDWING SATELLITE GUNSHIP]],
  objectName            = [[chicken_dodo.s3o]],
  onoffable             = true,
  power                 = 170,
  reclaimable           = false,
  selfDestructAs        = [[DODO_DEATH]],
  selfDestructCountdown = 0,

  sfxtypes              = {

    explosiongenerators = {
      [[custom:blood_spray]],
      [[custom:green_goo]],
      [[custom:dirt]],
    },

  },
  script                = "chicken_dodo.lua",
  sightDistance         = 256,
  sonarDistance         = 256,
  speed                 = 210,
  trackOffset           = 1,
  trackStrength         = 6,
  trackStretch          = 1,
  trackType             = [[ChickenTrack]],
  trackWidth            = 10,
  turnRate              = 2400,
  upright               = false,
  waterline             = 4,
  workerTime            = 0,

    weaponDefs = {
        DODO_DEATH = {
            name = "Extinction",
            areaofeffect = 300,
            craterboost =  1,
            cratermult = 3.5,
            edgeeffectiveness = 0.4,
            impulseboost = 0,
            impulsefactor = 0.4,
            explosiongenerator = [[custom:large_green_goo]],
            soundhit = [[explosion/mini_nuke]],

            damage = {
                default = 500,
                chicken = 50,
            },
        },
    },
} }
