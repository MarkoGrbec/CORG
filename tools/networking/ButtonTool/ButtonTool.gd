class_name ButtonTool extends Node

func _init(preloaded_button,				# what kind of button will apear with script attached extedned ISavable
	dictionary_container,					# what dictionary should it use for data
	on_button_clicked:Callable,				# <long> if button is clicked what happens
	cmd_refresh_container_item:Callable,	# <long> command to server for getting item back
	button_container						# where buttons will appear
	):
	#_windowManager = windowManager
	_preloaded_button			= preloaded_button
	
	_buttons					= {} # <long, Button>
	if dictionary_container:
		_container				= dictionary_container
	else:
		_container				= {} # <long, t_class>
	
	_on_button_click			= on_button_clicked
	_cmd_refresh_container_item	= cmd_refresh_container_item
	_content					= button_container

#region inputs
var _preloaded_button
## where all buttons are stored
var _buttons						#<long, Button>()
## where all data is stored
var _container						# <long, T>()
## created button that's clicked
var _on_button_click
## send request to refresh this data
var _cmd_refresh_container_item
## where everything is instantiated
var _content
#endregion inputs

func how_to_add_button(id, id_father, text):
	if id_father == 1 && _content:
		add_button(_content, id, text)
	elif _buttons.has(id_father):
		add_button(_buttons[id_father].get_content_container(id_father), id, text)
	else:
		add_button(_content, id, text)

func add_buttons(ids:Array, id_father = 0, show_buttons = false):
	for item in ids:
		if not _buttons.has(item):
			how_to_add_button(item, id_father, "x")
		
		var button = _buttons[item]
		if show_buttons:
			button.show()
		if button.get_text() != "x":
			continue
		if _container.has(item):
			button.set_text(_container[item])
		else:
			_cmd_refresh_container_item.call(item)
	
func add_buttons_at_content(atContent, ids):
	var con = _content
	if atContent:
		_content = atContent
		add_buttons(ids)
	_content = con

func get_button(id):
	return _buttons[id]

func get_t_class(id):
	return _container[id]

## note even hidden buttons usually correct if used only AddButtons/remove_buttons
## <returns>all buttons that are currently available</returns>
func get_all_open_ids():
	return _buttons.keys()

## overwrite class
func overwrite_t_class(id, t_class, id_father = 0):
	_container[id] = t_class
	refresh_text(id, t_class, id_father)

## if old data exist new data will not be here
func refresh_t(id, t_class, id_father = 0, force_make_button = false):
	if not _container.has(id):
		_container[id] = t_class
	refresh_text(id, t_class, id_father, force_make_button)

func refresh_text(id, t_class, id_father = 0, force_make_button = false):
	if _buttons.has(id):
		_buttons[id].set_text(t_class)
	elif force_make_button:
		how_to_add_button(id, id_father, t_class)

func refresh_text_only(id, text, id_father = 0, force_make_button = false):
	if _buttons.has(id):
		_buttons[id].set_text(text)
	elif force_make_button:
		how_to_add_button(id, id_father, text)

func add_button(content, id, text):
	var button = _preloaded_button.instantiate()
	content.add_child(button)
	button.reparent(content)
	button.id = id
	button.set_text(text)
	button.on_click_add_listener(_on_button_click)
	_buttons[id] = button

func reparent_buttons(ids, node):
	for id in ids:
		if _buttons.has(id):
			var button = _buttons[id]
			button.reparent(node)

func remove_buttons(ids:Array):
	for item in ids:
		if _buttons.has(item):
			_buttons[item].queue_free()
			_buttons.erase(item)

func remove_all_buttons():
	remove_buttons(_buttons.keys())

func hide_buttons(ids):
	for item in ids:
		if _buttons.has(item):
			_buttons[item].hide()

func hide_all_buttons():
	hide_buttons(_buttons.keys())

func permanently_delete(ids):
	for item in ids:
		if _buttons.has(item):
			_buttons[item].queue_free()
			_buttons.erase(item)
		if _container.has(item):
			_container.erase(item)

func id_exists(id):
	return _container.has(id)

#  call add_buttons(ids) 1 id or more
#  the process sends request to cmd
#  process needs data back on refresh_t(id, t_class)
## 
##
#  OnClick is the data that's going to be used when clicked on the button and the id of button is going to be send forward
