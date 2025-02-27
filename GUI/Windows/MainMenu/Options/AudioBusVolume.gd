class_name AudioBusVolume extends Node

@export var h_scroll_bar: HScrollBar

@export var volume_name: String = "music"
@export var volume_name_node: Label

@export var db_name: String
@export var bus_name: String

func _ready() -> void:
	volume_name_node.text = volume_name

func _volume_changed(value: float) -> void:
	change_save_bus_level(value)

func load_audio():
	var value = DataBase.select(false, g_man.dbms, "options", db_name, g_man.local_network_node.client.id, 0)
	var audio_bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(audio_bus_index, value)
	h_scroll_bar.value = value

func change_save_bus_level(value):
	var audio_bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(audio_bus_index, value)
	DataBase.insert(false, g_man.dbms, "options", db_name, g_man.local_network_node.client.id, value)
