class_name DataBase extends Node

#region table
enum DataType{
	ENULL = 0,
	BOOL = 1,
	INT = 2,
	FLOAT = 3,
	STRING = 4,
	VECTOR2 = 5,
	VECTOR2I = 6,
	RECT = 7,
	VECTOR3 = 9,
	DICTIONARY = 27,
	ARRAY = 28, # 14 chars per 1 string in array it accumulates it doesn't need to be even it can be ["23 chars", "1 char"] for array length 2
	LONG = 30 # my reservation
	#21 - 28 is array
	#29 max
}

class ColumnBase:
	func _init(dataType, table_name, column_name, length):
		_type = dataType
		_table_name = table_name
		_columnName = column_name
		_length = length
	
	var _type: DataType
	var _table_name: String
	var _columnName: String
	var _length: int

class Table:
	class Column:
		var column_base: ColumnBase
		func _init(dataType, table_name, column_name, length):
			column_base = ColumnBase.new(dataType, table_name, column_name, length)
	
	func _init(table_name : String):
		_table_name = table_name
		
	var _table_name: String
	
	func create_column(server: bool, data_base_dir: String, type: DataType, length: int, file_name_column: String, multi_array_length = 1):
		# change type
		var _file_name = DataBase.directory_exists(server, data_base_dir, _table_name, file_name_column, false)
		var header = DataBase.get_header(_file_name)
		var column_database = []
		# if type isn't same as meta
		if header and (type != header[3] or header[0] != length or header[2] != multi_array_length):
			# if database is compatible
			var comp1 = type == DataType.FLOAT or type == DataType.INT or type == DataType.LONG
			var comp2 = header[3] == DataType.FLOAT or header[3] == DataType.INT or header[3] == DataType.LONG
			var comp3 = (header[3] == DataType.STRING and type == DataType.STRING) or (header[3] == DataType.BOOL and type == DataType.BOOL) or (header[3] == DataType.RECT and type == DataType.RECT) or (header[3] == DataType.VECTOR3 and type == DataType.VECTOR3) or (header[3] == DataType.ARRAY and type == DataType.ARRAY) or (header[3] == DataType.DICTIONARY and type == DataType.DICTIONARY)
			if comp3 or (comp1 and comp2):
				# read all data from database
				column_database = read_all(server, data_base_dir, _table_name, file_name_column)
				# need to delete the file as data is totally wrong
				delete_file(_file_name, server, _table_name, file_name_column)
			else:
				# without reading
				# need to delete the file as data is totally wrong
				delete_file(_file_name, server, _table_name, file_name_column)
		
		var original_type = type
		if length > 1 and type != DataType.STRING:
			type = DataType.ARRAY
		var column = Column.new(type, _table_name, file_name_column, length)
		
		var path = DataBase.path(server, data_base_dir, _table_name)
		
		#save Table
		if(not DirAccess.dir_exists_absolute(path)):
			DirAccess.make_dir_recursive_absolute(path)
		
		var file_name = String("{path}/{column_name}.meta".format({path = path, column_name = file_name_column}))
		var file_access = DataBase.file_create_or_rea_or_write(file_name, FileAccess.WRITE_READ)
		
		# length of file size per row
		var dataSize = column.column_base._length
		file_access.store_32(dataSize)
		# we save column type
		file_access.store_8(type)
		# original value inside array if it occures
		file_access.store_8(original_type)
		# length of array
		file_access.store_32(multi_array_length)
		# 10 Bytes in total for meta data
		file_access.close()
		
		file_access = DataBase.file_create_or_rea_or_write(String("{path}/{column_name}".format({path = path, column_name = file_name_column})), FileAccess.WRITE_READ)
		# change all data in to new data type ment for int and float only
		for item in column_database:
			if item[0]:
				if item[1]:
					if item[1] is Array:
						change_array_to(item[1], original_type)
						DataBase.insert(server, data_base_dir, _table_name, file_name_column, item[0], item[1])
					else:
						if original_type == DataType.FLOAT:
							DataBase.insert(server, data_base_dir, _table_name, file_name_column, item[0], float(item[1]))
						elif original_type == DataType.INT:
							DataBase.insert(server, data_base_dir, _table_name, file_name_column, item[0], int(item[1]))
						else:# other variable types that are usually same but just length of file is different
							DataBase.insert(server, data_base_dir, _table_name, file_name_column, item[0], item[1])
				else:# if data is null
					DataBase.insert(server, data_base_dir, _table_name, file_name_column, item[0], null)
	
	func change_array_to(array, type: DataType):
		for i in array.size():
			if array[i] is Array:
				change_array_to(array[i], type)
			else:
				if type == DataType.FLOAT:
					array[i] = float(array[i])
				else:
					array[i] = int(array[i])
	
	func read_all(server, data_base_dir, table_name, file_name_column):
		var count = DBMSReadWriter.last_id(server, data_base_dir, table_name, file_name_column, false)
		var array = []
		if count:
			for id in count:
				array.push_back([id, DataBase.select(server, data_base_dir, table_name, file_name_column, id)])
		return array
	
	func delete_file(_file_name, server, _table_name, file_name_column):
		# need to delete the file as data is totally wrong
		var if_error = DirAccess.remove_absolute(_file_name)
		print("server: [", server, "] table: [", _table_name, "] column: [", file_name_column, "] was deleted: ", if_error)
