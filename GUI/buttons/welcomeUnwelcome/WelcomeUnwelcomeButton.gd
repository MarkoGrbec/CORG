class_name WelcomeUnwelcomeButton extends HBoxContainer

var unwelcome_mac
@export var reviel_me: Button
@export var wait_time: Label

func _on_button_reviel_me():
	reviel_me.text = String("{text}").format({text = unwelcome_mac.id})
	g_man.local_network_node.cmd_check_id_mac.rpc_id(1, unwelcome_mac.id, unwelcome_mac.id_mac)
	if unwelcome_mac.wait_time:
		wait_time.text = Time.get_datetime_string_from_unix_time(unwelcome_mac.wait_time)
		wait_time.show()
	else:
		wait_time.hide()

func _on_button_banned():
	g_man.welcome_unwelcome_window.move_to_banned(unwelcome_mac)

func _on_button_approved():
	g_man.welcome_unwelcome_window.move_to_approved(unwelcome_mac)

func _on_button_pending():
	g_man.welcome_unwelcome_window.move_to_pending(unwelcome_mac)

func refresh(text):
	reviel_me.text = String("{text}").format({text = text})
