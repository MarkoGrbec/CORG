class_name StoreCommercial extends MarginContainer
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var debug: Label = $HBoxContainer/VBoxContainer/debug

var _id_server_picture

func on_delete_pressed() -> void:
	g_man.local_network_node.net_corg_node.cmd_delete_id_commercial_picture.rpc_id(1, _id_server_picture)
	g_man.store_manager.delete_picture(_id_server_picture)

func show_picture(id_server_picture):
	debug.text = str(id_server_picture)
	_id_server_picture = id_server_picture
	var picture_data:PictureData = ConstructForClient.construct_client_shared_savable_multi(g_man.savable_multi_client__server_pictures, id_server_picture)
	texture_rect.texture = picture_data.get_texture()
	if not texture_rect.texture:
		var id_corg = g_man.local_network_node.client.load_return_employed_at_corg()
		if id_corg:
			g_man.local_network_node.net_corg_node.cmd_load_id_commercial_picture.rpc_id(1, id_corg, id_server_picture)
