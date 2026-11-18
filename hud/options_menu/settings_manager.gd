extends Node

const SETTINGS_FILE = "user://settings.tres"

var settings_data: SettingsData = SettingsData.new()
var is_modified: bool = false

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	ResourceSaver.save(settings_data, SETTINGS_FILE)
	apply_settings()
	is_modified = false

func load_settings():
	if not FileAccess.file_exists(SETTINGS_FILE):
		return
	settings_data = ResourceLoader.load(SETTINGS_FILE).duplicate(true)
	
	apply_settings()
	is_modified = false

func apply_settings() -> void:
	if settings_data.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(settings_data.resolution)
		
	for action in settings_data.keybindings:
		var val = settings_data.keybindings[action]
		InputMap.action_erase_events(action)
			
		if val > 0:
			var new_event = InputEventKey.new()
			new_event.keycode = val
			InputMap.action_add_event(action, new_event)
		elif val < 0:
			var new_event = InputEventMouseButton.new()
			new_event.button_index = -val
			InputMap.action_add_event(action, new_event)
	
	for bus_name in settings_data.sound_levels:
		pass
		# TODO: aplikowanie poziomów głośności