#endregion table

#region FileSystem
	#region Path
#const metaDataLength = 5

static func path(server : bool, DataBaseDir : String, tableNamePath : String):
	var fullPath
	if server:
		fullPath = String("{data}/{base}/sun/{path}".format({data = OS.get_user_data_dir(), base = DataBaseDir, path = tableNamePath}))
	else:
		fullPath = String("{data}/{base}/planet/{path}".format({data = OS.get_user_data_dir(), base = DataBaseDir, path = tableNamePath}))
	return fullPath
	#endregion Path
	#region file not overwriting
static func file_create_or_rea_or_write(file_path, file_mode : FileAccess.ModeFlags = FileAccess.ModeFlags.READ):
	if(file_mode == FileAccess.READ):
		if FileAccess.file_exists(file_path):
			return FileAccess.open(file_path, file_mode)
		else:
			push_error(String("file {path} does not exist").format({path = file_path}), get_stack())
			return
	else: if file_mode == FileAccess.WRITE or FileAccess.READ_WRITE:
		if FileAccess.file_exists(file_path):
			file_mode = FileAccess.READ_WRITE
		else:
			file_mode = FileAccess.WRITE
			
		var file = FileAccess.open(file_path, file_mode)
		return file
	#endregion file not overwriting
	#region dir exists
static func directory_exists(server : bool, data_base_dir, table_name, column_name, print_error = true):
	var _path = path(server, data_base_dir, table_name)
	if not DirAccess.dir_exists_absolute(str(_path)):
		if print_error:
			push_error(str("directory doesn't exist server[", server, "] table name[", table_name,"] column[", column_name, "]", "abs[", _path ,"]"))
		return ""
	return str(_path, "/", column_name)
	#endregion dir exists
#endregion FileSystem

#region saveload backeup files
static func load_back(dir, i):
	var backStr = String("{dir}.b").format({dir = dir})
	if(! FileAccess.file_exists(backStr)):
		i = 0
		return i
	var file_access = file_create_or_rea_or_write(backStr, FileAccess.READ)
	i = file_access.get_8()
	file_access.close()
	return i
	
static func save_back(dir, i):
	var file_access = file_create_or_rea_or_write(String("{dir}.b").format({dir = dir}), FileAccess.READ_WRITE)
	file_access.store_8(i)
	file_access.close()
	
	
static func save_back_data(_path, column_name, type, length, array_depth, id, data, original_type):
	#save backeup
	if DirAccess.dir_exists_absolute(_path):
		#it has to overwrite it so that the last portion is available for reading string of a file
		var file_access = FileAccess.open(String("{path}/.backup").format({path = _path}), FileAccess.WRITE)
		file_access.store_32(length)
		file_access.store_8(type)
		file_access.store_8(original_type)
		file_access.store_32(array_depth)
		file_access.store_64(id)
		file_access.store_buffer(data)
		var seek_position = 13 + get_data_length(type, length, array_depth, original_type)
		file_access.seek(seek_position)
		file_access.store_string(column_name)#I could use buffer and I would know the length of the string!!!
		file_access.close()

# TODO make save file ready for insert
static func load_back_data(_path, length):
	DirAccess.dir_exists_absolute(_path)
	var file_name = String("{path}.backup").format({path = _path})
	FileAccess.file_exists(file_name)
	var column_name = ""
	#get meta
	var file_access = FileAccess.open(str(file_name), FileAccess.READ)
	length = file_access.get_32()
	var type = file_access.get_8()
	var original_type = file_access.get_8()
	var array_depth = file_access.get_32()
	var id = file_access.get_64()
	var data_length = get_data_length(type, length, array_depth, original_type)
	var buffer = file_access.get_buffer(data_length)
	var data
	# 17 is (4 length + 1 type + 4 array_depth + 8 id)
	var seek_position = 17 + get_data_length(type, length, array_depth, original_type)
	#load filename whch is on the end of file
	file_access.seek(seek_position)
	while not file_access.eof_reached():
		data = file_access.get_8()
		#it'll read 0 if it's end of file so we must not set it
		if not file_access.eof_reached():
			column_name += char(data)
	file_access.close()
	
	file_access = file_create_or_rea_or_write(str(_path, column_name), FileAccess.READ_WRITE)
	if file_access:
		file_access.seek(id * data_length)
		file_access.store_buffer(buffer)
		file_access.close()
	save_back(_path, 0)
