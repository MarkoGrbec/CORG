class_name FileDialogMan extends Node

static func get_file_path(file_dialog:FileDialog, callable:Callable):
	file_dialog.file_selected.connect(callable)
	file_dialog.file_selected.connect(
		func(_file_path):
			cancel(file_dialog)
	)
	file_dialog.canceled.connect(
		func():
			cancel(file_dialog)
	)

static func cancel(file_dialog:FileDialog):
	for item in file_dialog.file_selected.get_connections():
		file_dialog.file_selected.disconnect(item.callable)
	for item in file_dialog.canceled.get_connections():
		file_dialog.canceled.disconnect(item.callable)
