class_name WelcomeUnwelcome extends Node

@export var entered_with_label: Label

func _ready():
	g_man.welcome_unwelcome_window = self
	get_parent().set_id_window(4, "welcome unwelcome")

func show_window(_show):
	get_parent().show_window(_show)

func close_window():
	get_parent().close_window()

func add_macs(array_macs):
	entered_with_label.text = str("you entered with: ", OS.get_unique_id())
	var list_macs = Serializable.deserialize(UnwelcomeMac.new(), array_macs)
	for item in list_macs:
		add(item)



@onready var banned_container = $banned/Marginscroll/ScrollContainer/MarginContainer/bannedContainer
@onready var pending_container = $pending/MarginScroll/ScrollContainer/MarginContainer/pendingContainer
@onready var approved_container = $approved/MarginContainer/ScrollContainer/MarginContainer/approvedContainer
const WELCOME_UNWELCOME_BUTTONS = preload("res://GUI/buttons/welcomeUnwelcome/WelcomeUnwelcomeButtons.tscn")
const WELCOME_UNWELCOME_BUTTON = preload("res://GUI/buttons/welcomeUnwelcome/WelcomeUnwelcomeButton.gd")

var container = {}

#region add to the container
func add(unwelcome_mac:UnwelcomeMac):
	if container.has(unwelcome_mac.id):
		var button = container.get(unwelcome_mac.id)
		button.unwelcome_mac = unwelcome_mac
		_move(unwelcome_mac)
		button._on_button_reviel_me()
		return
	var button = WELCOME_UNWELCOME_BUTTONS.instantiate()
	pending_container.add_child(button)
	button.set_script(WELCOME_UNWELCOME_BUTTON)
	button.unwelcome_mac = unwelcome_mac
	#button.text = String("{text}").format({text = unwelcome_mac.id_mac})
	container[unwelcome_mac.id] = button
	_move(unwelcome_mac)
	button._on_button_reviel_me()
#endregion add to the container
#region move
func _move(unwelcome_mac: UnwelcomeMac):
	if unwelcome_mac.approved == UnwelcomeMac.approving.BANNED:
		move_banned(unwelcome_mac)
	elif unwelcome_mac.approved == UnwelcomeMac.approving.PENDING:
		move_pending(unwelcome_mac)
		show_window(true)
	elif unwelcome_mac.approved == UnwelcomeMac.approving.APPROVED:
		move_approved(unwelcome_mac)

func move_approved(mac:UnwelcomeMac):
	container[mac.id].reparent(approved_container)
	mac.approved = UnwelcomeMac.approving.APPROVED
	
func move_banned(mac:UnwelcomeMac):
	container[mac.id].reparent(banned_container)
	mac.approved = UnwelcomeMac.approving.BANNED

func move_pending(mac:UnwelcomeMac):
	container[mac.id].reparent(pending_container)
	mac.approved = UnwelcomeMac.approving.PENDING
#endregion move
#region move and send data
func move_to_approved(mac:UnwelcomeMac):
	# it can be moved BUT it needs to wait certain time
	if can_change_mac(mac):
		move_approved(mac)
		send_change_status(mac)
	else:
		g_man.local_network_node.cmd_change_mac_to_approved.rpc_id(1, mac.id_mac)

func move_to_banned(mac):
	if can_change_mac(mac):
		move_banned(mac)
		send_change_status(mac)

func move_to_pending(mac):
	if can_change_mac(mac):
		move_pending(mac)
		send_change_status(mac)

func send_change_status(mac):
	var ser_mac = Serializable.serialize([mac])
	g_man.local_network_node.cmd_change_mac_status.rpc_id(1, ser_mac)
#endregion move and send data
#region
func can_change_mac(mac):
	if OS.get_unique_id() == container[mac.id].reviel_me.text:
		g_man.mold_window.set_instructions_only(["can't change your mac with wich you came in"])
		return false
	if g_man.local_network_node.client.came_in_with_other_computer:
		g_man.mold_window.set_instructions_only(["can't change macs status", "this is not your approved mac", "of this account"])
		return false
	return true
#endregion
