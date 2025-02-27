class_name Savable extends Node

#region constructor
## server, path, instance it can be class with copy() non parameters DO NOT delete THIS instance of a class
func _init(server: bool, dbms: String, path:String, default_instance):
	_dbms = dbms
	var table = DataBase.Table.new(path)
	table.create_column(server, _dbms, DataBase.DataType.LONG, 1, "id")
	_null_data_list = NullList.new()
	_default_instance = default_instance
	_path = path
	_server = server
	_multi_null = DataBase.MultiTable.new(_dbms, String("multi{server}p{path}nulls").format({server = server, path = path}))
	var ids = _multi_null.select(0, 1)
	
	for item in ids:
		_null_data_list.remove_at(item)
	#we make starter 0 id as null
	var data = _default_instance.copy()
	data._server = _server
	data._path = _path
	data.id = 0
	DataBase.insert(server, _dbms, _path, "id", data.id, data.id)

#endregion constructor
#region inputs
## data with nulls
var _null_data_list: NullList
## multi nulls container
var _multi_null: DataBase.MultiTable
var _default_instance
var _path: String
var _server: bool
var _dbms
var _indexes: Dictionary = {}
#endregion end inputs
#region partly load all
## load full list with children and fathers and only PartlyLoadData configured At: (T)
func partly_load_all():
	var lastId = DataBase.last_id(_server, g_man.dbms, _path, "id")
	print("last id:", lastId)
	if lastId:
		for i in range(1, lastId, 1):
			var data = get_index_data(i, true)
			if data == null:
				continue
			data._path = _path
			data._server = _server
			#// //if table and column exists
			#// if (!System.IO.File.Exists(
			#//         DataBase.DirectoryExists(Server, _path.ToString(),
			#//             DataBase.fileName.father.ToString()
			#//         )
			#//     )
			#//    )
			#//     continue
			#// //override idFather
			#// t.idFather = (long)DataBase.Select(Server, _path, DataBase.fileName.father, id, true)
			#// if (t.idFather != 0)
			#// {
			#//     SetFather(t.ID, t.idFather, false)
			#// }
#endregion partly load all
#region has
func has(id):
	id = DataBase.select(_server, g_man.dbms, _path, "id", id)
	if id:
		return true
#endregion has
#region get set data
## new instance without config
func get_new():
	var new_instance = _default_instance.copy()
	new_instance._path = _path
	new_instance._server = _server
	return new_instance

## set new instance in savable but it's not saved but it's configured
func get_set_new():
	var new_instance = _default_instance.copy()
	set_data(new_instance, 0)
	return new_instance

func try_get(id, partly_load: int = 2):
	var data = get_index_data(id, partly_load)
	if data != null:
		return data
	return false
	
## get id of saved item
func get_index_data(id, partly_load: int = 2):
	if not id:
		return
	var data = _null_data_list.get_index_data(id)
	if not data:
		#needs to be created we don't have it but it may exist in database
		var deleted_id = _multi_null.select(id, 1)
		if not deleted_id:
			data = _default_instance.copy()
			data._server = _server
			data._path = _path
			var new_id = DataBase.select(_server, g_man.dbms, _path, "id", id)
			if not new_id or new_id == 0:
				#we save null to the multi DB
				remove_at(id, false)
				return
			data.id = new_id
			#if it was deleted
			if data.id == 0:
				return
			set_index_data(data.id, data, 0)
			# load only part
			if partly_load == 1:
				data.partly_loaded = 1
				data.partly_load()
			# fully load
			elif partly_load == 2:
				data.partly_loaded = 2
				data.fully_load()
			return data
		return
	#data is never null so we set it's path
	data.id = id
	data._path = _path
	data._server = _server
	#if fully was already loaded
	if data.partly_loaded > 1:
		return data
	#load only part
	if partly_load == 1:
		if data.partly_loaded >= 1:
			return data
		data.partly_loaded = 1
		data.partly_load()
		return data
	#if it's going to be fully loaded
	if data.partly_loaded < 2:
		data.partly_loaded = 2
		data.fully_load()
	return data
