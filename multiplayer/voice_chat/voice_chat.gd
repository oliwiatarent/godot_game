extends Node

@export var output_path: NodePath

@onready var input: AudioStreamPlayer
var index: int
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
var input_threshold: float = 0.01
var receive_buffer: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		process_mic()
	process_voice()
	
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
		
		send_data.rpc(data)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_data(data: PackedFloat32Array):
	receive_buffer.append_array(data)

func process_voice():
	if receive_buffer.size() <= 0:
		return
	
	for i in range(min(playback.get_frames_available(), receive_buffer.size())):
		playback.push_frame(Vector2(receive_buffer[0], receive_buffer[0]))
		receive_buffer.remove_at(0)