#endregion end saveload backeup files

#region header
static func get_length(server, data_base_dir, table_name, column_name):
	var file_name = directory_exists(server, data_base_dir, table_name, column_name)
	if file_name == "":
		push_error(String("table does not exists: {table_name}\ncolumn: {column_name}").format({table_name = table_name, column_name = column_name}))
		return
	if not FileAccess.file_exists(file_name):
		push_error("table: ", table_name, " file: ", column_name, " doesn't exist")
		return
	#we load intengrety of files in this path
	#var intengrety = -1
	var _path = path(server, data_base_dir, table_name)
	_path += '/'
	#read length
	file_name = String("{file_name}.meta").format({file_name = file_name})
	if not FileAccess.file_exists(file_name):
		return
	var file_access = file_create_or_rea_or_write(file_name, FileAccess.READ)
	file_access.seek(0)
	var length = file_access.get_32()
	file_access.close()
	return length

## [length (0)], [type (32)], [multi array (48)], [original type (40)],  [last id (80)] -> 144
static func get_header(file_name):
	file_name = String("{file_name}.meta").format({file_name = file_name})
	if not FileAccess.file_exists(file_name):
		return null
	var file_access = file_create_or_rea_or_write(file_name, FileAccess.READ)
	file_access.seek(0)
	var length = file_access.get_32()
	var type = file_access.get_8()
	var original_type = file_access.get_8()
	var multi_array = file_access.get_32()
	var last_id = file_access.get_64()
	file_access.close()
	return [length, type, multi_array, original_type, last_id]
#endregion header

#region converting
#first 4 bytes are for data type
static func get_data_length(type: DataType, length, array_depth, original_type: DataType):
	var original_length = _get_original_data_type_length(original_type, length)
	## 8: is type array
	## pow(array_depth, array_depth): is all datas
	## 16: is max data storage (Vector3)
	## sum_powered * 8: is number of arrays
	if type == DataType.ARRAY:
		var minus_power = array_depth
		var sum_powered = 0
		while minus_power > 0:
			minus_power -= 1
			sum_powered += pow(array_depth, minus_power)
		return 8 + pow(array_depth, array_depth) * original_length * length + sum_powered * 8 # 8 is empty for heaving empty between datas
	return original_length

static func _get_original_data_type_length(type: DataType, length):
	if type == DataType.BOOL:
		return 8 # 4 bytes for type and 4 bytes for data
	if type == DataType.INT:
		return 8
	if type == DataType.FLOAT:
		return 12
	if type == DataType.STRING:
		return 8 + length
	if type == DataType.VECTOR2:
		return 16
	if type == DataType.VECTOR2I:
		return 16
	if type == DataType.VECTOR3:
		return 16
	if type == DataType.RECT:
		return 20
	if type == DataType.LONG:
		return 12
	if type == DataType.DICTIONARY:
		return 20 + length
	if type == DataType.ARRAY:
		return 20
#endregion converting


#region insert
## server, data_base_dir, table_name, column_name, id, data, oper
static func insert(server : bool, data_base_dir : String, table_name, column_name, id: int, data, _oper = "equals"):
	var _path = path(server, data_base_dir, table_name)
	var file_name = directory_exists(server, data_base_dir, table_name, column_name)
	if not FileAccess.file_exists(str(file_name, ".meta")):
		printerr("server: ", server, " Exception table: [", table_name, "] file_name: [", column_name, "].meta does not exist")
		push_error("server: ", server, " Exception table: [", table_name, "] file_name: [", column_name, "].meta does not exist")
		return
	#started creating a file
	save_back(_path, 1)
	# read column config
	var length
	var converted
	var file_access = file_create_or_rea_or_write(file_name, FileAccess.READ_WRITE)
	var meta_data = get_header(file_name)
	length = meta_data[0]
	if length == 0:
		printerr("something is wrong ", file_name)
		push_error(String("something is wrong {file_name}").format({file_name = file_name}))
		return
	var data_length = get_data_length(meta_data[1], length, meta_data[2], meta_data[3])
	#slice data
	if data is Array or data is PackedByteArray:
		if data.size() > data_length:
			data = data.slice(0, data_length)
	if data is String:
		if data.length() > length:
			data = data.substr(0, length)
			pass
	#convert data to bytes
	converted = var_to_bytes(data)
	if not type_check(converted[0], meta_data[1]):
		return
	#save to backeup
	save_back_data(_path, column_name, meta_data[1], length, meta_data[2], id, converted, meta_data[3])
	#backeup has been sucessfully written
	_path += "/"
	save_back(_path, 2)
	
	#saved permenantly
	file_access.seek(id * data_length)
	file_access.store_buffer(converted)
	
	#read if end of file
	var total_length = file_access.get_length()
	@warning_ignore("integer_division")
	if (total_length / data_length) <= id:
	#write 4 more bytes for string to read properly else it reads nothing if it comes to eof
		file_access.store_32(0)
	file_access.close()
	
	if id > meta_data[4]:
		file_access = file_create_or_rea_or_write(str(file_name, ".meta"), FileAccess.READ_WRITE)
		file_access.seek(10)
		file_access.store_64(id)
		file_access.close()
	# close back failsafe
	save_back(_path, 0)
