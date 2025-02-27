class_name VoxTerrain extends Node3D

## Brushes
enum OBJ {
	SPHERE,
	CUBE,
	RANDOM,
	PLANE,
	HEIGHTMAP
}

## Brush effects
enum EFFECT {
	ADD,
	SUB,
	PAINT
}

static var instance: VoxTerrain

var terrain_name: String = ""
var width: int = 128
var height: int = 128
var depth: int = 128
var res: int = 32

var first_load: bool = false

static var heightmap: ImageTexture = null
static var heightmap_depth: float = 0.20

var cubes: Array = []               # All cubes
var rebuild: Array = []             # Cubes for rebuild
var rebuild_collider: Array = []     # Cube Colliders for rebuild
var rebuild_collider_count: int = 0  # Number of colliders to rebuild

var cubes_client: Array = []
var rebuild_client: Array = []
var rebuild_collider_client: Array = []
var rebuild_collider_count_client: int = 0

## 3D arrays
var map
var client_map
var colors   # Use PoolIntArray for short arrays (16-bit)
var client_colors

## Material reference (if applicable)
var material: Material

## Texture channels (colors)
var texture_channels: Array = [
	Color(1.0, 0.0, 0.0, 0.0), # Texture 1
	Color(0.0, 1.0, 0.0, 0.0), # Texture 2
	Color(0.0, 0.0, 1.0, 0.0), # Texture 3
	Color(0.0, 0.0, 0.0, 1.0)  # White or no texture
]

var handler;
var handler_client



func _ready():
	if terrain_name == "":
		print("TerrainName is null. Variable TerrainName needs to be set.")
		return

	if get_node_or_null("Terrain") != null:
		get_node("Terrain").queue_free()  # Equivalent to DestroyImmediate in Unity
	handler = Node.new()
	handler.name = "Terrain"
	add_child(handler)

	if get_node_or_null("TerrainClient") != null:
		get_node("TerrainClient").queue_free()

	if not client_colors:
		client_colors = ArrayManipulation.create_multi_dimensional_array([width + 1, height + 1, depth + 1], 0)
#
	if not client_map:
		client_map = ArrayManipulation.create_multi_dimensional_array([width + 1, height + 1, depth + 1], 0)
#
	## Singleton pattern for instance
	instance = self
#
	cubes.clear()
	rebuild.clear()
	rebuild_collider.clear()
	rebuild_collider_count = 0
#
	cubes_client.clear()
	rebuild_client.clear()
	rebuild_collider_client.clear()
	rebuild_collider_count_client = 0
#
	## Load terrain if exists, or load empty world if not.
	#var loaded_from_file = load_map_from_file()

	#TODO: much more to translate
	var renderer:ImmediateMesh# = $ImmediateMesh

	if not material:
		material = renderer.surface_get_material(0)

	# Instantiate all cubes
	for x in range(width / res):
		for y in range(height / res):
			for z in range(depth / res):
				var cube_bounds = AABB(Vector3(x, y, z) * res, Vector3(res, res, res))
				var cube = Cube.new(false, cube_bounds, self)
				cubes.push_back(cube)

	if not map or not colors:
		map = ArrayManipulation.create_multi_dimensional_array([width + 1, height + 1, depth + 1], 0)
		
		colors = ArrayManipulation.create_multi_dimensional_array([width + 1, height + 1, depth + 1], 0)

		#TODO: uncomment
		#reset_map()

	#if loaded_from_file:
		#draw_loaded_map(false)
#
	#if heightmap != null:
		# Resize texture to equal terrain size
		#heightmap = scale_texture(heightmap, width, depth)
		#draw_terrain_from_heightmap()
#
	#rebuild_collider()
#
#func get_data_for_client() -> Dictionary:
	#var data: Dictionary = {}
	#
	#data["colors1d"] = save_load.colors_to_1D(colors, width, height, depth)
	#data["map1d"] = save_load.map_to_1D(map, width, height, depth)
	#
	#data["paramWidth"] = width
	#data["paramHeight"] = height
	#data["paramDepth"] = depth
	#
	#return data