## get the opposite column
#func get_id_rows(left, right): return _multiLeftRight.Select(left, right)
#func remove_id_rows(left, right): _multiLeftRight.Delete(left, right)
#func Set(left, right): _multiLeftRight.add_row(0, left, right)
## if you make gap inside it stays a gap forever /
## unless you make new ones in gap /
## proceed with caution or treat it as private
func set_index_data(id, data, partly_save := 2) -> Variant:
	data._path = _path
	data._server = _server
	_null_data_list.set_index_data(id, data)
	remove_multi(id)
	data.id = id
	
	DataBase.insert(_server, g_man.dbms, _path, "id", id, id)
	
	data.partly_loaded = 2
	if partly_save == 1:
		data.partly_save()
	elif partly_save == 2:
		data.fully_save()
	return data
## id is automatically added
## 0 don't save,
## 1 partly save,
## 2 fully save,
## id where it's added is returned
func set_data(data, save: int = 2):
	data._path = _path
	data._server = _server
	if _multi_null.select(0, 1).size() == 0:
		data.id = DataBase.last_id(_server, g_man.dbms, _path, "id")
	else:
		data.id = _multi_null.select(0, 1)[0]
	remove_multi(data.id)
	if data.id == 0:
		push_error("ERROR data.id is 0")
		printerr("ERROR data.id is 0")
		return 0
	set_index_data(data.id, data, save)
	return data.id

## get old data or set new data under index
func get_or_set(id:int, partly_load:bool = false):
	var data = get_index_data(id, partly_load)
	if data:
		return data
	data = _default_instance.copy()
	set_index_data(id, data, 0)
	return data
#endregion get set data
#region index
## set type "weight" -> 
## set key "0.5" -> value
## set id "ISavable.id"
func set_index(enum_type, key, id_value):
	custom_index = -1
	if enum_type and key and id_value:
		var index = _indexes.get_or_add(enum_type, [])
		var pair = [key, id_value]
		index.insert(index.bsearch_custom(pair, _sort, false), pair)
## remove exact index that existed when added to the index
## before saving index changed data remove index
## when loading first remove than set
func remove_index(enum_type, before_key, id_value):
	custom_index = -1
	var index = _indexes.get(enum_type, null)
	if index:
		var i = index.bsearch_custom([before_key, null], _sort, true)
		if index.size() > i:
			if index[i][1] == id_value:
				index.remove_at(i)
## find pair
func get_index_pair(enum_type, key, exactly: bool = false):
	custom_index = -1
	var index = _indexes.get(enum_type, null)
	if index:
		var i = index.bsearch_custom([key, null], _sort, true)
		var pair = index[i]
		if exactly:
			if pair[0] == key:
				return pair
		else:
			return pair
## get many indexes included min and max
func get_index_pair_range(enum_type, min_k, max_k, count = 10, _custom_index = -1):
	var index = _indexes.get(enum_type, null)
	if index:
		custom_index = _custom_index
		var min_i = index.bsearch_custom([min_k, null], _sort, true)
		var max_i = index.bsearch_custom([max_k, null], _sort, false)
		var array = []
		for i in range(min_i, max_i):
			count -= 1
			array.push_back(index[i])
			if count <= 0:
				break
		return array
var custom_index = -1
## sort indexes
func _sort(a, b):
	if custom_index == -1:
		if a[0] < b[0]:
			return true
	else:
		if a[0][custom_index] < b[0][custom_index]:
			return true
	return false
#endregion index
#region remove
func remove_at(id:int, destroy: bool = true):
	if destroy:
		var data = get_index_data(id, 0)
		if data:
			data.destroy()
	_null_data_list.remove_at(id)
	DataBase.insert(_server, g_man.dbms, _path, "id", id, 0)
	add_multi(id)

func remove_multi(id):
	_multi_null.delete(id, 1)

func add_multi(id):
	_multi_null.add_row(0, id, 1)
#endregion remove

func last_id():
	return DataBase.last_id(_server, g_man.dbms, _path, "id")

func remove_all():
	var _count = last_id()
	for i in range(1, _count):
		remove_at(i)
