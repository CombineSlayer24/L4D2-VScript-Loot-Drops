Msg( "-----------------------------------\n" );
Msg( "  Infected Loot Drops Initialized\n"  );
Msg( "-----------------------------------\n" );
// ===========================================
//				CONSTANTS
// ===========================================
const FLASH_THRESHOLD = 10.0;
const ITEM_REMOVE_TIMER	= 25.0;
const THINK_INTERVAL = 0.1;
// ===========================================
// 				LOCAL VARIABLES
// ===========================================
local DropSound 		= "ui/gift_drop.wav"
local RemoveSound 		= "ui/beep_error01.wav"
local SoundDelay 		= 0;
local lastHintTime 		= 0;
local WasTextFirstRan 	= false;
local hintStartTime 	= -1;
local hasShownSecondHint = false;
local lootThinkEnt = SpawnEntityFromTable("info_target", { targetname = "lootThinkEnt" });

local AmmoConfig = {
	/*
		TOC
		A. MagSizeMin
		B. MagSizeMax
		C. ReserveMin
		D. CvarAmmo (ReserveMaax)
		E. FallbackReserveMax
	*/

	// Format: 					  [ A,   B,  C,  D, 						E]
	"weapon_rifle" 				: [	25,  50, 50, "ammo_assaultrifle_max", 	360	],
	"weapon_rifle_ak47" 		: [	20,  40, 40, "ammo_assaultrifle_max", 	360	],
	"weapon_rifle_desert" 		: [	30,  60, 60, "ammo_assaultrifle_max", 	360	],
	"weapon_rifle_sg552" 		: [	25,  50, 50, "ammo_assaultrifle_max", 	360	],
	"weapon_shotgun_spas" 		: [	5,	 10, 20, "ammo_autoshotgun_max", 	90	],
	"weapon_autoshotgun" 		: [	5,	 10, 20, "ammo_autoshotgun_max", 	90	],
	"weapon_hunting_rifle" 		: [	5,	 15, 30, "ammo_huntingrifle_max", 	150	],
	"weapon_sniper_military" 	: [	10,	 30, 30, "ammo_sniperrifle_max", 	180	],
	"weapon_sniper_awp" 		: [	10,	 20, 20, "ammo_sniperrifle_max", 	180	],
	"weapon_sniper_scout" 		: [	10,	 15, 20, "ammo_sniperrifle_max", 	180	],
	"weapon_grenade_launcher" 	: [	1,	 1, 5, 	 "ammo_grenadelauncher_max", 30	],
	"weapon_smg_silenced" 		: [	25,  50, 50, "ammo_smg_max", 			650	],
	"weapon_smg" 				: [	25,  50, 50, "ammo_smg_max", 			650	],
	"weapon_smg_mp5" 			: [	25,	 50, 50, "ammo_smg_max", 			650	],
	"weapon_shotgun_chrome" 	: [	4,	 8, 20,  "ammo_shotgun_max", 		72	],
	"weapon_pumpshotgun" 		: [	4,	 8, 20,  "ammo_shotgun_max", 		72	],
	"weapon_pistol" 			: [	7,	 9, 50,  "ammo_pistol_max", 		-2	],
	"weapon_pistol_magnum" 		: [	4,	 8, 20,  "ammo_pistol_max", 		-2	],
	"weapon_rifle_m60" 			: [	100, 150, 0, "ammo_m60_max", 			0	]
};

DroppedItems <- {};

LootHintFirstKill <-
{
	hint_name = "loot_hint_start"
	hint_caption = "The Infected are carrying loot. Make sure you loot them!",
	hint_timeout = 5,
	hint_icon_onscreen = "icon_info",
	hint_instance_type = 2,
	hint_color = "255 255 255"
}

LootHintItemsDeletion <-
{
	hint_name = "loot_hint_start"
	hint_caption = "The Loot will not stay forever, make sure you pick them up!",
	hint_timeout = 8,
	hint_icon_onscreen = "icon_alert",
	hint_instance_type = 2,
	hint_color = "240 240 50"
}

LootDroppedHint <-
{
	hint_name = "item_dropped_hint"
	hint_caption = "An item has fallen!",
	hint_timeout = 8,
	hint_icon_onscreen = "icon_interact",
	hint_instance_type = 0,
	hint_range = 1000,
	hint_color = "50 200 50"
};

