class_name LawManager extends Node

@onready var laws_container: VBoxContainer = $"laws/ScrollContainer/laws container"
@onready var law_header: LineEdit = $"laws/ScrollContainer/laws container/submit law container/law header"
@onready var law_body: TextEdit = $"laws/ScrollContainer/laws container/submit law container/law body"

#TODO:for constitution!!! or so???
#@onready var submit_law: Button = $"laws/ScrollContainer/laws container/submit law container/submit law"

var id_type

func _ready() -> void:
	g_man.law_manager = self
	get_parent().set_id_window(10, "law manager")
	laws_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/Law/Law.tscn"), null, on_law_click, cmd_refresh_law, laws_container)

func show_window(id_law_type):
	id_type = id_law_type
	laws_button_tool.hide_all_buttons()
	g_man.local_network_node.net_corg_node.cmd_get_id_laws_from_types.rpc_id(1, id_law_type)
	get_parent().show_window()

func close_window():
	get_parent().close_window()

var laws_button_tool:ButtonTool

func on_suggest_law():
	g_man.local_network_node.net_corg_node.cmd_add_suggest_law.rpc_id(1, id_type, law_header.text, law_body.text)

func add_buttons(id_laws):
	laws_button_tool.add_buttons(id_laws, 0, true)

func refresh_law(law:Law):
	if not law.header_text || not law.body_text:
		laws_button_tool.permanently_delete([law.id])
		return
	laws_button_tool.refresh_t(law.id, law)

func on_law_click(id, vote_toggle):
	g_man.local_network_node.net_corg_node.cmd_vote_law.rpc_id(1, id, vote_toggle)

func cmd_refresh_law(id_law):
	g_man.local_network_node.net_corg_node.cmd_get_law.rpc_id(1, id_law)
