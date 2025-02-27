class_name GUICell extends Node

var header:GUIColumn
var dbms:DBMSReadWriter
var id

var data

var connected := false

func insert():
	DBMSReadWriter.insert(header.server, header.database_path, header.table_name, header.column_name, id, data)
	connected = false

func _on_submit(new_text):
	var save
	if header.type == DataBase.DataType.STRING:
		data = new_text
		save = true
	if header.type == DataBase.DataType.LONG || header.type == DataBase.DataType.INT:
		data = int(new_text)
		save = true
	if header.type == DataBase.DataType.FLOAT:
		data = float(new_text)
		save = true
	# if _data is valid set it to write
	if save:
		if not connected:
			dbms.on_insert.connect(insert)
		connected = true