func create_client_map(colors1d: Array, map1d: Array, param_width: int, param_height: int, param_depth: int):
	width = param_width
	height = param_height
	depth = param_depth
	_ready()  # Call the start function to initialize the terrain

	#TODO: uncomment
	#client_colors = save_load.colors_to_3D(colors1d, width, height, depth)
	#client_map = save_load.map_to_3D(map1d, width, height, depth)

	if get_node_or_null("TerrainClient") != null:
		get_node("TerrainClient").queue_free()  # Remove existing TerrainClient node

	handler_client = Node.new()
	handler_client.name = "TerrainClient"
	add_child(handler_client)

	#TODO: much more to translate
	var renderer:ImmediateMesh# = $ImmediateMesh

	if not material:
		material = renderer.surface_get_material(0)

	# Instantiate all cubes for the client
	for x in range(width / res):
		for y in range(height / res):
			for z in range(depth / res):
				var cube_bounds_client = AABB(Vector3(x, y, z) * res, Vector3(res, res, res))
				var cube_client = Cube.new(true, cube_bounds_client, self)
				cubes_client.append(cube_client)
	
	if not client_map or not client_colors:
		client_map = ArrayManipulation.create_multi_dimensional_array([width + 1, height + 1, depth + 1], 0)
		
		client_colors = ArrayManipulation.create_multi_dimensional_array([width + 1, height + 1, depth + 1], 0)
		
	#draw_loaded_map(true)
#
	#if heightmap != null:
		## Resize texture to equal terrain size
		#heightmap = scale_texture(heightmap, width, depth)
		#draw_terrain_from_heightmap()
#
	#rebuild_collider_client()

func _process(delta: float) -> void:
	# Build mesh for server cubes
	if rebuild.size() > 0:
		var data = rebuild.pop_back()
		data.rebuild(false)

	# Build collider for server cubes
	if rebuild_collider_count > 0:
		rebuild_collider_count -= 1
		var data = rebuild_collider.pop_back()
		data.rebuild_collider()

	# Build mesh for client cubes
	if rebuild_client.size() > 0:
		var data = rebuild_client.pop_back()
		data.rebuild(true)

	# Build collider for client cubes
	if rebuild_collider_count_client > 0:
		rebuild_collider_count_client -= 1
		var data = rebuild_collider_client.pop_back()
		data.rebuild_collider()


func draw_3d(position: Vector3, scale: Vector3, obj: int, brush_effect: int, texture_id: int, do_sculpt: bool, do_paint: bool, force: bool, material, drop: bool, client: bool = false) -> void:
	# Get point in terrain location
	var matrix = global_transform.affine_inverse()  # Equivalent to transform.worldToLocalMatrix
	position = matrix.xform(position)
	scale = matrix.basis.scale(scale)
	var bounds = AABB(position, scale)

	var sX = int(scale.x / 2) + 1
	var sY = int(scale.y / 2) + 1
	var sZ = int(scale.z / 2) + 1
	var bX = max(int(position.x) - sX, 1)
	var bY = max(int(position.y) - sY, 1)
	var bZ = max(int(position.z) - sZ, 1)
	var eX = min(int(position.x) + sX + 2, width - 2)
	var eY = min(int(position.y) + sY + 2, height - 2)
	var eZ = min(int(position.z) + sZ + 2, depth - 2)

	var center = bounds.position
	var sculpt_radius = min(min(bounds.size.x, bounds.size.y), bounds.size.z) / 2.0
	var paint_radius = sculpt_radius + 0.5

	# Inverse effect for subtraction
	if brush_effect == EFFECT.SUB:
		inverse_sphere_effect_for_subtraction(bX, eX, bY, eY, bZ, eZ, center, sculpt_radius, paint_radius, force, material, not drop, client)

	# Begin of effect
	match brush_effect:
		EFFECT.ADD:
			match obj:
				OBJ.CUBE: add_cube(bounds, bX, bY, bZ, eX, eY, eZ, texture_id, do_sculpt, do_paint)
				OBJ.SPHERE: add_sphere(bounds, bX, bY, bZ, eX, eY, eZ, texture_id, do_sculpt, do_paint, brush_effect, force, drop, client)
				OBJ.RANDOM: add_random(bounds, bX, bY, bZ, eX, eY, eZ, texture_id, do_sculpt, do_paint)
				OBJ.PLANE: add_plane(bounds, bX, bY, bZ, eX, eY, eZ, texture_id, do_sculpt, do_paint)
				OBJ.HEIGHTMAP: add_height_map(bounds,bX,bY,bZ,eX,eY,eZ,texture_id)

		EFFECT.SUB:
			match obj:
				OBJ.CUBE: add_cube(bounds,bX,bY,bZ,eX,eY,eZ,texture_id,false,false)
				OBJ.SPHERE: add_sphere(bounds,bX,bY,bZ,eX,eY,eZ,texture_id,false,false,EFFECT.SUB,false,false,false)
				OBJ.RANDOM: add_random(bounds,bX,bY,bZ,eX,eY,eZ,texture_id,false,false)
				OBJ.PLANE: add_plane(bounds,bX,bY,bZ,eX,eY,eZ,texture_id,false,false)

	# End effect

	# Inverse effect for subtraction again
	if brush_effect == EFFECT.SUB:
		inverse_sphere_effect_for_subtraction(bX,eX,bY,eY,bZ,eZ,
											  center,
											  sculpt_radius,
											  paint_radius,
											  force,
											  material,
											  not drop,
											  client)

	# Rebuild map in this bounds
	bounds.position = Vector3(bX,bY,bZ)
	
	if client:
		rebuild_client_bounds(bounds)
		_rebuild_collider_client()
	else:
		rebuild_bounds(bounds)
		_rebuild_collider()