#endregion insert

#region type check
static func type_check(converted, meta_data):
	if converted == meta_data:
		return true
	#if it's converted int and meta data long
	if converted == 2 and (meta_data == 30):
		return true
	if converted == 0:
		return true
	if converted == 29:
		return true
	# if it's copnverted string and meta data is array
	if converted == 28 and meta_data == 4:
		return true
	push_error("wrong data type is trying to be used data:[", DataType.find_key(converted), "] / meta:[", DataType.find_key(meta_data), "]")
	printerr("wrong data type: [", converted, "]  meta: [", meta_data, "]")
	return false
#endregion type check
#region select
static func select(server: bool, data_base_dir, table_name, column_name, id: int, default_value = null):
	#if id < 1:
		#push_error("id is too small: [", id, "] ", get_stack())
		#return
	var file_name = directory_exists(server, data_base_dir, table_name, column_name)
	if file_name == "":
		printerr("server: [", server, "] table does not exists: [", table_name, "] column: [", column_name, "]")
		push_error("server: [", server, "] table does not exists: [", table_name, "] column: [", column_name, "]")
		return default_value
	if not FileAccess.file_exists(file_name):
		printerr("server: [", server, "] table: [", table_name, "] file: [", column_name, "] doesn't exist")
		push_error("server: [", server, "] table: [", table_name, "] file: [", column_name, "] doesn't exist")
		return default_value
	#we load intengrety of files in this path
	var intengrety = -1
	var _path = path(server, data_base_dir, table_name)
	_path += '/'
	#read length
	var meta_data = get_header(file_name)
	if not meta_data:
		return default_value
	var length = meta_data[0]
	intengrety = load_back(_path, intengrety)
	#Save backedUp file that we didn't save correctly to disc but to the bakedUpFile
	if intengrety == 2:
		load_back_data(_path, length)
	
	##read file section
	#get to the id section
	var data_length = get_data_length(meta_data[1], length, meta_data[2], meta_data[3])
	
	if not FileAccess.file_exists(file_name):
		return default_value
	var file_access = FileAccess.open(file_name, FileAccess.READ)
	file_access.seek(data_length * id)
	# needs to read 8 bytes more than it is needed to the process is skipped in the end
	var buffer = file_access.get_buffer(data_length+4)

	file_access.close()
	if buffer.size() == 0:
		return default_value
	if not type_check(buffer[0], meta_data[1]):
		return default_value
	var text = bytes_to_var(buffer)
	if text == null:
		text = default_value
	return text

## excluding last one is used (use it as size() - 1)
static func last_id(server: bool, data_base_dir, table_name, column_name):
	var file_name = directory_exists(server, data_base_dir, table_name, column_name)
	if file_name == "":
		push_error(String("table does not exists: {table_name}\ncolumn: {column_name}").format({table_name = table_name, column_name = column_name}))
		return
	if not FileAccess.file_exists(file_name):
		printerr("server: ", server, "table: ", table_name, " file: ", column_name, " doesn't exist")
		push_error("server: ", server, "table: ", table_name, " file: ", column_name, " doesn't exist")
		return
	#we load intengrety of files in this path
	var intengrety = -1
	var _path = path(server, data_base_dir, table_name)
	_path += '/'
	
	#read length
	var file_access = FileAccess.open(file_name, FileAccess.READ)
	var meta_data = get_header(file_name)
	if meta_data == null:
		file_access.close()
		return 0
	file_access.close()
	var length = meta_data[0]
	
	intengrety = load_back(path, intengrety)
	#Save backedUp file that we didn't save correctly to disc but to the bakedUpFile
	if intengrety == 2:
		load_back_data(path, length)
	
	return meta_data[4] +1
	###read file section
	##get to the id section
	#var data_length = get_data_length(meta_data[1], length, meta_data[2], meta_data[3])
	#var total_length = 0
	#if FileAccess.file_exists(file_name):
		#total_length = file_access.get_length()
	#@warning_ignore("integer_division")
	#var idCount = (total_length) / data_length
	#if file_access:
		#file_access.close()
	#return idCount
