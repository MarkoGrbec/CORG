extends Node
	
@export var id: int
@export var username: String
@export var id_server: int

@export var username_button: Button

func set_button(_id, _username):
	id = _id
	username = _username
	username_button.text = _username

func login():
	push_warning("login with id ", id, " username: ", username, " server id: ", id_server)
	g_man.login_with_ref(id, id_server)

func delete_username():
	g_man.savable_client_client.remove_at(id)
	g_man.multi_client__server_client.delete(id, id_server)
	g_man.reg_login_tabs.remove_button(id)