// Make sure our sounds are loaded.
if ( !IsSoundPrecached( DropSound ) )
{
	PrecacheSound( DropSound )
}

if ( !IsSoundPrecached( RemoveSound ) )
{
	PrecacheSound( RemoveSound )
}

// ===========================================
// 			THINK HOOK
// ===========================================
function LootThink()
{
    if ( lootThinkEnt.ValidateScriptScope() )
    {
        local scope = lootThinkEnt.GetScriptScope();

        // annoying shit
        scope.DroppedItems <- DroppedItems;
        scope.LootHintItemsDeletion <- LootHintItemsDeletion;
        scope.WasTextFirstRan <- WasTextFirstRan;
        scope.hintStartTime <- hintStartTime;
        scope.hasShownSecondHint <- hasShownSecondHint;
        scope.DisplayInstructorHint <- DisplayInstructorHint;
        scope.DisableLight <- DisableLight;
        scope.DisableGlow <- DisableGlow;
        scope.SpawnParticleEffect <- SpawnParticleEffect;
        scope.ITEM_REMOVE_TIMER <- ITEM_REMOVE_TIMER;
        scope.FLASH_THRESHOLD <- FLASH_THRESHOLD;
        scope.THINK_INTERVAL <- THINK_INTERVAL;

        scope["Think"] <- function()
		{
			local currentTime = Time();

			// for our second hint when an infected is killed.
			if ( WasTextFirstRan && !hasShownSecondHint && hintStartTime != -1 )
			{
				if ( currentTime - hintStartTime >= 6.0 )
				{
					DisplayInstructorHint( LootHintItemsDeletion );
					hasShownSecondHint = true;
				}
			}

			foreach ( itemIndex, itemData in DroppedItems )
			{
				local item = EntIndexToHScript( itemIndex );

				if ( !item || !item.IsValid() || currentTime - itemData.spawnTime > ITEM_REMOVE_TIMER )
				{
					if ( item && item.IsValid() && item.GetOwnerEntity() == null )
					{
						local itemOrigin = item.GetOrigin();

						DisableLight( itemData );
						item.Kill();
						EmitAmbientSoundOn( RemoveSound, 0.8, 85, RandomInt( 94, 106 ), item );

						// Spawn and trigger particle effect at item’s location
						local particle = SpawnParticleEffect( "st_elmos_fire_cp0", itemOrigin );
						if ( particle && particle.IsValid() )
						{
							DoEntFire( "!self", "Start", "", 0, null, particle );
							DoEntFire( "!self", "Kill", "", 0.65, null, particle );
						}
					}
					delete DroppedItems[ itemIndex ];
				}
				else if ( item.GetOwnerEntity() != null )
				{
					// Item picked up: disable glow and light
					DisableGlow( item );
					DisableLight( itemData );
					DroppedItems[ itemIndex ].glowing = false;
					delete DroppedItems[ itemIndex ];
				}
				else
				{
					// Update light and particle position without rotation
					if ( "lightEnt" in itemData )
					{
						local itemPos = item.GetCenter();
						if ( itemData.lightEnt.light && itemData.lightEnt.light.IsValid() )
						{
							itemData.lightEnt.light.SetOrigin( itemPos );
						}
						if ( itemData.lightEnt.particle && itemData.lightEnt.particle.IsValid() )
						{
							itemData.lightEnt.particle.SetOrigin( itemPos );
							local flashState = ( currentTime % 1.6 < 0.3 );
							if ( flashState )
							{
								DoEntFire( "!self", "Start", "", 0, null, itemData.lightEnt.particle );
							}
							else
							{
								DoEntFire( "!self", "Stop", "", 0, null, itemData.lightEnt.particle );
							}
						}
					}

					// Glow flashing logic
					local timeRemaining = ITEM_REMOVE_TIMER - ( currentTime - itemData.spawnTime );
					if ( timeRemaining > FLASH_THRESHOLD )
					{
						NetProps.SetPropInt( item, "m_Glow.m_bFlashing", 0 );
						NetProps.SetPropInt( item, "m_Glow.m_glowColorOverride", 50 | ( 200 << 8 ) | ( 50 << 16 ) );
					}
					else if ( timeRemaining > 5 )
					{
						//NetProps.SetPropInt( item, "m_Glow.m_bFlashing", 1 );
						NetProps.SetPropInt( item, "m_Glow.m_glowColorOverride", 240 | ( 240 << 8 ) | ( 50 << 16 ) );
					}
					else
					{
						NetProps.SetPropInt( item, "m_Glow.m_bFlashing", 1 );
						NetProps.SetPropInt( item, "m_Glow.m_glowColorOverride", 255 | ( 0 << 8 ) | ( 0 << 16 ) );
                    }
                }
            }
            return THINK_INTERVAL;
        }
        AddThinkToEnt( lootThinkEnt, "Think" );
    }
}

