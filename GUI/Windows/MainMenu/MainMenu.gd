class_name MainMenu extends TabContainer

func _ready():
	g_man.main_menu_tabs = self
	get_parent().set_id_window(3, "main menu")

#region social
@onready var forum_container = $social/forum
@onready var my_rererrer_name: LineEdit = $corg/stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/referrer/whom
@onready var corg_tab: Corg = $corg

func on_main_menu_tab_clicked(tab):
	if tab == 0:	# corg tab
		get_current_tab_control().check_confirmed()
		cmd_refresh_money()
	elif tab == 1:	# options tab
		get_current_tab_control().update_from_client()
	elif tab == 2:	# social tab
		get_current_tab_control().send()
	elif not tab == 3:
		corg_tab.enable_tab_buttons()

func starter_tab():
	show_window()
	current_tab = 1
	on_main_menu_tab_clicked(1)
	# admin tab
	if not g_man.local_network_node.client.user_level == Client.ADMIN_USER_LEVEL:
		set_tab_hidden(5, true)
#endregion social
#region window properties
func show_window():
	get_parent().show_window(true)

func on_logout():
	get_parent().hide()
	g_man.logout()

func on_quit():
	get_tree().quit()
#endregion window properties
#region referrer
func cmd_set_referrer(referrer_name):
	g_man.local_network_node.net_corg_node.cmd_set_referrer.rpc_id(1, referrer_name)

func refresh_referrer():
	var referrer = Client.construct_for_client_new_id(g_man.local_network_node.client.referrer, "ref")
	my_rererrer_name.text = referrer._username
	cmd_refresh_money()

#endregion referrer
#region money
@onready var wheets: Label = $corg/stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/wheets
@onready var carrots: Label = $corg/stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/carrots
@onready var apples: Label = $corg/stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/apples
@onready var pineapples: Label = $corg/stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/pineapples
@onready var bananas: Label = $corg/stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/bananas
@onready var greyfruits: Label = $corg/stats/person/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/greyfruits

func cmd_refresh_money():
	if g_man.local_network_node.net_corg_node:
		g_man.local_network_node.net_corg_node.cmd_refresh_money.rpc_id(1)

func refresh_money():
	var money		= g_man.local_network_node.client.money_system.get_money()
	wheets.text		= MoneyCurrency.balance(money, MoneyCurrency.plant.wheet)
	carrots.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.carrot)
	apples.text		= MoneyCurrency.balance(money, MoneyCurrency.plant.apple)
	pineapples.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.pineapple)
	bananas.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.banana)
	greyfruits.text	= MoneyCurrency.balance(money, MoneyCurrency.plant.greyfruit)
#endregion money
