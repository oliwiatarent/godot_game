extends Node

@onready var animated_sprite = $Player/Animation

const SAM = 1

const sam_room_1 = preload("res://rooms/sam_room_1/sam_room_1.tscn")
const ellie_room_1 = preload("res://rooms/ellie_room_1/ellie_room_1.tscn")

const ellie_frames = preload("res://players/ellie_frames.tres")

func _ready() -> void:
	var instance = null
	if multiplayer.get_unique_id() == SAM:
		instance = sam_room_1.instantiate()
	else:
		animated_sprite.sprite_frames = ellie_frames
		instance = ellie_room_1.instantiate()
	
	add_child(instance)
	move_child(instance, 1)
