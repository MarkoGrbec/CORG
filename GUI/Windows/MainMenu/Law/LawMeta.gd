class_name LawMeta extends ISavable

#region input
var header
#endregion input
#region button tool
# custom how to set text by data provided
func set_text(_text):
	if _text is LawMeta:
		header = _text.get_text()
		self.text = header
	else:
		header = _text
		self.text = str(header)

# custom how to return only one text: String
func get_text():
	return header

func on_click_add_listener(on_button_click:Callable):
	self.pressed.connect(
		func():
			on_button_click.call(id)
	)
	pass
#endregion button tool
#region define:
func copy():
	return LawMeta.new()

func partly_save():
	pass

func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "header", id, header)

func partly_load():
	pass

func fully_load():
	header = DataBase.select(_server, g_man.dbms, _path, "header", id)
#endregion
