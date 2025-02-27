class_name Options extends Node

func _ready() -> void:
	g_man.options = self


@export var new_password: LineEdit
@export var confirm_password: LineEdit
@export var old_password: LineEdit
@export var other_computers_can_come_in: CheckBox
@export var other_clients_can_come_in: CheckBox
@export var speach_dialogs: CheckBox
@export var font_size_text: LineEdit
@export var font_size: Theme


@export var audio_container: Control

#region security
func on_submit_security():
	if old_password.text:
		if new_password.text:
			if new_password.text == confirm_password.text:
				var encrypt:EncriptData = g_man.local_network_node.encrypted
				
				var new_enc_pass = EncriptData.synchronous_encrypting(new_password.text, encrypt.secret_key)
				var old_enc_pass = EncriptData.synchronous_encrypting(old_password.text, encrypt.secret_key)
				
				g_man.local_network_node.cmd_change_security.rpc_id(1,
					other_clients_can_come_in.button_pressed,
					other_computers_can_come_in.button_pressed,
					old_enc_pass,
					new_enc_pass
				)
		else:
			var encrypt:EncriptData = g_man.local_network_node.encrypted
				
			var old_enc_pass = EncriptData.synchronous_encrypting(old_password.text, encrypt.secret_key)
			
			g_man.local_network_node.cmd_change_security.rpc_id(1,
				other_clients_can_come_in.button_pressed,
				other_computers_can_come_in.button_pressed,
				old_enc_pass,
				0
			)
		update_can_get_in()
func update_can_get_in():
	g_man.local_network_node.client.other_client_can_get_in = other_clients_can_come_in.button_pressed
	g_man.local_network_node.client.other_computers_can_get_in = other_computers_can_come_in.button_pressed

func update_from_client():
	other_clients_can_come_in.button_pressed = g_man.local_network_node.client.other_client_can_get_in
	other_computers_can_come_in.button_pressed = g_man.local_network_node.client.other_computers_can_get_in

func on_ban_or_approve_mac():
	g_man.welcome_unwelcome_window.show_window(true)
#endregion security
#region dialogs
func load_speach_dialogs():
	var speach = DataBase.select(false, g_man.dbms, "options", "dialogs", g_man.local_network_node.client.id)
	if speach:
		speach_dialogs.button_pressed = speach

func _toggle_speach_dialogs(yes: bool):
	DataBase.insert(false, g_man.dbms, "options", "dialogs", g_man.local_network_node.client.id, yes)
#endregion
#region options
func load_font_size():
	var size = DataBase.select(false, g_man.dbms, "options", "c_font_size", g_man.local_network_node.client.id)
	if size:
		font_size.default_font_size = size
		font_size_text.text = str(size)

func _on_font_size_change(new_text: String) -> void:
	var size = int(new_text)
	size = clampi(size, 10, 50)
	font_size.default_font_size = size
	DataBase.insert(false, g_man.dbms, "options", "c_font_size", g_man.local_network_node.client.id, size)
#endregion options
#region save system
## from g_man sucessfully login
func fully_load():
	load_speach_dialogs()
	load_font_size()
	#load_audio()
#endregion save system
#region audio
	#region load
func load_audio():
	for audio in audio_container.get_children():
		if audio is AudioBusVolume:
			audio.load_audio()
	#endregion load
#endregion audio
