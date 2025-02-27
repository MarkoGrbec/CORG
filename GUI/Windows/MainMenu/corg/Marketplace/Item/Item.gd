class_name Item extends ISavable
@onready var item_click: Button = $"item click"

enum buy_as{
	customer = 1,
	corg = 2,
	spender = 3
}

var name_text
var cost_text
var id_server_corg
var quantity = 1

#region save load:
func copy():
	return Item.new()
func partly_save():
	pass
func fully_save():
	pass
func partly_load():
	pass
func fully_load():
	name_text = DataBase.select(_server, g_man.dbms, _path, "item_name", id)
	cost_text = DataBase.select(_server, g_man.dbms, _path, "item_cost", id)
	id_server_corg = DataBase.select(_server, g_man.dbms, _path, "item_id_server_corg", id)

func save_name(item_name):
	name_text = item_name
	DataBase.insert(_server, g_man.dbms, _path, "item_name", id, item_name)

func save_cost(item_cost):
	cost_text = int(item_cost)
	DataBase.insert(_server, g_man.dbms, _path, "item_cost", id, cost_text)

func save_id_server_corg(item_id_server_corg):
	id_server_corg = item_id_server_corg
	DataBase.insert(_server, g_man.dbms, _path, "item_id_server_corg", id, item_id_server_corg)
#endregion save load
#region IButtonTool
# custom how to set text by data provided
func set_text(text):
	if text is Item:
		pass
		name_text = text.name_text
		if name_text:
			item_click.text = name_text
	else:
		name_text = text
		item_click.text = text

# custom how to return only one text: String
func get_text():
	return name_text

func on_click_add_listener(on_button_click:Callable):
	item_click.pressed.connect(
		func():
			on_button_click.call(id)
	)
#endregion IButtonTool
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(id_server_corg)
	data.push_back(name_text)
	data.push_back(cost_text)
	return data
	
func deserialize(data):
	cost_text = data.pop_back()
	name_text = data.pop_back()
	id_server_corg = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize

func set_new_reserve(money, id_seller, id_buyer):
	return ReservedOnItem.set_new(id, id_seller, id_buyer, MoneyCurrency.convert_money(float(money), MoneyCurrency.plant.apple))
