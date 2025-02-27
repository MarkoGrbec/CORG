class_name PictureData extends ISavable

#region define:
func copy():					# copy the class which is used by savable when new needs to be created
	return PictureData.new()

func partly_save():			# only part save
	pass
func fully_save():				# full save
	pass
func partly_load():			# load only critical data
	pass
func fully_load():				# fully load
	pass
#endregion

var id_server
var _texture2d

func save_picture(raw_texture):
	DataBase.insert(_server, g_man.dbms, _path, "raw_texture", id, raw_texture)

func save_time(time):
	DataBase.insert(_server, g_man.dbms, _path, "time", id, time)

func load_return_raw_texture():
	return DataBase.select(_server, g_man.dbms, _path, "raw_texture", id)

func load_return_time():
	var time = DataBase.select(_server, g_man.dbms, _path, "time", id)
	if time:
		return time
	return 0

func check_timer(time):
	var before_time = load_return_time()
	if time > before_time:
		save_picture(null)
		_texture2d = null

func get_texture():
	if not _texture2d:
		var raw_texture = load_return_raw_texture()
		if raw_texture:
			_texture2d = SaveLoadPicture.load_image_from_raw_png(raw_texture)
	return _texture2d

func add_texture(texture2d):
	_texture2d = texture2d
