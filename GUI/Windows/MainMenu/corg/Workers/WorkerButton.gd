class_name WorkerButton extends IButtonTool

var default_text

# custom how to set text by data provided
func set_text(text):
	if text is WorkerButton:
		self.text = text.get_text()
	else:
		default_text = text
		self.text = text

# custom how to return only one text: String
func get_text():
	return default_text

# custom manage which button must be pressed
func on_click_add_listener(on_button_click:Callable):
	self.pressed.connect(
		func():
			on_button_click.call(id)
	)
