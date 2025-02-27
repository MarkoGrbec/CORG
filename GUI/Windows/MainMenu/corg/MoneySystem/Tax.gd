class_name Tax extends ISavable

#region inputs
var money;
#endregion inputs
func copy():
	return Tax.new()
#region save
func fully_save():
	DataBase.insert(_server, g_man.dbms, _path, "money", id, int(money))
#endregion save
#region load
func fully_load():
	money = DataBase.select(_server, g_man.dbms, _path, "money", id)
#endregion load
#region ToString
func to_custom_string():
	return MoneyCurrency.balance(money, MoneyCurrency.plant.all)
#endregion
