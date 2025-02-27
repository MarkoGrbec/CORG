class_name MoneyCurrency extends Node

enum plant{
	all =		2,
	last =		3,
	wheet =		1,
	carrot =	1000,
	apple =		1000000,
	pineapple =	1000000000,
	banana =	1000000000000,
	greyfruit =	1000000000000000
}
var money = 0
var partMoney = 0
func set_money(full_money):
	money = full_money

func money_workers_tops(workersCount):
	money = workersCount * 5000000000
	#//Calc()

# from 0-1000 multi with plant to get raw currency
static func convert_money(number, multi:plant = plant.all):
	if(multi == plant.all || multi == plant.last):
		return 0
	return int(number * multi)

static func balance(number, which:plant = plant.all):
	# long number = money
	var text = ""
	# we sort which tipe is it from raw money
	if which == plant.last:
		if number > plant.greyfruit:
			which = plant.greyfruit
		elif number > plant.banana:
			which = plant.banana
		elif number > plant.pineapple:
			which = plant.pineapple
		elif number > plant.apple:
			which = plant.apple
		elif number > plant.carrot:
			which = plant.carrot
		else:
			which = plant.wheet
	if(which == plant.all):
		var part = number
		part = int(number / plant.greyfruit) % 1000
		if part > 0:
			text += str(part) + " greyfruits "
		part = int(number / plant.banana) % 1000
		if part > 0:
			text += str(part) + " bananas "
		part = int(number / plant.pineapple) % 1000
		if part > 0:
			text += str(part) + " pineapples "
		part = int(number / plant.apple) % 1000
		if part > 0:
			text += str(part) + " apples "
		part = int(number / plant.carrot) % 1000
		if part > 0:
			text += str(part) + " carrots "
		part = int(number / plant.wheet) % 1000
		if part > 0:
			text += str(part) + " wheets "
	else:
		text = String("{number} {w}s").format({number = int(number/which) % 1000, w = plant.find_key(which)})
	return text

## add to this balance
func add(added_money):
	money += int(added_money)

## substract from this balance
func remove(removed_money):
	push_warning(money, " : ", removed_money)
	money -= removed_money
	if money < 0:
		money = 0

func enough_money(check_money):
	if money >= check_money:
		return true
	return false