func sphere_has_rock(position: Vector3 , scale: Vector3 , client: bool = false) -> bool:
	# Get point in terrain location
	var matrix = global_transform.affine_inverse()
	position = matrix.xform(position)
	scale = matrix.basis.scale(scale)
	
	var bounds = AABB(position , scale)

	var sX = int(scale.x / 2) + 1
	var sY = int(scale.y / 2) + 1
	var sZ = int(scale.z / 2) + 1
	var bX = max(int(position.x) - sX , 1)
	var bY = max(int(position.y) - sY , 1)
	var bZ = max(int(position.z) - sZ , 1)
	
	var eX = min(int(position.x) + sX + 2 , width - 2)
	var eY = min(int(position.y) + sY + 2 , height - 2)
	var eZ = min(int(position.z) + sZ + 2 , depth - 2)

	
	var center = bounds.position
	var sculpt_radius = min(min(bounds.size.x , bounds.size.y),bounds.size.z)/2.0
	var paint_radius = sculpt_radius + 0.5
	
	for x in range(bX , eX):
		for y in range(bY , eY):
			for z in range(bZ , eZ):
				var dist_to_center = position.distance_to(Vector3(x , y , z))
				var dist = (dist_to_center - sculpt_radius) * 255

				dist = (dist_to_center - paint_radius) * 255
				
				# Get sphere paint
				if client:
					if dist < 255 and client_colors[x][y][z] == 1:
						return true
				else:
					if dist < 255 and colors[x][y][z] == 1:
						return true
	
	return false

## Inverse effect for subtraction
func inverse_sphere_effect_for_subtraction(bx:int , ex:int , by:int , ey:int , bz:int , ez:int ,
												   center:Vector3 ,
												   sculpt_radius:float ,
												   paint_radius:float ,
												   force:bool ,
												   material ,
												   dig:bool ,
												   client:bool ) -> void:

	for x in range(bx , ex):
		for y in range(by , ey):
			for z in range(bz , ez):
				var dist_to_center = position.distance_to(Vector3(x,y,z))
				var dist =(dist_to_center - sculpt_radius)*255

				dist =(dist_to_center - paint_radius)*255
				
				if client:
					client_map[x][y][z] =(int)(255-client_map[x][y][z])
				else:
					map[x][y][z] = (int)(255-map[x][y][z])

				# Get all the materials
				if dig and !client and dist <255 and material != null:
					var index=colors[x][y][z]
					if index <4:
						material[index]+=1
					else:
						print("white or empty??? ",index)

