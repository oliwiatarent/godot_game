extends Node

@onready var locker = $Locker
@onready var extended_locker = $LockerExtended
@onready var opened_locker = $LockerOpened


func _on_locker_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		extended_locker.show()


func _on_locker_extended_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		extended_locker.hide()
		opened_locker.show()


func _on_locker_opened_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		opened_locker.hide()
		extended_locker.show()


func _on_locker_close_button_pressed() -> void:
	opened_locker.hide()
	extended_locker.hide()
