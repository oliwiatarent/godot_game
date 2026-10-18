extends Node

@export var can_transmit: bool = true

@onready var input: AudioStreamPlayer = $Input
@onready var output: AudioStreamPlayer = $Output

var index: int
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
var input_threshold: float = 0.001
var receive_buffer: PackedFloat32Array = PackedFloat32Array()
var is_mic_active: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not multiplayer.has_multiplayer_peer():
		return
		
	if is_multiplayer_authority():
		process_mic()
	process_voice()
	
func setup_audio(id: int, allow_mic: bool = true) -> void:
	can_transmit = allow_mic
	set_multiplayer_authority(id)
	
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 0)
	
	output.play()
	playback = output.get_stream_playback()

func set_mic_active(active: bool) -> void:
	is_mic_active = active

func process_mic():
	var frames = effect.get_frames_available()
	if frames <= 0:
		return
	var stereo_data: PackedVector2Array = effect.get_buffer(frames)
	
	if not can_transmit or not is_mic_active:
		return
	
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
		
		var compressed_data = data
		send_data.rpc(compressed_data)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_data(compressed_data: PackedFloat32Array):
	var data = compressed_data
	receive_buffer.append_array(data)

func process_voice():
	if receive_buffer.size() <= 0:
		return
	
	var frames = min(playback.get_frames_available(), receive_buffer.size())
	if frames > 0:
		var out_buffer = PackedVector2Array()
		out_buffer.resize(frames)
		
		for i in range(frames):
			out_buffer[i] = Vector2(receive_buffer[i], receive_buffer[i])
			
		playback.push_buffer(out_buffer)
		receive_buffer = receive_buffer.slice(frames)
