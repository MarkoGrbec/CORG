class_name RequestedCustomer extends IButtonTool


func set_text(text):
	if text is RequestedCustomer:
		self.text = text.get_text()
	else:
		self.text = text

func get_text():
	return self.text

func on_click_add_listener(on_button_click:Callable):
	self.pressed.connect(
		func():
			on_button_click.call(id)
	)
