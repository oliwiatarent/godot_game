extends Control

signal closed

@onready var display_menu = $VerticalContainer/TabContainer/Display
@onready var key_bindings_menu = $"VerticalContainer/TabContainer/Key Bindings"
@onready var sound_menu = $VerticalContainer/TabContainer/Sound
@onready var back_button = $VerticalContainer/HBoxContainer/BackButton
@onready var save_changes_dialog: ConfirmationDialog = $SaveChangesDialog

func _update_ui_state() -> void:
	display_menu._update_ui_state()
	key_bindings_menu._update_ui_state()
	sound_menu._update_ui_state()

func _on_back_button_pressed() -> void:
	if SettingsManager.is_modified:
		save_changes_dialog.popup_centered()
	else:
		closed.emit()

func _on_save_changes_dialog_canceled() -> void:
	SettingsManager.load_settings()
	closed.emit()

func _on_save_changes_dialog_confirmed() -> void:
	SettingsManager.save_settings()
	closed.emit()

func _on_save_settings_button_pressed() -> void:
	SettingsManager.save_settings()