func height_map_draw_3d(position : Vector3 , scale : Vector3 , texture_id : int ) -> void:

	var bounds=AABB(position , scale)

	var size=int(scale.x/2)+1
	
	var bX=max(int(position.x)-size ,1)
	var bY=max(int(position.y)-size ,1)
	var bZ=max(int(position.z)-size ,1)
	var eX=min(int(position.x)+size+2,width-2)
	var eY=min(int(position.y)+size+2,height-2)
	var eZ=min(int(position.z)+size+2,width-2)

	# Draw spheres to represent 3D pixels
	var center=bounds.position
	
	var radius=scale.x/2
	
	for x in range(bX,eX):
		for y in range(bY,eY):
			for z in range(bZ,eZ):
				var dist=(position.distance_to(Vector3(x,y,z))-radius)*255
				
				# Sphere equation
				var bVal= clamp(dist ,0 ,255).to_byte()
				
				if bVal < map[x][y][z]:
					map[x][y][z]=bVal
				
				# Paint sphere
				colors[x][y][z]=texture_id
				
# Save level
func save_map(file_name: String) -> void:
	pass
	#SaveLoad.save_map(_map, _colors, width, height, depth, file_name, _material)

# Load level
func load_map(file_name: String) -> void:
	pass
	# Call load_map to get saved terrain
	#SaveLoad.load_map(file_name, width, height, depth, _map, _colors, _material)

func load_map_from_file() -> bool:
	return false
	#var path = "res://VoxelLevels/" + TerrainName + ".bytes"
	# For mobile devices, use persistent data path instead
	#if OS.get_name() == "Android" or OS.get_name() == "iOS":
		#path = OS.get_user_data_dir() + "/VoxelLevels/" + TerrainName + ".bytes"

	#if FileAccess.file_exists(path):
		#load_map(TerrainName)
		#return true
	#else:
		#if not first_load:
			#print("Warning: Terrain at path: (" + path + ") does not exist. Loading empty world.")
		#return false

func draw_loaded_map(client: bool) -> void:
	# Rebuild loaded terrain
	var scale = Vector3(width, height, depth) * 2
	var matrix = global_transform.affine_inverse()
	var position = Vector3.ZERO
	position = matrix.xform(position)
	scale = matrix.basis.scale(scale)
	
	var bounds = AABB(position, scale)
	
	var sX = int(scale.x / 2) + 1
	var sY = int(scale.y / 2) + 1
	var sZ = int(scale.z / 2) + 1
	
	var bX = max(int(position.x) - sX, 1)
	var bY = max(int(position.y) - sY, 1)
	var bZ = max(int(position.z) - sZ, 1)
	
	var eX = min(int(position.x) + sX + 2, width - 2)
	var eY = min(int(position.y) + sY + 2, height - 2)
	var eZ = min(int(position.z) + sZ + 2, depth - 2)

	# Rebuild map in this bounds
	bounds.position = Vector3(bX, bY, bZ)

	if client:
		rebuild_client_bounds(bounds)
	else:
		rebuild_bounds(bounds)

static func create_new_terrain(level_name: String, width: int, height: int, depth: int, chunk_res: int) -> VoxTerrain:
	var old_terrain #= get_tree().get_root().get_node("VoxTerrain") # Assuming VoxTerrain is a singleton or unique node

	var loaded_terrain #= Node.new()
	var vox_terrain #= loaded_terrain.add_child(VoxTerrain.new())
	
	vox_terrain.TerrainName = level_name
	vox_terrain.name = "VTerrain"
	
	vox_terrain.width = width
	vox_terrain.height = height
	vox_terrain.depth = depth
	vox_terrain.RES = chunk_res
	vox_terrain.first_load = true

	if old_terrain != null:
		if Engine.is_editor_hint():
			old_terrain.queue_free()
		else:
			old_terrain.queue_free()

	return vox_terrain

static func load_from_file(level_name: String) -> VoxTerrain:
	var old_terrain #= get_tree().get_root().get_node("VoxTerrain") # Assuming VoxTerrain is a singleton or unique node

	var loaded_terrain #= Node.new()
	var vox_terrain #= loaded_terrain.add_child(VoxTerrain.new())
	
	vox_terrain.TerrainName = level_name
	vox_terrain.name = "VTerrain"

	if old_terrain != null:
		if Engine.is_editor_hint():
			old_terrain.queue_free()
		else:
			old_terrain.queue_free()

	return vox_terrain

