Config = {}

Config.TextUI = "arp_ui" -- Options: "qb-core", "ox_lib", "cd_drawtextui", "arp_ui"

Config.WaitTime = 2000 -- Time in milliseconds for the teleportation to complete
Config.DefaultRadius = 1.0

Config.Elevators = {
    -- LSPDPDMainElevator = {    
    --     ExampleBuilding = {
    --         {
    --             coords = vector3(100.0, 200.0, 30.0), heading = 90.0, level = "Floor 1", label = "Lobby",
    --             jobs = {
    --                 ["police"] = 0, -- Minimum grade 0 for police job
    --                 ["ambulance"] = 1, -- Minimum grade 1 for ambulance job
    --             },
    --             items = {"elevator_key", "access_card"}, -- Requires at least one of these items
    --             citizenIDs = {"ABC12345", "DEF67890"}, -- List of allowed Citizen IDs
    --             jobAndItem = false, -- Either a valid job OR one of the items is sufficient for access
    --         },
    --         {
    --             coords = vector3(110.0, 210.0, 40.0), heading = 180.0, level = "Floor 2", label = "Office Floor",
    --             jobs = {
    --                 ["police"] = 2, -- Minimum grade 2 for police job
    --             },
    --             items = {"office_key"}, -- Requires at least one of these items
    --             citizenIDs = {"XYZ98765"}, -- List of allowed Citizen IDs
    --             jobAndItem = true, -- Must have BOTH a valid job and one of the items to access this floor
    --         },
    --         {
    --             coords = vector3(120.0, 220.0, 50.0), heading = 270.0, level = "Floor 3", label = "Restricted Area",
    --             jobs = {
    --                 ["security"] = 3, -- Minimum grade 3 for security job
    --             },
    --             items = {"restricted_card"}, -- Requires this specific item
    --             citizenIDs = {}, -- No specific Citizen ID required for this floor
    --             jobAndItem = true, -- Must have BOTH a valid job and the item
    --         },
    --     },
    -- },
    LosSantosMedical = {
        {
            coords = vector3(90.68, -399.31, 84.4),
            heading = 160.0,
            level = "Floor 7",
            label = "Helipad",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
        {
            coords = vector3(96.86, -419.29, 39.38),
            heading = 340.0,
            level = "Floor 0",
            label = "Ground Floor",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
    },

    SandyShoresMedical1 = {
        {
            coords = vec3(610.28, 2811.37, 52.27),
            heading = 90.0,
            level = "Floor 2",
            label = "Garage Second Floor",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
        {
            coords = vec3(610.4, 2811.55, 41.94),
            heading = 90.0,
            level = "Floor 0",
            label = "Garage Ground Floor",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
    },
    SandyShoresMedical2 = {
        {
            coords = vec3(610.48, 2808.47, 52.27),
            heading = 90.0,
            level = "Floor 2",
            label = "Garage Second Floor",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
        {
            coords = vec3(610.59, 2808.6, 41.94),
            heading = 90.0,
            level = "Floor 0",
            label = "Garage Ground Floor",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
    },

    PaletoBayMedical = {
        {
            coords = vector3(90.68, -399.31, 84.4),
            heading = 160.0,
            level = "Floor 7",
            label = "Helipad",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
        {
            coords = vector3(96.86, -419.29, 39.38),
            heading = 340.0,
            level = "Floor 0",
            label = "Ground Floor",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["ambulance"] = 0,
            },
        },
    },

    FIB = {
        {
            coords = vector3(136.06, -761.71, 242.15),
            heading = 160.44,
            level = "FIB Offices",
            label = "",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["fib"] = 0,
                ["doj"] = 0,
            },
        },
        {
            coords = vector3(136.35, -769.74, 45.75),
            heading = 345.78,
            level = "FIB Lobby",
            label = "",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["fib"] = 0,
                ["doj"] = 0,
            },
        },
    },

    lppd = {
        {
            coords = vec3(-467.21, -1075.27, 25.17 ),
            heading = 1.37,
            level = "LPPD 1st Floor",
            label = "",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["fib"] = 0,
                ["doj"] = 0,
            },
        },
        {
            coords = vec3(-467.31, -1075.44, 30.05),
            heading = 356.42,
            level = "LPPD 2nd Floor",
            label = "",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["fib"] = 0,
                ["doj"] = 0,
            },
        },
        {
            coords = vec3(-457.48, -1021.63, 64.61 ),
            heading = 96.98,
            level = "LPPD Roof Access",
            label = "",
            prompt = "Use Elevator",
            jobs = {
                ["police"] = 0,
                ["fib"] = 0,
                ["doj"] = 0,
            },
        },
    },

    PDTRAINING0 = {
        {
            coords = vec3(-458.06, -1067.19, 25.33 ),
            heading = 60.74,
            level = "LSPD Training Office",
            label = "",
            prompt = "Go to Training Center",
            radius = 2.5,
            jobs = {
                ["police"] = 0,
                ["sheriff"] = 0,
                ["ambulance"] = 0,
            },
        },
        {
            coords = vec3(-2041.32, 3176.56, 32.81),
            heading = 237.2,
            level = "Training Center",
            label = "",
            prompt = "Return To MRPD",
            radius = 2.5,
            jobs = {
                ["police"] = 0,
                ["sheriff"] = 0,
                ["ambulance"] = 0,
            },
        },
    },

    Tequilala = {
        {
            coords = vec3(-565.29, 284.61, 85.38),
            heading = 0.0,
            level = "Upper Bar",
            label = "Floor 1",
            prompt = "Use Elevator",
            jobs = {
                ["tequilala"] = 0,
            },
        },
        {
            coords = vec3(-561.65, 289.81, 82.18),
            heading = 180.0,
            level = "Lower Bar",
            label = "Floor 0",
            prompt = "Use Elevator",
            jobs = {
                ["tequilala"] = 0,
            },
        },
    },

    ABC = {
        {
            coords = vec3(-141.46, -620.94, 168.82),
            heading = 275.0,
            level = "ABC Office",
            label = "Floor 21",
            prompt = "Use Elevator",
        },
        {
            coords = vec3(-117.22, -604.59, 36.28),
            heading = 250.0,
            level = "Lobby Entrance",
            label = "Floor 0",
            prompt = "Use Elevator",
        },
    },

    LSGolf = {
        {
            coords = vec3(2505.24, -304.75, 112.39),
            heading = 90.0,
            level = "Rooftop",
            label = "Floor 5",
            prompt = "Use Elevator",
        },
        {
            coords = vec3(2505.24, -304.74, 107.54),
            heading = 90.0,
            level = "Forth Floor",
            label = "Floor 4",
            prompt = "Use Elevator",
        },
        {
            coords = vec3(2505.26, -304.73, 102.69),
            heading = 90.0,
            level = "Third Floor",
            label = "Floor 3",
            prompt = "Use Elevator",
        },
        {
            coords = vec3(2505.25, -304.74, 97.84),
            heading = 90.0,
            level = "Second Floor",
            label = "Floor 2",
            prompt = "Use Elevator",
        },
        {
            coords = vec3(2505.28, -304.72, 92.99),
            heading = 9.0,
            level = "Lobby",
            label = "Floor 1",
            prompt = "Use Elevator",
        },
    },

    Heroin = {
        {
            coords = vector3(509.02, 3099.72, 41.31),
            heading = 51.25,
            level = "Exit Trailer",
            label = "",
            prompt = "Enter",
        },
        {
            coords = vector3(482.4, -2623.8, -49.06),
            heading = 176.97,
            level = "Enter Trailer",
            label = "",
            prompt = "Exit",
        },
    },

    PDtraininghouse = {
        {
            coords = vec3(-2016.53, 3214.17, 33.34),
            heading = 239.34,
            level = "Exit House",
            label = "",
            prompt = "Enter",
            jobs = {
                ["police"] = 0,
                ["sheriff"] = 0,
                ["ambulance"] = 0,
            },
        },
        {
            coords = vec3(346.48, -1013.24, -99.2),
            heading = 3.66,
            level = "Enter House",
            label = "",
            prompt = "Exit",
            jobs = {
                ["police"] = 0,
                ["sheriff"] = 0,
                ["ambulance"] = 0,
            },
        },
    },

}
