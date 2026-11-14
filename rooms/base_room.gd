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
