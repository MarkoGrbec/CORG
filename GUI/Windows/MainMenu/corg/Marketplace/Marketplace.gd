class_name Marketplace extends Node

func _ready():
	g_man.marketplace = self
	trader_button_tool = ButtonTool.new(TRADER, null, trader_clicked, cmd_refresh_trader, traders_container)

const TRADER = preload("res://GUI/Windows/MainMenu/corg/Marketplace/TraderButton.tscn")
@onready var traders_container: VBoxContainer = $"VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer/traders container"

@onready var previous_traders: Button = $"VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/previous 10"
@onready var next_traders: Button = $"VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/next 10"

var trader_index = 0
var trader_button_tool:ButtonTool

func open_my_store():
	var corg:Company = Company.try_get_client_corg(g_man.local_network_node.client.id)
	g_man.store_manager.show_window(corg.id_server)
	g_man.store_manager.refresh_self_corg()
	
#region trader
func add_trader_buttons(ids):
	trader_button_tool.add_buttons(ids)

func refresh_trader(id_corg, trader_name):
	trader_button_tool.refresh_text_only(id_corg, trader_name)
	
func trader_clicked(id):
	g_man.store_manager.show_window(id)
	g_man.store_manager.refresh_corg(id)

func cmd_refresh_trader(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_trader.rpc_id(1, id)
#endregion trader
