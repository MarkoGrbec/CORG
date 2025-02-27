class_name CanvasControl extends Control

func _ready():
	g_man.global_canvas = self

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouse:
		#if g_man.inside_window(event.position):
			#g_man.pick_up_indicator.focus(true)
		#else:
			#g_man.pick_up_indicator.focus(false)

func get_global_canvas_rect():
	return get_global_rect()
