class_name PendingForCorg extends IButtonTool

@onready var face_picture = $"face picture"
@onready var id_picture = $"id picture"
@onready var edit_id_number = $"VBoxContainer/MarginContainer/edit id number"
@onready var button:Button = $VBoxContainer/MarginContainer2/Button

var raw_face
var raw_id
var emso

## custom how to set text by data provided
func set_text(t_class):
	if t_class is PendingForCorg:
		button.text = "I approve it"
		if t_class.emso:
			edit_id_number.text = t_class.emso
		else:
			edit_id_number.text = "repairP"
		face_picture.texture = SaveLoadPicture.load_image_from_raw_png(t_class.raw_face)
		id_picture.texture = SaveLoadPicture.load_image_from_raw_png(t_class.raw_id)
	else:
		button.text = t_class

## custom how to return only one text: String
func get_text():
	return button.text

## custom manage which button must be pressed
func on_click_add_listener(on_button_click:Callable):
	button.pressed.connect(
		func():
			on_button_click.call(id, edit_id_number.text)
	)
