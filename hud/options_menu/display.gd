extends MarginContainer

@onready var fullscreen_check_box: CheckBox = $VerticalContainer/FullScreenContainer/FullScreenCheckBox
@onready var resolution_option_button: OptionButton = $VerticalContainer/ResolutionContainer/ResolutionOptionButton

var resolutions: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

func _ready() -> void:
	_setup_resolution_options()
	_update_ui_state()
	

func _setup_resolution_options() -> void:
	resolution_option_button.clear()
	
	var current_size = SettingsManager.settings_data.resolution
	var selected_index = 0
	
	for i in range(resolutions.size()):
		var res = resolutions[i]
		var text = str(res.x) + " x " + str(res.y)
		resolution_option_button.add_item(text, i)
		
		if res == current_size:
			selected_index = i
			
	resolution_option_button.selected = selected_index
	
	
func _update_ui_state() -> void:
	var mode = DisplayServer.window_get_mode()
	var is_fullscreen = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	fullscreen_check_box.button_pressed = is_fullscreen
	resolution_option_button.disabled = is_fullscreen
	
	
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SettingsManager.settings_data.fullscreen = toggled_on
	resolution_option_button.disabled = toggled_on
	SettingsManager.apply_settings()
	

func _on_resolution_selected(index: int) -> void:
	SettingsManager.settings_data.resolution = resolutions[index]
	SettingsManager.apply_settings()
