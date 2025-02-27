class_name LawTab extends Node

func _ready() -> void:
	g_man.law_tab = self
	law_meta_button_tool = ButtonTool.new(preload("res://GUI/Windows/MainMenu/Law/LawMeta.tscn"), null, on_law_meta_click, cmd_law_meta_refresh, law_types)

@onready var law_types: VBoxContainer = $ScrollContainer/law_types

var law_meta_button_tool:ButtonTool

func send():
	g_man.local_network_node.net_corg_node.cmd_get_last_id_law_types.rpc_id(1)
#region button tool
func add_buttons_last_id(last_id):
	law_meta_button_tool.add_buttons(range(1, last_id))

func refresh_law_meta(id, header):
	law_meta_button_tool.refresh_text_only(id, header)
	if not header:
		law_meta_button_tool.hide_buttons([id])

func on_law_meta_click(id):
	g_man.law_manager.show_window(id)

func cmd_law_meta_refresh(id):
	g_man.local_network_node.net_corg_node.cmd_refresh_law_meta.rpc_id(1, id)
#endregion button tool
