class_name Post extends ISavable

func copy():
	return Post.new()

var id_father
var id_client
var thread_name
var body

@onready var post_header = $"HBoxContainer/post margin/post container/post header"
@onready var post_text = $"HBoxContainer/post margin/post container/post text"
@onready var post_footer = $"HBoxContainer/post margin/post container/post footer"

@onready var comment_text = $"HBoxContainer/post margin/post container/comment text"

@onready var comment_container = $"HBoxContainer/post margin/post container/comment margin/comment container"

func get_content_container(_id_father):
	push_error("id father: ", _id_father)
	return g_man.social.forum_button_tool.get_button(_id_father).posts_container

func get_comment_container():
	return comment_container

#region button tool
func set_text(text):
	if text is Post:
		thread_name = text.thread_name
		post_header.text = thread_name
		body = text.body
		post_text.text = body
		var poster = Client.construct_for_client_new_id(text.id_client, "x")
		post_footer.text = String("{id}").format({id = poster._username})
		if post_footer.text == "x":
			g_man.local_network_node
	else:
		thread_name = text

func get_text():
	return thread_name

func on_click_add_listener(_on_button_click):
	pass
#endregion button tool

#region savable:
func partly_save():			# only part save
	pass
func fully_save():				# full save
	DataBase.insert(_server, g_man.dbms, _path, "id_father", id, id_father)
	DataBase.insert(_server, g_man.dbms, _path, "id_client", id, id_client)
	DataBase.insert(_server, g_man.dbms, _path, "thread_name", id, thread_name)
	DataBase.insert(_server, g_man.dbms, _path, "body", id, body)
func partly_load():			# load only critical data
	pass
func fully_load():				# fully load
	id_father = DataBase.select(_server, g_man.dbms, _path, "id_father", id)
	id_client = DataBase.select(_server, g_man.dbms, _path, "id_client", id)
	thread_name = DataBase.select(_server, g_man.dbms, _path, "thread_name", id)
	body = DataBase.select(_server, g_man.dbms, _path, "body", id)
#endregion
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(id_father)
	data.push_back(id_client)
	data.push_back(thread_name)
	data.push_back(body)
	return data

func deserialize(data):
	body = data.pop_back()
	thread_name = data.pop_back()
	id_client = data.pop_back()
	id_father = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize


func on_comment_submit():
	if comment_text.text:
		g_man.social.create_comment(id, comment_text.text)
