extends Node

@onready var extended_locker = $LockerExtended
@onready var opened_locker = $LockerOpened

@onready var extended_door = $DoorExtended

var window_opened = false


func _on_locker_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
			
		EventBus.disable_walking.emit()
		extended_locker.show()
		window_opened = true


func _on_locker_extended_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_mouse_over_pickable_item():
			return
			
		extended_locker.hide()
		opened_locker.show()


func _on_locker_opened_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_mouse_over_pickable_item():
			return
			
		opened_locker.hide()
		extended_locker.show()


func _on_locker_close_button_pressed() -> void:
	opened_locker.hide()
	extended_locker.hide()
	window_opened = false
	EventBus.enable_walking.emit()
	
	
func _on_door_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
			
		EventBus.disable_walking.emit()
		extended_door.show()
		window_opened = true


func _on_door_close_button_pressed() -> void:
	extended_door.hide()
	window_opened = false
	EventBus.enable_walking.emit()
	

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
