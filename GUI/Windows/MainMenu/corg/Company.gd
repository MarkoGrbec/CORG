class_name Company extends ISavable

func copy():
	return Company.new()

#region inputs
	#region comercialist
var comercialist_company_add_wait = 0
var comercialist_pay = 10000
	#endregion comercialist
var id_server
var money_system: MoneySystem = MoneySystem.new()
var max_profit = 0
var id_last_daily_income
var id_newest_daily_income

const K_PROFIT_CAP = 2.5
	#static long minSalary = 5000000
var founder = 0
#endregion end inputs
#region get corg
## id_client id local client
static func try_get_client_corg(id_client):
	var client:Client = g_man.savable_client_client.get_index_data(id_client)
	var id_corg = client.load_return_employed_at_corg()
	if id_corg:
		return ConstructForClient.construct_client_shared_multi_table_savable(g_man.multi_client__server_corg, g_man.savable_client_corg, id_corg)

static func try_get_client_from_corg(id_server_corg, return_func):
	var id_client_corgs = g_man.multi_client__server_corg.select(0, id_server_corg)
	if id_client_corgs:
		var client_corg:Company = g_man.savable_client_corg.get_index_data(id_client_corgs[0])
		if client_corg:
			if client_corg.founder:
				var client:Client = Client.construct_for_client_new_id(client_corg.founder, "")
				if client._username:
					return client
				else:
					push_error("founder wasn't loaded")
					if return_func:
						g_man.client_signal.connect(return_func)
					else:
						for item in g_man.client_signal.get_connections():
							g_man.client_signal.disconnect(item.callable)
					g_man.local_network_node.get_client_data.rpc_id(1, client_corg.founder)
					return
			#else:
				#push_warning("founder doesn't exist all else does")
		#else:
			#push_warning("corg isn't saved")
	#else:
		#push_warning("corg isn't linked")
	if return_func:
		g_man.corg_signal.connect(return_func)
	else:
		for item in g_man.corg_signal.get_connections():
			g_man.corg_signal.disconnect(item.callable)
	g_man.local_network_node.net_corg_node.cmd_refresh_corg.rpc_id(1, id_server_corg)

## id_client id local client
static func try_get_server_corg(id_client, client_is_founder = true):
	if client_is_founder:
		var corgs = g_man.savable_multi_account__corg.get_all(id_client, 0)
		if corgs:
			return corgs[0]
	else:
		var id_corgs = g_man.multi_server_worker__corg.select(id_client, 0)
		if id_corgs:
			var corgs = g_man.savable_multi_account__corg.get_all(0, id_corgs[0])
			if corgs:
				return corgs[0]
#endregion get corg
#region money
func get_money():
	return money_system.get_money()

func set_money(money):
	money_system.set_money(money)

## server only
func outcome(money, id_to_whom, id_customer, id_item, quantity):
	var corg_to_whom = g_man.savable_multi_account__corg.get_index_data(id_to_whom)
	if corg_to_whom:
		var sav_money = money
		# check how much was reserved on this corg towards the customer_corg
		var customer_corg = try_get_server_corg(id_customer)
		if customer_corg:
			money = ReservedOnCorg.subtract(customer_corg.id, corg_to_whom.id, money)
		var out = money_system.outcome(money, true)
		if out:
			money = out
			sav_money -= MoneySystem.TAXING * sav_money
			save_money()
			# sending subtracted of tax
			corg_to_whom.income(sav_money, id_item, id_customer, quantity)
			return true

func outcome_comercial(id_to_whom):
	pass
	push_error(id, " : ", MoneyCurrency.balance(comercialist_pay, MoneyCurrency.plant.all))
	var money = money_system.outcome(comercialist_pay, true)
	if money:
		save_money()
		var client:Client = g_man.savable_server_accounts.get_index_data(id_to_whom)
		if client:
			client.income(money)
			return true
	# we delete all commercials
	g_man.savable_multi_corg__pictures.delete_p_s(id, 0)
	return false

# trade only and need to calc the UTD
func income(income_money, id_item, _id_seller, quantity):
	var item:Item = g_man.savable_multi_corg__items.get_index_data(id_item)
	# we calculate UTD
	push_error(income_money, "MAX PROFIT: ", max_profit)
	if money_system.get_money() + income_money > max_profit:
		money_system.utd(money_system.get_money() + income_money - max_profit)
		# if money is 0 it means all the income money was taxed
		if money_system.get_money() == 0:
			income_money = 0
	# we remove reserved money
	ReservedOnCorg.add_reserve_to_corg(item.id, income_money, quantity)
	# we pay rest of money
	money_system.income(income_money)
	save_money()

func get_last_daily():
	if not id_newest_daily_income:
		var daily_incoms = g_man.savable_multi_corg__daily_income.get_all(id, 0)
		if daily_incoms:
			var newest = 0
			for daily:DailyIncome in daily_incoms:
				daily.load_if_needed()
				if daily.get_unix_time() > newest:
					newest = daily.get_unix_time()
					id_newest_daily_income = daily.id
		else:
			var daily = g_man.savable_multi_corg__daily_income.new_data(id, 0)
			daily.set_date_time()
			id_newest_daily_income = daily.id
	var daily_in = g_man.savable_multi_corg__daily_income.get_all(id, id_newest_daily_income)
	if daily_in:
		return daily_in
	else:
		push_error("daily income does not exist nor new one is created OR wrong one is trying to be loaded: ", id, " : ", id_newest_daily_income)

func add_to_profit_cap(to_pay):
	get_last_daily().add_money(to_pay)
	calc_profit_cap()

