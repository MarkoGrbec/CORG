class_name ConstructForClient extends Node

## if left is 0 it's given accordinatly experimental for now
static func construct_client_shared_multi_table_savable(multi_client__server:DataBase.MultiTable, savable_client:Savable, id_server):
	var id_client = multi_client__server.select(0, id_server)
	var data
	if not id_client:
		data = savable_client.get_set_new()
	else:
		data = savable_client.get_index_data(id_client[0])
		if not data:
			data = savable_client.get_set_new()
		else:
			data.id_server = id_server
			return data
	multi_client__server.add_row(0, data.id, id_server)
	data.id_server = id_server
	return data

## if left is 0 it's given accordinatly
static func construct_client_shared_savable_multi(savable_multi_client__server:SavableMulti, id_server):
	var id_client = savable_multi_client__server.select(0, id_server)
	var data
	if not id_client:
		data = savable_multi_client__server.new_data(0, id_server)
	else:
		#if left: # id client is id row
			#data = savable_multi_client__server.get_index_data(id_client)
		#else: # id client is id left
		data = savable_multi_client__server.get_all(id_client[0], id_server)
	data.id_server = id_server
	return data