#endregion select
#region reserve
static func reserve(server, data_base_dir, table_name, column_name, bytes_reserve, min_ratio_reserve = 0.01):
	var _path = path(server, data_base_dir, table_name)
	var file_name = directory_exists(server, data_base_dir, table_name, column_name)
	if not FileAccess.file_exists(str(file_name, ".meta")):
		printerr("server: ", server, " Exception table: [", table_name, "] file_name: [", column_name, "].meta does not exist")
		push_error("server: ", server, " Exception table: [", table_name, "] file_name: [", column_name, "].meta does not exist")
		return
	# read column config
	var length
	var file_access = file_create_or_rea_or_write(file_name, FileAccess.READ_WRITE)
	var meta_data = get_header(file_name)
	length = meta_data[0]
	if length == 0:
		printerr("something is wrong ", file_name)
		push_error(String("something is wrong {file_name}").format({file_name = file_name}))
		return
	var data_length = get_data_length(meta_data[1], length, meta_data[2], meta_data[3])
	var max_used_buffer = (meta_data[4] + 1) * data_length
	var to_eof = file_access.get_length()
	
	var max_unused_length = to_eof - max_used_buffer
	if max_unused_length < bytes_reserve * min_ratio_reserve:
		file_access.seek(max_used_buffer + bytes_reserve)
		file_access.store_8(0)
	file_access.close()
	##saved permenantly
	#file_access.seek(id * data_length)
	#file_access.store_buffer(converted)
	#
	##read if end of file
	#var total_length = file_access.get_length()
	#@warning_ignore("integer_division")
	#if (total_length / data_length) <= id:
	##write 4 more bytes for string to read properly else it reads nothing if it comes to eof
		#file_access.store_32(0)
	#file_access.close()
	#
	#if id > meta_data[4]:
		#file_access = file_create_or_rea_or_write(str(file_name, ".meta"), FileAccess.READ_WRITE)
		#file_access.seek(10)
		#file_access.store_64(id)
		#file_access.close()
#endregion reserve
#region delete
static func delete_column(server: bool, data_base_dir, table_name, column_name):
		var file_name = directory_exists(server, data_base_dir, table_name, column_name)
		if file_name == null:
			return
		DirAccess.remove_absolute(file_name)
		DirAccess.remove_absolute(str(file_name, ".meta"))
#endregion delete
#endregion general table
#region multitable
## to quickly get left or right join or simply get reference from right id to left column or vise versa
class MultiTable:
	const PRI = "_id_pri"
	const SEC = "_id_sec"
	func _init(data_base_dir, path):
		table_name = path
		dataBasePathText = data_base_dir
		
		nl_primary_column = NullList.new()
		nlSecondaryColumn = NullList.new()
		nl_all_rows = NullList.new()
		
		var table = Table.new(path)
		table.create_column(true, data_base_dir, DataType.LONG, 1, "id")
		table.create_column(true, data_base_dir, DataType.LONG, 1, PRI)
		table.create_column(true, data_base_dir, DataType.LONG, 1, SEC)
		var lastId = DataBase.last_id(true, data_base_dir, path, "id")
		if lastId:
			for i in range(1, lastId):
				var id = DataBase.select(true, data_base_dir, path, "id", i)
				if id:
					var pri = DataBase.select(true, data_base_dir, path, PRI, id)
					var sec = DataBase.select(true, data_base_dir, path, SEC, id)
					if pri && sec:
						add_row(id, pri, sec)
				else:
					nl_all_rows.add_null(i)
				
	var table_name:String
	var dataBasePathText:String
	var nl_primary_column:NullList
	var nlSecondaryColumn:NullList
	var nl_all_rows:NullList
	
	class Column:
		func _init(id):
			id = id
		var opositeColumn = {}
	class MultiColumn:
		func _init(_left, _right):
			left = _left
			right = _right
		var left
		var right
		var id = 0
	
	## add row if it doesn't exist yet
	## main key: if null add new row else overwrite row
	## returns: id row is written on
	func add_row(main_key, pri, sec):
		if not pri || not sec:
			push_error(String("cannot make multi key too little info {pri} {sec} on {tableNameText}").format({pri = pri, sec = sec, tableNameText = table_name}))
			return
		#if(primary == 0 || secondary == 0){Debug.LogError($"cannot make multi key too little info {mainKey} {primary} {secondary} on {tableNameText}") return 0}
		var pc = nl_primary_column.get_index_data(pri)
		var sc = nlSecondaryColumn.get_index_data(sec)
		
		#we create row if it doesn't exist
		if pc == null:
			pc = Column.new(pri)
			nl_primary_column.set_index_data(pri, pc)
		if sc == null:
			sc = Column.new(sec)
			nlSecondaryColumn.set_index_data(sec, sc)
			
		#if main_key != 0:
			#var row = MultiColumn.new(pri, sec)
			#
			#var mc = nl_all_rows.get_index_data(mainKey)
			#if mc != null:
				#Delete(mainKey)
		#else:
		#//we stop if it already exists on both ends 1 should be enough
		if pc.opositeColumn.has(sec):
			return pc.opositeColumn[sec]
		elif sc.opositeColumn.has(pri):
			push_error(String("when does this happen [{tableNameText}] [{pri}] [{columnDataPri}] [{sec}]").format({tableNameText = table_name, pri = pri, columnDataPri = sc.opositeColumn[pri], sec = sec}))
			return sc.opositeColumn[pri]
		#//we add savable rows for database
		var row = MultiColumn.new(pri, sec)
		#main key should never be given in
		if main_key == 0 || not main_key:
			row.id = nl_all_rows.set_data(row)
		else:
			nl_all_rows.set_index_data(main_key, row)
			row.id = main_key
