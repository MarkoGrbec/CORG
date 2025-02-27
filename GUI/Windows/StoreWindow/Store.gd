class_name StoreManager extends Node

func _ready() -> void:
	g_man.store_manager = self
	requested_customers_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/corg/Marketplace/Item/RequestedCustomer.tscn"), null, on_click_requested_customers, cmd_refresh_requested_customer, requested_customer_container)
	requested_items_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/corg/Marketplace/Item/RequestedItem.tscn"), null, on_click_requested_item_of_customer_shipment, cmd_refresh_requested_item_of_customer, requested_items_container)
	#self_item_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/corg/Marketplace/Item/SelfItem.tscn"), null, on_item_click, cmd_refresh_item, items_container)
	item_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/corg/Marketplace/Item/Item.tscn"), null, on_item_click, cmd_refresh_item, items_container)
	get_parent().set_id_window(8, "store window")

func show_window(id_trader):
	_id_trader = id_trader
	get_parent().show_window()
	var corg = Company.try_get_client_corg(g_man.local_network_node.client.id)
	if corg && corg.id_server == id_trader: # if founder is looking at his own store
		requested_items_tab.current_tab = 0
		requested_items_tab.set_tab_hidden(1, true)
		requested_items_tab.set_tab_hidden(0, false)
		item_name.show()
		item_cost.show()
		add_item.show()
	else: # if customer is looking at store
		requested_items_tab.current_tab = 1
		requested_items_tab.set_tab_hidden(0, true)
		cmd_get_requested_items_from_trader(id_trader)
		item_name.hide()
		item_cost.hide()
		add_item.hide()

func close_window():
	get_parent().close_window()

#region tabs
@onready var requested_items_tab: TabContainer = $"requested items"

func on_tab_clicked(tab: int) -> void:
	if tab == 1:
		show_all_requested_customers()
	elif tab == 2:
		show_store_commercials()
#endregion tabs
#region requested customer
@onready var requested_customer_container: VBoxContainer = $"requested items/customers/customers/Marginscroll/ScrollContainer/Requested Customer Container"
var requested_customers_button_tool: ButtonTool

func show_all_requested_customers():
	g_man.local_network_node.net_corg_node.cmd_get_customers_of_requested_items.rpc_id(1)

func add_requested_customers_buttons(ids):
	requested_customers_button_tool.hide_all_buttons()
	requested_customers_button_tool.add_buttons(ids, 0, true)

func refresh_requested_customers_button(id, requested_customer_name):
	requested_customers_button_tool.refresh_text_only(id, requested_customer_name)

func on_click_requested_customers(id):
	show_requested_items_of_customer(id)

