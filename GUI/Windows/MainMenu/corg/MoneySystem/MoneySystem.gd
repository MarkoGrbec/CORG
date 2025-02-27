class_name MoneySystem extends Node

func StartServer():
	_server_tax = []
	var sav = g_man.savable_tax
	for i in range(1, sav.last_id()):
		
		var t:Tax = sav.get_index_data(i)
		_server_tax.push_back(t)
		push_warning(t)
	if len(_server_tax) < 1:
		var t:Tax = Tax.new()
		t.money = 100
		sav.set_data(t)
		_server_tax.push_back(t)

#region serverTax
static var _server_tax
const TAXING = 0.03
#endregion end serverTax
var money_currency = MoneyCurrency.new()
## we give read only money
func get_money():
	return money_currency.money

func set_money(full_money):
	if full_money:
		money_currency.set_money(full_money)

## calculates new money balance
func income(income_money):
	money_currency.add(income_money)

## if taxable it substracts tax from money and calculates new money balance
## returns how much money was been removed
func outcome(rem_money, taxable:bool):
	if money_currency.enough_money(rem_money):
		var calculated_tax = 0
		if taxable:
			calculated_tax = TAXING * rem_money
			MoneySystem.tax(calculated_tax)
		money_currency.remove(rem_money)
		rem_money -= calculated_tax
		return rem_money
	return

## it calculates if enough money and removes it returns the remaining of money that was given in
func outcome_per_utd(rem_money, percentage_utd):
	if percentage_utd > 1 || percentage_utd < 0:
		percentage_utd = 1
	if money_currency.enough_money(rem_money):
		var calculated_tax = 0
		
		calculated_tax = percentage_utd * rem_money
		MoneySystem.tax(calculated_tax)
		
		money_currency.remove(rem_money)
		rem_money -= calculated_tax
		return rem_money
	return 0

func utd(money):
	push_warning("tax money: ", money)
	money_currency.remove(money)
	MoneySystem.tax(money)

static func tax(money):
	push_warning("server tax count: ", len(_server_tax))
	_server_tax[0].money += money
	push_warning("server has taxed: ", MoneyCurrency.balance(_server_tax[0].money, MoneyCurrency.plant.all), " aditional: ", MoneyCurrency.balance(money, MoneyCurrency.plant.last))
	_server_tax[0].fully_save()

func empty_all_in_utd():
	utd(get_money())
