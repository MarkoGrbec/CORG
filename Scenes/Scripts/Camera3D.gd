class_name Camera extends Node3D

@export var camera: Camera3D

var _current_mob_visuals

func _ready() -> void:
	g_man.camera = self

func rotate_camera(value):
	camera.rotate_x(value)
	var rot = camera.rotation.x
	rot = clampf(rot, deg_to_rad(-75), deg_to_rad(65))
	# reset the rotation
	camera.rotation = Vector3(rot, deg_to_rad(180), 0)

func get_point_position(event: InputEventMouse, _max_distance: float, option: String = "collider"):
	# if window isn't active
	if not g_man.inside_window(event.position):
		var space_state = get_world_3d().direct_space_state
		var end_ray = camera.project_position(event.position, 50)
		var query = PhysicsRayQueryParameters3D.create(global_position, end_ray)
		query.collide_with_bodies = true
		var result = space_state.intersect_ray(query)
		if result:
			return result[option]