static func save_to_file(vox_terrain: VoxTerrain, file_name: String = "") -> void:
	if file_name == "":
		file_name = vox_terrain.TerrainName
	else:
		vox_terrain.TerrainName = file_name

	#SaveLoad.save_map(vox_terrain._map, vox_terrain._colors, vox_terrain.width, vox_terrain.height, vox_terrain.depth, file_name, vox_terrain._material)
	
	
	
	# Effects
func add_plane(bounds: AABB, bX: int, bY: int, bZ: int, eX: int, eY: int, eZ: int, texture_id: int, do_sculpt: bool, do_paint: bool) -> void:
	# Average height between min and max
	var height = (bY + eY) / 2

	if do_sculpt:
		for x in range(bX, eX):
			for z in range(bZ, eZ):
				map[x][height][z] = 0

	if do_paint:
		for x in range(bX - 1, eX):
			for y in range(height - 1, height + 1):
				for z in range(bZ - 1, eZ):
					colors[x][y][z] = texture_id

func add_cube(bounds: AABB, bX: int, bY: int, bZ: int, eX: int, eY: int, eZ: int, texture_id: int, do_sculpt: bool, do_paint: bool) -> void:
	if do_sculpt and do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					map[x][y][z] = 0

		for x in range(bX - 1, eX):
			for y in range(bY - 1, eY):
				for z in range(bZ - 1, eZ):
					colors[x][y][z] = texture_id
	elif do_sculpt and not do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					map[x][y][z] = 0
	elif not do_sculpt and do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					colors[x][y][z] = texture_id
					


# Effects
func add_sphere(bounds: AABB, bX: int, bY: int, bZ: int, eX: int, eY: int, eZ: int, texture_id: int, do_sculpt: bool, do_paint: bool, effect: int, force: bool, drop: bool, client: bool = false) -> void:
	var center = bounds.position
	var sculpt_radius = min(min(bounds.size.x, bounds.size.y), bounds.size.z) / 2.0
	var paint_radius = sculpt_radius + 0.5
	var paint_only_radius = sculpt_radius - 1.0

	# Add extra space for more accurate check
	bX -= 2; bX = max(bX, 1)
	bY -= 2; bY = max(bY, 1)
	bZ -= 2; bZ = max(bZ, 1)

	eX += 2; eX = min(eX, width - 2)
	eY += 2; eY = min(eY, height - 2)
	eZ += 2; eZ = min(eZ, depth - 2)

	if do_sculpt and do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					# Get distance for marching cubes
					var dist_to_center = center.distance_to(Vector3(x, y, z))
					var dist = (dist_to_center - sculpt_radius) * 255
					var b_val = clamp(int(dist), 0, 255)

					dist = (dist_to_center - paint_radius) * 255
					# Paint sphere
					if dist < 255:
						if effect == EFFECT.ADD and not force:
							if not drop:
								if client:
									client_colors[x][y][z] = texture_id
								else:
									colors[x][y][z] = texture_id
							else:
								# Don't paint rock
								if client:
									if client_colors[x][y][z] != 1:
										client_colors[x][y][z] = texture_id
								else:
									if colors[x][y][z] != 1:
										colors[x][y][z] = texture_id

					var xyz = map[x][y][z]
					if client:
						xyz = client_map[x][y][z]

					if b_val < xyz:
						if client:
							client_map[x][y][z] = b_val
						else:
							map[x][y][z] = b_val

	elif do_sculpt and not do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					# Get distance for marching cubes
					var dist_to_center = center.distance_to(Vector3(x, y, z))
					var dist = (dist_to_center - sculpt_radius) * 255
					var b_val = clamp(int(dist), 0, 255)

					var xyz = map[x][y][z]
					if client:
						xyz = client_map[x][y][z]

					if b_val < xyz:
						if client:
							client_map[x][y][z] = b_val
						else:
							map[x][y][z] = b_val

	elif not do_sculpt and do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					# Get distance for marching cubes
					var dist_to_center = center.distance_to(Vector3(x, y, z))
					var dist = (dist_to_center - paint_only_radius) * 255

					# Paint sphere
					if dist < 255:
						if client:
							if not (client_colors[x][y][z] == 1 and not drop):
								client_colors[x][y][z] = texture_id
						else:
							if not (colors[x][y][z] == 1 and not drop):
								colors[x][y][z] = texture_id




