extends Node

func _input(event):
	if event.is_action_pressed("database"):
		g_man.database_reader.show_window()
