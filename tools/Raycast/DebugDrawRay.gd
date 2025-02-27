class_name DebugDrawRay extends MeshInstance3D

func _ready() -> void:
	g_man.debug_draw_ray = self

var array_trees = []

func draw_line(origin: Vector3, end_point: Vector3, color: Color = Color.RED, _time: float = 1):
	if origin.is_equal_approx(end_point):
		return
	if mesh is ImmediateMesh:
		mesh.clear_surfaces()
		
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		mesh.surface_set_color(color)
		
		mesh.surface_add_vertex(origin)
		mesh.surface_add_vertex(end_point)
		
		mesh.surface_end()

static func ray_cast(origin: Vector3, end_point: Vector3, collide_with_bodies: bool = true, collide_with_areas: bool = false):
	var space_state = g_man.debug_draw_ray.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, end_point)
	query.collide_with_bodies = collide_with_bodies
	query.collide_with_areas = collide_with_areas
	var result = space_state.intersect_ray(query)
	if result:
		return result
