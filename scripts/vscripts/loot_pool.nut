/*
		Colors
		220 75 50 	= RED (Lethal Weapons)
		50 200 50	= GREEN (Healing items)
		240 240 50	= YELLOW (Deployable Ammo)
		240 120 0 	= ORANGE (Throwables)
*/

::SpawnListCommon <-
[
	//Entity:									Probability:	Ammo:				Melee type:			Light Color:
	{ ent = "weapon_rifle"						prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_rifle_ak47"					prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_rifle_desert"				prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_rifle_sg552"	    		prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_shotgun_spas"				prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_autoshotgun"				prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_hunting_rifle"				prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_sniper_military"			prob = 5,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_sniper_awp"	    			prob = 4,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_sniper_scout"				prob = 4,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },

	{ ent = "weapon_rifle_m60"					prob = 1,		ammo = null,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_grenade_launcher"			prob = 2,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },

	{ ent = "weapon_smg_silenced"				prob = 10,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_smg"						prob = 10,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_smg_mp5"					prob = 10,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_shotgun_chrome"				prob = 10,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_pumpshotgun"				prob = 10,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },

	{ ent = "weapon_pistol_magnum"				prob = 2,		ammo = null,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_pistol"						prob = 5,		ammo = null,		melee_type = null,	lightColor = "220 75 50" },

	{ ent = "weapon_adrenaline" 				prob = 20,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },
	{ ent = "weapon_pain_pills" 				prob = 30,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },
	{ ent = "weapon_vomitjar" 					prob = 2,		ammo = null,		melee_type = null,	lightColor = "240 120 0" },
	{ ent = "weapon_molotov" 					prob = 5,		ammo = null,		melee_type = null,	lightColor = "240 120 0" },
	{ ent = "weapon_pipe_bomb" 					prob = 6,		ammo = null,		melee_type = null,	lightColor = "240 120 0" },
	{ ent = "weapon_first_aid_kit" 				prob = 3,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },
	{ ent = "weapon_defibrillator" 				prob = 1,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },

	// Note: These items don't retain their entities when spawned, and cannot be tracked.
	{ ent = "weapon_melee_spawn"				prob = 75,		ammo = null,		melee_type = "any",	lightColor = "220 75 50"  },
	{ ent = "weapon_upgradepack_explosive" 		prob = 4,		ammo = null,		melee_type = null,	lightColor = "240 240 50" },
	{ ent = "weapon_upgradepack_incendiary" 	prob = 4,		ammo = null,		melee_type = null,	lightColor = "240 240 50" },
]

::SpawnListSpecial <-
[
	//Entity:									Probability:	Ammo:				Melee type:			Light Color:
	{ ent = "weapon_rifle"						prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_rifle_ak47"					prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_rifle_desert"				prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_rifle_sg552"				prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_shotgun_spas"				prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_autoshotgun"				prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_hunting_rifle"				prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_sniper_military"			prob = 25,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_sniper_awp"					prob = 15,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_sniper_scout"				prob = 15,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },

	{ ent = "weapon_rifle_m60"					prob = 2,		ammo = null,		melee_type = null,	lightColor = "220 75 50" },
	{ ent = "weapon_grenade_launcher"			prob = 3,		ammo = true,		melee_type = null,	lightColor = "220 75 50" },

	{ ent = "weapon_adrenaline" 				prob = 30,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },
	{ ent = "weapon_pain_pills" 				prob = 30,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },
	{ ent = "weapon_vomitjar" 					prob = 5,		ammo = null,		melee_type = null,	lightColor = "240 120 0" },
	{ ent = "weapon_molotov" 					prob = 15,		ammo = null,		melee_type = null,	lightColor = "240 120 0" },
	{ ent = "weapon_pipe_bomb" 					prob = 10,		ammo = null,		melee_type = null,	lightColor = "240 120 0" },
	{ ent = "weapon_first_aid_kit" 				prob = 15,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },
	{ ent = "weapon_defibrillator" 				prob = 10,		ammo = null,		melee_type = null,	lightColor = "50 200 50" },

	// Note: These items don't retain their entities when spawned, and cannot be tracked.
	{ ent = "weapon_upgradepack_explosive" 		prob = 6,		ammo = null,		melee_type = null,	lightColor = "240 240 50" },
	{ ent = "weapon_upgradepack_incendiary" 	prob = 6,		ammo = null,		melee_type = null,	lightColor = "240 240 50" },
	// Laser Sights
	{ ent = "upgrade_spawn" 					prob = 6,		ammo = null,		melee_type = null,	lightColor = "220 75 50" },
]