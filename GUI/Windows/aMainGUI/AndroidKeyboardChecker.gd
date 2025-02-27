class_name AndroidKeyboardChecker extends Control

var y

func _ready() -> void:
	y = get_rect().size.y

func _process(_delta: float) -> void:
	if g_man.android:
		var y_v_keyboard = DisplayServer.virtual_keyboard_get_height()
		g_man.changes_manager.add_key_change("virtual keyboard", str(y_v_keyboard) )
		if y_v_keyboard:
			set_size(Vector2(get_global_rect().size.x, y - y_v_keyboard))
		else:
			set_size(Vector2(get_global_rect().size.x, y))
