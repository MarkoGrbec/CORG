class_name MusicManager extends AudioStreamPlayer

func _ready() -> void:
	g_man.music_manager = self
	finished.connect(next_track)
	clips[music_status.main_menu] = main_menu_music
	clips[music_status.shop] = shop_music
	clips[music_status.wandering] = wandering_music
	clips[music_status.action] = action_music
	g_man.music_manager.set_music_type(MusicManager.music_status.main_menu)

#region inputs
@export var level_up_player: AudioStreamPlayer
@export var level_up: AudioStream
@export var mile_stone: AudioStream
@export var main_menu_music: Array[AudioStream]
@export var shop_music: Array[AudioStream]
@export var wandering_music: Array[AudioStream]
@export var action_music: Array[AudioStream]
#endregion end inputs
@export var clips = {}
var flip = 0
@export var status: music_status = music_status.main_menu
var _id_mobs_in_area = []
func  set_mob_in_area(id_mob):
	if _id_mobs_in_area.size() == 0:
		set_music_type(music_status.action)
		
	if not _id_mobs_in_area.has(id_mob):
		_id_mobs_in_area.push_back(id_mob)
func erase_mobs_in_area(id_mob):
	_id_mobs_in_area.erase(id_mob)
	if _id_mobs_in_area.size() == 0:
		set_music_type(music_status.wandering)

enum music_status{
	main_menu,
	shop,
	wandering,
	action,
}
func next_track():
	flip += 1
	if flip >= clips[status].size():
		flip = 1
	if flip >= clips[status].size():
		flip = 0
	stream = clips[status][flip]
	play()

func play_level_up(lvl_up: int):
	if lvl_up == 0:
		if not level_up_player.stream == level_up:
			level_up_player.stream = level_up
	elif lvl_up == 1:
		if not level_up_player.stream == mile_stone:
			level_up_player.stream = mile_stone
	level_up_player.stop()
	level_up_player.play()

func play_new():
	stream = clips[status][flip]
	play()

func set_music_type(new_status: music_status):
	status = new_status
	flip = 0
	stop()
	play_new()
	
