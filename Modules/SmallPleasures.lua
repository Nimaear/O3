local addon, ns = ...
local O3 = ns.O3

local treasures = {}

O3:module({
	name = 'SmallPleasures',
	readable = 'Small Pleasures',
	config = {
		enabled = true,
		rareWarning = true,
		rareWarningMessage = "%s spotted!",
	},
	events = {
	},
    ignoreRare = {
        ['Garrison Cache'] = true,
    },
	settings = {},
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'Rare warning',
		})
		self:addOption('rareWarning', {
			type = 'Toggle',
			label = 'Enabled',
		})
		self:addOption('rareWarningMessage', {
			type = 'String',
			label = 'Warning message',
		})
		self:addOption('addTreasures', {
			type = 'Button',
			label = 'Add treasures using TomTom',
			onClick = function (option)
				self:addTreasures()
			end,
		})		
	end,
	VARIABLES_LOADED = function (self)
		if (self.settings.rareWarning) then
			self.events.VIGNETTE_ADDED = true
		end
	end,
	VIGNETTE_ADDED = function (self, vignetteInstanceId, ...)
		local x, y, name, objectIcon = C_Vignettes.GetVignetteInfoFromInstanceID(vignetteInstanceId)
		name = name or 'Rare'
        if (not self.ignoreRare[name]) then
            PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
            RaidNotice_AddMessage(RaidWarningFrame, self.settings.rareWarningMessage:format(name), ChatTypeInfo["RAID_WARNING"])
        end
	end,
	rareWarningSet = function (self)
		if (self.settings.rareWarning) then
			self:registerEvent('VIGNETTE_ADDED')
		else
			self:unregisterEvent('VIGNETTE_ADDED')
		end
	end,
	register = function (self, O3)
	end,
	makeTrackerMovable = function (self)
		ObjectiveTrackerFrame.ignoreFramePositionManager = true
		ObjectiveTrackerFrame:SetMovable(true)
		ObjectiveTrackerFrame:SetUserPlaced(false)

		local adjustSetPoint =  function (self,...)
			local a1,af,a2,x,y = ...
			if af == "MinimapCluster" and not done then    
				self:SetPoint(a1,af,a2,36,-36)
			end
		end

		hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", adjustSetPoint)
	
	end,
	postInit = function (self)
		-- self:makeTrackerMovable()
	end,
	addTreasures = function (self)
		local adder = SlashCmdList["TOMTOM_WAY"]
		TomTom.waydb:ResetProfile()
        TomTom:ReloadWaypoints()
		--adder('reset all')
		for zone, treasureList in pairs(treasures) do
			for i= 1,#treasureList do 
				local treasure = treasureList[i]
                if zone == 'Naagrand' then
                    zone = ''
                end
				if treasure.questId then
					if not IsQuestFlaggedCompleted(treasure.questId) then
						for c = 1, #treasure.coords do
							local coord = treasure.coords[c]
							local string = string.format('%s %f %f %s-%d', zone, coord[1], coord[2], treasure.name,c)
							adder(string)
						end
					end
				else
					for c = 1, #treasure.coords do
						local coord = treasure.coords[c]
						local string = string.format('%s %f %f %s-%d', zone, coord[1], coord[2], treasure.name,c)
						adder(string)
					end
				end
			end
		end
	end,
})


