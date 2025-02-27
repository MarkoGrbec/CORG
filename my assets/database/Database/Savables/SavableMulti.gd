class_name SavableMulti extends Node

func _init(server: bool, dbms: String, path: String, default_class, partly_load = false):
	_default_class = default_class
	_savable = Savable.new(server, dbms, path, default_class)
	var path_multi = path# String("multi_{path}_{server}").format({path = path, server = server})
	_multi = DataBase.MultiTable.new(dbms, path_multi)
	#_multi.add_row(0, 0)
	if partly_load:
		_savable.partly_load_all()
	

var _savable: Savable
var _multi: DataBase.MultiTable
var _default_class

func get_id_row(id_primary: int, id_secondary: int):
	return _multi.select_id_row_p_s(id_primary, id_secondary)

func get_id_rows(id_primary: int, id_secondary: int):
	return _multi.select_id_rows(id_primary, id_secondary)
	
func get_left_rows(id_secondary = 0, start_at = 0, length = 0):
	return _multi.select_left_row(id_secondary, start_at, length)
	
func get_right_rows(id_primary = 0, start_at = 0, length = 0):
	return _multi.select_right_row(id_primary, start_at, length)
	
	## same as get_all with less functionalities
func try_get_p_s(id_primary: int, id_secondary: int):
	var id_row = get_id_rows(id_primary, id_secondary)
	if id_row != 0:
		return get_index_data(id_row)
	
## get all data for the opposite column
func get_all(id_primary: int, id_secondary: int):
	if id_primary != 0 && id_secondary != 0:
		var row = get_id_row(id_primary, id_secondary)
		if row:
			return get_index_data(row)
	else:
		var rows = []
		var id_rows = _multi.select_oposite_ids(id_primary, id_secondary)
		rows.resize(len(id_rows))
		for i in len(id_rows):
			var p = id_primary
			var s = id_secondary
			if id_primary == 0:
				p = id_rows[i]
			if id_secondary == 0:
				s = id_rows[i]
			rows[i] = _multi.select_id_row_p_s(p, s)
		var ret = []
		ret.resize(len(rows))
		for i in len(rows):
			ret[i] = get_index_data(rows[i])
		return ret
## if both columns are set and something exists old is returned
## returns New data and an opposite column is made by savable id
func new_data(id_primary: int, id_secondary: int, partly_load = 2, partly_save = 2):
	var idRow
	if id_primary and id_secondary:
		idRow = _multi.select_id_row_p_s(id_primary, id_secondary)
	if idRow:
		return _savable.get_index_data(idRow, partly_load)
	var data = _default_class.copy()
	return set_data(id_primary, id_secondary, data, partly_save)

## all data needs to be loaded and saved before moving and resaved on end of move
func move_data(id_primary, id_secondary, data):
	_multi.delete_row(data.id)
	_savable.remove_at(data.id)
	return set_data(id_primary, id_secondary, data, 2)

## overwrite data
func set_data(id_primary, id_secondary, data, partly_save):
	if id_primary != 0 && id_secondary != 0:
		var id_row = _multi.add_row(0, id_primary, id_secondary)
		_savable.set_index_data(id_row, data, partly_save)
		return data
	elif id_primary != 0:
		var id_row = _multi.first_available_row()
		id_row = _multi.add_row(id_row, id_primary, id_row)
		_savable.set_index_data(id_row, data, partly_save)
		return data
	elif id_secondary != 0:
		var id_row = _multi.first_available_row()
		id_row = _multi.add_row(id_row, id_row, id_secondary)
		_savable.set_index_data(id_row, data, partly_save)
		return data
	push_error(String("{data} has not ben set correctly and base is empty").format({data = data.to_string()}))
	return data

## if it doesn't exist it creates on idRow if more exists it takes only first row
## if id_primary 0 it tries to fetch it from other row
## if id_secondary 0 it tries to fetch it from other row
## returns new or old if exists on idRow
func get_p_s_data(id_primary: int, id_secondary:int):
	if id_primary == 0:
		var id_rows = _multi.select(0, id_secondary)
		if len(id_rows) > 0:
			id_primary = id_rows[0]
	elif id_secondary == 0:
		var id_rows = _multi.select(id_primary, 0)
		if len(id_rows) > 0:
			id_secondary = id_rows[0]
	var id_row = _multi.add_row(0, id_primary, id_secondary)
	var data = _savable.get_index_data(id_row)
	#if it doesn't exist on the disc create one
	if data == null:
		data = _default_class.copy()
		#save on a disc
		_savable.set_index_data(id_row, data)
	return data

##oposite rows
func select(id_primary:int, id_secondary:int):
	return _multi.select(id_primary, id_secondary)

func get_mc_from_id(id):
	return _multi.select_mc_from_id_row(id)
	
func get_index_data(idRow):
	return _savable.get_index_data(idRow)

## deletes all rows if opposite is 0 than all opposite rows
func delete_p_s(id_primary: int, id_secondary: int):
	var id_rows = _multi.delete(id_primary, id_secondary)
	if not id_rows:
		return
	for id_row in id_rows:
		_savable.remove_at(id_row)
	if id_rows:
		return true

func delete_id_row(idRow: int):
	_multi.delete_row(idRow)
	_savable.remove_at(idRow)
	
func remove_all():
	_savable.remove_all()
	_multi.clear()