# Effects
func add_random(bounds: AABB, bX: int, bY: int, bZ: int, eX: int, eY: int, eZ: int, texture_id: int, do_sculpt: bool, do_paint: bool) -> void:
	var center = bounds.position
	var sculpt_radius = min(min(bounds.size.x, bounds.size.y), bounds.size.z) / 2.0
	var paint_radius = sculpt_radius + 1.0
	var paint_only_radius = sculpt_radius - 1.0

	# Add extra space for more accurate check
	bX -= 2; bX = max(bX, 1)
	bY -= 2; bY = max(bY, 1)
	bZ -= 2; bZ = max(bZ, 1)

	eX += 2; eX = min(eX, width - 2)
	eY += 2; eY = min(eY, height - 2)
	eZ += 2; eZ = min(eZ, depth - 2)

	if do_sculpt and do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					# Get distance for marching cubes
					var dist_to_center = center.distance_to(Vector3(x, y, z))
					var dist = (dist_to_center - sculpt_radius) * 0.5
					dist += randf() # Random value between 0 and 1
					var b_val = clamp(int(dist * 255), 0, 255)

					if b_val < map[x][y][z]:
						map[x][y][z] = b_val

					dist = (dist_to_center - paint_radius) * 255
					if dist < 255:
						colors[x][y][z] = texture_id

	elif do_sculpt and not do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					# Get distance for marching cubes
					var dist = (center.distance_to(Vector3(x, y, z)) - sculpt_radius) * 0.5
					dist += randf() # Random value between 0 and 1
					var b_val = clamp(int(dist * 255), 0, 255)

					if b_val < map[x][y][z]:
						map[x][y][z] = b_val

	elif not do_sculpt and do_paint:
		for x in range(bX, eX):
			for y in range(bY, eY):
				for z in range(bZ, eZ):
					# Get distance for marching cubes
					var dist = (center.distance_to(Vector3(x, y, z)) - paint_only_radius) * 0.5
					dist += randf() # Random value between 0 and 1

					if dist < 255:
						colors[x][y][z] = texture_id


func add_height_map(bounds: AABB, bX: int, bY: int, bZ: int, eX: int, eY: int, eZ: int, texture_id: int) -> void:
	var pixel_size = Vector3(13.0, 13.0, 13.0)
	var y_depth = depth * heightmap_depth

	for x in range(height):
		for z in range(width):
			var y_size = int(get_avg_height(x, z) * y_depth)
			for y in range(y_size):
				if y > y_size - 2:
					var pos = Vector3(x, y, z)
					height_map_draw_3d(pos, pixel_size, texture_id)

				if (x < 2 or z < 2 or x > width - 2 or z > height - 2):
					var pos_edge = Vector3(x, y, z)
					height_map_draw_3d(pos_edge, pixel_size, texture_id)


# Used for heightmap
func get_avg_height(x: int, z: int) -> float:
	if (x < 2 or z < 2 or x > width - 2 or z > height - 2):
		return heightmap.get_pixel(x,z).a

	var two = heightmap.get_pixel(x + 1,z).a
	var three = heightmap.get_pixel(x,z + 1).a
	var four = heightmap.get_pixel(x - 1,z).a
	var five = heightmap.get_pixel(x,z - 1).a

	return (two + three + four + five) / 4.0




# Initialize all points in map to val
func reset_map() -> void:
	for x in range(width + 1):
		for y in range(height + 1):
			for z in range(depth + 1):
				map[x][y][z] = 255

	for x in range(10, width + 1, 10):
		for y in range(10, height + 1, 10):
			for z in range(10, depth + 1, 10):
				for ix in range(x - 10, x):
					for iy in range(y - 10, y):
						for iz in range(z - 10, z):
							colors[ix][iy][iz] = 3

	_rebuild()


