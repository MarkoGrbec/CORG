class_name Forum extends ISavable

func copy():
	return Forum.new()

var id_father
var id_client
var thread_name

var new_post_header
var new_post_body

@onready var content_container = $forum
@onready var posts_container = $"forum/forum posts/forum posts/posts container"

@onready var add_post_header = $"forum/create forum _ post/add post header"
@onready var post_body = $"forum/create forum _ post/MarginContainer/post body"

var _on_button_click:Callable

func get_content_container(_id_father):
	return content_container

func get_post_container():
	return posts_container

#region button tool
func set_text(text):
	if text is Forum:
		text = text.get_text()
		return
	name = text
	thread_name = text

func get_text():
	return thread_name

func on_click_add_listener(on_button_click:Callable):
	_on_button_click = on_button_click
	get_parent().tab_clicked.connect(
		func(id_tab):
			print(id_tab)
			var x = get_parent().get_current_tab_control()
			if x is Forum:
				if get_parent().get_current_tab_control().id == id:
					_on_button_click.call(id)
	)
#endregion button tool

#region savable:
func partly_save():			# only part save
	pass
func fully_save():				# full save
	DataBase.insert(_server, g_man.dbms, _path, "id_father", id, id_father)
	DataBase.insert(_server, g_man.dbms, _path, "id_client", id, id_client)
	DataBase.insert(_server, g_man.dbms, _path, "thread_name", id, thread_name)
func partly_load():			# load only critical data
	pass
func fully_load():				# fully load
	id_father = DataBase.select(_server, g_man.dbms, _path, "id_father", id)
	id_client = DataBase.select(_server, g_man.dbms, _path, "id_client", id)
	thread_name = DataBase.select(_server, g_man.dbms, _path, "thread_name", id)
#endregion
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(id_father)
	data.push_back(id_client)
	data.push_back(thread_name)
	return data
	
func deserialize(data):
	thread_name = data.pop_back()
	id_client = data.pop_back()
	id_father = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize



func on_add_forum_submit(new_text):
	g_man.social.create_forum(id, new_text)

func on_post_submit():
	if add_post_header.text:
		if post_body.text:
			g_man.social.create_post(id, add_post_header.text, post_body.text)
