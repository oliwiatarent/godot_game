extends Area2D

@export_group('Pickable Item Properties')
@export var item_id: String = ""
	
func _ready():
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_pick_up()

func try_pick_up():
	var data = {"id": item_id, "icon": $ItemIcon.texture}
	
	var equipment = get_tree().get_first_node_in_group("equipment")
	if equipment and equipment.has_method("add_item"):
		var success = equipment.add_item(data)
		if success:
			queue_free()
