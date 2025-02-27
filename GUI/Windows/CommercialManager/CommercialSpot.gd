class_name CommercialSpot extends MarginContainer

@onready var texture_rect: TextureRect = $TextureRect

var spot_index

func show_picture(corg:Company):
	var picture_data:PictureData = corg.get_next_picture()
	if not picture_data:
		corg.delete_previous_picture()
		g_man.commercial_manager.give_free_spot(spot_index, corg)
		return
	texture_rect.texture = picture_data.get_texture()
	if not texture_rect.texture:
		corg.delete_previous_picture()
		g_man.commercial_manager.give_free_spot(spot_index, corg)
		return
	show()
	await get_tree().create_timer(2).timeout
	hide()
	g_man.commercial_manager.give_free_spot(spot_index, corg)
	g_man.local_network_node.net_corg_node.cmd_get_reward_commercial.rpc_id(1, picture_data.id_server)
