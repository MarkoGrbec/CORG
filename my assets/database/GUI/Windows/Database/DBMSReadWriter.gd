class_name DBMSReadWriter extends Node

func _ready():
	# just so it populates the database
	push_warning("DataBase.new() shouldn't be here it should be at your starter script to populate the database and if you want to save id window simply uncomment #get_parent().set_id_window(100, database)")
	#DataBase.new()
	# you can poppulate database like this or within your game but it's not recommended to do it more than once
	
	# to make this line work you need to add window manager to DataBase so parent of DBMS
	# note you'll need to set global canvas in starter script
	#get_parent().set_id_window(100, "database")
	#g_man.database_reader = self
	var table = DataBase.Table.new("myDBMSviuer")
	table.create_column(false, "DBMS", DataBase.DataType.LONG, 1, "id")
	table.create_column(false, "DBMS", DataBase.DataType.STRING, 120, "dbms_root")
	table.create_column(false, "DBMS", DataBase.DataType.FLOAT, 1, "x")
	table.create_column(false, "DBMS", DataBase.DataType.FLOAT, 1, "y")
	
	database_path = DataBase.select(false, "DBMS", "myDBMSviuer", "dbms_root", 1)
	if database_path:
		root_text.text = database_path

var list_server_table_names = []
var list_client_table_names = []
var database_path
var server_tab:TabContainer
var client_tab:TabContainer

signal on_insert

func show_window():
	get_parent().last_sibling()
	get_parent().show()
@export var table: PackedScene
@export var gui_server_client_tab: PackedScene
@export var root_text: LineEdit
@export var data_base_table_container: TabContainer

func _on_root_text_submit(new_text):
	destroy_tables()
	database_path = new_text
	show_all_tables()

#region show all tables
func show_all_tables():
	# check if dir exists
	if (! DirAccess.dir_exists_absolute(database_path)):
		DatabaseDoesNotExists(" wrong dir ")
		return
#
	var subDirs = DirAccess.get_directories_at(database_path)
	#if dir has any sub directories
	if not subDirs:
		DatabaseDoesNotExists(" empty dir ")
		return
#
	var server:String = DataBase.path(true, database_path, "")
	var client:String = DataBase.path(false, database_path, "")
	client = client.substr(len(client) - 7, 6)
	server = server.substr(len(server) - 4, 3)
	#if sub dirs are correct at all if it's truly database
	if subDirs[0] != server && subDirs[0] != client:
		DatabaseDoesNotExists(subDirs[0])
		return
	
	DataBase.insert(false, "DBMS", "myDBMSviuer", "dbms_root", 1, database_path)
	
	var server_path = String("{path}/{server}").format({path = database_path, server = server})
	#load all servers tables:
	if DirAccess.dir_exists_absolute(server_path):
		server_tab = gui_server_client_tab.instantiate()
		data_base_table_container.add_child(server_tab)
		server_tab.name = "server"
		server_tab.tab_clicked.connect(_on_database_server_table_container_tab_clicked)
		subDirs = DirAccess.get_directories_at(server_path)
		for item in subDirs:
			var table_name = item
			OpenTable(true, table_name)
	# load all client tables:
	var client_path = String("{path}/{client}").format({path = database_path, client = client})
	if DirAccess.dir_exists_absolute(client_path):
		client_tab = gui_server_client_tab.instantiate()
		data_base_table_container.add_child(client_tab)
		client_tab.name = "client"
		client_tab.tab_clicked.connect(_on_database_client_table_container_tab_clicked)
		subDirs = DirAccess.get_directories_at(client_path)
		for item in subDirs:
			var table_name = item
			OpenTable(false, table_name)



func OpenTable(server:bool, table_name:String):
	var table_tab = table.instantiate()
	if server:
		server_tab.add_child(table_tab)
	else:
		client_tab.add_child(table_tab)
	table_tab.name = table_name
	# add button to the list for removal reference
	if server:
		list_server_table_names.push_back(table_tab)
	else:
		list_client_table_names.push_back(table_tab)
	table_tab.server = server
	table_tab.table_name = table_name
	table_tab.path = database_path
	table_tab.dbms = self
	