func calc_profit_cap():
	var daily_in:DailyIncome = get_last_daily()
	daily_in.load_money()
	max_profit = daily_in._money * K_PROFIT_CAP
	if get_money() > max_profit:
		money_system.utd(get_money() - max_profit)
		save_money()

# this company pays salary
func pay_salary(money, id_worker):
	var worker:Client = g_man.savable_server_accounts.get_index_data(id_worker)
	if not worker:
		push_error("worker does not exist: ", id_worker)
		return
	# never taxed as it's salary
	money = money_system.outcome(money, false)
	if money:
		save_money()
		push_error("enough money")
		worker.income(money)
	# we fire worker as we don't have enough money to pay him salary
	else:
		push_error("not enough money fire")
		worker.fire_me(true)
	
func empty_all_in_utd():
	money_system.empty_all_in_utd()
#endregion end money
#region comercialist
	#public List<string> AVIUrl = new List<string>()
	#public string currentUrl = ""
var pictures = [] # Texture2D
	#public List<Sprite> sprites = new List<Sprite>()
var rawPicturesData = [] #[[]]
	#public Sprite currentSprite
var picture_index = 0

## server only
func server_add_picture(raw_texture):
	var picture_data:PictureData = g_man.savable_multi_corg__pictures.new_data(id, 0)
	picture_data.save_picture(raw_texture)
	picture_data.save_time(int(Time.get_unix_time_from_system()))

func client_add_id_pictures(id_server_pictures, timers):
	# what's extra I delete
	g_man.multi_client_corg__client_commercial_pictures.delete(id, 0)
	# i make it back what's nessesary
	for i in len(id_server_pictures):
		var picture_data:PictureData = ConstructForClient.construct_client_shared_savable_multi(g_man.savable_multi_client__server_pictures, id_server_pictures[i])
		picture_data.check_timer(timers[i])
		g_man.multi_client_corg__client_commercial_pictures.add_row(0, id, picture_data.id)

## client
func client_add_raw_picure(raw_texture, id_server_picture):
	var picture_data:PictureData = ConstructForClient.construct_client_shared_savable_multi(g_man.savable_multi_client__server_pictures, id_server_picture)
	picture_data.save_picture(raw_texture)
	picture_data.add_texture(SaveLoadPicture.load_image_from_raw_png(raw_texture))

#public void A_NextAVI()
#{
	#if (index == 8)
	#{
		#index = 0
	#}
	#currentUrl = AVIUrl[index]
	#index++
#}
func load_commercial_pictures():
	var id_pictures = g_man.multi_client_corg__client_commercial_pictures.select(id, 0)
	for _id in id_pictures:
		var picture_data:PictureData = g_man.savable_multi_client__server_pictures.get_index_data(_id)
		if picture_data:
			var texture = picture_data.get_texture()
			if texture:
				pictures.push_back(picture_data)
			if not texture:
				g_man.local_network_node.net_corg_node.cmd_load_id_commercial_picture.rpc_id(1, id_server, picture_data.id_server)

func get_next_picture():
	if len(pictures) > 0:
		picture_index += 1
		if picture_index >= len(pictures):
			picture_index = 0
	else:
		return
	return pictures[picture_index]

func delete_previous_picture():
	if pictures:
		# set index back
		picture_index -= 1
		if picture_index < 0:
			picture_index = len(pictures) -1
		# delete picture
		pictures.remove_at(picture_index)

func reload_picture(id_picture):
	var picture_data:PictureData = g_man.savable_multi_client__server_pictures.get_index_data(id_picture)
	if picture_data:
		var texture = picture_data.get_texture()
		if texture:
			pictures.push_back(picture_data)
		if not texture:
			push_error("something is seriously wrong it's not loading as it should load texture")

#endregion comercilist
#region save
func fully_save():
	save_money()
	save_commercials_time()
	save_commercials_pay()
	save_founder()

func save_money():
	DataBase.insert(_server, g_man.dbms, _path, "money", id, get_money())

func save_commercials_pay():
	DataBase.insert(_server, g_man.dbms, _path, "company_comercial_pay", id, comercialist_pay)

func save_commercials_time():
	DataBase.insert(_server, g_man.dbms, _path, "company_wait_add_time", id, comercialist_company_add_wait)

func save_founder():
	DataBase.insert(_server, g_man.dbms, _path, "founder", id, founder)

#endregion save
#region load
func fully_load():
	set_money( DataBase.select(_server, g_man.dbms, _path, "money", id) )
	if _server:
		calc_profit_cap()
	comercialist_company_add_wait = DataBase.select(_server, g_man.dbms, _path, "company_wait_add_time", id)
	comercialist_pay = DataBase.select(_server, g_man.dbms, _path, "company_comercial_pay", id)
	founder = DataBase.select(_server, g_man.dbms, _path, "founder", id)
	
	if not comercialist_company_add_wait:
		comercialist_company_add_wait = 0
	if not comercialist_pay:
		comercialist_pay = 10000
#endregion load
#region ToStringFounderName
	#public override string ToString() => NetMan.sin.SavableServerPerson.TryGet(Founder, out var founder) ? $"idCorg: {ID} idFounder: {Founder} => {founder.userName}" : $"{Founder}"
	#public static string ToString(long idCorg) => NetMan.sin.SavableCorg.TryGet(idCorg, out var corg) ? corg.ToString() : idCorg.ToString()
#endregion
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(comercialist_company_add_wait)
	return data
	
func deserialize(data:Array):
	comercialist_company_add_wait = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize
