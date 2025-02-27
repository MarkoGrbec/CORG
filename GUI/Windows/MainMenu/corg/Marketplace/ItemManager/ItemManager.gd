class_name ItemManager extends Node

func _ready() -> void:
	g_man.item_manager = self
	get_parent().set_id_window(9, "item manager")
	reserved_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/corg/Marketplace/Item/ReservedOnItem.tscn"), null, on_reserved_click, cmd_refresh_reserved, items_container)

func show_window(id_trader, item:Item, is_corg):
	reserved_button_tool.hide_all_buttons()
	_id_trader = id_trader
	_item = item
	get_parent().show_window()
	if is_corg:
		item_name.show()
		label_item_name.hide()
		item_cost.show()
		label_item_cost.hide()
		item_quantity.show()
		label_item_quantity.hide()
		update_item.show()
		remove_item.show()
		buy.hide()
		info.show()
		new_reserve_on_corg.show()
		submit_reserved_trader.show()
		buy_as_check_box.hide()
		g_man.local_network_node.net_corg_node.cmd_refresh_reserved_from_item.rpc_id(1, _item.id)
	else:
		item_name.hide()
		label_item_name.show()
		item_cost.hide()
		label_item_cost.show()
		item_quantity.hide()
		label_item_quantity.show()
		update_item.hide()
		remove_item.hide()
		buy.show()
		info.hide()
		new_reserve_on_corg.hide()
		submit_reserved_trader.hide()
		buy_as_check_box.show()
	update_item_data()

func close_window():
	get_parent().close_window()

#region inputs
var _id_trader
var _item:Item

@onready var item_name: LineEdit = $"items/Marginscroll/ScrollContainer/items container/item name"
@onready var label_item_name: Label = $"items/Marginscroll/ScrollContainer/items container/label item name"
@onready var item_cost: LineEdit = $"items/Marginscroll/ScrollContainer/items container/item cost"
@onready var label_item_cost: Label = $"items/Marginscroll/ScrollContainer/items container/label item cost"
@onready var item_quantity: LineEdit = $"items/Marginscroll/ScrollContainer/items container/item quantity"
@onready var label_item_quantity: Label = $"items/Marginscroll/ScrollContainer/items container/label item quantity"
@onready var update_item: Button = $"items/Marginscroll/ScrollContainer/items container/update item"
@onready var remove_item: Button = $"items/Marginscroll/ScrollContainer/items container/remove item"
@onready var buy: Button = $"items/Marginscroll/ScrollContainer/items container/buy"
@onready var info: Label = $"items/Marginscroll/ScrollContainer/items container/info"
@onready var new_reserve_on_corg: = $"items/Marginscroll/ScrollContainer/items container/new reserve on corg"
@onready var new_reserve_name_on_corg: LineEdit = $"items/Marginscroll/ScrollContainer/items container/new reserve on corg/new reserve on corg"
@onready var new_reserve_money: LineEdit = $"items/Marginscroll/ScrollContainer/items container/new reserve on corg/reserve money"
@onready var submit_reserved_trader: Button = $"items/Marginscroll/ScrollContainer/items container/submit reserved trader"

@onready var buy_as_check_box: CheckBox = $"items/Marginscroll/ScrollContainer/items container/buy as"

#endregion inputs
#region item
func on_item_click_update():
	var item_cost_text = MoneyCurrency.convert_money(float(item_cost.text), MoneyCurrency.plant.apple)
	g_man.local_network_node.net_corg_node.cmd_update_market_item.rpc_id(1, _item.id, item_name.text, int(item_cost_text))
	
	_item.name_text = item_name.text
	_item.cost_text = float(item_cost_text)
	_item.quantity = int(item_quantity.text)
	update_item_data()

func on_item_click_buy():
	var buy_as = Item.buy_as.customer
	if buy_as_check_box.button_pressed:
		buy_as = Item.buy_as.corg
	##TODO: buy as spender
	g_man.local_network_node.net_corg_node.cmd_buy_market_item.rpc_id(1, _item.id, 1, buy_as)
	close_window()

func cmd_remove_item():
	g_man.store_manager.cmd_remove_item(_item.id)
	reserved_button_tool.remove_all_buttons()
	close_window()

func update_item_data():
	if not _item.cost_text:
		_item.cost_text = 0
	item_name.text = str(_item.name_text)
	item_cost.text = MoneyCurrency.balance(float(_item.cost_text), MoneyCurrency.plant.all)
	item_quantity.text = str(_item.quantity)
	
	label_item_name.text = item_name.text
	label_item_cost.text = item_cost.text
	label_item_quantity.text = item_quantity.text
