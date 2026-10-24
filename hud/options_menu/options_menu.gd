extends Control

func _on_save_settings_button_pressed() -> void:
	SettingsManager.save_settings()
