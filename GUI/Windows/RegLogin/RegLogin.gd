class_name reg_login extends TabContainer

@export var window_manager: WindowManager

@export var debug: TextureRect
var camera: CameraFeed

func _ready():
	## for getting permissions for android as soon as it starts
	OS.request_permissions()
	
	g_man.reg_login_tabs = self
	g_man.server_accounts_container = accounts_container
	g_man.file_dialog = file_dialog
	window_manager.set_id_window(2, "register login")
	for i in range(1, 6):
		set_tab_hidden(i, true)
	
	await get_tree().create_timer(1).timeout
	var server: bool = false
	## if it's server
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg is String:
			if arg == "server":
				server = true
				server()
	## if it's local client
	if not server and start_client_button.is_visible_in_tree():
		server_ip_address.text = "::1"
		server()
	## if it's normal client
	elif not server:
		client()

@export var file_dialog:FileDialog

@export var existing_account_container: VBoxContainer
@export var accounts_container: VBoxContainer

@export var server_ip_address: LineEdit
@export var server_port: LineEdit

@export var start_client_button: Button

func set_current_tabing(id):
	current_tab = id

func config(toggle: bool):
	g_man.self_send = toggle

func show_window(_show: bool = false):
	window_manager.show_window(_show)
	
	set_current_tabing(0)

func close():
	window_manager.close_window()

func show_log_reg_ref():
	for i in range(1, 4):
		set_tab_hidden(i, false)

func config_address_port():
	var ip_address = server_ip_address.text
	var port = int(server_port.text)
	if not ip_address:
		ip_address = "92.37.84.199"
	if not port:
		port = 50123
	g_man.server_ip_address = ip_address
	g_man.port = port

func client():
	multiplayer.multiplayer_peer.disconnect_peer(1)
	config_address_port()
	g_man.client()
	show_log_reg_ref()

func server():
	push_warning("config")
	config_address_port()
	push_warning("start server")
	g_man.server()
	show_log_reg_ref()
	set_tab_hidden(5, false)

@export var log_username: LineEdit
@export var log_password: LineEdit

func login():
	g_man.login(log_username.text, log_password.text)

@export var reg_username: LineEdit
@export var reg_password: LineEdit
@export var reg_confirm_password: LineEdit

func register():
	if reg_password.text == reg_confirm_password.text:
		g_man.register(reg_username.text, reg_password.text)
	else:
		g_man.mold_window.set_instructions_only(["both passwords needs to be same"])

@export var confirm_line: LineEdit

func confirm():
	confirm_text(confirm_line.text)

func confirm_text(text: String):
	if confirm_line.placeholder_text != text:
		g_man.mold_window.set_instructions_only(["you have written wrong confirmation please try again", confirm_line.placeholder_text, text])
		return
	g_man.local_network_node.cmd_registration_confirmation.rpc_id(1, text.to_int())

func set_confirmation(id_confirm:int):
	set_current_tabing(4)
	confirm_line.placeholder_text = String("{id_confirm}").format({id_confirm = id_confirm})

var buttons = {}

func add_existing_account(id:int, username:String):
	var button = preload("res://GUI/buttons/reg_login/existing_account_button.tscn").instantiate()
	existing_account_container.add_child(button)
	button.set_button(id, username)
	buttons[id] = button
	var ids = g_man.multi_client__server_client.select_oposite_ids(id, 0)
	if ids:
		button.id_server = ids[0]

func update_existing_account(_client:Client):
	var button = buttons.get(_client.id)
	if button:
		button.set_button(_client.id, _client._username)
	else:
		add_existing_account(_client.id, _client._username)

func remove_button(id):
	buttons.get(id).queue_free()
	buttons.erase(id)
	g_man.existing_accounts.erase(id)
