class_name Corg extends TabContainer

func _ready():
	g_man.corg = self
	mod_pictures_button_tool = ButtonTool.new(PENDING_FOR_CORG, null, button_pressed_approve, cmd_refresh_id_picture, mod_pictures_to_approve_container)
	workers_button_tool = ButtonTool.new(WORKER_BUTTON, null, open_worker_window, cmd_refresh_worker, workers_container)
	applicators_button_tool = ButtonTool.new(WORKER_BUTTON, null, open_worker_window, cmd_refresh_applicator, applicators_container)
	set_tab_hidden(0, true)

var mod_pictures_button_tool:ButtonTool

@onready var mod_pictures_to_approve_container = $"Moderator_place/margin top2/VBoxContainer/ScrollContainer/MarginContainer/mod pictures to approve container"
const PENDING_FOR_CORG = preload("res://GUI/Windows/MainMenu/corg/Confirm/pending_for_corg.tscn")

@onready var scroll_corg_stats: ScrollContainer = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats"
@onready var button_become_corg: Button = $"stats/corg/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button become corg"
@onready var apply_to_corg_text: LineEdit = $"stats/corg/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/apply to corg"

#region connect to corg
func check_confirmed():
	is_self_proprietor()
	if not g_man.local_network_node.net_corg_node:
		g_man.local_network_node.add_net_custom.rpc_id(1, 2)

func start():
	update_personal_stats()
	g_man.commercial_manager.set_client_commercials_wait(g_man.local_network_node.client.load_return_commercials_wait())
	get_parent().cmd_refresh_money()
	#refresh comercials only at start for now
	g_man.local_network_node.net_corg_node.cmd_load_corg_commercialists.rpc_id(1)
	if not enable_tab_buttons():
		# not verified yet send him away
		if g_man.local_network_node.client.user_level == 0:
			get_parent().set_tab_disabled(0, true)
			get_parent().current_tab = 1
			if not g_man.local_network_node.client.send_picture:
				g_man.corg_apply_to_be_approved.show_window()
			for i in range(1, 6):
				set_tab_disabled(i, true)
	

func enable_tab_buttons():
	if g_man.local_network_node.client.user_level >= Client.BECOME_MODERATOR:
		# corg tab this
		get_parent().set_tab_disabled(0, false)
		# moderator place
		set_tab_hidden(0, false)
		# all other corg tabs
		for i in 6:
			set_tab_disabled(i, false)
		return true
		
#endregion connect to corg
#region personal stats
@onready var honor_number: Label = $"stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/honor/honor number"
@onready var username: Label = $stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/username/name
@onready var employed_at_label: Label = $"stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/employed at/employed at label"
func update_personal_stats():
	g_man.local_network_node.net_corg_node.cmd_load_honor.rpc_id(1)
	update_honor()
	update_employed_at()
	update_username()

func update_honor():
	var client:Client = g_man.local_network_node.client
	honor_number.text = str(client.honor)

func update_employed_at():
	var id_server_employed_at = g_man.local_network_node.client.load_return_employed_at()
	if id_server_employed_at:
		var client:Client = Client.construct_for_client_new_id(id_server_employed_at, "null")
		employed_at_label.text = client._username
	else:
		employed_at_label.text = "unemployed"

func update_username():
	var client:Client = g_man.local_network_node.client
	username.text = client._username
#endregion personal stats
#region buttons
func on_set_stats():
	g_man.account_worker_stats_window.show_window()
#endregion buttons
#region tabs clicked
func on_stats_corg_tab_clicked(tab):
	if tab == 0:
		update_personal_stats()
		get_parent().cmd_refresh_money()
	if tab == 1:
		is_self_proprietor()
		get_parent().cmd_refresh_money()

func on_corg_tab_clicked(tab):
	is_self_proprietor()
	if tab == 0: # moderator place
		var user_level = g_man.local_network_node.client.user_level
		if user_level < 3:
			set_tab_hidden(0, true)
			current_tab = 1
		else:
			g_man.local_network_node.net_corg_node.cmd_refresh_id_pictures.rpc_id(1)
	elif tab == 2: # market place
		g_man.local_network_node.net_corg_node.cmd_get_traders.rpc_id(1, 0)
	elif tab == 3: # workplace
		refresh_workers()
		refresh_applicators()
	elif tab == 4: # law
		get_current_tab_control().send()
#endregion tabs clicked
#region adds
@onready var submit_person_adds_time: LineEdit = $"stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/adds/submit person adds time"

@onready var submit_adds_time: LineEdit = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/adds/submit adds time"
@onready var submit_adds_pay: LineEdit = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/adds pay/submit adds pay"

func set_person_adds_time(time):
	g_man.commercial_manager.set_client_commercials_wait(int(time))

