class_name ReservedOnCorg extends ISavable

#region input
var money = 0
var id_buyer
var id_seller
#endregion input
#region on corg
static func get_corg_reserve_money(reserved: ReservedOnItem):
	var corg_reserved_on_corg:ReservedOnCorg = g_man.savable_multi_corg__reserved_on_corg.get_all(reserved.id_buyer, reserved.id_seller)
	if corg_reserved_on_corg:
		return corg_reserved_on_corg.money
## reserve to all Corg at id_item and idTrader
## item: item on which reserves were done
## id_trader: trader which had reserved
## money: money that was given
static func add_reserve_to_corg(id_item, income_money, quantity):
	# check how much reserved money is menat from this item on this Buyer
	# all idBuyers
	var reserved_on_item = g_man.savable_multi_item__seller____reserved_on_item.get_all(id_item, 0)
	for on_item in reserved_on_item:
		# this buyer has reserved some money:
		var reserved = on_item.money * quantity
		# we see if all money has to be processed
		income_money -= reserved
		if income_money < 0:
			reserved += income_money
		# we transfer to corg
		if reserved > 0:
			add(on_item.id_buyer, on_item.id_seller, reserved)
		if income_money <= 0:
			# need to mark it 0 to give feed back income is none
			income_money = 0
	return income_money

static func add(id_trader, _id_seller, _money):
	# we're looking for specific row
	var corg_reserved_on_corg:ReservedOnCorg = g_man.savable_multi_corg__reserved_on_corg.get_all(id_trader, _id_seller)
	if not corg_reserved_on_corg:
		corg_reserved_on_corg = g_man.savable_multi_corg__reserved_on_corg.new_data(id_trader, _id_seller)
		corg_reserved_on_corg.id_buyer = id_trader
		corg_reserved_on_corg.id_seller = _id_seller
		corg_reserved_on_corg.save_traders()
	corg_reserved_on_corg.money += _money
	corg_reserved_on_corg.save_money()
	#corg_reserved_on_corg.id_buyer = id_trader
	#corg_reserved_on_corg.id_seller = id_seller
	#corg_reserved_on_corg.fully_save()

## id_customer_corg: id trader which
## id_corg_to_whom: id item from which it'll calculate the reserved
static func subtract(id_customer_corg, id_corg_to_whom, _money):
	if not id_customer_corg || not id_corg_to_whom:
		return 0
	var res_on_corg = g_man.savable_multi_corg__reserved_on_corg.get_all(id_customer_corg, id_corg_to_whom)
	if res_on_corg:
		var r_money = res_on_corg.money
		var part_money = int(r_money / 3)
		r_money -= _money
		if r_money > part_money:
			var tax_money = r_money - part_money
			MoneySystem.tax(tax_money)
			# reserved is bigger than 0 so it costs him 0
			_money = 0
		# let's calculate how much money is left
		elif r_money < 0:
			_money = r_money * -1
			r_money = 0
		else: #there is still money is reserve so it costs him 0
			_money = 0
		res_on_corg.money = r_money
		res_on_corg.save_money()
	return _money
#endregion on corg
#region Savable

func copy():
	return ReservedOnCorg.new()

	#region Save

func fully_save():
	save_money()
	save_traders()

func partly_save():
	pass

func save_traders():
	DataBase.insert(_server, g_man.dbms, _path, "id_buyer", id, id_buyer)
	DataBase.insert(_server, g_man.dbms, _path, "id_seller", id, id_seller)

# item_reserved_values
func save_money():
	DataBase.insert(_server, g_man.dbms, _path, "money", id, int(money))

	#endregion
	#region Load

func fully_load():
	money = DataBase.select(_server, g_man.dbms, _path, "money", id)
	if not money:
		money = 0
	id_buyer = DataBase.select(_server, g_man.dbms, _path, "id_buyer", id)
	id_seller = DataBase.select(_server, g_man.dbms, _path, "id_seller", id)

func partly_load():
	pass

	#endregion
#endregion
