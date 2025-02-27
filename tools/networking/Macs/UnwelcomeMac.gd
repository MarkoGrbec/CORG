class_name UnwelcomeMac extends ISavable

var id_mac
var approved
var wait_time = 0

enum approving{
	PENDING = 0,
	BANNED = 1,
	APPROVED = 2
}

func copy():
	return UnwelcomeMac.new()

func change_status(approve, owner: bool):
	if owner:
		approved = approve
	elif not approved == approving.BANNED:
		approved = approve
		save_approved()
		wait_time = 0.0
		save_wait_time()
		print("changed status")

func make_wait_time():
	load_wait_time()
	if not wait_time:
		wait_time = Time.get_unix_time_from_system() + (3600*24*7)
		save_wait_time()

func partly_save():
	pass
	
func fully_save():
	save_approved()
	DataBase.insert(_server, g_man.dbms, _path, "id_mac", id, id_mac)
	
func partly_load():
	pass
	
func fully_load():
	approved = DataBase.select(_server, g_man.dbms, _path, "approved", id)
	id_mac = DataBase.select(_server, g_man.dbms, _path, "id_mac", id)
	load_wait_time()

func save_approved():
	DataBase.insert(_server, g_man.dbms, _path, "approved", id, approved)

func save_wait_time():
	DataBase.insert(_server, g_man.dbms, _path, "wait_time", id, wait_time)

func load_wait_time():
	wait_time = DataBase.select(_server, g_man.dbms, _path, "wait_time", id, 0)

#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(id_mac)
	data.push_back(approved)
	data.push_back(wait_time)
	return data
	
var deserialize_index = 0
func deserialize(data):
	wait_time = data.pop_back()
	approved = data.pop_back()
	id_mac = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize
