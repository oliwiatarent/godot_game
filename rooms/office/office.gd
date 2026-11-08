extends Node

@onready var extended_locker = $LockerExtended
@onready var opened_locker = $LockerOpened
@onready var card = $LockerOpened/Card

@onready var extended_door = $DoorExtended

var window_opened = false


func _ready() -> void:
	set_item_active(card, false)


func _on_locker_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
			
		EventBus.disable_walking.emit()
		extended_locker.show()
		window_opened = true


func _on_locker_extended_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		extended_locker.hide()
		opened_locker.show()
		set_item_active(card, true)


func _on_locker_opened_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		opened_locker.hide()
		extended_locker.show()
		set_item_active(card, false)


func _on_locker_close_button_pressed() -> void:
	opened_locker.hide()
	extended_locker.hide()
	set_item_active(card, false)
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
	
	
func set_item_active(item, active: bool) -> void:
	if item:
		item.visible = active
		item.input_pickable = active
		
		for child in item.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.disabled = not active
