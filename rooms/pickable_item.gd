extends Area2D

@export_group('Pickable Item Properties')
@export var item_id: String = ""
@export var pickup_distance: float = 100.0

var is_picked: bool = false

func try_pick_up():
	if is_picked:
		return false
		
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance > pickup_distance:
			return

	var data = {"id": item_id, "icon": $ItemIcon.texture}
	var equipment = get_tree().get_first_node_in_group("equipment")
	
	if equipment and equipment.has_method("add_item"):
		var success = equipment.add_item(data)
		if success:
			is_picked = true
			queue_free()