// ===========================================
// 			GAME EVENTS
// ===========================================
function OnGameEvent_round_start( params )
{
	LootThink();
	WasTextFirstRan = false;
	hintStartTime = -1; // Reset on round start
	hasShownSecondHint = false;
}

function OnGameEvent_player_death( params )
{
	if ( "entityid" in params )
	{
		local entity = EntIndexToHScript( params.entityid );
		if ( entity && entity.IsValid() )
		{
			if ( entity.GetClassname() == "infected" )
			{
				if ( !WasTextFirstRan )
				{
					DisplayInstructorHint( LootHintFirstKill );
					WasTextFirstRan = true;
					hintStartTime = Time();
				}

				if ( RandomInt( 0, 100 ) < 9 )	// 7
				{
					SpawnRandomItem( ::SpawnListCommon, entity.GetOrigin() + Vector( 0, 0, 12 ) );
				}
			}
		}
	}

	else if ( "userid" in params )
	{
		local origin = Vector( params.victim_x, params.victim_y, params.victim_z );
		if ( RandomInt( 0, 100 ) < 65 )	// 50
			SpawnRandomItem( ::SpawnListSpecial, origin + Vector( 0, 0, 12 ) );
	}
}

function OnGameEvent_item_pickup( params )
{
	local player = GetPlayerFromUserID( params.userid );
	local itemName = params.item;

	if ( player && player.IsValid() )
	{
		// Look through DroppedItems for a match
		foreach ( itemIndex, itemData in DroppedItems )
		{
			local item = EntIndexToHScript( itemIndex );
			if ( item && item.IsValid() )
			{
				// Check if the item’s classname matches the picked-up item
				local itemClass = item.GetClassname();
				if ( itemClass == itemName && itemData.glowing )
				{
					// Check if the item is now owned or invalid (picked up)
					if ( item.GetOwnerEntity() != null || !item.IsValid() )
					{
						DisableGlow( item );
						DisableLight( itemData );
						DroppedItems[ itemIndex ].glowing = false;
						delete DroppedItems[ itemIndex ]; // Remove from tracking since it’s picked up
						printl( "Glow disabled for picked-up item: " + itemName );
						break; // Exit loop after finding the match
					}
				}
			}
			else
			{
				// Item is invalid, likely picked up or removed
				if ( itemData.glowing )
				{
					DisableLight( itemData );
					delete DroppedItems[ itemIndex ]; // Clean up
				}
			}
		}
	}
}

// ===========================================
// 			UTILITY FUNCTIONS
// ===========================================

function CalcTotalProbability( list )
{
	local totalProb = 0;
	foreach( item in list )
		totalProb += item.prob;

	return totalProb;
}

// Spawns a random item.
function SpawnRandomItem( list, location )
{
	local spawnedItem = null;
	local probCount = RandomInt( 1, CalcTotalProbability( list ) );

	foreach( item in list )
	{
		if ( ( probCount -= item.prob ) <= 0 )
		{
			local lightColor = ( "lightColor" in item ) ? item.lightColor : "220 75 50";
			spawnedItem = CreateRandomLoot( item.ent, item.ammo, item.melee_type, location, lightColor );
			break;
		}
	}

	return spawnedItem;
}

// dumb hack way to mimick GetInt from TF2's VScript
function GetConVarInt( CVarName )
{
	local floatValue = Convars.GetFloat( CVarName )
	local lower = floor( floatValue )
	local upper = lower + 1

	if ( floatValue - lower < upper - floatValue )
	{
		return lower
	}
	else
	{
		return upper
	}
}

