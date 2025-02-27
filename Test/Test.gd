class_name Testing extends Node

func _ready() -> void:
	g_man.test = self

class Test extends ISavable:
	var var_x
	func copy():
		return Test.new()
	func fully_save():
		pass
	func fully_load():
		pass
	func partly_save():
		pass
	func partly_load():
		load_x()

	func save_x(variable):
		if var_x:
			g_man.test.test_save.remove_index(3, var_x, id)
		var_x = float(variable)
		DataBase.insert(_server, g_man.dbms, _path, "x", id, var_x)
		g_man.test.test_save.set_index(3, var_x, id)
	
	func load_x():
		if var_x:
			g_man.test.test_save.remove_index(3, var_x, id)
		var_x = DataBase.select(_server, g_man.dbms, _path, "x", id)
		g_man.test.test_save.set_index(3, var_x, id)


var test_save: Savable

func test_remove_all_in_savables():
	test_save = Savable.new(false, g_man.dbms, "test", Test.new())
	test_save.set_index_data(1, Test.new())
	test_save.set_index_data(2, Test.new())
	test_save.remove_all()
	if not test_save.get_index_data(2):
		push_warning("test pass: ", test_save.get_index_data(2))
	else:
		push_error("exists don't know why check it!!!")
	
func test_indexing():
	var table = DataBase.Table.new("test")
	table.create_column(false, g_man.dbms, DataBase.DataType.FLOAT, 1, "x")
	table.create_column(false, g_man.dbms, DataBase.DataType.FLOAT, 1, "y")
	table.create_column(false, g_man.dbms, DataBase.DataType.FLOAT, 1, "z")
	test_save = Savable.new(false, g_man.dbms, "test", Test.new())
	test_save.partly_load_all()
	
	var t = test_save.get_or_set(1)
	t.save_x(1)
	t = test_save.get_or_set(2)
	t.save_x(2.3)
	t = test_save.get_or_set(3)
	t.save_x(1.2)
	t = test_save.get_or_set(4)
	t.save_x(4)
	t = test_save.get_or_set(5)
	t.save_x(2.2)
	
	var two_point_two = test_save.get_index_pair(3, 1)
	print(two_point_two, " is it id 1?")
	var rangeing = test_save.get_index_pair_range(3, 1.1, 3.2)
	print(rangeing, " is it id 3,5,2 ?")
	
	rangeing = test_save.get_index_pair_range(3, 1, 1.2)
	print(rangeing, " is it id 1, 3 ?")

func test_create_sql():
	var table = DataBase.Table.new("test")
	table.create_column(false, g_man.dbms, DataBase.DataType.INT, 4, "x", 4)
	print("created")
	test_insert_sql()
	test_select_sql()

func test_insert_sql():
	var data = Vector3(1, 2, 3)
	var array = ArrayManipulation.create_multi_dimensional_array([4, 4, 4, 4], data)
	DataBase.insert(false, g_man.dbms, "test", "x", 1, array)
	print("inserted")

func test_select_sql():
	print(DataBase.select(false, g_man.dbms, "test", "x", 1))

func test_make_column_int():
	var table = DataBase.Table.new("test_float_int")
	table.create_column(false, g_man.dbms, DataBase.DataType.INT, 1, "float_int")

func test_make_column_float():
	var table = DataBase.Table.new("test_float_int")
	table.create_column(false, g_man.dbms, DataBase.DataType.FLOAT, 1, "float_int")

func test_add_column_int():
	DataBase.insert(false, g_man.dbms, "test_float_int", "float_int", 1, int(555))

func test_add_column_float():
	DataBase.insert(false, g_man.dbms, "test_float_int", "float_int", 1, float(0.436))

func test_read_column_float_int():
	print(DataBase.select(false, g_man.dbms, "test_float_int", "float_int", 1))

func test_array_change():
	var array = [[1.2, 1.1], [1.3, 2.4], 5.5]
	DataBase.Table.new("").change_array_to(array, DataBase.DataType.INT)
	print(array)
	DataBase.Table.new("").change_array_to(array, DataBase.DataType.FLOAT)
	print(array)

func test_number(number):
	number = int(number)
	if number == 0:
		test_remove_all_in_savables()
	elif number == 1:
		test_indexing()
	elif number == 2:
		test_create_sql()
	elif number == 3:
		test_insert_sql()
	elif number == 4:
		test_select_sql()
	
	elif number == 5:
		test_make_column_int()
	elif number == 6:
		test_make_column_float()
	elif number == 7:
		test_add_column_int()
	elif number == 8:
		test_add_column_float()
	elif number == 9:
		test_read_column_float_int()
	
	elif number == 10:
		test_array_change()

func record():
	g_man.record_voice.record()
func play_record():
	g_man.record_voice.play_recorded()
func stream():
	g_man.record_voice.start_streaming()