func _on_database_server_table_container_tab_clicked(tab):
	list_server_table_names[tab].destroy()
	list_server_table_names[tab].ShowAllAttributes()
	
func _on_database_client_table_container_tab_clicked(tab):
	list_client_table_names[tab].destroy()
	list_client_table_names[tab].ShowAllAttributes()
#endregion
#region saveData
func save_data():
	on_insert.emit()
	remove_signal()
#endregion
#region destroyButtons
func destroy_tables():
	remove_signal()
	destroy_table(list_server_table_names)
	destroy_table(list_client_table_names)
	if server_tab:
		server_tab.queue_free()
	if client_tab:
		client_tab.queue_free()

func destroy_table(list):
	for item in list:
		item.destroy()
		item.queue_free()
	list.clear()

func remove_signal():
	for item in on_insert.get_connections():
		on_insert.disconnect(item.callable)
#endregion
#region debug
func DatabaseDoesNotExists(actually):
	push_error(String("{path} DataBase does not exist actually: [{actually}] exists").format({path = database_path, actually = actually}))
#endregion debug

#region file system
	#region Path
#const metaDataLength = 5

static func path(server : bool, database_dir : String, table_name_path : String):
	var full_path
	if server:
		full_path = String("{base}/sun/{path}".format({base = database_dir, path = table_name_path}))
	else:
		full_path = String("{base}/planet/{path}".format({base = database_dir, path = table_name_path}))
	return full_path
	#endregion Path
	#region file not overwriting
static func file_create_or_read_or_write(file_path, file_mode : FileAccess.ModeFlags = FileAccess.ModeFlags.READ):
	if(file_mode == FileAccess.READ):
		if FileAccess.file_exists(file_path):
			return FileAccess.open(file_path, file_mode)
		else:
			printerr(String("file {path} does not exist").format({path = file_path}), get_stack())
			return null
	else: if file_mode == FileAccess.WRITE or FileAccess.READ_WRITE:
		if FileAccess.file_exists(file_path):
			file_mode = FileAccess.READ_WRITE
		else:
			file_mode = FileAccess.WRITE
			
		var file = FileAccess.open(file_path, file_mode)
		return file
	#endregion file not overwriting
	#region dir exists
static func directory_exists(server : bool, database_dir, table_name, column_name):
	var _path = path(server, database_dir, table_name)
	if not DirAccess.dir_exists_absolute(String("{_path}").format({_path = _path, column = column_name})):
		printerr(String("directory doesn't exist server[{server}] table name[{table_name}] column[{column_name}]\n").format({server = server, table_name = table_name, column_name = column_name}))
		return ""
	return String("{path}/{column_name}").format({path = _path, column_name = column_name})
	#endregion dir exists
#endregion file system
#region select
static func select(server: bool, database_dir, table_name, column_name, id: int):
		var file_name = directory_exists(server, database_dir, table_name, column_name)
		if file_name == "":
			push_error(String("table does not exists: {table_name}\ncolumn: {column_name}").format({table_name = table_name, column_name = column_name}))
			return
		if not FileAccess.file_exists(file_name):
			push_error("table: ", table_name, " file: ", column_name, " doesn't exist")
		#we load intengrety of files in this path
		var intengrety = -1
		var _path = path(server, database_dir, table_name)
		_path += '/'
		#read length
		var meta_data = DataBase.get_header(file_name)
		if meta_data == null:
			return
		var length = meta_data[0]
		intengrety = DataBase.load_back(_path, intengrety)
		#Save backedUp file that we didn't save correctly to disc but to the bakedUpFile
		if intengrety == 2:
			DataBase.load_back_data(_path, length)
		
		##read file section
		#get to the id section
		var dataLength = DataBase.get_data_length(meta_data[1], length, meta_data[2], meta_data[3])
		
		if not FileAccess.file_exists(file_name):
			return
		var file_access = FileAccess.open(file_name, FileAccess.READ)
		file_access.seek(dataLength * id)
		# needs to read 4 bytes more than it is needed to the process is skipped in the end
		var buffer = file_access.get_buffer(dataLength+4)

		file_access.close()
		if buffer.size() == 0:
			return
		if not DataBase.type_check(buffer[0], meta_data[1]):
			return
		var text = bytes_to_var(buffer)
		return text
		
