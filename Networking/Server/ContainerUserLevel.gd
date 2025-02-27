class_name ContainerUserLevel extends ISavable

func copy():
	return ContainerUserLevel.new()

var count = 3

func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "count", id, count)
	
func fully_load():
	count = DataBase.select(_server, g_man.dbms, _path, "count", id)
	if count == null:
		count = 3
