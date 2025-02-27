extends Button

func _ready():
	name = str(get_multiplayer_authority())
	text = name

func on_pressed():
	push_error("Disconnect peer ", get_multiplayer_authority())
	printerr("PlayerButton disconnect peer")
	if get_multiplayer_authority() != 1:
		multiplayer.multiplayer_peer.disconnect_peer(get_multiplayer_authority())
	else:
		multiplayer.multiplayer_peer.disconnect_peer(1)
		multiplayer.multiplayer_peer.close()
		await get_tree().create_timer(16).timeout
		get_tree().quit()

func change_button_name(button_name: String):
	text = button_name
