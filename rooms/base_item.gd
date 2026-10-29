extends Area2D
class_name BaseItem

var is_mouse_hovering: bool = false

func _input(event: InputEvent) -> void:
	if not is_mouse_hovering:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			CursorManager.set_clicked_cursor()
		else:
			CursorManager.unset_clicked_cursor()
	

func _on_mouse_entered():
	is_mouse_hovering = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	
func _on_mouse_exited():
	is_mouse_hovering = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
