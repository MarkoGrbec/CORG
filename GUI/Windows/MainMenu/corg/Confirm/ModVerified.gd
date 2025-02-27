class_name ModVerified extends ISavable

var emso
var id_mod

func copy():
	return ModVerified.new()

func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "emso", id, emso)
	DataBase.insert(_server, g_man.dbms, _path, "id_mod", id, id_mod)

func fully_load():
	emso = DataBase.select(_server, g_man.dbms, _path, "emso", id)
	id_mod = DataBase.select(_server, g_man.dbms, _path, "id_mod", id)