treasures = {
    ["Spires of Arak"]= {
        {
            coords= {
                {
                    36.8,
                    17.2
                }
            },
            level= 0,
            name= "Outcast's Belongings",
            type= 2,
            id= 234147,
            questId= "36243"
        },
        {
            coords= {
                {
                    50.4,
                    22.1
                },
                {
                    50.5,
                    22.1
                }
            },
            level= 0,
            name= "Fractured Sunstone",
            type= 2,
            id= 234157,
            questId= "36401"
        },
        {
            coords= {
                {
                    50.7,
                    28.7
                }
            },
            level= 0,
            name= "Lost Herb Satchel",
            type= 2,
            id= 234159,
            questId= "36247"
        },
        {
            coords= {
                {
                    58.7,
                    60.4
                }
            },
            level= 0,
            name= "Ogron Plunder",
            type= 2,
            id= 234432,
            questId= "36340"
        },
        {
            coords= {
                {
                    47.9,
                    30.7
                }
            },
            level= 0,
            name= "Shattered Hand Lockbox",
            type= 2,
            id= 234456,
            questId= "36361"
        },
        {
            coords= {
                {
                    56.2,
                    28.8
                }
            },
            level= 0,
            name= "Shattered Hand Cache",
            type= 2,
            id= 234458,
            questId= "36362"
        },
        {
            coords= {
                {
                    54.3,
                    32.5
                }
            },
            level= 0,
            name= "Toxicfang Venom",
            type= 2,
            id= 234461,
            questId= "36364"
        },
        {
            coords= {
                {
                    59.7,
                    81.3
                }
            },
            level= 0,
            name= "Spray-O-Matic 5000 XT",
            type= 2,
            id= 234471,
            questId= "36365"
        },
        {
            coords= {
                {
                    55.5,
                    90.8
                }
            },
            level= 0,
            name= "Campaign Contributions",
            type= 2,
            id= 234473,
            questId= "36366"
        },
        {
            coords= {
                {
                    43.9,
                    15
                }
            },
            level= 0,
            name= "Elixir of Shadow Sight",
            type= 2,
            id= 234703,
            questId= "36395"
        },
        {
            coords= {
                {
                    43.8,
                    24.7
                }
            },
            level= 0,
            name= "Elixir of Shadow Sight",
            type= 2,
            id= 234704,
            questId= "36397"
        },
        {
            coords= {
                {
                    69.2,
                    43.3
                }
            },
            level= 0,
            name= "Elixir of Shadow Sight",
            type= 2,
            id= 234705,
            questId= "36398"
        },
        {
            coords= {
                {
                    48.9,
                    62.5
                }
            },
            level= 0,
            name= "Elixir of Shadow Sight",
            type= 2,
            id= 234734,
            questId= "36399"
        },
        {
            coords= {
                {
                    55.6,
                    22.1
                }
            },
            level= 0,
            name= "Elixir of Shadow Sight",
            type= 2,
            id= 234735,
            questId= "36400"
        },
        {
            coords= {
                {
                    36.2,
                    39.3
                },
                {
                    36.3,
                    39.4
                }
            },
            level= 0,
            name= "Orcish Signaling Horn",
            type= 2,
            id= 234740,
            questId= "36402"
        },
        {
            coords= {
                {
                    53.3,
                    55.6
                }
            },
            level= 0,
            name= "Offering to the Raven Mother",
            type= 2,
            id= 234744,
            questId= "36403"
        },
        {
            coords= {
                {
                    48.3,
                    52.6
                }
            },
            level= 0,
            name= "Offering to the Raven Mother",
            type= 2,
            id= 234746,
            questId= "36405"
        },
        {
            coords= {
                {
                    48.9,
                    54.7
                }
            },
            level= 0,
            name= "Offering to the Raven Mother",
            type= 2,
            id= 234748,
            questId= "36406"
        },
        {
            coords= {
                {
                    51.9,
                    64.6
                }
            },
            level= 0,
            name= "Offering to the Raven Mother",
            type= 2,
            id= 235073,
            questId= "36407"
        },
        {
            coords= {
                {
                    61,
                    63.9
                }
            },
            level= 0,
            name= "Offering to the Raven Mother",
            type= 2,
            id= 235090,
            questId= "36410"
        },
        {
            coords= {
                {
                    47.8,
                    36.1
                }
            },
            level= 0,
            name= "Lost Ring",
            type= 2,
            id= 235091,
            questId= "36411"
        },
        {
            coords= {
                {
                    36.5,
                    57.9
                }
            },
            level= 0,
            name= "Ephial's Dark Grimoire",
            type= 2,
            id= 235097,
            questId= "36418"
        },
        {
            coords= {
                {
                    37.2,
                    47.4
                },
                {
                    37.2,
                    47.5
                }
            },
            level= 0,
            name= "Garrison Supplies",
            type= 2,
            id= 235103,
            questId= "36420"
        },
        {
            coords= {
                {
                    34.1,
                    27.4
                },
                {
                    34.1,
                    27.5
                }
            },
            level= 0,
            name= "Sun-Touched Cache",
            type= 2,
            id= 235104,
            questId= "36421"
        },
        {
            coords= {
                {
                    50.4,
                    25.8
                }
            },
            level= 0,
            name= "Iron Horde Explosives",
            type= 2,
            id= 235141,
            questId= "36444"
        },
        {
            coords= {
                {
                    49.2,
                    37.3
                }
            },
            level= 0,
            name= "Assassin's Spear",
            type= 2,
            id= 235143,
            questId= "36445"
        },
        {
            coords= {
                {
                    46.9,
                    34
                }
            },
            level= 0,
            name= "Outcast's Pouch",
            type= 2,
            id= 235168,
            questId= "36446"
        },
        {
            coords= {
                {
                    42.1,
                    21.7
                }
            },
            level= 0,
            name= "Outcast's Belongings",
            type= 2,
            id= 235172,
            questId= "36447"
        },
        {
            coords= {
                {
                    71.6,
                    48.5
                }
            },
            level= 0,
            name= "Sethekk Ritual Brew",
            type= 2,
            id= 235282,
            questId= "36450"
        },
        {
            coords= {
                {
                    41.8,
                    50.5
                },
                {
                    41.9,
                    50.4
                }
            },
            level= 0,
            name= "Garrison Workman's Hammer",
            type= 2,
            id= 235289,
            questId= "36451"
        },
        {
            coords= {
                {
                    68.4,
                    89
                }
            },
            level= 0,
            name= "Coinbender's Payment",
            type= 2,
            id= 235299,
            questId= "36453"
        },
        {
            coords= {
                {
                    63.6,
                    67.4
                }
            },
            level= 0,
            name= "Mysterious Mushrooms",
            type= 2,
            id= 235300,
            questId= "36454"
        },
        {
            coords= {
                {
                    66.5,
                    56.5
                }
            },
            level= 0,
            name= "Waterlogged Satchel",
            type= 2,
            id= 235307,
            questId= "36071"
        },
        {
            coords= {
                {
                    60.9,
                    84.6
                }
            },
            level= 0,
            name= "Shredder Parts",
            type= 2,
            id= 235310,
            questId= "36456"
        },
        {
            coords= {
                {
                    40.6,
                    55
                }
            },
            level= 0,
            name= "Abandoned Mining Pick",
            type= 2,
            id= 235313,
            questId= "36458"
        }
    },
    ["Shadowmoon Valley"]= {
        {
            coords= {
                {
                    44.4,
                    63.5
                },
                {
                    44.5,
                    63.5
                }
            },
            level= 0,
            name= "Peaceful Offering",
            type= 2,
            id= 223533,
            questId= "33384"
        },
        {
            coords= {
                {
                    37.2,
                    23.1
                }
            },
            level= 0,
            name= "Bubbling Cauldron",
            type= 2,
            id= 224228,
            questId= "33613"
        },
        {
            coords= {
                {
                    47.1,
                    46.1
                }
            },
            level= 0,
            name= "Hanging Satchel",
            type= 2,
            id= 224750,
            questId= "33564"
        },
        {
            coords= {
                {
                    67.1,
                    84.3
                }
            },
            level= 0,
            name= "Scaly Rylak Egg",
            type= 2,
            id= 224753,
            questId= "33565"
        },
        {
            coords= {
                {
                    39.2,
                    83.8
                }
            },
            level= 0,
            name= "Waterlogged Chest",
            type= 2,
            id= 224754,
            questId= "33566"
        },
        {
            coords= {
                {
                    37.4,
                    59.3
                },
                {
                    37.5,
                    59.3
                }
            },
            level= 0,
            name= "Iron Horde Tribute",
            type= 2,
            id= 224755,
            questId= "33567"
        },
        {
            coords= {
                {
                    55,
                    45
                }
            },
            level= 0,
            name= "Alchemist's Satchel",
            type= 2,
            id= 224756,
            questId= "35581"
        },
        {
            coords= {
                {
                    45.8,
                    24.6
                }
            },
            level= 0,
            name= "Shadowmoon Exile Treasure",
            type= 2,
            id= 224770,
            questId= "33570"
        },
        {
            coords= {
                {
                    22.8,
                    33.9
                }
            },
            level= 0,
            name= "Rotting Basket",
            type= 2,
            id= 224781,
            questId= "33572"
        },
        {
            coords= {
                {
                    51.8,
                    35.4
                },
                {
                    51.8,
                    35.5
                }
            },
            level= 0,
            name= "False-Bottomed Jar",
            type= 2,
            id= 224783,
            questId= "33037"
        },
        {
            coords= {
                {
                    51.1,
                    79.1
                }
            },
            level= 0,
            name= "Vindicator's Cache",
            type= 2,
            id= 224784,
            questId= "33574"
        },
        {
            coords= {
                {
                    20.3,
                    30.6
                }
            },
            level= 0,
            name= "Demonic Cache",
            type= 2,
            id= 224785,
            questId= "33575"
        },
        {
            coords= {
                {
                    45.2,
                    60.4
                },
                {
                    45.2,
                    60.5
                }
            },
            level= 0,
            name= "Peaceful Offering",
            type= 2,
            id= 225501,
            questId= "33610"
        },
        {
            coords= {
                {
                    43.8,
                    60.6
                }
            },
            level= 0,
            name= "Peaceful Offering",
            type= 2,
            id= 225502,
            questId= "33611"
        },
        {
            coords= {
                {
                    44.4,
                    59.2
                },
                {
                    44.5,
                    59.2
                }
            },
            level= 0,
            name= "Peaceful Offering",
            type= 2,
            id= 225503,
            questId= "33612"
        },
        {
            coords= {
                {
                    42.1,
                    61.3
                }
            },
            level= 0,
            name= "Iron Horde Cargo Shipment",
            type= 2,
            id= 227134,
            questId= "33041"
        },
        {
            coords= {
                {
                    26.5,
                    5.7
                }
            },
            level= 0,
            name= "Fantastic Fish",
            type= 2,
            id= 227743,
            questId= "34174"
        },
        {
            coords= {
                {
                    28.8,
                    7.1
                }
            },
            level= 0,
            name= "Sunken Treasure",
            type= 2,
            id= 232066,
            questId= "35279"
        },
        {
            coords= {
                {
                    27.1,
                    2.4
                },
                {
                    27.1,
                    2.5
                },
                {
                    27.1,
                    2.6
                }
            },
            level= 0,
            name= "Stolen Treasure",
            type= 2,
            id= 232067,
            questId= "35280"
        },
        {
            coords= {
                {
                    52.9,
                    24.9
                }
            },
            level= 0,
            name= "Mushroom-Covered Chest",
            type= 2,
            id= 232494,
            questId= "37254"
        },
        {
            coords= {
                {
                    30.3,
                    19.9
                }
            },
            level= 0,
            name= "Lunarfall Egg",
            type= 2,
            id= 232507,
            questId= "35530"
        },
        {
            coords= {
                {
                    57.9,
                    45.3
                }
            },
            level= 0,
            name= "Kaliri Egg",
            type= 2,
            id= 232579,
            questId= "33568"
        },
        {
            coords= {
                {
                    37.2,
                    26.1
                }
            },
            level= 0,
            name= "Sunken Fishing boat",
            type= 2,
            id= 233101,
            questId= "35677"
        },
        {
            coords= {
                {
                    28.3,
                    39.3
                }
            },
            level= 0,
            name= "Shadowmoon Treasure",
            type= 2,
            id= 233126,
            questId= "33571"
        },
        {
            coords= {
                {
                    48.7,
                    47.5
                }
            },
            level= 0,
            name= "Glowing Cave Mushroom",
            type= 2,
            id= 233241,
            questId= "35798"
        },
        {
            coords= {
                {
                    66.9,
                    33.4
                },
                {
                    67,
                    33.5
                }
            },
            level= 0,
            name= "Orc Skeleton",
            type= 2,
            id= 235860,
            questId= "36507"
        }
    },
    ["Frostfire Ridge"]= {
        {
            coords= {
                {
                    34.2,
                    23.5
                },
                {
                    34.3,
                    23.4
                }
            },
            level= 0,
            name= "Thunderlord Cache",
            type= 2,
            id= 220641,
            questId= "34642"
        },
        {
            coords= {
                {
                    27.6,
                    42.8
                }
            },
            level= 0,
            name= "Slave's Stash",
            type= 2,
            id= 224392,
            questId= "34642"
        },
        {
            coords= {
                {
                    42.7,
                    31.7
                }
            },
            level= 0,
            name= "Crag-Leaper's Cache",
            type= 2,
            id= 226983,
            questId= "34642"
        },
        {
            coords= {
                {
                    16.1,
                    49.8
                }
            },
            level= 0,
            name= "Supply Dump",
            type= 2,
            id= 226990,
            questId= "34642"
        },
        {
            coords= {
                {
                    64.7,
                    25.7
                }
            },
            level= 0,
            name= "Survivalist's Cache",
            type= 2,
            id= 226993,
            questId= "34642"
        },
        {
            coords= {
                {
                    68.2,
                    45.8
                }
            },
            level= 0,
            name= "Grimfrost Treasure",
            type= 2,
            id= 226994,
            questId= "34642"
        },
        {
            coords= {
                {
                    66.7,
                    26.4
                },
                {
                    66.8,
                    26.5
                }
            },
            level= 0,
            name= "Goren Leftovers",
            type= 2,
            id= 226996,
            questId= "34642"
        },
        {
            coords= {
                {
                    57.1,
                    52.1
                }
            },
            level= 0,
            name= "Frozen Orc Skeleton",
            type= 2,
            id= 229367,
            questId= "34642"
        },
        {
            coords= {
                {
                    24.2,
                    48.6
                }
            },
            level= 0,
            name= "Frozen Frostwolf Axe",
            type= 2,
            id= 229640,
            questId= "34642"
        },
        {
            coords= {
                {
                    42.4,
                    19.7
                }
            },
            level= 0,
            name= "Burning Pearl",
            type= 2,
            id= 230252,
            questId= "34642"
        },
        {
            coords= {
                {
                    51,
                    22.8
                }
            },
            level= 0,
            name= "Glowing Obsidian Shard",
            type= 2,
            id= 230253,
            questId= "34642"
        },
        {
            coords= {
                {
                    9.8,
                    45.4
                }
            },
            level= 0,
            name= "Sealed Jug",
            type= 2,
            id= 230401,
            questId= "34642"
        },
        {
            coords= {
                {
                    19.2,
                    12
                }
            },
            level= 0,
            name= "Lucky Coin",
            type= 2,
            id= 230402,
            questId= "34642"
        },
        {
            coords= {
                {
                    24,
                    13
                }
            },
            level= 0,
            name= "Snow-Covered Strongbox",
            type= 2,
            id= 230424,
            questId= "34642"
        },
        {
            coords= {
                {
                    25.5,
                    20.4
                },
                {
                    25.5,
                    20.5
                }
            },
            level= 0,
            name= "Gnawed Bone",
            type= 2,
            id= 230425,
            questId= "34642"
        },
        {
            coords= {
                {
                    21.6,
                    50.7
                }
            },
            level= 0,
            name= "Pale Loot Sack",
            type= 2,
            id= 230611,
            questId= "34642"
        },
        {
            coords= {
                {
                    43.7,
                    55.5
                }
            },
            level= 0,
            name= "Forgotten Supplies",
            type= 2,
            id= 230909,
            questId= "34642"
        },
        {
            coords= {
                {
                    37.2,
                    59.2
                }
            },
            level= 0,
            name= "Raided Loot",
            type= 2,
            id= 231103,
            questId= "34642"
        },
        {
            coords= {
                {
                    56.7,
                    71.8
                }
            },
            level= 0,
            name= "Iron Horde Munitions",
            type= 2,
            id= 236693,
            questId= "34642"
        }
    },
    ["Gorgrond"]= {
        {
            coords= {
                {
                    43.1,
                    92.9
                }
            },
            level= 0,
            name= "Ockbar's Pack",
            type= 2,
            id= 227998,
            questId= "34241"
        },
        {
            coords= {
                {
                    53,
                    80
                }
            },
            level= 0,
            name= "Strange Looking Dagger",
            type= 2,
            id= 231069,
            questId= "34940"
        },
        {
            coords= {
                {
                    42.6,
                    46.8
                }
            },
            level= 0,
            name= "Horned Skull",
            type= 2,
            id= 231644,
            questId= "35056"
        },
        {
            coords= {
                {
                    48.9,
                    47.3
                }
            },
            level= 0,
            name= "Warm Goren Egg",
            type= 2,
            id= 234054,
            questId= "36203"
        },
        {
            coords= {
                {
                    41.7,
                    53
                }
            },
            level= 0,
            name= "Brokor's Sack",
            type= 2,
            id= 235859,
            questId= "36506"
        },
        {
            coords= {
                {
                    49.3,
                    43.6
                }
            },
            level= 0,
            name= "Weapons Cache",
            type= 2,
            id= 235869,
            questId= "36596"
        },
        {
            coords= {
                {
                    46.2,
                    42.9
                }
            },
            level= 0,
            name= "Petrified Rylak Egg",
            type= 2,
            id= 235881,
            questId= "36521"
        },
        {
            coords= {
                {
                    48.1,
                    93.4
                }
            },
            level= 0,
            name= "Stashed Emergency Rucksack",
            type= 2,
            id= 236092,
            questId= "36604"
        },
        {
            coords= {
                {
                    57.8,
                    56
                }
            },
            level= 0,
            name= "Remains of Balldir Deeprock",
            type= 2,
            id= 236096,
            questId= "36605"
        },
        {
            coords= {
                {
                    45.7,
                    49.7
                }
            },
            level= 0,
            name= "Suntouched Spear",
            type= 2,
            id= 236099,
            questId= "36610"
        },
        {
            coords= {
                {
                    43.7,
                    42.4
                },
                {
                    43.7,
                    42.5
                }
            },
            level= 0,
            name= "Iron Supply Chest",
            type= 2,
            id= 236138,
            questId= "36618"
        },
        {
            coords= {
                {
                    40.4,
                    76.6
                }
            },
            level= 0,
            name= "Explorer Canister",
            type= 2,
            id= 236139,
            questId= "36621"
        },
        {
            coords= {
                {
                    42.4,
                    83.4
                },
                {
                    42.4,
                    83.5
                }
            },
            level= 0,
            name= "Discarded Pack",
            type= 2,
            id= 236141,
            questId= "36625"
        },
        {
            coords= {
                {
                    59.3,
                    63.7
                },
                {
                    59.4,
                    63.7
                }
            },
            level= 0,
            name= "Vindicator's Hammer",
            type= 2,
            id= 236147,
            questId= "36628"
        },
        {
            coords= {
                {
                    39,
                    68.1
                }
            },
            level= 0,
            name= "Sasha's Secret Stash",
            type= 2,
            id= 236149,
            questId= "36631"
        },
        {
            coords= {
                {
                    45,
                    42.6
                }
            },
            level= 0,
            name= "Sniper's Crossbow",
            type= 2,
            id= 236158,
            questId= "36634"
        },
        {
            coords= {
                {
                    53.1,
                    74.4
                },
                {
                    53.1,
                    74.5
                }
            },
            level= 0,
            name= "Remains of Balik Orecrusher",
            type= 2,
            id= 236170,
            questId= "36654"
        },
        {
            coords= {
                {
                    52.5,
                    66.9
                }
            },
            level= 0,
            name= "Odd Skull",
            type= 2,
            id= 236715,
            questId= "36509"
        }
    },
    ["Talador"]= {
        {
            coords= {
                {
                    68.8,
                    56.1
                }
            },
            level= 0,
            name= "Lightbearer",
            type= 2,
            id= 227527,
            questId= "34101"
        },
        {
            coords= {
                {
                    40.7,
                    89.5
                }
            },
            level= 0,
            name= "Yuuri's Gift",
            type= 2,
            id= 227587,
            questId= "34140"
        },
        {
            coords= {
                {
                    36.5,
                    96.1
                }
            },
            level= 0,
            name= "Aarko's Family Treasure",
            type= 2,
            id= 227793,
            questId= "34182"
        },
        {
            coords= {
                {
                    64.9,
                    13.3
                }
            },
            level= 0,
            name= "Rook's Tacklebox",
            type= 2,
            id= 227951,
            questId= "34232"
        },
        {
            coords= {
                {
                    65.4,
                    11.3
                },
                {
                    65.5,
                    11.3
                }
            },
            level= 0,
            name= "Jug of Aged Ironwine",
            type= 2,
            id= 227953,
            questId= "34233"
        },
        {
            coords= {
                {
                    52.5,
                    29.5
                }
            },
            level= 0,
            name= "Luminous Shell",
            type= 2,
            id= 227954,
            questId= "34235"
        },
        {
            coords= {
                {
                    62,
                    32.4
                },
                {
                    62.1,
                    32.5
                }
            },
            level= 0,
            name= "Amethyl Crystal",
            type= 2,
            id= 227955,
            questId= "34236"
        },
        {
            coords= {
                {
                    57.4,
                    28.7
                }
            },
            level= 0,
            name= "Foreman's Lunchbox",
            type= 2,
            id= 227956,
            questId= "34238"
        },
        {
            coords= {
                {
                    66.6,
                    86.9
                }
            },
            level= 0,
            name= "Curious Deathweb Egg",
            type= 2,
            id= 227996,
            questId= "34239"
        },
        {
            coords= {
                {
                    77,
                    50
                }
            },
            level= 0,
            name= "Charred Sword",
            type= 2,
            id= 228012,
            questId= "34248"
        },
        {
            coords= {
                {
                    35.4,
                    96.5
                },
                {
                    35.5,
                    96.6
                }
            },
            level= 0,
            name= "Farmer's Bounty",
            type= 2,
            id= 228013,
            questId= "34249"
        },
        {
            coords= {
                {
                    75.8,
                    44.7
                }
            },
            level= 0,
            name= "Relic of Aruuna",
            type= 2,
            id= 228014,
            questId= "34250"
        },
        {
            coords= {
                {
                    64.6,
                    79.2
                }
            },
            level= 0,
            name= "Iron Box",
            type= 2,
            id= 228015,
            questId= "34251"
        },
        {
            coords= {
                {
                    62.4,
                    48
                }
            },
            level= 0,
            name= "Barrel of Fish",
            type= 2,
            id= 228016,
            questId= "34252"
        },
        {
            coords= {
                {
                    55.2,
                    66.8
                }
            },
            level= 0,
            name= "Draenei Weapons",
            type= 2,
            id= 228017,
            questId= "34253"
        },
        {
            coords= {
                {
                    39.5,
                    55.2
                }
            },
            level= 0,
            name= "Soulbinder's Reliquary",
            type= 2,
            id= 228018,
            questId= "34254"
        },
        {
            coords= {
                {
                    65.4,
                    88.6
                },
                {
                    65.5,
                    88.6
                }
            },
            level= 0,
            name= "Webbed Sac",
            type= 2,
            id= 228019,
            questId= "34255"
        },
        {
            coords= {
                {
                    47,
                    91.7
                }
            },
            level= 0,
            name= "Relic of Telmor",
            type= 2,
            id= 228020,
            questId= "34256"
        },
        {
            coords= {
                {
                    38.4,
                    84.4
                },
                {
                    38.4,
                    84.5
                }
            },
            level= 0,
            name= "Treasure of Ango'rosh",
            type= 2,
            id= 228021,
            questId= "34257"
        },
        {
            coords= {
                {
                    38.1,
                    12.4
                }
            },
            level= 0,
            name= "Light of the Sea",
            type= 2,
            id= 228022,
            questId= "34258"
        },
        {
            coords= {
                {
                    33.3,
                    76.7
                },
                {
                    33.3,
                    76.8
                }
            },
            level= 0,
            name= "Bonechewer Remnants",
            type= 2,
            id= 228023,
            questId= "34259"
        },
        {
            coords= {
                {
                    81.9,
                    35
                }
            },
            level= 0,
            name= "Aruuna Mining Cart",
            type= 2,
            id= 228024,
            questId= "34260"
        },
        {
            coords= {
                {
                    75.7,
                    41.4
                }
            },
            level= 0,
            name= "Keluu's Belongings",
            type= 2,
            id= 228025,
            questId= "34261"
        },
        {
            coords= {
                {
                    78.3,
                    14.8
                }
            },
            level= 0,
            name= "Pure Crystal Dust",
            type= 2,
            id= 228026,
            questId= "34263"
        },
        {
            coords= {
                {
                    66,
                    85.1
                }
            },
            level= 0,
            name= "Rusted Lockbox",
            type= 2,
            id= 228483,
            questId= "34276"
        },
        {
            coords= {
                {
                    54,
                    27.6
                }
            },
            level= 0,
            name= "Ketya's Stash",
            type= 2,
            id= 228570,
            questId= "34290"
        },
        {
            coords= {
                {
                    73.5,
                    51.4
                }
            },
            level= 0,
            name= "Bright Coin",
            type= 2,
            id= 229354,
            questId= "34471"
        },
        {
            coords= {
                {
                    39.3,
                    77.7
                },
                {
                    39.8,
                    76.7
                },
                {
                    54.1,
                    56.3
                },
                {
                    70.8,
                    32
                },
                {
                    70.9,
                    35.5
                },
                {
                    72.4,
                    37
                },
                {
                    72.8,
                    35.6
                },
                {
                    73.4,
                    30.7
                },
                {
                    73.5,
                    30.7
                },
                {
                    74.3,
                    34
                },
                {
                    74.6,
                    29.3
                },
                {
                    75.8,
                    54.9
                },
                {
                    76.2,
                    51.1
                }
            },
            level= 0,
            name= "Teroclaw Nest",
            type= 2,
            id= 230643,
            questId= "35162"
        },
        {
            coords= {
                {
                    70.1,
                    7
                }
            },
            level= 0,
            name= "Burning Blade Cache",
            type= 2,
            id= 236935,
            questId= "36937"
        },
        {
            coords= {
                {
                    61.1,
                    71.7
                }
            },
            level= 0,
            name= "Norana's Cache",
            type= 2,
            id= 239194,
            questId= "34116"
        }
    },
    ["Nagrand"]= {
        {
            coords= {
                {
                    37.7,
                    70.6
                }
            },
            level= 0,
            name= "Treasure of Kull'krosh",
            type= 2,
            id= 230725,
            questId= "34760"
        },
        {
            coords= {
                {
                    69.9,
                    52.4
                }
            },
            level= 0,
            name= "Adventurer's Pack",
            type= 2,
            id= 232406,
            questId= "35597"
        },
        {
            coords= {
                {
                    47.2,
                    74.3
                }
            },
            level= 0,
            name= "Goblin Pack",
            type= 2,
            id= 232571,
            questId= "35576"
        },
        {
            coords= {
                {
                    50.1,
                    82.2
                }
            },
            level= 0,
            name= "Steamwheedle Supplies",
            type= 2,
            id= 232584,
            questId= "35577"
        },
        {
            coords= {
                {
                    50,
                    66.4
                },
                {
                    50,
                    66.5
                }
            },
            level= 0,
            name= "Void-Infused Crystal",
            type= 2,
            id= 232590,
            questId= "35579"
        },
        {
            coords= {
                {
                    52.7,
                    80.1
                }
            },
            level= 0,
            name= "Steamwheedle Supplies",
            type= 2,
            id= 232595,
            questId= "35583"
        },
        {
            coords= {
                {
                    73,
                    62.2
                }
            },
            level= 0,
            name= "Goblin Pack",
            type= 2,
            id= 232597,
            questId= "35590"
        },
        {
            coords= {
                {
                    77.8,
                    51.9
                }
            },
            level= 0,
            name= "Steamwheedle Supplies",
            type= 2,
            id= 232598,
            questId= "35591"
        },
        {
            coords= {
                {
                    80.6,
                    60.4
                },
                {
                    80.6,
                    60.6
                }
            },
            level= 0,
            name= "Warsong Spoils",
            type= 2,
            id= 232599,
            questId= "35593"
        },
        {
            coords= {
                {
                    88.2,
                    42.6
                }
            },
            level= 0,
            name= "Steamwheedle Supplies",
            type= 2,
            id= 232985,
            questId= "35616"
        },
        {
            coords= {
                {
                    87.5,
                    45
                }
            },
            level= 0,
            name= "Hidden Stash",
            type= 2,
            id= 232986,
            questId= "35622"
        },
        {
            coords= {
                {
                    70.5,
                    13.9
                }
            },
            level= 0,
            name= "Mountain Climber's Pack",
            type= 2,
            id= 233032,
            questId= "35643"
        },
        {
            coords= {
                {
                    70.6,
                    18.6
                }
            },
            level= 0,
            name= "Steamwheedle Supplies",
            type= 2,
            id= 233033,
            questId= "35646"
        },
        {
            coords= {
                {
                    64.6,
                    17.6
                }
            },
            level= 0,
            name= "Steamwheedle Supplies",
            type= 2,
            id= 233034,
            questId= "35648"
        },
        {
            coords= {
                {
                    88.9,
                    18.2
                }
            },
            level= 0,
            name= "Fungus-Covered Chest",
            type= 2,
            id= 233044,
            questId= "35660"
        },
        {
            coords= {
                {
                    81.1,
                    37.2
                }
            },
            level= 0,
            name= "Brilliant Dreampetal",
            type= 2,
            id= 233048,
            questId= "35661"
        },
        {
            coords= {
                {
                    87.6,
                    20.3
                }
            },
            level= 0,
            name= "Steamwheedle Supplies",
            type= 2,
            id= 233052,
            questId= "35662"
        },
        {
            coords= {
                {
                    73.1,
                    75.5
                }
            },
            level= 0,
            name= "Appropriated Warsong Supplies",
            type= 2,
            id= 233079,
            questId= "35673"
        },
        {
            coords= {
                {
                    73,
                    70.4
                }
            },
            level= 0,
            name= "Warsong Lockbox",
            type= 2,
            id= 233103,
            questId= "35678"
        },
        {
            coords= {
                {
                    76.1,
                    70
                }
            },
            level= 0,
            name= "Warsong Spear",
            type= 2,
            id= 233113,
            questId= "35682"
        },
        {
            coords= {
                {
                    73.1,
                    21.6
                }
            },
            level= 0,
            name= "Freshwater Clam",
            type= 2,
            id= 233132,
            questId= "35692"
        },
        {
            coords= {
                {
                    58.2,
                    52.6
                }
            },
            level= 0,
            name= "Golden Kaliri Egg",
            type= 2,
            id= 233134,
            questId= "35694"
        },
        {
            coords= {
                {
                    51.7,
                    60.3
                }
            },
            level= 0,
            name= "Warsong Cache",
            type= 2,
            id= 233135,
            questId= "35695"
        },
        {
            coords= {
                {
                    65.8,
                    61.1
                },
                {
                    65.9,
                    61.2
                }
            },
            level= 0,
            name= "Abu'gar's Vitality",
            type= 2,
            id= 233157,
            questId= "35711"
        },
        {
            coords= {
                {
                    67.6,
                    59.8
                }
            },
            level= 0,
            name= "Abandoned Cargo",
            type= 2,
            id= 233206,
            questId= "35759"
        },
        {
            coords= {
                {
                    82.3,
                    56.6
                }
            },
            level= 0,
            name= "Adventurer's Pack",
            type= 2,
            id= 233218,
            questId= "35765"
        },
        {
            coords= {
                {
                    73,
                    10.9
                }
            },
            level= 0,
            name= "A Pile of Dirt",
            type= 2,
            id= 233452,
            questId= "35951"
        },
        {
            coords= {
                {
                    81.4,
                    13
                },
                {
                    81.5,
                    13
                }
            },
            level= 0,
            name= "Adventurer's Staff",
            type= 2,
            id= 233457,
            questId= "35953"
        },
        {
            coords= {
                {
                    66.9,
                    19.5
                }
            },
            level= 0,
            name= "Elemental Offering",
            type= 2,
            id= 233492,
            questId= "35954"
        },
        {
            coords= {
                {
                    73.9,
                    14.1
                }
            },
            level= 0,
            name= "Adventurer's Sack",
            type= 2,
            id= 233499,
            questId= "35955"
        },
        {
            coords= {
                {
                    85.4,
                    38.7
                }
            },
            level= 0,
            name= "Abu'gar's Missing Reel",
            type= 2,
            id= 233506,
            questId= "36089"
        },
        {
            coords= {
                {
                    45.6,
                    52
                }
            },
            level= 0,
            name= "Adventurer's Pack",
            type= 2,
            id= 233511,
            questId= "35969"
        },
        {
            coords= {
                {
                    89.4,
                    65.8
                }
            },
            level= 0,
            name= "Warsong Supplies",
            type= 2,
            id= 233521,
            questId= "35976"
        },
        {
            coords= {
                {
                    77.3,
                    28.2
                }
            },
            level= 0,
            name= "Bone-Carved Dagger",
            type= 2,
            id= 233532,
            questId= "35986"
        },
        {
            coords= {
                {
                    43.3,
                    57.5
                }
            },
            level= 0,
            name= "Genedar Debris",
            type= 2,
            id= 233539,
            questId= "35987"
        },
        {
            coords= {
                {
                    48,
                    60.1
                }
            },
            level= 0,
            name= "Genedar Debris",
            type= 2,
            id= 233549,
            questId= "35999"
        },
        {
            coords= {
                {
                    44.6,
                    67.4
                },
                {
                    44.6,
                    67.5
                }
            },
            level= 0,
            name= "Genedar Debris",
            type= 2,
            id= 233551,
            questId= "36002"
        },
        {
            coords= {
                {
                    48.6,
                    72.7
                }
            },
            level= 0,
            name= "Genedar Debris",
            type= 2,
            id= 233555,
            questId= "36008"
        },
        {
            coords= {
                {
                    55.3,
                    68.2
                }
            },
            level= 0,
            name= "Genedar Debris",
            type= 2,
            id= 233557,
            questId= "36011"
        },
        {
            coords= {
                {
                    45.8,
                    66.3
                }
            },
            level= 0,
            name= "Fragment of Oshu'gun",
            type= 2,
            id= 233560,
            questId= "36020"
        },
        {
            coords= {
                {
                    58.3,
                    59.4
                }
            },
            level= 0,
            name= "Pokkar's Thirteenth Axe",
            type= 2,
            id= 233561,
            questId= "36021"
        },
        {
            coords= {
                {
                    72.7,
                    61
                }
            },
            level= 0,
            name= "Polished Saberon Skull",
            type= 2,
            id= 233593,
            questId= "36035"
        },
        {
            coords= {
                {
                    78.8,
                    15.4
                },
                {
                    78.9,
                    15.5
                }
            },
            level= 0,
            name= "Elemental Shackles",
            type= 2,
            id= 233598,
            questId= "36036"
        },
        {
            coords= {
                {
                    67.4,
                    49
                }
            },
            level= 0,
            name= "Highmaul Sledge",
            type= 2,
            id= 233611,
            questId= "36039"
        },
        {
            coords= {
                {
                    64.7,
                    65.8
                }
            },
            level= 0,
            name= "Telaar Defender Shield",
            type= 2,
            id= 233613,
            questId= "36046"
        },
        {
            coords= {
                {
                    81,
                    79.8
                }
            },
            level= 0,
            name= "Ogre Beads",
            type= 2,
            id= 233618,
            questId= "36049"
        },
        {
            coords= {
                {
                    56.6,
                    72.9
                }
            },
            level= 0,
            name= "Adventurer's Pouch",
            type= 2,
            id= 233623,
            questId= "36050"
        },
        {
            coords= {
                {
                    87.1,
                    72.9
                }
            },
            level= 0,
            name= "Grizzlemaw's Bonepile",
            type= 2,
            id= 233626,
            questId= "36051"
        },
        {
            coords= {
                {
                    38.4,
                    49.3
                },
                {
                    38.4,
                    49.4
                }
            },
            level= 0,
            name= "Abu'Gar's Favorite Lure",
            type= 2,
            id= 233642,
            questId= "36072"
        },
        {
            coords= {
                {
                    52.4,
                    44.4
                }
            },
            level= 0,
            name= "Warsong Helm",
            type= 2,
            id= 233645,
            questId= "36073"
        },
        {
            coords= {
                {
                    75.4,
                    47.1
                }
            },
            level= 0,
            name= "Gambler's Purse",
            type= 2,
            id= 233649,
            questId= "36074"
        },
        {
            coords= {
                {
                    75.8,
                    62
                }
            },
            level= 0,
            name= "Adventurer's Mace",
            type= 2,
            id= 233650,
            questId= "36077"
        },
        {
            coords= {
                {
                    61.8,
                    57.4
                }
            },
            level= 0,
            name= "Lost Pendant",
            type= 2,
            id= 233651,
            questId= "36082"
        },
        {
            coords= {
                {
                    65.7,
                    57.6
                },
                {
                    66.3,
                    57.3
                }
            },
            level= 12,
            name= "Adventurer's Pouch",
            type= 2,
            id= 233658,
            questId= "36088"
        },
        {
            coords= {
                {
                    75.3,
                    65.7
                }
            },
            level= 0,
            name= "Important Exploration Supplies",
            type= 2,
            id= 233696,
            questId= "36099"
        },
        {
            coords= {
                {
                    75.2,
                    65
                }
            },
            level= 0,
            name= "Saberon Stash",
            type= 2,
            id= 233697,
            questId= "36102"
        },
        {
            coords= {
                {
                    57.8,
                    62.2
                }
            },
            level= 0,
            name= "Pale Elixir",
            type= 2,
            id= 233768,
            questId= "36115"
        },
        {
            coords= {
                {
                    62.5,
                    67.1
                }
            },
            level= 0,
            name= "Bag of Herbs",
            type= 2,
            id= 233773,
            questId= "36116"
        },
        {
            coords= {
                {
                    89.1,
                    33.1
                }
            },
            level= 0,
            name= "Smuggler's Cache",
            type= 2,
            id= 236633,
            questId= "36857"
        },
        {
            coords= {
                {
                    40.4,
                    68.6
                }
            },
            level= 0,
            name= "Spirit Coffer",
            type= 2,
            id= 237946,
            questId= "37435"
        }
    }
}