func set_adds_time(time):
	g_man.local_network_node.client.save_commercials_wait(int(time))

func set_adds_pay(money):
	g_man.local_network_node.net_corg_node.cmd_set_pay_commercial.rpc_id(1, int(money))

func update_add_pay(money):
	var corg:Company = Company.try_get_client_corg(g_man.local_network_node.client.id)
	if corg:
		corg.comercialist_pay = money
		corg.save_commercials_pay()
		submit_adds_pay.text = MoneyCurrency.balance(money, MoneyCurrency.plant.all)
#endregion adds
#region money
@onready var wheets: Label = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/wheets"
@onready var carrots: Label = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/carrots"
@onready var apples: Label = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/apples"
@onready var pineapples: Label = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/pineapples"
@onready var bananas: Label = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/bananas"
@onready var greyfruits: Label = $"stats/corg/MarginContainer/VBoxContainer/scroll corg stats/VBoxContainer/greyfruits"

func refresh_money():
	var client:Client = g_man.local_network_node.client
	var corg:Company = Company.try_get_client_corg(client.id)
	var money = corg.get_money()
	wheets.text		= MoneyCurrency.balance(money, MoneyCurrency.plant.wheet)
	carrots.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.carrot)
	apples.text		= MoneyCurrency.balance(money, MoneyCurrency.plant.apple)
	pineapples.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.pineapple)
	bananas.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.banana)
	greyfruits.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.greyfruit)
#endregion money
#region approving
## i approve it
func button_pressed_approve(id, emso):
	g_man.local_network_node.net_corg_node.cmd_add_id.rpc_id(1, id, emso)
	mod_pictures_button_tool.permanently_delete([id])

func cmd_refresh_id_picture(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_id_picture.rpc_id(1, id)

func refreshed_id(id, t_class):
	mod_pictures_button_tool.refresh_t(id, t_class)
#endregion approving
#region self proprietor
func is_self_proprietor():
	var client = g_man.local_network_node.client
	var employed_at = client.load_return_employed_at()
	var employed_at_corg = client.load_return_employed_at_corg()
	# not employed
	if employed_at == 0 && employed_at_corg == 0:
		scroll_corg_stats.hide()
		button_become_corg.show()
		apply_to_corg_text.show()
		# workplace
		set_tab_hidden(3, true)
	# self proprietor
	elif client.id_server == employed_at:
		scroll_corg_stats.show()
		button_become_corg.hide()
		apply_to_corg_text.hide()
		# workplace
		set_tab_hidden(3, false)
	# cannot be self proprietor
	else:
		scroll_corg_stats.hide()
		button_become_corg.hide()
		apply_to_corg_text.hide()
		# workplace
		set_tab_hidden(3, true)

func become_corg():
	g_man.local_network_node.net_corg_node.cmd_add_self_proprietor.rpc_id(1)
#endregion self proprietor
#region workers
const WORKER_BUTTON = preload("res://GUI/Windows/MainMenu/corg/Workers/WorkerButton.tscn")
@onready var workers_container: VBoxContainer = $"workplace/TabContainer/corg workplace/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/workers container"
var workers_button_tool: ButtonTool

func refresh_workers():
	g_man.local_network_node.net_corg_node.cmd_refresh_workers.rpc_id(1)

func add_workers(ids):
	workers_button_tool.add_buttons(ids)

func refresh_worker(employee:Client):
	workers_button_tool.refresh_text_only(employee.id_server, employee._username)

func remove_worker(employee:Client):
	workers_button_tool.permanently_delete([employee.id_server])

func open_worker_window(id):
	g_man.workers_window.show_window()
	var worker:Client = Client.construct_for_client_new_id(id, "null")
	g_man.workers_window.set_worker(worker)

func cmd_refresh_worker(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_worker.rpc_id(1, id)
#endregion workers
#region applicators
var applicators_button_tool: ButtonTool
@onready var applicators_container: VBoxContainer = $"workplace/TabContainer/corg workplace/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/applicators container"

func apply_to_corg(text):
	g_man.local_network_node.net_corg_node.cmd_apply_for_job.rpc_id(1, text)

func refresh_applicators():
	g_man.local_network_node.net_corg_node.cmd_refresh_applicators.rpc_id(1)

func add_applicators(ids):
	applicators_button_tool.add_buttons(ids)

func refresh_applicator(applicator:Client):
	applicators_button_tool.refresh_text_only(applicator.id_server, applicator._username)

func remove_applicator(applicator:Client):
	applicators_button_tool.permanently_delete([applicator.id_server])

func cmd_refresh_applicator(id):
	print("cmd refresh applicator id", id)
	g_man.local_network_node.net_corg_node.cmd_refresh_applicator.rpc_id(1, id)
#endregion applicators
