extends Label

var time_to_disapear: float = 0.5

func set_text_time(_text, _time):
	time_to_disapear = _time
	text = _text
	await get_tree().create_timer(time_to_disapear).timeout
	g_man.changes_manager.remove_change(self)

func set_key_text(_key, _text):
	text = str(_key, ": ", _text)
