class_name Enums extends Node

enum Esprite{
	nul										= 0,
	undefined								= 1,
	server_planet							= 2,
	client_planet							= 3,
	server_avatar							= 4,
	client_avatar							= 5,
	empty_server_avatar						= 6,
	empty_client_avatar						= 7,
#region resources 10 - 29
	rock									= 10,
	dirt									= 11,
	sand									= 12,
	clay									= 13,
	tar										= 14,
	peat									= 15,
	wood_log								= 16,
	ore										= 18,
	liquid									= 19,
	hard_metal								= 20,
#endregion resources 10 - 29
#region trees 30 - 100
	pine_tree_sprout						= 30,
	pine_tree_stump							= 31,
	pine_tree								= 32,
	pine_tree_cut							= 33,
	pine_spruce_cone						= 34,
	oak_tree_sprout							= 35,
	oak_tree_stump							= 36,
	oak_tree								= 37,
	oak_tree_cut							= 38,
	oak_Acorn								= 39,
	sprout									= 99,
	farm									= 100,
#endregion trees 30 - 100
#region players 200 - 249

#endregion players 200 - 249
#region animals 250 - 500
	mob_commander							= 250,
	mob_commander_client					= 251,
	mob_ghost								= 308,
	mob_ghost_client						= 309,
	mob_quest								= 310,
	mob_quest_client						= 311,
	mob_trader_client						= 313,
	mob_marketplace_client					= 315,
	mob_customer							= 316,
	mob_customer_client						= 317,
	empty_visual							= 350,
	kate_visual								= 351,
	zombie_naked_visual						= 352,
	jaku_visual								= 353,
	cop_zombie_visual						= 354,
	megan_visual							= 355,
	romeo_visual							= 356,
	worker_visual							= 357,
	naked_middle_aged_woman_visual			= 358,
#endregion animals 250 - 500
#region wall 1300 - 1349

#endregion wall 1300 - 1349
#region houses 1350 - 1500


#endregion houses 1350 - 1500
#region earth 1501 - 1550


#endregion earth 1501 - 1550
#region vehicles 1551 - 1600
	plan_entity								= 1551,
#endregion vehicles 1551 - 1600
#region fire places 1601 - 2000
	fire									= 1601,
	campfire								= 1602,
	torch									= 1603,
#endregion fire places 1601 - 2000
#region wood 5500 - 15000
	wood_scrap								= 5500,
	fire_wood								= 5501,
	wood_head								= 5502,
	wood_plank								= 5504,
	bow										= 5505,
	wooden_shaft							= 5506,
	arrow_shaft								= 5508,
	wooden_handle							= 5510,
	wooden_mallet							= 5512,
	kindling								= 5514,
	hole_plank								= 5516,
	peg										= 5518,
	chair									= 5520,
	barrel									= 5522,
	door									= 5524,
	chest									= 5526,
	bed										= 5528,
	bed_head_frame							= 5530,
	bed_feet_frame							= 5532,
	bed_body								= 5534,
	chair_backrest							= 5536,
	platform								= 5537,
	display_rack							= 5538,
	wheel_axis								= 10000,
	target									= 10001,
	wheel									= 10002,
	pulling_pole							= 10003,
#endregion wood 5500 - 14999
#region clay 15000-24999
	mold_arrow_tip							= 15000,
	mold_war_arrow_tip						= 15001,
	mold_crowbar							= 15002,
	mold_nail								= 15003,
	mold_hinge								= 15004,
	mold_knife_head							= 15005,
	mold_hatched_head						= 15006,
	mold_pickaxe_head						= 15007,
	mold_shovel_head						= 15008,
	mold_hammer_head						= 15009,
	raw_bowl								= 15010,
	#region hard clay 17500
	hard_mold_arrow_tip						= 17500,
	hard_mold_war_arrow_tip					= 17501,
	hard_mold_crowbar						= 17502,
	hard_mold_nail							= 17503,
	hard_mold_hinge							= 17504,
	hard_mold_knife_head					= 17505,
	hard_mold_hatched_head					= 17506,
	hard_mold_pickaxe_head					= 17507,
	hard_mold_shovel_head					= 17508,
	hard_mold_hammer_head					= 17509,
	bowl									= 17510,
	#endregion hard clay 17500
#endregion clay 15001-24999
#region metal 25000-40000
	metal_scrap								= 25000,
	arrow_tip								= 25001,
	war_arrow_tip							= 25003,
	crowbar									= 25005,
	nail									= 25007,
	ribbon									= 25009,
	hinge									= 25011,
	knife_head								= 25013,
	hatched_head							= 25015,
	pickaxe_head							= 25017,
	showel_head								= 25019,
	chiesel_head							= 25021,
	hammer_head								= 25023,