function GetMaxAmmo( ent )
{
	if ( ent in AmmoConfig )
	{
		local config = AmmoConfig[ ent ];
		return GetConVarInt( config[ 3 ] );
	}
	return 4; // Default fallback if weapon not in config
}

// Generates an entity table and spawns an item of the spaecified type.
function CreateRandomLoot( ent, ammo, melee_type, origin, lightColor = "220 75 50" )
{
	entTable <- {}

	if ( ent == null )
	{
		return;
	}
	else if ( ammo != null ) // Firearm
		entTable <-
		{
			targetname				= "random_spawned_item"
			classname				= ent
			origin					= origin
			angles					= Vector( 0, RandomFloat( 0, 360 ), ( RandomInt( 0, 1 ) * 180 - 90 ) )
			solid					= "6" // Vphysics
		}
	else if ( melee_type != null ) // Melee weapon
	{
		entTable <-
		{
			targetname				= "random_spawned_nontrackable"
			classname				= ent
			origin					= origin
			angles					= Vector( 0, RandomFloat( 0, 360 ), ( RandomInt( 0, 1 ) * 180 - 90 ) )
			solid					= "6" // Vphysics
			melee_weapon			= melee_type
			spawnflags				= "3"
		}
	}
	else if ( ent == "upgrade_spawn" ) // Laser upgrade
	{
		entTable <-
		{
			targetname				= "random_spawned_nontrackable"
			classname				= ent
			origin					= origin
			angles					= Vector( 0, RandomFloat( 0, 360 ), 0 )
			solid					= "6" // Vphysics
			laser_sight 			= 1
			upgradepack_incendiary 	= 0
			upgradepack_explosive 	= 0
		}
	}
	else if ( ( ent == "weapon_upgradepack_explosive" ) || ( ent == "weapon_upgradepack_incendiary" ) )
	{
		entTable <-
		{
			targetname				= "random_spawned_nontrackable"
			classname				= ent
			origin					= origin
			angles					= Vector( 0, RandomFloat( 0, 360 ), 0 )
			solid					= "6" // Vphysics
		}
	}
	else // Any other item
	{
		entTable <-
		{
			targetname				= "random_spawned_item"
			classname				= ent
			origin					= origin
			angles					= Vector( 0, RandomFloat( 0, 360 ), 0 )
			solid					= "6" // Vphysics
		}
	}

	local spawnedItem = SpawnEntityFromTable( entTable.classname, entTable );

	if ( spawnedItem && spawnedItem.IsValid() )
	{
		local currentTime = Time();

		// Assign a unique name to each item for director hints
		local uniqueName = "dropped_item_" + UniqueString();
		spawnedItem.__KeyValueFromString( "targetname", uniqueName );

		if ( RandomInt( 0, 5 ) == 1 )
	   		DisplayInstructorHint( LootDroppedHint, spawnedItem );

		// Add a 2 second delay to prevent sound spam.
		if ( currentTime >= SoundDelay )
		{
			EmitAmbientSoundOn( DropSound, 1.0, 85, RandomInt( 94, 106 ), spawnedItem );
			SoundDelay = currentTime + 2;
		}

		// Add a halo outline
 		NetProps.SetPropInt( spawnedItem, "m_Glow.m_iGlowType", 3 );
		NetProps.SetPropInt( spawnedItem, "m_Glow.m_glowColorOverride", 50 | ( 200 << 8 ) | ( 50 << 16 ) );
		NetProps.SetPropInt( spawnedItem, "m_Glow.m_bFlashing", 0 );
		NetProps.SetPropInt( spawnedItem, "m_Glow.m_nGlowRangeMin", 60 );
		NetProps.SetPropInt( spawnedItem, "m_Glow.m_nGlowRange", 300 );

		// Randomize Ammo
		if ( ent in AmmoConfig )
		{
			local config = AmmoConfig[ ent ];
			local clipAmmo = RandomInt( config[ 0 ], config[ 1 ] );
			local reserveMax = GetMaxAmmo( ent );
			local reserveAmmo = RandomInt( config[ 2 ], reserveMax );

			NetProps.SetPropInt( spawnedItem, "m_iClip1", clipAmmo );
			NetProps.SetPropInt( spawnedItem, "m_iExtraPrimaryAmmo", reserveAmmo );
		}

		// Apply random velocity
		local velocity = Vector( RandomFloat( -100, 100 ), RandomFloat( -100, 100 ), RandomFloat( 50, 150 ) );
		local angVelocity = Vector( RandomFloat( -150, 200 ), RandomFloat( -250, 150 ), RandomFloat( -5, 5 ) );
		spawnedItem.ApplyAbsVelocityImpulse( velocity );
		spawnedItem.ApplyLocalAngularVelocityImpulse( angVelocity )

		// Set the light glow
		local lightEnt = CreateLightGlow( spawnedItem, origin, lightColor );
		DroppedItems[ spawnedItem.GetEntityIndex() ] <- { spawnTime = Time(), glowing = true, lightEnt = lightEnt };
		return spawnedItem;
	}
	else
	{
		// Inem failed to create, this should never happen!
		return null;
	}
}

