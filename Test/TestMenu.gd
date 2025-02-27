extends MenuButton

func _ready() -> void:
	get_popup().id_pressed.connect(call_me)

func _on_about_to_popup() -> void:
	pass

func call_me(id):
	print(id)
	#get_popup().set_item_checked(id, true)
