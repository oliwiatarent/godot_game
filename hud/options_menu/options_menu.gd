extends Control

@onready var display_menu = $VerticalContainer/TabContainer/Display
@onready var key_bindings_menu = $"VerticalContainer/TabContainer/Key Bindings"
@onready var sound_menu = $VerticalContainer/TabContainer/Sound

func _on_save_settings_button_pressed() -> void:
	SettingsManager.save_settings()

func _update_ui_state() -> void:
	display_menu._update_ui_state()
	key_bindings_menu._update_ui_state()
	sound_menu._update_ui_state()
	