#
		#//if it doesn't exist on other end
		pc.opositeColumn[sec] = row.id
		sc.opositeColumn[pri] = row.id
		
		DataBase.insert(true, dataBasePathText, table_name, "id", row.id, row.id, "equals")
		DataBase.insert(true, dataBasePathText, table_name, PRI, row.id, row.left, "equals")
		DataBase.insert(true, dataBasePathText, table_name, SEC, row.id, row.right, "equals")
		return row.id
	
	func first_available_row():
		var id_row = nl_all_rows.get_null()
		if id_row:
			return id_row
		return nl_all_rows._container.size()
	
	func delete_row(idRow: int):
		var mc = nl_all_rows.get_index_data(idRow)
		if mc:
			var leftC = nl_primary_column.get_index_data(mc.left)
			leftC.opositeColumn.erase(mc.right)
			
			var rightC = nlSecondaryColumn.get_index_data(mc.right)
			rightC.opositeColumn.erase(mc.left)
			
			DataBase.insert(true, dataBasePathText, table_name, "id", mc.id, 0)
			nl_all_rows.remove_at(mc.id)
		else:
			push_error(String("you want to delete row: {idRow} which doesn't exist").format({idRow = idRow}))
	
	#///<summary>
	#/// if it returns 0 nothing was deleted
	#/// if one is 0 all rows are deleted with that oposite id - last idRow is returned
	#/// </summary>
	func delete(left, right):
		#Debug.LogError(nslPrimaryColumn.get_index_data(left).opositeColumn[right])
		var ret = []
		var lc = nl_primary_column.get_index_data(left)
		if lc:
			#delete all rows with right from left id
			if right == 0:
				#get left column 
				var col_left = nl_primary_column.get_index_data(left)
				if not col_left:
					return
				#get all right keys
				var arrayRight = col_left.opositeColumn.keys()
				for keyRight in arrayRight:
					var row = lc.opositeColumn[keyRight]
				#foreach (var keyRight in arrayRight)
				#{
					#ret = lc.opositeColumn[keyRight]
					#//delete from left column all right keys
					#// lc.opositeColumn.Remove(keyRight)
					#// //delete from right columns all left keys
					#// nlSecondaryMaster.get_index_data(keyRight).opositeColumn.Remove(left)
#
					var mc = nl_all_rows.get_index_data(row)
					if mc:
						delete_row(row)
						ret.push_back(row)
				return ret
				#end of deleting all rows with all right with left id
			if lc.opositeColumn.has(right):
				var row = lc.opositeColumn[right]
				#//delete from left column the right value
				#// lc.opositeColumn.Remove(right)
				#// //delete from right column just 1 left value
				#// nlSecondaryMaster.get_index_data(right).opositeColumn.Remove(left)

				var mc = nl_all_rows.get_index_data(row)
				if mc:
					delete_row(row)
					ret.push_back(row)
					return ret
		var rc = nlSecondaryColumn.get_index_data(right)
		if rc:
			#//delete all rows with right from left id
			if left == 0:
				var colRight = nlSecondaryColumn.get_index_data(right)
				if not colRight:
					return 0
				#get all left keys
				var arrayLeft = colRight.opositeColumn.keys()
				for keyLeft in arrayLeft:
					var row = rc.opositeColumn[keyLeft]
					#//delete from right column all left keys
					#// rc.opositeColumn.Remove(keyLeft)
					#// //delete from right columns just 1 left key
					#// nlPrimaryMaster.get_index_data(keyLeft).opositeColumn.Remove(right)
