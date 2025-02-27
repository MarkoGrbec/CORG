class_name Mac extends ISavable

func _init():
	pass

func copy():
	return Mac.new()

#var _dictMacs = {} # string, Mac
#var _listMacs:NullList
var _str_mac
var id_macs;
static func get_or_create(mac):# -> Mac
	var m
	if g_man.dictMac.has(mac):
		m = g_man.dictMac[mac]
		return m
	m = g_man.SavableMac.get_new()
	m._str_mac = mac
	g_man.SavableMac.set_data(m)
	g_man.dictMac[mac] = m
	if not m.id_macs:
		Macs.get_index_from_string(mac)
	return m
	
static func get_index_data(_id): #-> Mac
	return g_man.SavableMac.get_index_data(_id)

#region Save
func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "mac", id, _str_mac)
	if id_macs:
		save_id_macs(id_macs)
	
func save_id_macs(idMacs):
	id_macs = idMacs
	DataBase.insert(_server, g_man.dbms, _path, "id_macs", id, id_macs)

#endregion save
#region load
func fully_load():
	_str_mac = DataBase.select(_server, g_man.dbms, _path, "mac", id)
	id_macs = DataBase.select(_server, g_man.dbms, _path, "id_macs", id)
	g_man.dictMac[_str_mac] = self
	
func partly_load():
	fully_load()
#endregion