static func last_id(server: bool, database_dir, table_name, column_name, absolute: bool = true):
	var file_name = ""
	if absolute:
		file_name = directory_exists(server, database_dir, table_name, column_name)
	else:
		file_name = DataBase.directory_exists(server, database_dir, table_name, column_name)
	if file_name == "":
		printerr(String("table does not exists: {table_name}\ncolumn: {column_name}").format({table_name = table_name, column_name = column_name}))
		return
	#we load intengrety of files in this path
	var intengrety = -1
	var _path = path(server, database_dir, table_name)
	_path += '/'
	
	#read length
	var file_access = FileAccess.open(file_name, FileAccess.READ)
	var meta_data = DataBase.get_header(file_name)
	if meta_data == null:
		file_access.close()
		return 0
	var length = meta_data[0]
	
	intengrety = DataBase.load_back(path, intengrety)
	#Save backedUp file that we didn't save correctly to disc but to the bakedUpFile
	if intengrety == 2:
		DataBase.load_back_data(path, length)
	
	##read file section
	#get to the id section
	var dataLength = DataBase.get_data_length(meta_data[1], length, meta_data[2], meta_data[3])
	var totalLength = 0
	if FileAccess.file_exists(file_name):
		totalLength = file_access.get_length()
	@warning_ignore("integer_division")
	var idCount = (totalLength) / dataLength
	if file_access:
		file_access.close()
	return idCount
#endregion select
#region insert
## server, database_dir, table_name, column_name, id, data, oper
static func insert(server : bool, database_dir : String, table_name, column_name, id: int, data, _oper = "equals"):
	if(data == null):
		push_error("data is null")
		return
	var _path = path(server, database_dir, table_name)
	var file_name = directory_exists(server, database_dir, table_name, column_name)
	if not FileAccess.file_exists(String("{file_name}.meta").format({file_name = file_name})):
		printerr(String("Exception file_name: {file_name}.meta does not exist\n").format({file_name = column_name}), get_stack())
		return
	# started creating a file
	DataBase.save_back(path, 1)
	# read column config
	var length
	var converted
	var file_access = file_create_or_read_or_write(file_name, FileAccess.READ_WRITE)
	var meta_data = DataBase.get_header(file_name)
	length = meta_data[0]
	if length == 0:
		push_error(String("something is wrong {file_name}").format({file_name = file_name}), get_stack())
		return
	var dataLength = DataBase.get_data_length(meta_data[1], length, meta_data[2], meta_data[3])
	#convert data to bytes
	if data is Array || data is PackedByteArray:
		if len(data) > length:
			data = data.slice(0, length)
	converted = var_to_bytes(data)
	if not DataBase.type_check(converted[0], meta_data[1]):
		return
	##4 in front because it is type variable saved with it
	#if converted.size() > dataLength:
		#if length > 1:
			#converted[4] = length
		#converted = converted.slice(0, dataLength)
		
		
		
	#save to backeup
	DataBase.save_back_data(_path, column_name, meta_data[1], length, meta_data[2], id, converted, meta_data[3])
	#backeup has been sucessfully written
	_path += "/"
	DataBase.save_back(_path, 2)
	
	#saved permenantly
	file_access.seek(id * dataLength)
	file_access.store_buffer(converted)
	
	#read if end of file
	var total_length = file_access.get_length()
	@warning_ignore("integer_division")
	if (total_length / dataLength) <= id:
	#write 4 more bytes for string to read properly else it reads nothing if it comes to eof
		file_access.store_32(0)
	file_access.close()
	DataBase.save_back(path, 0)
#endregion insert


func _on_exit():
	get_parent().hide()
