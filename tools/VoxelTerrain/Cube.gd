class_name Cube extends Node
var _object: Node3D
var _mesh: ImmediateMesh
var _bounds: AABB
var _min_x: int
var _min_y: int
var _min_z: int
var _max_x: int
var _max_y: int
var _max_z: int
var _terrain: VoxTerrain

const CUBE = preload("res://tools/VoxelTerrain/Cube.tscn")

func bounds():
	return _bounds

func mesh():
	return _mesh

## Create new mesh zone
func _init(client: bool, bounds: AABB, terrain):
		# Limit to this zone
		_min_x = int(bounds.position.x)
		_min_y = int(bounds.position.y)
		_min_z = int(bounds.position.z)
		_max_x = int(bounds.end.x)
		_max_y = int(bounds.end.y)
		_max_z = int(bounds.end.z)
		_bounds = bounds

		# Limit to all zone
		if terrain:
			_terrain = terrain
		_object = CUBE.instantiate()
		#_object.mesh = Mesh.new()
		_mesh = _object.mesh
		##TODO: no idea how to set it
		#var aabb: AABB = _mesh.get_aabb()
		#_object.custom_aabb = bounds
		#_object.mesh = ImmediateMesh.new()
		#_object.custom_aabb = bounds
		#aabb = _object.mesh.get_aabb()
		if client:
			_object.global_position += g_man.dp.client_offset
		#_object.layer = 7
		# Visuals
		#_object.name = "GroundVisuals"
		rebuild(false)
#
func rebuild(client: bool):
	var w = 128# _terrain.width
	var h = 128# _terrain.height
	var d = 128# _terrain.depth

	var vertices = []
	var triangles = []
	var uv_y = []
	var uv_z = []
	var colors = []

	## Delete old vertices and triangles mesh
	#_mesh.clear()
	
	if client:
		var data = MarchingCubes.polygonize(_terrain.client_map,
				_min_x, _min_y, _min_z,
				_max_x, _max_y, _max_z,
				vertices,
				triangles)
		vertices = data[0]
		triangles = data[1]
	else:
		var data = MarchingCubes.polygonize(_terrain.map,
				_min_x, _min_y, _min_z,
				_max_x, _max_y, _max_z,
				vertices,
				triangles)
		vertices = data[0]
		triangles = data[1]

	for i in len(vertices):
		# Planar with global position
		var v: Vector3 = vertices[i]
		
		# For top planar
		uv_y[i] = Vector2(v.x / w, v.z / d)

		# For side planar
		uv_z[i] = Vector2(v.x / w, v.y / h)

		var x = int(v.x)
		if x == 0:
			x = 1
		var y = int(v.y)
		if y == 0:
			y = 1
		var z = int(v.z)
		if z == 0:
			z = 1

		# Index of texture
		if client:
			colors[i] = VoxTerrain.instance.texture_channels[_terrain.client_colors[x][y][z]]
		else:
			colors[i] = VoxTerrain.instance.texture_channels[_terrain.colors[x][y][z]]

	## Apply mesh
	_mesh.vertices = vertices
	_mesh.indices = triangles
	_mesh.uv = uv_y
	_mesh.uv2 = uv_z
	_mesh.colors = colors

	_mesh.generate_normals()


## Rebuild collider after paint
func rebuild_collider() -> void:
	var mesh_collider = _object.get_node("MeshCollider") # Assuming _object is a reference to the parent node
	mesh_collider.shared_mesh = null
	if _mesh.get_vertex_count() > 0:
		mesh_collider.shared_mesh = _mesh

## Not used
func average_normals(normal1: Vector3, normal2: Vector3) -> void:
	var average = (normal1 + normal2) * 0.5
	normal1 = average
	normal2 = average

## Not used
func compute_vertex_normals() -> void:
	var normal_buffer = []
	var vertex_normal_neighbors = []
	
	for i in range(_mesh.get_vertex_count()):
		vertex_normal_neighbors.append([])

	var index_buffer = _mesh.get_indices()
	
	for i in range(0, index_buffer.size() - 3, 3):
		var normal = (_mesh.get_vertex(index_buffer[i + 2]) - _mesh.get_vertex(index_buffer[i])).normalized()
		normal = normal.cross((_mesh.get_vertex(index_buffer[i + 1]) - _mesh.get_vertex(index_buffer[i]))).normalized()

		vertex_normal_neighbors[index_buffer[i]].append(normal)
		vertex_normal_neighbors[index_buffer[i + 1]].append(normal)
		vertex_normal_neighbors[index_buffer[i + 2]].append(normal)

	for i in range(normal_buffer.size()):
		normal_buffer.append(Vector3.ZERO)
		for n in range(vertex_normal_neighbors[i].size()):
			normal_buffer[i] += vertex_normal_neighbors[i][n]
		normal_buffer[i] = normal_buffer[i].normalized()

	_mesh.normals = normal_buffer
