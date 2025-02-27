class_name EntityObject extends Resource
#region general inputs
@export var entity_num: Enums.Esprite
@export_multiline var description: String
@export_group("general")
@export var scene: PackedScene
@export var texture: Texture
@export var house_frame: int
#endregion general inputs
#region entity inputs

@export_group("entity type")
## to which entity it'll transform if I'll be planted
@export var entity_type: Enums.entity_type
@export var scrap_type: Enums.Esprite = Enums.Esprite.undefined
@export var is_key: bool = false

@export_group("change type")
## to which entity it'll transform if it will be given in this inventory: undefined it'll not be transformed
## and new tree type
@export var new_entity: Enums.Esprite = Enums.Esprite.undefined
## what kind of tree is it going to fall
@export var fallen_tree_type: Enums.Esprite = Enums.Esprite.undefined
## what kind of stump is it going to be at bottom of the tree
@export var tree_stump_type: Enums.Esprite = Enums.Esprite.undefined
## to which hard clay will become if it'll reach 900°C
@export var new_clay_type: Enums.Esprite = Enums.Esprite.undefined
## to which entity will become liquid metal once it cools down in this mold
@export var new_hard_metal_type: Enums.Esprite = Enums.Esprite.undefined

@export_group("compatibility")
## only entities can get in this inventory 
## if 0 all entities can get in to this inventory
@export var compatibility: Array[Enums.Esprite]
## in what containers am I compatible usually used for water
## if 0 means all containers
@export var i_am_compatible: Array[Enums.Esprite]
## number of entities it can recieve in to the inventory 0 = infinity
@export var inventory_quantity: int = 0
## can I be sold
@export var sellable: bool = false

@export_group("construction")
## key tool,
## value result
## add tool with which this workpiece will be modified and end gain end results
@export var dict_transform_tool__results: Dictionary[Enums.Esprite, Array]
## what entities will it have if it will be constructed
@export var construct_materials: Array[Enums.Esprite]

@export_group("material")
## what materials does it have
@export var type_material: Enums.material
## additional materials for food in pair with weight_materials
@export var type_materials: Array[Enums.material]
## and how much they have ratio in pair with type_materials 0 - 1
@export var weight_ratio_materials: Array[float]
## what kind of metal type is it
@export var type_metal: Enums.metal

@export_group("craft")
## with which tools it can be improved
@export var improvable_tools: Array[Enums.Esprite]
## if the item can be improved
@export var is_improvable: bool
## if it can be combined with same type of entity
@export var is_combinable: bool
## if it can be devided in to more same type entities
@export var is_dividable: bool
## if can be repaired with whetstone
@export var is_sharpable: bool = false
## how much weight it can recieve per 1 dm^3 (l)
@export var clay_mold_volume_ratio: float
## how much stanina it'll drain by using 0 - 1
@export var hard_use: float = 0.5

@export_group("world space")
@export var is_top_inventory: bool
## when it's transformed from another entity it could go in to world space OR if false inventory
@export var in_world_space: bool
## if it can be shown in hands either world space or equipable else nothing is in hands visual
@export var equipable: bool
## currently needed only for loading
@export var attachable: bool = false

@export_group("default parameters")
## how will every entity look like in beginning
@export var default_visual_entity: Enums.Esprite = Enums.Esprite.undefined
## if entity is container it can get other items in self
@export var is_container: bool
## quality level
@export var ql: float = 100
## kg
@export var weight_get = 1.0
## dm^3
@export var volume_get = 1.0
## gold coins
@export var cost: int
## how hard is it to create / imp / repair
@export var hard: float = 1

@export_group("timers")
## minimum moving time
@export var time_to_finish_min: float = 1
## maximum moving time
@export var time_to_finish_max: float = 2
## minimum crafting time
@export var time_to_create_min: float = 1
## maximum crafting time
@export var time_to_create_max: float = 2
## minimum using time combat
@export var time_to_use_min: float = 1
## maximum using time combat
@export var time_to_use_max: float = 2
## improving time
@export var time_to_improve: float = 1