# Rebuild this cube
func rebuild_cube(cube: Cube) -> void:
	# Add mesh to rebuild list
	if not rebuild.has(cube):
		rebuild.push_back(cube)

	# Add mesh collider to rebuild list
	if not rebuild_collider.has(cube):
		rebuild_collider.push_back(cube)


func rebuild_client_cube(cube: Cube) -> void:
	# Add mesh to rebuild list
	if not rebuild_client.has(cube):
		rebuild_client.push_back(cube)

	# Add mesh collider to rebuild list
	if not rebuild_collider_client.has(cube):
		rebuild_collider_client.push_back(cube)


# Rebuild all cubes in bounds of effect
func rebuild_bounds(bounds: AABB) -> void:
	for cube in cubes:
		if bounds.intersects(cube.bounds):
			rebuild_cube(cube)


func rebuild_client_bounds(bounds: AABB) -> void:
	for cube in cubes_client:
		if bounds.intersects(cube.bounds):
			rebuild_client_cube(cube)


# Rebuild all cubes
func _rebuild() -> void:
	for cube in cubes:
		rebuild_cube(cube)


# Rebuild collider after Draw3D
func _rebuild_collider() -> void:
	# Get the count for ReBuild, for reduction of time process
	rebuild_collider_count_client = rebuild_collider.size()


func _rebuild_collider_client() -> void:
	# Get the count for ReBuild, for reduction of time process
	rebuild_collider_count_client = rebuild_collider_client.size()


# Called once to draw empty plane (default terrain)
func draw_plane_terrain() -> void:
	# Load empty terrain (plane)
	draw_3d(Vector3(width / 2, 1, depth / 2), Vector3(width, 1, depth), OBJ.PLANE, EFFECT.ADD, 0, true, true, true, null, false)
	
	# Move camera right to get space from all sides (first voxel is at (0,0,0) position)
	get_tree().current_scene.get_node("Camera").position = Vector3(width / 2, 25, -25)


# Called once to draw terrain from heightmap
func draw_terrain_from_heightmap() -> void:
	# Load terrain (heightmap)
	draw_3d(Vector3(width / 2, 0, height / 2), Vector3(width, depth, height), OBJ.HEIGHTMAP, EFFECT.ADD, 0, true, true, true, null, false)
	
	draw_plane_terrain()
	
	# Move camera right to get space from all sides (first voxel is at (0,0,0) position)
	#get_tree().current_scene.get_node("Camera").position = Vector3(width / 2, 25, -25)
	#get_tree().current_scene.get_node("Camera").rotate_y(deg2rad(45))


# Add terrain chunk
func add_object(client: bool) -> Node:
	var obj: Node
	
	if not client:
		obj = Node.new()
		obj.name = "Cube" + str(cubes.size())
		obj.set_parent(handler)
	else:
		obj = Node.new()
		obj.name = "CubeClient" + str(cubes_client.size())
		obj.set_parent(handler_client)

	#obj.add_child(MeshInstance.new())
	#
	#var mesh_renderer = obj.get_node("MeshInstance")
	#mesh_renderer.material_override = get_node("MeshInstance").material_override
	#
	#obj.add_child(MeshCollider.new())
	
	return obj


func scale_texture(source: ImageTexture, target_width: int, target_height: int) -> ImageTexture:
	var result = ImageTexture.new()
	
	result.create(target_width, target_height, false, source.get_format(), source.get_flags())
	
	var rpixels = result.get_data().get_pixels(0)
	
	var inc_x = (1.0 / source.get_width()) * (source.get_width() / target_width)
	var inc_y = (1.0 / source.get_height()) * (source.get_height() / target_height)

	for px in range(rpixels.size()):
		rpixels[px] = source.get_data().get_pixel_bilinear(inc_x * (px % target_width), inc_y * floor(px / target_width))

	result.set_data(rpixels)
	
	return result


func _on_Destroy():
	if OS.is_debug_build():
		pass
		# Uncomment this section if you want to save on destroy
		# if (_saveOnDestroy):
		#     print("Saving terrain on destroy")
		#     VoxTerrain.Instance.save_map(TerrainName)
