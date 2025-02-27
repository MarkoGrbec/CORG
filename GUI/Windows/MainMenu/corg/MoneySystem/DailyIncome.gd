class_name DailyIncome extends ISavable

var _money = 0
var year
var month
var day

#region savable:
func copy():
	return DailyIncome.new()

func partly_save():
	pass

func fully_save():
	save_money()
	save_time()

func partly_load():
	pass

func fully_load():
	load_money()
	year = DataBase.select(_server, g_man.dbms, _path, "year", id)
	month = DataBase.select(_server, g_man.dbms, _path, "month", id)
	day = DataBase.select(_server, g_man.dbms, _path, "day", id)
#endregion savable
#region save
func save_money():
	DataBase.insert(_server, g_man.dbms, _path, "money", id, int(_money))

func save_time():
	DataBase.insert(_server, g_man.dbms, _path, "year", id, year)
	DataBase.insert(_server, g_man.dbms, _path, "month", id, month)
	DataBase.insert(_server, g_man.dbms, _path, "day", id, day)
#endregion save
#region load
func load_money():
	_money = DataBase.select(_server, g_man.dbms, _path, "money", id)
	if not _money:
		_money = 0

func load_if_needed():
	if partly_loaded != 2:
		partly_loaded = 2
		fully_load()
	if not year || not month || not day:
		set_date_time()
	if not _money:
		_money = 0
#endregion load
#region get set time
func get_unix_time():
	var dict = Time.get_datetime_dict_from_system()
	dict["year"] = year
	dict["month"] = month
	dict["day"] = day
	return Time.get_unix_time_from_datetime_dict(dict)
func set_date_time():
	var dict = Time.get_datetime_dict_from_system()
	year = dict["year"]
	month = dict["month"]
	day = dict["day"]
	save_time()
#endregion get set time
#region money
func add_money(money):
	_money += money
	save_money()
#endregion money
