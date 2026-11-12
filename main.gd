extends Node

const SAM = 1
const sam_room_1 = preload("res://rooms/sam_room_1/sam_room_1.tscn")
const ellie_room_1 = preload("res://rooms/ellie_room_1/ellie_room_1.tscn")

func _ready() -> void:
	var instance = null
	if multiplayer.get_unique_id() == SAM:
		instance = sam_room_1.instantiate()
	else:
		instance = ellie_room_1.instantiate()
	
	add_child(instance)
	move_child(instance, 1)