	hatchet									= 30000,
	carvingknife							= 30002,
	saw										= 30004,
	shovel									= 30006,
	pickaxe									= 30008,
	chiesel									= 30010,
	hammer									= 30012,

	huntingArrow							= 35001,
	warArrow								= 35003,
	sledge_hammer							= 35005,
#endregion metal 25001-40000
#region cotton 40001 - 50000


#endregion cotton 40001 - 50000
#region leader 50001 - 60000
	queviar									= 50001,
#endregion leader 50001 - 60000
#region ropes 60001 - 70000


#endregion ropes 60001 - 70000
#region food water 70001 - 80000
	pumpkin									= 70001,
	water									= 70002,
	pumpkin_flesh							= 70003,
	pumpkin_shell							= 70004,
	pumpkin_seed							= 70005,
#endregion food water 70001 - 80000
#region stone 80001 - 90000
	whetstone								= 80001,
	flattening_stone						= 80002,
#endregion stone 80001 - 90000
#region plan 90001 - 130000


#endregion plan 90001 - 130000
#region bullet and weapons 130001 - 150000
	bullet									= 130001,
	rifle									= 130002,
	rifle_mag								= 130003,
	rifle_bullet							= 130004,
#endregion bullet and weapons 130001 - 150000
#region containers inventory 150001 - 150999
	entity_visual_universal					= 150001,
	inventory								= 150002,
	belt									= 150003,
	right_hand								= 150004,
	mouth									= 150005,
	dead_inventory							= 150050,
	trader_inventory						= 150051,
	quest_inventory							= 150052,
	marketplace_inventory					= 150053,
#endregion containers inventory 150001 - 150999
#region 151000 - 160000 rewards
	small_loot_crate						= 151000,
	medium_loot_crate						= 151002,
	large_loot_crate						= 151004,
	loot_crate_key							= 151006,
	reward									= 151007,
#endregion 151000 - 160000 rewards
#region research and artifacts 160001 - 


#endregion research and artifacts 160001 - 169999
#region dungeon
	dungeon_entrance						= 170000,
	start_dungeon_node						= 170001,
	dungeon_node							= 170002,
	dungeon_door							= 170003,
	dungeon_floor							= 170004,
	dungeon_wall_poster						= 170005,
	dungeon_wall							= 170006,
	dungeon_trap_crush						= 170007,
	dungeon_middle_node						= 170008,
	dungeon_treasure						= 170009,
	dungeon_gold_coin						= 170010,
#endregion dungeon
}

enum entity_type{
	nul			= 0,
	tree_sprout = 1,
	tree		= 2,
	tree_stump	= 3,
	tree_cut	= 4,
	farm		= 5,
	clay		= 6,
	water		= 7,
	bow			= 8,
	torch		= 9
}

enum material{
	mix = 0,
	stone = 1,
	dirt = 2,
	sand = 3,
	clay = 4,
	tar = 5,
	wood = 6,
	iron = 7,
	water = 8,
	proteines = 9,
	fat = 10,
	carbon_hidrates = 11,
}

enum metal{
	noMetal,
	onlyMetal,
	metalAndMix
}

