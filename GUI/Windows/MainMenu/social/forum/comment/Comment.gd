class_name Comment extends ISavable


func copy():
	return Comment.new()

var id_father
var id_client
var body
var comment_of_comment = false

@onready var comment_text = $"comment margin/comment container/MarginContainer/comment/comment text"
@onready var add_comment_text = $"comment margin/comment container/MarginContainer/comment/add comment text"

#@onready var post_header = $"HBoxContainer/post margin/post container/post header"
#@onready var post_text = $"HBoxContainer/post margin/post container/post text"
#@onready var post_footer = $"HBoxContainer/post margin/post container/post footer"
#
#@onready var comment_text = $"HBoxContainer/post margin/post container/comment text"
#
#@onready var comment_container = $"HBoxContainer/post margin/post container/comment margin/comment container"

func get_content_container(_id_father):
	#push_error("id father: ", _id_father)
	#return g_man.social.forum_button_tool.get_button(_id_father).posts_container
	pass

func get_comment_container():
	pass
	#return comment_container

#region button tool
func set_text(text):
	if text is Comment:
		body = text.body
		comment_text.text = text.body
	else:
		body = text
		push_error(text)

func get_text():
	return body

func on_click_add_listener(_on_button_click):
	pass
#endregion button tool

#region savable:
func partly_save():			# only part save
	pass
func fully_save():				# full save
	DataBase.insert(_server, g_man.dbms, _path, "id_father", id, id_father)
	DataBase.insert(_server, g_man.dbms, _path, "id_client", id, id_client)
	DataBase.insert(_server, g_man.dbms, _path, "body", id, body)
	DataBase.insert(_server, g_man.dbms, _path, "c_of_c", id, comment_of_comment)
	
func partly_load():			# load only critical data
	pass
func fully_load():				# fully load
	id_father = DataBase.select(_server, g_man.dbms, _path, "id_father", id)
	id_client = DataBase.select(_server, g_man.dbms, _path, "id_client", id)
	body = DataBase.select(_server, g_man.dbms, _path, "body", id)
	comment_of_comment = DataBase.select(_server, g_man.dbms, _path, "c_of_c", id)
#endregion
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(id_father)
	data.push_back(id_client)
	data.push_back(body)
	data.push_back(comment_of_comment)
	return data
	
func deserialize(data):
	comment_of_comment = data.pop_back()
	body = data.pop_back()
	id_client = data.pop_back()
	id_father = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize


func on_comment_submit():
	if add_comment_text:
		g_man.social.create_comment_comment(id, add_comment_text.text, comment_of_comment)
