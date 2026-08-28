extends Node

@export var output_path: NodePath

@onready var input: AudioStreamPlayer
var index: int
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
var input_threshold = 0.01

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		process_mic()
	pass
	
func setup_audio(id: int) -> void:
	input = $Input
	set_multiplayer_authority(id)
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 0)
	
	var output = get_node(output_path)
	output.play()
	playback = get_node(output_path).get_stream_playback()

func process_mic():
	var stereo_data: PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if stereo_data.size() > 0:
		var max_amplitude: float = 0.0
		var data = PackedFloat32Array()
		data.resize(stereo_data.size())
		
		for i in range(stereo_data.size()):
			var value = (stereo_data[i].x + stereo_data[i].y) / 2
			max_amplitude = max(abs(value), max_amplitude)
			data[i] = value
		if max_amplitude < input_threshold:
			return
		
		print(data)