#
					var mc = nl_all_rows.get_index_data(row)
					if mc != null:
						delete_row(row)
						ret.push_back(row)
				return ret
				#//end of deleting all rows with all right with left id
			if rc.opositeColumn.has(left):
				var row = rc.opositeColumn[left]
				#//delete from right column the left value
				#// rc.opositeColumn.Remove(left)
				#// //delete from left column just 1 right value
				#// nlPrimaryMaster.get_index_data(left).opositeColumn.Remove(right)
#
				var mc = nl_all_rows.get_index_data(row)
				#//so that we get rid of error row does not exist as we are destroying it double times
				if mc != null:
					delete_row(row)
					ret.push_back(row)
				return ret
	
	func count(idPrimary: int, idSecondary: int):
		if idPrimary != 0:
			var colP = nl_primary_column.get_index_data(idPrimary)
			if colP == null:
				return 0
			return colP.opositeColumn.size()
		if idSecondary == 0:
			return 0
		var colS = nlSecondaryColumn.get_index_data(idSecondary)
		if colS == null:
			return 0
		return colS.opositeColumn.size()
	
	## full rows no duplicates
	func select_left_row(id_secondary = 0, startAt := 0, length := 0):
		startAt = max(0, startAt)
		if id_secondary:
			var sc:Column = nlSecondaryColumn.get_index_data(id_secondary)
			if sc:
				var oposite_keys:Array = sc.opositeColumn.keys()
				if length:
					return oposite_keys.slice(startAt, startAt + length)
				return oposite_keys
			return
		var _count = nl_all_rows.count()
		var newCount = _count
		if length:
			newCount = min(_count, startAt + length)
		var array = []
		for i in range(startAt, newCount):
			var mc = nl_all_rows.get_index_data(i + 1 + startAt)
			if mc:
				array.append(mc.left)
		array = ArrayManipulation.unique_array(array)
		return array
	
	## full rows no duplicates
	func select_right_row(id_primary = 0, startAt = 0, length = 0):
		startAt = max(0, startAt)
		if id_primary:
			var pc:Column = nl_primary_column.get_index_data(id_primary)
			if pc:
				var oposite_keys:Array = pc.opositeColumn.keys()
				if length:
					return oposite_keys.slice(startAt, startAt + length)
				return oposite_keys
			return
		startAt = max(0, startAt)
		var _count = nl_all_rows.count()
		var newCount = _count
		if length != 0:
			newCount = min(_count, startAt + length)
		var array = []
		for i in range(startAt, newCount):
			var mc = nl_all_rows.get_index_data(i + 1 + startAt)
			if mc:
				array.append(mc.right)
		array = ArrayManipulation.unique_array(array)
		return array
	
	func select_mc_from_id_row(id_row):
		return nl_all_rows.get_index_data(id_row)
	
	## if you set id for something you'll get oposite. if both are set something you get inner join</summary>
	## idPrimary left join
	## idSecondary right join
	## returns if both are being set it's left and right use with caution as left and right could be 2 same numbers</returns>
	func select(idPrimary, idSecondary):
		if idPrimary != 0 && idSecondary != 0:
			# It returns both IDs from left and right. It should be used only for checking if any ROW exists.
			var colp = nl_primary_column.get_index_data(idPrimary)
			if not colp:
				return []
			var p = colp.opositeColumn.keys()
			var cols = nlSecondaryColumn.get_index_data(idSecondary)
			if not cols:
				return []
			var s = cols.opositeColumn.keys()
			for item in s:
				if not p.has(item):
					p.push_back(item)
			if not p:
				return []
			return p[0]
		elif idPrimary != 0:
			var col = nl_primary_column.get_index_data(idPrimary)
			if col == null:
				return []
			return col.opositeColumn.keys()
		elif idSecondary != 0:
			var col = nlSecondaryColumn.get_index_data(idSecondary)
			if col == null:
				return []
			return col.opositeColumn.keys()
		return []
	
	func select_range(idPrimary, idSecondary, start_at, _count):
		start_at = max(0, start_at)
		if idPrimary != 0 && idSecondary != 0:
			#Debug.log("check if correct CONFIGURED as now it's tested and working " + str(start_at) + ", " + str(_count) + " TEST them all only after test remove each one by one!!!")
			var colp = nl_primary_column.get_index_data(idPrimary)
			if colp == null:
				#Debug.log("0 returns length: 0")
				return []
			var p = colp.opositeColumn.keys()
			var cols = nlSecondaryColumn.get_index_data(idSecondary)
			if cols == null:
				#Debug.log("1 returns length: 0")
				return []
			var s = cols.opositeColumn.keys()

			start_at = min(start_at + _count, s.size()) - _count
			start_at = max(0, start_at)

			for i in range(_count):
				if not p.has(s[i]):
					p.append(s[i])
			#Debug.log("0 returns length: " + str(p.size()) + " " + str(_count))
			return p.to_array()
		elif idPrimary != 0:
			var col = nl_primary_column.get_index_data(idPrimary)
			if col == null:
				#Debug.log("2 returns length: 0")
				return []

			start_at = min(start_at + _count, col.opositeColumn.size()) - _count
			start_at = max(0, start_at)

			var ret = null
			for i in range(_count):
				if col.opositeColumn.size() > start_at + i:
					ret.append(col.opositeColumn.keys()[start_at + i])
			return ret
		elif idSecondary != 0:
			var col = nlSecondaryColumn.get_index_data(idSecondary)
			if col == null:
				#Debug.log("3 returns length: 0")
				return []
			
			start_at = min(start_at + _count, col.opositeColumn.size()) - _count
			start_at = max(0, start_at)

			var ret = null
			for i in range(_count):
				if col.opositeColumn.size() > start_at + i:
					ret.append(col.opositeColumn.keys()[start_at + i])
			#Debug.log("2 returns length: " + str(ret.size()) + " " + str(_count))
			return ret
		#Debug.log("idPrimary and idSecondary are both 0 so it returns long[0]")
		return []
	
	
	## get oposite ids
	func select_id_row_p_s(idPrimary, idSecondary):
		if idPrimary != 0:
			var col = nl_primary_column.get_index_data(idPrimary)
			if not col:
				return 0
			if col.opositeColumn.has(idSecondary):
				return col.opositeColumn[idSecondary]
			return 0

	## get oposite id rows
	func select_id_rows(idPrimary, idSecondary):
		var ids = []
		if idPrimary == 0:
			var col = nlSecondaryColumn.get_index_data(idSecondary)
			if col:
				ids = col.opositeColumn.values()
		else:
			var col = nl_primary_column.get_index_data(idPrimary)
			if col:
				ids = col.opositeColumn.values()
		return ids

	## get oposite ids
	func select_oposite_ids(idPrimary, idSecondary):
		var ids = []
		if idPrimary == 0:
			var col = nlSecondaryColumn.get_index_data(idSecondary)
			if col:
				ids = col.opositeColumn.keys()
		elif idSecondary == 0:
			var col = nl_primary_column.get_index_data(idPrimary)
			if col:
				ids = col.opositeColumn.keys()
		return ids

	## get p, s from specific row
	func select_id_row(idRow):
		var two = []
		var mc = nl_all_rows.get_index_data(idRow)
		if mc == null:
			return 0
		two.append(mc.left)
		two.append(mc.right)
		return two

	func left_join(ids):
		var left = {}
		for id in ids:
			left[id] = select_oposite_ids(id, 0)
		var list = []
		for item in left:
			for lon in left[item]:
				if not list.has(lon):
					list.append(lon)
		return list.to_array()
	
	
	func right_join(ids):
		var right = {}
		for id in ids:
			right[id] = select_oposite_ids(0, id)
		var list = []
		for item in right:
			for lon in right[item]:
				if not list.has(lon):
					list.append(lon)
		return list.to_array()

	func last_id():
		return nl_all_rows.count()

	func clear():
		var _count = last_id()
		for i in range(1, _count + 1):
			delete_row(i)
#endregion multitable

#TODO:
	#public enum Operating{
		#/// <summary>
		#/// it only overwrites data that was given everything that's later on array it's left as it is
		#/// </summary>
		#equals,
		#/// <summary>
		#/// it overwrites all array if it's 0 data it writes 0 to the end of array
		#/// </summary>
		#overwrite,
		#plus,
		#minus,
		#multiply,
		#divide
	
	
	## manual:
	## create normal table
	## var table = DataBase.Table.new("table_name")
	## 
	## create column / attribute
	## table.create_column(true, "DBMS root", DataType.long, 1, "attribut")
	##
	## Create multi table connection between 2 tables
	## var multiTable = DataBase.MultiTable.new("DBMS root", "table_name")
	## you need to store this one because it has stored values in RAM indexes about full table
	##
	## Create link between 2 tables
	## multiTable.add_row(123, 321)
	##
	## Delete row or certain links
	## multiTable.delete(0, 321) <- deletes all links on left side linked to right row 321
