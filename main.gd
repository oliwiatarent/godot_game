extends Node

@export var voice_chat: PackedScene

func _ready() -> void:
	var vc = voice_chat.instantiate()
	add_child(vc)
	vc.setup_audio(multiplayer.get_unique_id())
