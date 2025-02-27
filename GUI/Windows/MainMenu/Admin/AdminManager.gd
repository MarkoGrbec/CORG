class_name AdminManager extends TabContainer# inside main menu

const PLAYER_ID = preload("res://GUI/buttons/Admin/player_id.tscn")
@export var id_players_container: VBoxContainer
var dict_id__button = {}

func _ready() -> void:
	g_man.admin_manager = self

func _on_disconnect_all_pressed() -> void:
	g_man.local_network_node.cmd_disconnect_all_players.rpc_id(1)

func add_ids_player(ids):
	for id in ids:
		var button = PLAYER_ID.instantiate()
		id_players_container.add_child(button)
		button.text = str(id)
		dict_id__button[id] = button

func change_id_name(id__username):
	var button = dict_id__button.get(id__username[0])
	if button:
		button.text = id__username[1]