enum exp{
	nul = 0,
	dungeonering = 1,
	craft = 2,
	construct = 3,
	repair = 4,
	improve = 5,
	stick = 6,
	bow = 7,
	cross_bow = 8,
	spear = 9,
	sword = 10,
	hammer = 11,
	armor = 12,
	elbow_pads = 13,
	gloves = 14,
	chest = 15,
	shield = 16,
	helmet = 17,
	boots = 18,
	kneepads = 19,
	move = 20,
	lift = 21,
	run = 22,
	jump = 23,
	fight = 24,
	attack = 25,
	trap_placement = 26,
	defense = 27,
	head_on = 28,
	shield_bash = 29,
	dodge = 30,
	support = 31,
	cook_master = 32,
	poison = 33,
	cooking = 34,
	baking = 35,
	time_shifter = 36,
	speed_time = 37,
	slow_time = 38,
	medic = 39,
	imobilize = 40,
	bandage = 41,
	CPR = 42,
	technology = 43,
	nature_leftovers = 44,
	fishing = 45,
	wood_chopping = 46,
	digging = 47,
	mining = 48,
	farming = 49,
	sowing = 50,
	harvest = 51,
	ripping = 52,
	process_materials = 53,
	wood = 54,
	textile = 55,
	cotton = 56,
	leather = 57,
	wemp_fibre = 58,
	rope = 59,
	stone = 60,
	copper = 61,
	sheet = 62,
	chain = 63,
	bronze = 64,
	iron = 65,
	steel = 66,
	clay = 67
}

enum slider{
	time,
	health,
	stamina,
	mana,
	food
}

enum ani{
	idle,
	walking
}

enum flag_customer_calculate{
	success = 1,
	haggle = 2,
	rage_quit = 3
}

enum weapon_type{
	melee = 0,
	ranged = 1,
	throwable = 2
}
#public enum researchType : short{
	#nul,
	#ally_members,
	#invitation_speed,
	#trade,
	#
#}

#public enum Esprite : int{
	#test								= 199,
	#MOBHolder							= 200,
	#AvatarServer						= 201,
	#AvatarClient						= 202,
	#AvatarClientVisual1				= 203,

	#horse								= 226,
	#horse_Visuals						= 227,
	#NPC_Trader							= 298,
	#NPC_Trader_Visuals					= 299,
	#NPC_Customer						= 300,
	#NPC_Customer_Visuals				= 301,
	#MOB_Commander_Server				= 302,
	#MOB_Commander						= 304,
	#MOB_Commander_Visuals				= 305,
	#MOB_Minion							= 306,
	#MOB_Minion_Visuals					= 307,
	#MOB_Customer						= 308,
	#MOB_Customer_Visuals				= 309,
	
	#MobCommanderDead					= 501,

	#wallTotalMasterCreator				= 1301,
	#wallMasterCreator					= 1302,
	#wallSlaveCreator					= 1303,
	#wallTotalMaster					= 1304,
	#wallMaster							= 1305,
	#wallSmallSlave						= 1306,
	#wallLongSlave						= 1307,
	#house_frame_floor					= 1310,
	#house_frame_wall					= 1311,
	#house_frame_floor_visuals			= 1312,
	#house_frame_floor_check			= 1313,
	#house_frame_wall_visuals			= 1314,
	#house_frame_wall_check				= 1315,
	#house_wooden_floor_in_construction	= 1316,
	#house_wooden_floor					= 1317,
	#house_wooden_wall_in_construction	= 1318,
	#house_wooden_wall					= 1319,

	#GroundSphere						= 1501,

	#vehicleCart						= 1552,


	#Stone_block						= 14999,
	#Stone_block_cube					= 15000,
	#Stone_block_box					= 15001,
	#Stone_block_cube_check				= 15002,
	#Stone_block_box_check				= 15003,
	#//metal

	#EntityVisualUniversal				= 79999,
	#EntityVisualUniversals				= 80000,
	#bullets_bag						= 80001,
	#pistol_mag							= 80002,
	#pistol_mags						= 80003,
	#pistol								= 80004,
	#pistols							= 80005,
	#warehouse							= 80009,
	#ally_warehouse						= 80010,
	#backpack							= 80012,
	#backpacks							= 80013,
	#assault_rifle						= 80014,
	#assault_rifles						= 80015,
	#assault_rifle_mag					= 80016,
	#assault_rifle_mags					= 80017,
	#/*
	#head								= 150009,
	#torso								= 150000,
	#leftHand							= 150001,
	#rightHand							= 150002,
	#leftFinger							= 150005,
	#rightFinger						= 150006,
	#pants								= 150003,
	#leftBoot							= 150007,
	#rightBoot							= 150008,
	#back								= 150004,
	#*/

	#fists								= 150019,
	#bullet								= 150020,
	#pistol_bullet						= 150021,
	#pistol_bullets						= 150022,
	#rifle_bullet						= 150023,

	#minion_skull						= 160000,
	#minion_skulls						= 160001,
	#commander_skull					= 160002,
	#commander_skulls					= 160003,


#}
