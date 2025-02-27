class_name IButtonTool extends Node

var id

#func get_content_container(id_father):

## custom how to set text by data provided
#func set_text(text):
#	if text is t_class_name:
##		default_text = text.get_text()
## 		custom set text managable or other stuff
##		AND default_text needs to be changed
#	else:
#		default_text = text

## custom how to return only one text: String
#func get_text():
#	return default_text

## custom manage which button must be pressed
## (pressed).connect(
##		func():
##			_on_button_click.call(id)
##	)
#func on_click_add_listener(on_button_click:Callable):
