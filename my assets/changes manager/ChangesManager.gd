class_name ChangesManager extends VBoxContainer

var unix_time_last_char: float = 0

@export var top_parent: HBoxContainer
@export var changes_label: PackedScene

var key_changes: Dictionary[String, Variant]

var dict_changes: Dictionary[Variant, Variant]

var toggle_changes: bool = true

func _ready() -> void:
	g_man.changes_manager = self

func close_window():
	for change in key_changes.values():
		change.hide()
	toggle_changes = false

func open_window():
	for change in key_changes.values():
		change.show()
	toggle_changes = true

func change_opened_window():
	if toggle_changes:
		close_window()
	else:
		open_window()

func add_change(text: String):
	var change: Label = changes_label.instantiate()
	_add_child(change)
	var unix_now = Time.get_unix_time_from_system()
	var time_last_char = unix_time_last_char - unix_now
	if time_last_char < 0:
		unix_time_last_char = unix_now
	unix_time_last_char += text.length() * 0.075
	change.set_text_time(text, unix_time_last_char - unix_now)
	dict_changes[change] = unix_time_last_char - unix_now
	if dict_changes.size() > 5:
		var rm_time = 250
		var rm_change
		for rem_change in dict_changes:
			var check_time = dict_changes[rem_change]
			if rm_time > check_time:
				rm_change = rem_change
				rm_time = check_time
		unix_time_last_char -= rm_time
		remove_change(rm_change)

func remove_change(change):
	if dict_changes.erase(change):
		change.queue_free()

func add_key_change(key, text):
	var change = key_changes.get(key)
	if change == null:
		change = changes_label.instantiate()
		key_changes[key] = change
		_add_child(change)
	change.set_key_text(key, text)

func delete_changes():
	for change in key_changes.values():
		change.queue_free()
	key_changes.clear()

func _add_child(change: Label):
	add_child(change)
