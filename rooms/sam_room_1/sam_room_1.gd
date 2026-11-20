extends BaseRoom

@onready var locker = $Locker
@onready var door = $Door
@onready var extended_locker = $LockerExtended
@onready var opened_locker = $LockerOpened
@onready var card = $LockerOpened/Card
@onready var panel = $Panel
@onready var riddle = $SamCommunicationRiddle
@onready var extended_door = $DoorExtended

var window_opened = false


func _ready() -> void:
	set_item_active(card, false)
	set_item_active(locker, false)
	set_item_active(door, false)
	riddle.riddle_closed.connect(_on_close_riddle_button_pressed)
	EventBus.enable_objects.connect(_on_voice_connection_established)


func _on_locker_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
		
		set_item_active(panel, false)
		extended_locker.show()
		window_opened = handle_window_operation(window_opened)


func _on_locker_extended_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		extended_locker.hide()
		opened_locker.show()
		set_item_active(card, true)


func _on_locker_opened_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_mouse_over_pickable_item():
			return
			
		opened_locker.hide()
		extended_locker.show()
		set_item_active(card, false)


func _on_locker_close_button_pressed() -> void:
	opened_locker.hide()
	extended_locker.hide()
	set_item_active(card, false)
	set_item_active(panel, true)
	window_opened = handle_window_operation(window_opened)


func _on_door_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
			
		set_item_active(panel, false)
		extended_door.show()
		window_opened = handle_window_operation(window_opened)


func _on_door_close_button_pressed() -> void:
	extended_door.hide()
	set_item_active(panel, true)
	window_opened = handle_window_operation(window_opened)


func _on_panel_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
			
		riddle.show()
		window_opened = handle_window_operation(window_opened)
		
		
func _on_close_riddle_button_pressed():
	riddle.hide()
	window_opened = handle_window_operation(window_opened)
	

func _on_voice_connection_established():
	set_item_active(locker, true)
	set_item_active(door, true)