function SpawnParticleEffect( particleName, origin )
{
	local particleEnt = SpawnEntityFromTable( "info_particle_system",
	{
		targetname = "loot_poof_" + UniqueString(),
		origin = origin,
		effect_name = particleName,
		start_active = 0
	});

	return particleEnt;
}

function CreateLightGlow( item, origin, lightColor = "220 75 50" )
{
	local lightEnt = SpawnEntityFromTable( "light_dynamic",
	{
		targetname = "loot_light_" + UniqueString(),
		origin = origin,
		brightness = 2.65,	// 2.5
		_inner_cone = 0,
		_cone = 0,
		spotlight_radius = 24,	// 32
		distance = 38,
		//style = 2,
		_light = lightColor
	} );


	local particleEnt = SpawnEntityFromTable( "info_particle_system",
	{
		targetname = "loot_particle_" + UniqueString(),
		origin = origin,
		effect_name = "electrical_arc_01_cp0",
		start_active = 0
	} );

	return { light = lightEnt, particle = particleEnt };
}

function DisableGlow( ent )
{
	if ( ent && ent.IsValid() )
	{
		NetProps.SetPropInt( ent, "m_Glow.m_iGlowType", 0 );
		NetProps.SetPropInt( ent, "m_Glow.m_glowColorOverride", 0 );
	}
}

function DisableLight( itemData )
{
	if ( "lightEnt" in itemData )
	{
		if ( itemData.lightEnt.light && itemData.lightEnt.light.IsValid() )
		{
			itemData.lightEnt.light.Kill();
		}
		if ( itemData.lightEnt.particle && itemData.lightEnt.particle.IsValid() )
		{
			DoEntFire( "!self", "Stop", "", 0, null, itemData.lightEnt.particle );
			itemData.lightEnt.particle.Kill();
		}
	}
}

function DisplayInstructorHint( keyvalues, target = null, player = null )
{
	keyvalues.classname <- "env_instructor_hint";
	keyvalues.hint_auto_start <- 0;
	keyvalues.hint_allow_nodraw_target <- 1;

	if ( target && target.IsValid() )
	{
		keyvalues.hint_target <- target.GetName();
		keyvalues.hint_static <- 0;
	}
	else
	{
		// Static target for fallback
		if ( Entities.FindByName( null, "static_hint_target" ) == null )
			SpawnEntityFromTable( "info_target_instructor_hint", { targetname = "static_hint_target" } );

		keyvalues.hint_target <- "static_hint_target";
		keyvalues.hint_static <- 1;
		keyvalues.hint_range <- 0;
	}

	local hint = SpawnEntityFromTable( "env_instructor_hint", keyvalues );
	//printl( hint );

	if ( player )
	{
		DoEntFire( "!self", "ShowHint", "", 0, player, hint );
	}
	else
	{
		local player = null;
		while ( player = Entities.FindByClassname( player, "player" ) )
		{
			//printl( player );
			DoEntFire( "!self", "ShowHint", "", 0, player, hint );
		}
	}

	if ( keyvalues.hint_timeout && keyvalues.hint_timeout != 0 )
	{
		DoEntFire( "!self", "Kill", "", keyvalues.hint_timeout, null, hint );
	}

	return hint;
}

__CollectEventCallbacks( this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener );