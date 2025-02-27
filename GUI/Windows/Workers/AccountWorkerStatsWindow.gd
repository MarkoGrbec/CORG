class_name AccountWorkerStatsWindow extends Node

func _ready() -> void:
	g_man.account_worker_stats_window = self
	get_parent().set_id_window(7, "worker accounts stats window")

func show_window():
	get_parent().show_window()
	set_worker()

func close_window():
	get_parent().close_window()

var id
var employed_at
var employed_at_corg
@onready var username: Label = $HBoxContainer/Marginscroll/ScrollContainer/VBoxContainer/username
@onready var start_working: Button = $"HBoxContainer/Marginscroll/ScrollContainer/VBoxContainer/HBoxContainer2/start working"
@onready var working_label: Label = $"HBoxContainer/Marginscroll/ScrollContainer/VBoxContainer/HBoxContainer2/working label"
@onready var stop_working: Button = $"HBoxContainer/Marginscroll/ScrollContainer/VBoxContainer/HBoxContainer2/stop working"
@onready var salary: Label = $HBoxContainer/Marginscroll/ScrollContainer/VBoxContainer/HBoxContainer/salary
@onready var quit_job: Button = $"HBoxContainer/Marginscroll/ScrollContainer/VBoxContainer/quit job"
@onready var biography: TextEdit = $HBoxContainer/Marginscroll/ScrollContainer/VBoxContainer/biography

func set_worker():
	var worker:Client = g_man.local_network_node.client
	username.text = worker._username
	employed_at = worker.load_return_employed_at()
	employed_at_corg = worker.load_return_employed_at_corg()
	if employed_at || employed_at_corg:
		quit_job.show()
	else:
		quit_job.hide()
	
	salary.text = String("{salary}").format({salary = MoneyCurrency.balance(worker.load_return_salary(), MoneyCurrency.plant.all)})
	id = worker.id_server
	g_man.local_network_node.net_corg_node.cmd_load_biography.rpc_id(1, id)

func set_working_stats(currently_working, seconds):
	var working
	if currently_working:
		working = "working for "
	else:
		working = "resting for "
	working_label.text = str(working, "%1.2f" % (float(seconds)/3600), " hours")

func on_start_working():
	g_man.local_network_node.net_corg_node.cmd_start_end_job.rpc_id(1, true)
	
func on_stop_working():
	g_man.local_network_node.net_corg_node.cmd_start_end_job.rpc_id(1, false)

func on_quit_job_pressed():
	if employed_at || employed_at_corg:
		g_man.local_network_node.net_corg_node.cmd_remove_worker.rpc_id(1, id)

func on_biography_text_set():
	g_man.local_network_node.net_corg_node.cmd_set_biography.rpc_id(1, biography.text)
	printerr("setting text: ", biography.text)