## stump and cut tree must be same as tree
@export_group("tree and farm")
## maximum time to grow ## is multiplied with grow scale ## stump and cut tree must be same as tree
@export var grow_time: float = 1
## maximum scale of tree or farm ## stump and cut tree must be same as tree
@export var grow_scale: float = 1

## usually for farm or fruit trees maybe I'll need to include seesion but later
@export_group("harvest")
## what can be harvested at peek of the growth
@export var harvest_type: Enums.Esprite
## what tool is needed to harvest undefined non is needed
@export var harvest_tool: Enums.Esprite = Enums.Esprite.undefined
## how many can be harvested
@export var harvest_quantity: int
## when is peek of harvest to be harvested from 0 - grow_scale
@export var harvest_scale: float = 1

@export_group("attack defense")
## how much does attack item
@export var attack: float = 1
## how much does defend item
@export var defense: float = 1
## how much range attack does it do
@export var range_attack: float = 1
## weapon_type
@export var weapon_type: Enums.weapon_type = Enums.weapon_type.melee

@export_group("sounds")
@export var working_sound: AudioStream
@export var is_sound_on_end: bool
## delay time between sounds
@export var delay_sound: float

@export_group("experience")
@export var experience_create_parent: Enums.exp = Enums.exp.nul
@export var experience_create: Array[Enums.exp]
@export var experience_move: Enums.exp = Enums.exp.support
@export var experience_use: Enums.exp = Enums.exp.nul

## volume / weight
var ratio_get = 1
var _pool = []
const K_EXP_CAP = 0.001
#endregion entity
#func get_attack_strength(entity, _weapon_type):
	#var i_obj = mp.get_item_object(entity.entity_num)
	##if it's hand don't use much attack
	#if i_obj.is_top_inventory:
		#return attack
	#if _weapon_type == Enums.weapon_type.melee:
		#return entity.ql * K_EXP_CAP * attack
	#else:
		#return entity.ql * K_EXP_CAP * range_attack

func get_defense_strength(entity):
	return entity.ql * K_EXP_CAP * defense

func get_raw_defense(damage):
	return clampf(damage / defense, 0, 1000)

func calc_ratio():
	ratio_get = volume_get / weight_get

## which objects can go in to this inventory
func is_compatible(child: int):
	if len(compatibility) == 0:
		return true
	for item in compatibility:
		# liquid has a special place it can fit everywhere
		if item == child or child == Enums.Esprite.liquid:
			return true
	return false

## only for bullets with no type in to which weapon it can go
func get_new_bullet_type(bullet):
	if bullet == Enums.Esprite.bullet:
		if new_entity != Enums.Esprite.undefined:
			return new_entity
	return bullet

## add to pool
func push(node: Node):
	_pool.push_back(node)
	node.reparent(g_man.map)
	if node is Node3D and node.is_visible_in_tree():
		node.hide()
	if node is Node3D:
		node.global_position = Vector3(-3000, -3000, -3000)

## Rremove from pool
func pop():
	if not scene:
		push_error(String("index: [{i}] selected Entity: [{e}] does not have a scene").format({i = entity_num, e = Enums.Esprite.find_key(entity_num)}))
	elif _pool.size() == 0:
		var instance = scene.instantiate()
		g_man.map.add_child(instance)
		#get script and set it's base to the index so that we have numbered them
		instance.entity_num = entity_num
		instance.entity_string = Enums.Esprite.find_key(entity_num)
		return instance
	else:
		var instance = _pool.pop_back()
		instance.entity_string = Enums.Esprite.find_key(entity_num)
		if instance is Node3D:
			instance.show()
		return instance

## if this object can be processed with provided tool
func get_workpieces(tool):
	var results = dict_transform_tool__results.get(tool)
	return results

## if this object creates next result
func can_be_created_result(tool_entity_num, result):
	if dict_transform_tool__results[tool_entity_num].has(result):
		return true
	return false

## if this workpiece can be processed with certain tool
func is_made_with_tool(tool):
	if dict_transform_tool__results.has(tool):
		return true
	return false

## free pool to the desired amount
func empty(left):
	if left < 0:
		left = 0
	while left < _pool.size():
		var temp = _pool.pop_back()
		temp.queue_free()

func to_string_name():
	return str(Enums.Esprite.find_key(entity_num)).replace("_", " ")
