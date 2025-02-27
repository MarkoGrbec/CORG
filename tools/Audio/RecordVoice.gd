class_name RecordVoice extends AudioStreamPlayer
#@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"
@onready var audio_master: AudioStreamPlayer = $"../AudioStreamMaster"
@onready var timer: Timer = $"../rec buffer timer"

var rec_effect: AudioEffectRecord
var buffer
var recording_info: AudioStreamWAV

signal stream_to(array: Array)

func _ready():
	g_man.record_voice = self
	# We get the index of the "Record" bus.
	var record_bus_index = AudioServer.get_bus_index("Record")
	rec_effect = AudioServer.get_bus_effect(record_bus_index, 0)
	timer.timeout.connect(send_to_buffer)
	start_streaming()
	# debug
	#stream_to.connect(send_stream)

func start_streaming():
	if not rec_effect.is_recording_active():
		playing = true
		rec_effect.set_recording_active(true)
		timer.start(0.25)
	else:
		stop_streaming()

func send_to_buffer():
	if buffer:
		stream_to.emit(buffer)
	recording_info = rec_effect.get_recording()
	buffer = recording_info.get_data()
	rec_effect.set_recording_active(false)
	rec_effect.set_recording_active(true)

## debug
#func send_stream(array):
	#var sample: AudioStreamWAV = AudioStreamWAV.new()
	#sample.data = array
	#sample.format = AudioStreamWAV.FORMAT_16_BITS
	#sample.mix_rate = int(AudioServer.get_mix_rate() * 2)
	#audio_master.stream = sample
	#audio_master.play()

func stop_streaming():
	timer.stop()
	rec_effect.set_recording_active(false)
	playing = false
