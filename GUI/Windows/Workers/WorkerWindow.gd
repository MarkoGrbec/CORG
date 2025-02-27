class_name WorkersWindow extends Node

func _ready() -> void:
	g_man.workers_window = self
	get_parent().set_id_window(6, "worker window")

func show_window():
	get_parent().show_window()

func close_window():
	get_parent().close_window()

var id
var employed_at

@onready var username: Label = $HBoxContainer/Marginscroll/ScrollContainer/workerContainer/username
@onready var fire_hire: Button = $"HBoxContainer/Marginscroll/ScrollContainer/workerContainer/fire hire"
@onready var salary: LineEdit = $HBoxContainer/Marginscroll/ScrollContainer/workerContainer/HBoxContainer/salary
@onready var biography: Label = $HBoxContainer/Marginscroll/ScrollContainer/workerContainer/biography

func set_worker(worker:Client):
	username.text = worker._username
	employed_at = worker.load_return_employed_at()
	if employed_at:
		fire_hire.text = "fire"
	else:
		fire_hire.text = "hire"
	
	var worker_salary = worker.load_return_salary()
	var apple = MoneyCurrency.convert_money(1, MoneyCurrency.plant.apple)
	var calc = float(worker_salary) / apple
	
	salary.text = str(calc)
	id = worker.id_server
	g_man.local_network_node.net_corg_node.cmd_load_biography.rpc_id(1, id)

func _on_fire_hire_pressed() -> void:
	if employed_at:
		g_man.local_network_node.net_corg_node.cmd_remove_worker.rpc_id(1, id)
	else:
		g_man.local_network_node.net_corg_node.cmd_add_worker.rpc_id(1, username.text, salary.text.to_float())

func set_salary(text:String):
	g_man.local_network_node.net_corg_node.cmd_change_salary.rpc_id(1, id, text.to_float())
