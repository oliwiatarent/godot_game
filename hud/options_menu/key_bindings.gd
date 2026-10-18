extends MarginContainer

@onready var container = $VerticalContainer

var is_remapping: bool = false
var action_name: String = ''
var clicked_button: Button = null

func _ready() -> void:
	create_key_nodes()


func create_key_nodes():
	var events = InputMap.get_actions()
	
	for event in events:
		if event.begins_with("ui_"):
			continue
		
		var horizontal_container = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
		
		label.text = event
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var action_events = InputMap.action_get_events(event)
		if action_events.size() > 0:
			button.text = action_events[0].as_text().trim_suffix("- Physical")
		else:
			button.text = "Brak"
			
		button.pressed.connect(_on_button_pressed.bind(button, event))
		
		horizontal_container.add_child(label)
		horizontal_container.add_child(button)
		
		container.add_child(horizontal_container)


func update_button_text() -> void:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		clicked_button.text = events[0].as_text().trim_suffix("- Physical")
	else:
		clicked_button.text = "Brak"


func _on_button_pressed(button, event) -> void:
	if is_remapping:
		update_button_text()
			
	is_remapping = true
	button.text = "Press a new button..."
	action_name = event
	clicked_button = button


func _unhandled_input(event: InputEvent) -> void:
	if not is_remapping:
		return
		
	if event is InputEventKey or event is InputEventMouseButton:
		if event is InputEventKey and event.keycode == KEY_ESCAPE:
			is_remapping = false
			update_button_text()
			return
			
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
		
		is_remapping = false
		update_button_text()
		
		get_viewport().set_input_as_handled()
