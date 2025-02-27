class_name MoldWindow extends TabContainer

func _ready():
	g_man.mold_window = self
	get_parent().set_id_window(1, "mold window")


func any_button():
	get_parent().close_window()
	clear_signals()

signal yes_actions
signal no_actions
signal text_submit_actions(text: String)

func yes():
	yes_actions.emit()
	any_button()

	
func no():
	no_actions.emit()
	any_button()

func submit():
	text_submit_actions.emit(text_edit.text)
	any_button()

func line_submit():
	text_submit_actions.emit(line_edit.text)
	any_button()

func submit_text(text: String):
	text_submit_actions.emit(text)
	any_button()

func clear_signals():
	for item in no_actions.get_connections():
		no_actions.disconnect(item.callable)
	for item in yes_actions.get_connections():
		yes_actions.disconnect(item.callable)
	for item in text_submit_actions.get_connections():
		text_submit_actions.disconnect(item.callable)

func get_string(array: Array):
	var string:String = ""
	for item in array:
		string = String("{before}\n{item}".format({before = string, item = item}))
	return string

@onready var instructions_only = $"instructions only/MarginContainer/VBoxContainer/instructions/ScrollContainer/MarginContainer/VBoxContainer/instructions"

func set_instructions_only(array: Array):
	begin()
	current_tab = 0
	instructions_only.text = get_string(array)
	print("instr\n", array)
	push_warning("instr\n", array)

@onready var instructions_yes_no_cancel = $"yes no cancel/MarginContainer/VBoxContainer/instructions/ScrollContainer/MarginContainer/VBoxContainer/instructions"

func set_yes_no_cancel(array: Array, yes_action:Callable, no_action:Callable):
	begin()
	current_tab = 1
	instructions_yes_no_cancel.text = get_string(array)
	yes_actions.connect(yes_action)
	no_actions.connect(no_action)

@onready var instructions_add_text = $"yes no cancel add text/MarginContainer/VBoxContainer/instructions/ScrollContainer/MarginContainer/VBoxContainer/instructions"
@onready var text_edit: TextEdit = $"yes no cancel add text/MarginContainer/VBoxContainer/buttons/VBoxContainer/TextEdit"

func set_add_submit_text(array: Array, placeholder_text:String, submit_action:Callable):
	begin()
	current_tab = 2
	instructions_add_text.text = get_string(array)
	text_edit.placeholder_text = placeholder_text
	text_submit_actions.connect(submit_action)

@export var instructions_add_label: Label
@export var line_edit: LineEdit
func set_add_submit_label(array: Array, placeholder_text:String, submit_action:Callable):
	begin()
	current_tab = 3
	instructions_add_label.text = get_string(array)
	line_edit.placeholder_text = placeholder_text
	text_submit_actions.connect(submit_action)

func set_yes_no_cancel_id(array: Array, yes_action:Callable, no_action:Callable, id):
	begin()
	current_tab = 1
	instructions_yes_no_cancel.text = get_string(array)
	yes_actions.connect(
		func():
			yes_action.call(id)
	)
	no_actions.connect(
		func():
			no_action.call(id)
	)

func begin():
	get_parent().last_sibling()
	get_parent().show()
	get_parent().set_min_size(Vector2(555, 333))
