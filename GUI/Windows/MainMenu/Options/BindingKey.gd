class_name BindingKey extends Node

func _ready() -> void:
	label.text = Options.keys.find_key(index).replace("_", " ")

@warning_ignore("enum_variable_without_default")
@export var index: Options.keys
@export var label: Label
@export var button: Button

func _change_binding():
	g_man.options.change_binding(index, self)

func set_binding_label(text):
	button.text = text
