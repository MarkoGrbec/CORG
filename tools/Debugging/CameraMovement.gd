extends Node3D

@export var space: bool

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	var input_dir: Vector2
	if Input.is_action_pressed("forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("back"):
		input_dir.y += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1
	global_position += (global_basis * (Vector3(input_dir.x, 0, input_dir.y).normalized())) * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if space:
			transform = transform.rotated_local(Vector3.RIGHT, event.relative.y * 0.001)
			transform = transform.rotated_local(Vector3.UP, event.relative.x * -0.001)
		else:
			var vec3 = basis.get_euler()
			vec3 += Vector3(event.relative.y * 0.001, event.relative.x * -0.001, 0)
			basis = basis.from_euler(vec3)
