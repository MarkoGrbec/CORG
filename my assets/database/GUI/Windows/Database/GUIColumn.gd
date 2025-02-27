class_name GUIColumn extends Node

@export var cell: PackedScene
@export var attribute_label: Label

var dbms
var server
var server_text
var table_name
var column_name
var database_path

var type

func instantiate_all_cells():
	attribute_label.text = column_name
	#//get type of the data
	type = DataBase.get_header(String("{path}/{s_text}/{table_name}/{column}").format({path = database_path, s_text = server_text, table_name = table_name, column = column_name}))
	
	# to get type out of (leng, type)
	if type:
		type = type[1]
	else:
		return
	# get last id of the attribute file
	var count = DBMSReadWriter.last_id(server, database_path, table_name, column_name)
	for i in range(0, count + 1):
		var cell_tran = cell.instantiate()
		add_child(cell_tran)
		cell_tran.dbms = dbms
		cell_tran.header = self
		cell_tran.id = i
		cell_tran.text = String("{text}").format({text = DBMSReadWriter.select(server, database_path, table_name, column_name, i)})
	# add data to the new row
	var newRowData = cell.instantiate()
	add_child(newRowData)
	newRowData.dbms = dbms
	newRowData.header = self
	newRowData.id = count
	newRowData.text = "<null>"

func destroy():
	pass
