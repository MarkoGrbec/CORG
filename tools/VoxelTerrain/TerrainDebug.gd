extends Node

var res = 32

func _ready() -> void:
	
	var cube_bounds = AABB(Vector3(0, 0, 0) * res, Vector3(res, res, res))
	Cube.new(false, cube_bounds, null)
