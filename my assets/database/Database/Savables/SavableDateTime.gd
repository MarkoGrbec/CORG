class_name SavableDateTime extends Node
#region constructor
func _init(server, dbms_root, path):
	_server = server
	dbms = dbms_root
	_path = path
	var table = DataBase.Table.new(path)
	table.create_column(server, dbms, DataBase.DataType.LONG, 1, "second")
#endregion constructor
#region inputs
var _server
var dbms
var _path
#endregion end inputs
#region period
	#region get dict
func _get_datetime_dict_from_last_save(id):
	var unix = load_from_last_save_elapsed(id)
	return Time.get_datetime_dict_from_unix_time(unix)
	#endregion get dict
	#region load period
func end_of_seconds(id, seconds):
	var dict = _get_datetime_dict_from_last_save(id)
	return calc_seconds(dict, seconds)

func end_of_minutes(id, minutes):
	var dict = _get_datetime_dict_from_last_save(id)
	return calc_minutes(dict, minutes)

func end_of_hours(id, hours):
	var dict = _get_datetime_dict_from_last_save(id)
	return calc_hours(dict, hours)

func end_of_days(id, days):
	var dict = _get_datetime_dict_from_last_save(id)
	return calc_days(dict, days)

func end_of_months(id, months):
	var dict = _get_datetime_dict_from_last_save(id)
	return calc_months(dict, months)

func end_of_years(id, years):
	var dict = _get_datetime_dict_from_last_save(id)
	return calc_years(dict, years)
	#endregion load period
	#region calc period
func calc_seconds(dict, seconds):
	seconds = float(seconds)
	if dict["second"] > seconds:
		return true
	return calc_minutes(dict, seconds/60)

func calc_minutes(dict, minutes):
	if dict["minute"] > minutes:
		return true
	return calc_hours(dict, minutes/60)

func calc_hours(dict, hours):
	if dict["hour"] > hours:
		return true
	return calc_days(dict, hours/24)
	
func calc_days(dict, days):
	if dict["day"] > days + 1:
		return true
	return calc_months(dict, days/30)

func calc_months(dict, months):
	if dict["month"] > months + 1:
		return true
	return calc_years(dict, months/12)

func calc_years(dict, years):
	if dict["year"] > years + 1970:
		return true
	return false
	#endregion calc period
#endregion period
#region saveload
#region save
func save_time_now(id):
	var seconds = Time.get_unix_time_from_system()
	DataBase.insert(_server, dbms, _path, "second", id, int(seconds))
#endregion save
#region load
func load_from_last_save_elapsed(id):
	var seconds = DataBase.select(_server, dbms, _path, "second", id)
	if not seconds:
		seconds = 0 #int(Time.get_unix_time_from_system())
	var elapsed_time = int(Time.get_unix_time_from_system()) - seconds
	return elapsed_time
#endregion load
#endregion saveload
