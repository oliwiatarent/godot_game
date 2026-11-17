extends Node
class_name BaseRoom

func handle_window_operation(window_opened):
	if window_opened:
		EventBus.enable_walking.emit()
		return false
	else:
		EventBus.disable_walking.emit()
		return true


func set_item_active(item, active: bool) -> void:
	if item:
		item.visible = active
		item.input_pickable = active
		
		for child in item.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.disabled = not active
				
				
func is_mouse_over_pickable_item() -> bool:
	var space_state = get_viewport().get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_viewport().get_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var result = space_state.intersect_point(query)
	for item in result:
		if item["collider"] is PickableItem:
			return true
	return false