#endregion item
#region reserved
@onready var items_container: VBoxContainer = $"items/Marginscroll/ScrollContainer/items container"

var reserved_button_tool: ButtonTool
func refresh_reserved(id, reserved):
	reserved_button_tool.refresh_t(id, reserved, 0, true)

func add_buttons_reserved(ids_reserved):
	reserved_button_tool.add_buttons(ids_reserved, 0, true)
	for id in ids_reserved:
		cmd_refresh_reserved_total(id)

func on_reserved_click(id):
	g_man.local_network_node.net_corg_node.cmd_remove_reserved.rpc_id(1, id)
	reserved_button_tool.permanently_delete([id])

func cmd_refresh_reserved(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_reserved.rpc_id(1, id)

func submit_reserve_trader():
	g_man.local_network_node.net_corg_node.cmd_add_reserve_to_item.rpc_id(1, _item.id, new_reserve_name_on_corg.text, float(new_reserve_money.text))

func cmd_refresh_reserved_total(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_total_reserved_on_corg.rpc_id(1, id)

func refresh_reserved_total_on_corg(id_reserved, money):
	var button = reserved_button_tool.get_button(id_reserved)
	if button:
		button.set_reserved_money(money)
	##TODO: make total reserve back
#endregion reserved




	##region window config
	#/*
	#private void OnGUI(){
		#if(GUI.Button(new Rect(150, 100, 350, 20), $"{buyAsCompany} buy as company")){
			#buyAsCompany = !buyAsCompany;
		#}
	#}*/
	#public static ItemManager singleton { get; private set; }
	#public void Awake(){
		#if (singleton != null){
			#Debug.Log("DESTROY GameObject");
			#Destroy(gameObject);
		#}
		#else{
			#singleton = this;
			#buttonsReserved = new ButtonTool<Reserved>(this, null);
		#}
	#}
	#public override void Start(){
		#idWindow = 5;
		#base.Start();
		#// iWindowManager = transform.GetComponent<IWindowManager>();
		#/*iWindowManager.*/windowName.text = "item";
		#DisableAll();
		#Onoff(false);
	#}
	#// public IWindowManager iWindowManager {get;set;}
	##endregion end window config
	##region windowlayouts
#
	#public void LayoutPersonManageItem(long idItem, long idTrader)
	#{
		#status = Status.AtTraderStore;
		#DisableAll();
		#submit.text = "buy this product";
		#OnOff.OnOffListGameObjects(true, allLayouts);
		#OnOff.OnOffListGameObjects(true, manageItems);
#
		#//ButtonCheckBuyAs();
		#buyAs = TypeBuyAs.Person;
		#Person person = NetMan.sin.Client;
		#if (Company.TryGetCorg(person.ID, out var corg))
		#{
			#OnOff.OnOffArrayGameObjects(true, buyAsCompanyGO);
		#}
		#item = MarketplaceManager.singleton.items.GetT(idItem);
		#shipmentName.text = item.Name;
		#shipmentcost.text = MoneyCurrency.Balance(item.Cost, MoneyCurrency.plant.all);
		#itemQuantityText.text = item.Quantity.ToString();
	#}
#
	#public void LayoutTraderManageItem(long idItem, long idTrader){
		#status = Status.myStore;
		#Debug.Log("trader manage item");
		#DisableAll();
		#submit.text = "change product";
		#OnOff.OnOffListGameObjects(true, allLayouts);
		#OnOff.OnOffListGameObjects(true, traderManageItems);
		#//item
		#item = MarketplaceManager.singleton.items.GetT(idItem);
		#if (item != null)
		#{
			#itemNameText.text = item.Name;
			#itemCostText.text = MoneyCurrency.Balance(item.Cost, MoneyCurrency.plant.all);
			#itemQuantityText.text = item.Quantity.ToString();
			#Debug.LogError("does it need to be client");
		#}
#
		#//reserved
		#var netC = NetMan.sin.Client.gos.netCORG.netC;
		#netC.CmdGetItemReserves(idItem);
		#if(buttonsReserved.NotSet){
			#buttonsReserved.Set(null, netC.CmdRemoveReservedCompany, netC.CmdRefreshReservedItem, null, content);
		#}
	#}
	#public void LayoutPersonManageRequestedItem(long idItem){
		#status = Status.CustomerShipment;
		#Debug.Log("manage req item");
		#DisableAll();
		#OnOff.OnOffListGameObjects(true, allLayouts);
		#OnOff.OnOffListGameObjects(true, manageShipments);OnOff.OnOffArrayGameObjects(false, deleteItem);
		#reqItem = MarketplaceManager.singleton.reqItems.GetT(idItem);
		#shipmentName.text = reqItem.Name;
		#shipmentcost.text = MoneyCurrency.Balance(reqItem.Cost, MoneyCurrency.plant.all);
		#shipmentquantity.text = reqItem.Quantity.ToString();
		#submit.text = reqItem.status.ToString().Replace('_', ' ');
		#ChangeCollor();
	#}
	#public void LayoutTraderManageRequestedItem(long idItem){
		#status = Status.TraderShipment;
		#Debug.Log($"trader manage req item {idItem}");
		#DisableAll();
		#OnOff.OnOffListGameObjects(true, allLayouts);
		#OnOff.OnOffListGameObjects(true, manageShipments);
		#OnOff.OnOffListGameObjects(true, manageShipments);OnOff.OnOffArrayGameObjects(false, deleteItem);
		#reqItem = MarketplaceManager.singleton.reqItems.GetT(idItem);
		#shipmentName.text = reqItem.Name;
		#shipmentcost.text = MoneyCurrency.Balance(reqItem.Cost, MoneyCurrency.plant.all);
		#shipmentquantity.text = reqItem.Quantity.ToString();
		#submit.text = reqItem.status.ToString().Replace('_', ' ');
		#ChangeCollor();
	#}
	##endregion end windowlayouts
	##region input
	#public enum Status{
		#myStore,
		#AtTraderStore,
		#TraderShipment,
		#CustomerShipment,
	#}
	#public enum TypeBuyAs
	#{
		#Person,
		#Company,
		#Spender
	#}
	#Transform IWindowManager.content => content;
	#public void ChangeEntity(EntityClient entity) { throw new System.NotImplementedException(); }
	#public List<GameObject> manageItems = new List<GameObject>();
	#public List<GameObject> traderManageItems = new List<GameObject>();
	#public List<GameObject> manageShipments = new List<GameObject>();
	#public List<GameObject> allButtons = new List<GameObject>();
	#public List<GameObject> allLayouts = new List<GameObject>();
	#public ButtonTool<Reserved> buttonsReserved;
	#public Status status;
	#public Item item;
	#public RequestedItem reqItem;
	#public string itemName = "new item name";
	#public double itemCost = 1000000;
	#public int itemQuantity = 1;
	#public InputField itemNameText;
	#public InputField itemCostText;
	#public InputField itemQuantityText;
	#public Text submit;
	#public GameObject deleteItem;
	#public Text shipmentName;
	#public Text shipmentcost;
	#public Text shipmentquantity;
	#public InputField reservedCompanyName;
	#public InputField reservedCost;
	#public Sprite check;
	#public Sprite unCheck;
	#public Sprite spendCheck;
	#public GameObject buyAsCompanyGO;
	#public Image checkMark;
	#private TypeBuyAs buyAs = TypeBuyAs.Person;
	##endregion end input
	##region reserved buttons
	#public void AddButtonsReserved(long[] ids){
		#buttonsReserved.AddButtons(ids);
	#}
	##endregion
	##region buyItem
	#public void ButtonCheckBuyAs()
	#{
		#var client = NetMan.sin.Client;
		#var founder = Company.TryGetCorg(client.ID, out var corg);
#
		#switch (buyAs)
		#{
			#//from person to company IF company exists
			#case TypeBuyAs.Person when founder:
				#buyAs = TypeBuyAs.Company;
				#checkMark.sprite = check;
				#break;
			#//from person to spender if it doesn't have company
			#case TypeBuyAs.Person:// when ! founder:
			#{
				#//ONLY if it's known spender
				#if (client.idSpender < 1)
				#{
					#buyAs = TypeBuyAs.Spender;
					#checkMark.sprite = spendCheck;
				#}
				#break;
			#}
			#// //from company to spender IF company exists
			#// else if (buyAs == TypeBuyAs.Company && founder)
			#// {
			#//     Debug.LogError(
			#//         "company shouldn't have ability to give more taxes but they should employ more people for more plants");
			#//     buyAs = TypeBuyAs.Spender;
			#//     checkMark.sprite = spendCheck;
			#// }
			#case TypeBuyAs.Company:
				#buyAs = TypeBuyAs.Person;
				#checkMark.sprite = unCheck;
				#break;
			#case TypeBuyAs.Spender:
				#buyAs = TypeBuyAs.Person;
				#checkMark.sprite = unCheck;
				#break;
			#default:
				#throw new ArgumentOutOfRangeException();
		#}
		#
		#Debug.Log($"buy as: {buyAs}");
	#}
	#// public void RemoveReservedTrader(long idTrader, Button button){
	#//     Destroy(button.gameObject);
	#//     //NetMan.sin.client.gos.netCORG.netC.cmdRemoveReservedCompany(item.idItem, idTrader);
	#//     Debug.LogError(idTrader.ToString());
	#// }
	##endregion
	##region edit
	#public void EditName(){
		#//ItemManager.singleton.itemNameText.text = inputField.text;
		#if(itemNameText.text is "x" or "null"){
			#itemNameText.text = "not an option";
		#}
		#itemName = itemNameText.text;
	#}
	#public void EditCost(){
		#itemCost = DbmsSqLite.DecodeDouble(itemCostText.text);
	#}
	#public void EditQuantity(){
		#itemQuantity = DataBase.DecodeInt(itemQuantityText.text);
	#}
	#public void BuyItem(){
		#if (itemQuantity == 0)
		#{
			#MoldWindowManager.sin.SetMoldWindowInstructionsOnly("buy error", "quantity is 0 you need to set it to buy something");
			#Debug.LogWarning("quantity is 0");
			#return;
		#}
		#NetMan.sin.Client.gos.netCORG.netC.CmdOrderGoods(item.IDItem, itemQuantity, buyAs);
	#}






	##endregion
	##region submitChangeItem
	#public void SubmitChangeItemProperties(){
		#if(status == Status.myStore)
		#{
			#item.Name = itemName;
			#item.Cost = MoneyCurrency.Convert(itemCost, MoneyCurrency.plant.apple);
			#item.Quantity = itemQuantity;
			#if(item.Cost < 100){
				#item.Cost = 100;
			#}
			#itemCostText.text = MoneyCurrency.Balance(item.Cost, MoneyCurrency.plant.all);
			#NetMan.sin.Client.gos.netCORG.netC.CmdUpdateItem(item.IDItem, item.Name, item.Cost, item.Quantity);
			#MarketplaceManager.singleton.items.SetItemName(item.IDItem, item.Name);
			#Onoff(false);
		#}
		#else if(status == Status.AtTraderStore){
			#BuyItem();
		#}
		#else if(status == Status.CustomerShipment || status == Status.TraderShipment){
			#NetMan.sin.Client.gos.netCORG.netC.CmdRequestShipmentChangeStatus(reqItem.ID);
		#}
	#}
	##endregion
	##region changeCollor
	#public void ChangeCollor(){
		#Debug.Log($"change color to trader {NetMan.sin.client.ID} {reqItem.IDTrader} {reqItem.idCustomer}");
		#submit.text = reqItem.status.ToString().Replace('_', ' ');
		#Button button = submit.transform.parent.GetComponent<Button>();
		#var colorType = reqItem.ShipmentColor(NetMan.sin.client.ID == reqItem.IDTrader);
		#button.gameObject.GetComponent<StartButtonColor>().SetColors(colorType.type, colorType.strength, colorType.alpha);
		#MarketplaceManager.singleton.ChangeCollorRequested(reqItem.ID);
	#}
	##endregion
	##region delete item
	#public void DeleteItem(){
		#if(status == Status.myStore){
			#NetMan.sin.Client.gos.netCORG.netC.CmdRemoveItem(item.IDItem);
			#MarketplaceManager.singleton.items.RemoveButtons(item.IDItem);
			#MarketplaceManager.singleton.items.DeleteIds(item.IDItem);
			#
			#Onoff(false);
			#Debug.Log($"delete item: {item.text} : {item.ID}");
		#}
	#}
	##endregion
	##region layout
		##region enableDisable
	#public void DisableAll(){
		#Onoff(true);
		#OnOff.OnOffListGameObjects(true, allLayouts);
		#OnOff.OnOffListGameObjects(false, allButtons);
		#OnOff.OnOffListGameObjects(false, allLayouts);
		#OnOff.OnOffArrayGameObjects(false, buyAsCompanyGO);
		#RemoveAll();
		#buttonsReserved.RemoveAllButtons();
	#}
#
	#public void Refresh()
	#{
	#}
		##endregion end enableDisable
	##endregion end layout
#}