func cmd_refresh_requested_customer(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_customer_of_requested_items.rpc_id(1, id)
#endregion requested customer
#region requested items
@onready var requested_items_container: VBoxContainer = $"requested items/requested items/customers/Marginscroll/ScrollContainer/Requested Items Container"
var requested_items_button_tool: ButtonTool

func cmd_get_requested_items_from_trader(id_trader):
	requested_items_tab.set_tab_hidden(1, true)
	g_man.local_network_node.net_corg_node.cmd_get_requested_items_for_customer.rpc_id(1, id_trader)

func show_requested_items_of_customer(id):
	requested_items_tab.set_tab_hidden(1, true)
	g_man.local_network_node.net_corg_node.cmd_get_requested_items.rpc_id(1, id)

func add_requested_items_of_customer_buttons(ids):
	requested_items_button_tool.hide_all_buttons()
	requested_items_button_tool.add_buttons(ids, 0, true)
	requested_items_tab.set_tab_hidden(1, false)

func refresh_requested_item_of_customer_button(id, requested_item):
	requested_items_button_tool.refresh_text(id, requested_item)

func on_click_requested_item_of_customer_shipment(id):
	g_man.local_network_node.net_corg_node.cmd_requested_item_shipment_change_status.rpc_id(1, id)

func cmd_refresh_requested_item_of_customer(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_requested_item.rpc_id(1, id)
#endregion requested items
#region items
var _id_trader
@onready var item_name: LineEdit = $"items/Marginscroll/ScrollContainer/items container/item name"
@onready var item_cost: LineEdit = $"items/Marginscroll/ScrollContainer/items container/item cost"
@onready var add_item: Button = $"items/Marginscroll/ScrollContainer/items container/add item"
@onready var items_container: VBoxContainer = $"items/Marginscroll/ScrollContainer/items container"

#var self_item_button_tool:ButtonTool
var item_button_tool:ButtonTool
	#region refresh corg
func refresh_self_corg():
	item_button_tool.hide_all_buttons()
	g_man.local_network_node.net_corg_node.cmd_refresh_trader_self.rpc_id(1)

func refresh_corg(id_corg):
	item_button_tool.hide_all_buttons()
	g_man.local_network_node.net_corg_node.cmd_refresh_trader_items.rpc_id(1, id_corg)
	#endregion refresh corg
	#region add item
func on_add_item():
	var cost = MoneyCurrency.convert_money(float(item_cost.text), MoneyCurrency.plant.apple)
	item_cost.text = MoneyCurrency.balance(cost, MoneyCurrency.plant.all)
	g_man.local_network_node.net_corg_node.cmd_add_item_to_market.rpc_id(1, item_name.text, cost)

func add_items_buttons(_id_corg, ids):
	if len(ids) > 1:
		item_button_tool.hide_all_buttons()
	item_button_tool.add_buttons(ids, 0, true)
	#endregion add item
	#region on click
func on_item_click(id):
	var item = item_button_tool.get_t_class(id)
	if item:
		var corg = Company.try_get_client_corg(g_man.local_network_node.client.id)
		if corg && corg.id_server == _id_trader:
			g_man.item_manager.show_window(_id_trader, item, true)
		else:
			g_man.item_manager.show_window(_id_trader, item, false)
	#endregion on click
	#region refresh item
func cmd_refresh_item(id_server_item):
	g_man.local_network_node.net_corg_node.cmd_refresh_item.rpc_id(1, id_server_item)

func refresh_item(item:Item):
	item_button_tool.refresh_t(item.id, item)
	#endregion refresh item
	#region remove item
func cmd_remove_item(id):
	g_man.local_network_node.net_corg_node.cmd_remove_market_item.rpc_id(1, id)
	item_button_tool.permanently_delete([id])
	#endregion remove iten
#endregion items
#region commercials
@onready var commercial_container: VBoxContainer = $"commercials/Marginscroll/ScrollContainer/commercial container"
const STORE_COMMERCIAL = preload("res://GUI/Windows/StoreWindow/StoreCommercial.tscn")

var store_commercial_dict = {}

func add_comercial_picture():
	g_man.file_dialog.show()
	g_man.file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	g_man.file_dialog.current_path = "/storage/emulated/0/" #OS.get_user_data_dir()
	FileDialogMan.get_file_path(g_man.file_dialog, commercial_picture)

func commercial_picture(file):
	var raw = SaveLoadPicture.load_image_to_raw_png(file)
	g_man.local_network_node.net_corg_node.cmd_send_commercial_picture_to_server.rpc_id(1, raw)

func show_store_commercials():
	g_man.local_network_node.net_corg_node.cmd_load_id_commercial_pictures.rpc_id(1)

func show_store_commercial(id_server_picture):
	if not store_commercial_dict.has(id_server_picture):
		var store_commercial:StoreCommercial = STORE_COMMERCIAL.instantiate()
		commercial_container.add_child(store_commercial)
		store_commercial_dict[id_server_picture] = store_commercial
		store_commercial.show_picture(id_server_picture)

func delete_picture(id_server_picture):
	if store_commercial_dict.has(id_server_picture):
		store_commercial_dict[id_server_picture].queue_free()
		store_commercial_dict.erase(id_server_picture)
#endregion commercials
