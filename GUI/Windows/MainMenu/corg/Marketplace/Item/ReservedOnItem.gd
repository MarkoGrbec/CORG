class_name ReservedOnItem extends ISavable
#region input
@onready var remove_reserved: Button = $"remove reserved"
@onready var corg_name: Label = $"corg name"
@onready var label_money: Label = $money
@onready var total_reserved_money: Label = $"total reserved money"

var default_text
var id_item
var id_seller
var id_buyer
var money
#endregion input
#region reserved
## id_seller: the one that is transferred money to
## id_buyer: the one that placed reserve
static func set_new(_id_item, _id_seller, _id_buyer, _money):
	var r = g_man.savable_multi_item__seller____reserved_on_item.get_p_s_data(_id_item, _id_seller)
	r.id_item = _id_item
	r.id_seller = _id_seller
	r.id_buyer = _id_buyer
	r.money = _money
	r.fully_save()
	return r.id

static func server_remove_reserved(_id_item, _id_seller):
	return g_man.savable_multi_item__seller____reserved_on_item.delete_p_s(_id_item, _id_seller)

#endregion end reserved
#region Savable
func copy():
	return ReservedOnItem.new()
	#region Save
func fully_save():
	save_money()
	DataBase.insert(_server, g_man.dbms, _path, "id_item", id, id_item)
	DataBase.insert(_server, g_man.dbms, _path, "id_buyer", id, id_buyer)
	DataBase.insert(_server, g_man.dbms, _path, "id_seller", id, id_seller)

func partly_save():
	pass

## item_reserved_values
func save_money():
	DataBase.insert(_server, g_man.dbms, _path, "money", id, money)
	#endregion
	#region Load
func fully_load():
	money = DataBase.select(_server, g_man.dbms, _path, "money", id)
	id_item = DataBase.select(_server, g_man.dbms, _path, "id_item", id)
	id_buyer = DataBase.select(_server, g_man.dbms, _path, "id_buyer", id)
	id_seller = DataBase.select(_server, g_man.dbms, _path, "id_seller", id)

func partly_load():
	pass
	#endregion
#endregion
#region side of button tool
func set_reserved_money(_money):
	total_reserved_money.text = MoneyCurrency.balance(_money, MoneyCurrency.plant.all)
#endregion side of button tool
#region button tool
func set_text(text):
	if text is ReservedOnItem:
		money = text.money
		label_money.text = MoneyCurrency.balance(money, MoneyCurrency.plant.all)
		# id_seller is item on which corg is reserved money
		var client:Client = Company.try_get_client_from_corg(int(text.id_seller), refresh_corg)
		if client:
			corg_name.text = str(client._username)
	else:
		money = text

func refresh_corg(corg_or_client):
	if corg_or_client is Company:
		var client:Client = Company.try_get_client_from_corg(corg_or_client.id_server, null)
		if client:
			corg_name.text = client._username
		else:
			money = "x"
	elif corg_or_client is Client:
		corg_name.text = corg_or_client._username

func get_text():
	return str(money)

func on_click_add_listener(on_button_click:Callable):
	remove_reserved.pressed.connect(
		func():
			on_button_click.call(id)
	)
#endregion button tool
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(id_item)
	data.push_back(id_seller)
	data.push_back(id_buyer)
	data.push_back(money)
	return data
	
func deserialize(data):
	money = data.pop_back()
	id_buyer = data.pop_back()
	id_seller = data.pop_back()
	id_item = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize
