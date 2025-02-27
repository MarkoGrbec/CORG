class_name CorgApplyToBeApproved extends TabContainer

func _ready():
	g_man.corg_apply_to_be_approved = self
	get_parent().set_id_window(5, "corg_apply_to_be_approved")

@onready var _face_picture = $"face/Marginscroll/ScrollContainer/bannedContainer/picture data/face picture"
@onready var _id_face_picture = $"id face/Marginscroll/ScrollContainer/bannedContainer/picture data/id face picture"
@onready var id_number = $"submit pictures/MarginContainer/approvedContainer/ID number"

var raw_face
var raw_id_face
var image_plugin

func show_window():
	get_parent().show_window()

func close_window():
	get_parent().close_window()

var what_image_to_set: Callable

func get_face_picture():
	g_man.file_dialog.show()
	g_man.file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	g_man.file_dialog.current_path = "/storage/emulated/0/" #OS.get_user_data_dir()
	FileDialogMan.get_file_path(g_man.file_dialog, face_picture)

func face_picture(file):
	raw_face = SaveLoadPicture.load_image_to_raw_png(file)
	var texture = SaveLoadPicture.load_image_from_raw_png(raw_face)
	_face_picture.texture = texture

func get_id_face_picture():
	g_man.file_dialog.show()
	g_man.file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	g_man.file_dialog.current_dir = "/storage/emulated/0/" #OS.get_user_data_dir()
	FileDialogMan.get_file_path(g_man.file_dialog, id_face_picture)

func id_face_picture(file):
	raw_id_face = SaveLoadPicture.load_image_to_raw_png(file)
	var texture = SaveLoadPicture.load_image_from_raw_png(raw_id_face)
	_id_face_picture.texture = texture

func on_submit_pictures_and_id_Number():
	if not _face_picture.texture:
		current_tab = 0
		return
	if not _id_face_picture.texture:
		current_tab = 1
		return
	if not id_number.text:
		g_man.mold_window.set_instructions_only(["please enter ID number that matches the ID number", "from ID picture you provided"])
		return
	if len(id_number.text) < 12:
		g_man.mold_window.set_instructions_only(["please enter ID number that matches the ID number", "from ID picture you provided", "you provided too short ID"])
		return
	g_man.local_network_node.cmd_send_id_picture_to_server.rpc_id(1, raw_face, raw_id_face, id_number.text)
	close_window()
	
