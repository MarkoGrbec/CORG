class_name CommercialManager extends Node

func _ready() -> void:
	g_man.commercial_manager = self
	var master = get_child(0)
	var left = master.get_child(0)
	var right = master.get_child(1)
	for id_child in left.get_child_count():
		var spot:CommercialSpot = left.get_child(id_child)
		commercial_spots.push_back(spot)
		spot.spot_index = index
		index_comercials_spots.push_back(index)
		index += 1
	for id_child in right.get_child_count():
		var spot:CommercialSpot = right.get_child(id_child)
		commercial_spots.push_back(spot)
		spot.spot_index = index
		index_comercials_spots.push_back(index)
		index += 1

var client_commercials_wait
var commercial_spots = []
var index_comercials_spots = []
var client_id_corgs = []
var client_corg_buffer = []

var index = 0

func set_client_commercials_wait(time):
	client_commercials_wait = time
	release_from_buffer()

func open_window():
	#g_man.local_network_node.net_corg_node
	var ids = g_man.multi_client_corg__client_commercial_pictures.select_left_row()
	for id_corg in ids:
		var corg:Company = g_man.savable_client_corg.get_index_data(id_corg)
		corg.load_commercial_pictures()
	fill_up_the_rest()

func give_free_spot(_index, corg:Company):
	index_comercials_spots.push_front(_index)
	release_from_buffer()
	# wait till times meet to show the add again
	var time = corg.comercialist_company_add_wait
	if time < client_commercials_wait:
		time = client_commercials_wait
	await get_tree().create_timer(time).timeout
	# push in to where money meets back is the biggest tip
	var inserted = false
	for i in len(client_corg_buffer):
		if client_corg_buffer[i].comercialist_pay > corg.comercialist_pay:
			client_corg_buffer.insert(i, corg)
			inserted = true
	# if loop went to the end and not inserted it's the highest value
	if not inserted:
		client_corg_buffer.push_back(corg)
	release_from_buffer()

## fill up the rest of the spots
func fill_up_the_rest():
	var ids = g_man.multi_client_corg__client_commercial_pictures.select_left_row()
	for id_corg in ids:
		if not client_id_corgs.has(id_corg):
			client_id_corgs.push_back(id_corg)
			var corg:Company = g_man.savable_client_corg.get_index_data(id_corg)
			client_corg_buffer.push_back(corg)
	release_from_buffer()

func release_from_buffer():
	if client_commercials_wait == 0:
		return
	for spot in index_comercials_spots:
		if client_corg_buffer:
			commercial_spots[index_comercials_spots.pop_back()].show_picture(client_corg_buffer.pop_back())
		else:
			break
