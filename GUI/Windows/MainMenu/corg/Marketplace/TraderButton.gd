class_name TraderButton extends IButtonTool

@onready var trader: Button = $"."

## custom how to set text by data provided
func set_text(text):
	if text is TraderButton:
		trader.text = text.get_text()
	else:
		trader.text = text

## custom how to return only one text: String
func get_text():
	return trader.text

## custom manage which button must be pressed
func on_click_add_listener(on_button_click:Callable):
	trader.pressed.connect(
		func():
			on_button_click.call(id)
	)
