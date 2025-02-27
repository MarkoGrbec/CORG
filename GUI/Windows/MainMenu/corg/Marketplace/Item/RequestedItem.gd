class_name RequestedItem extends ISavable
#region Config
func copy():
	return RequestedItem.new()
func config(item:Item, id_customer):
	cost = item.cost_text
	id_item = item.id
	_id_customer = id_customer
	id_trader = item.id_server_corg
	item_name = item.name_text
	quantity = item.quantity
#endregion end Config
#region button tool
func set_text(text):
	if text is RequestedItem:
		item_name = text.get_text()
		label_item_name.text = text.get_text()
		label_quantity.text = str("# ", text.quantity)
		button_shipment.text = Status.find_key(text.status).replace("_", " ")
	else:
		item_name = text
		label_item_name.text = text

func get_text():
	return item_name

func on_click_add_listener(on_button_click:Callable):
	button_shipment.pressed.connect(
		func():
			on_button_click.call(id)
	)
#endregion button tool
#region inputs
@onready var label_item_name: Label = $"item name"
@onready var label_quantity: Label = $quantity
@onready var button_shipment: Button = $shipment

var _id_customer
var cost
var id_item
var id_trader
var item_name
var quantity
var id_companys = []
var percents = []
var total_percent = 0
var status = 1
#endregion end inputs
#region shipment
	#region color
#public (byte type, byte strength, byte alpha) ShipmentColor(bool trader){
	#if(trader){
		#//urgently needs to focus on delivering the package
		#if(status == Status.boughted){
			#return(2, 3, 255)
		#}
		#//passive
		#else if(status == Status.has_been_delivered){
			#return(1, 1, 255)
		#}
		#//recieved shipment locked
		#else{
			#return(0, 3, 255)
		#}
	#}
	#else{
		#//passive it has been already bought
		#if(status == Status.boughted){
			#return(1, 1, 255)
		#}
		#//urgently needs to recieve the shipment when it is delivered
		#else if(status == Status.has_been_delivered){
			#return(2, 3, 255)
		#}
		#//recieved shipment locked
		#else{
			#return(0, 3, 255)
		#}
	#}
#}
	#endregion end color
	#//#region input
enum Status{
	bought				= 1,
	has_been_delivered	= 2,
	recived_shipment	= 3
}
#public Status status = Status.boughted
	#//#endregion end input
#region changeStatus
func trader_set_new_status():
	if status == Status.bought:
		status = Status.has_been_delivered
		return true
	elif status == Status.has_been_delivered:
		status = Status.bought
		return true
	if not status:
		status = Status.bought
		return true
# customer marks that he recieved shipment
func customer_set_new_status():
	if status == Status.has_been_delivered:
		status = Status.recived_shipment
		return true
	if not status:
		status = Status.bought
		return true

#func ChangeStatus(requester):
	#if (NetMan.sin.dictClientCorg.TryGetValue(id_trader, out var corg))
	#{
		#if (requester == corg.Founder)
		#{
			#if (TraderSetNewStatus())
			#{
				#SaveShipment(true)
				#return true
			#}
			#return false
		#}
	#}
	#if (requester == id_customer){
		#if(CustomerSetNewStatus()){
			#SaveShipment(true)
			#return true
		#}
		#return false
	#}
	#Debug.Log($"requester: {requester} not right trader {id_trader} or customer {id_customer}")
	#return false
#}
#endregion changeStatus
#endregion end shipment
#region 
func add(id_company, percent):
	if total_percent < 1:
		id_companys.push_back(id_company)
		# if percent is bigger than 100% we shrink it to 100% as we can't give more than we receive
		# we can't make it 97% as tax cuz we can't calculate it.
		if(total_percent + percent > 1):
			percent += total_percent
			percent = percent % 1
			total_percent = 1
		else:
			total_percent += percent
		percents.push_back(percent)
	return total_percent
#endregion
#region save
func partly_save():			# only part save
	pass

func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "cost", id, cost)
	DataBase.insert(_server, g_man.dbms, _path, "id_item", id, id_item)
	DataBase.insert(_server, g_man.dbms, _path, "id_customer", id, _id_customer)
	DataBase.insert(_server, g_man.dbms, _path, "id_trader", id, id_trader)
	DataBase.insert(_server, g_man.dbms, _path, "item_name", id, item_name)
	DataBase.insert(_server, g_man.dbms, _path, "quantity", id, quantity)
	save_shipment()

## if shipment was delivered or not
func save_shipment():
	DataBase.insert(_server, g_man.dbms, _path, "shipment", id, status)
#endregion save
#region load
func partly_load():			# load only critical data
	pass

func fully_load():
	cost = DataBase.select(_server, g_man.dbms, _path, "cost", id)
	id_item = DataBase.select(_server, g_man.dbms, _path, "id_item", id)
	_id_customer = DataBase.select(_server, g_man.dbms, _path, "id_customer", id)
	id_trader = DataBase.select(_server, g_man.dbms, _path, "id_trader", id)
	item_name = DataBase.select(_server, g_man.dbms, _path, "item_name", id)
	quantity = DataBase.select(_server, g_man.dbms, _path, "quantity", id)
	status = DataBase.select(_server, g_man.dbms, _path, "shipment", id)
	if not status:
		status = 1
#endregion load
#region serialize
func serialize():
	var data = []
	data.push_back(id)
	data.push_back(cost)
	data.push_back(id_item)
	data.push_back(_id_customer)
	data.push_back(id_trader)
	data.push_back(item_name)
	data.push_back(quantity)
	data.push_back(status)
	return data

func deserialize(data:Array):
	status = data.pop_back()
	quantity = data.pop_back()
	item_name = data.pop_back()
	id_trader = data.pop_back()
	_id_customer = data.pop_back()
	id_item = data.pop_back()
	cost = data.pop_back()
	id = data.pop_back()
	return data
#endregion serialize
