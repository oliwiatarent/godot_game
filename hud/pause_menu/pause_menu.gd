extends CanvasLayer

@onready var pause_container = $PauseContainer
@onready var options_menu = $OptionsMenu
@onready var options_back_button = $OptionsMenu/VerticalContainer/HBoxContainer/BackButton
@onready var save_changes_dialog: ConfirmationDialog = $OptionsMenu/SaveChangesDialog

func _ready():
	hide_pause_menu()
	
	options_back_button.pressed.connect(_on_back_button_pressed)
	save_changes_dialog.confirmed.connect(_on_save_changes_dialog_confirmed)
	save_changes_dialog.canceled.connect(_on_save_changes_dialog_canceled)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		

func _notification(what):
	match what:
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			if not get_tree().paused:
				toggle_pause()


func toggle_pause():
	var is_paused = get_tree().paused
	
	if is_paused:
		if options_menu.visible:
			options_menu.hide()
			pause_container.show()
		hide_pause_menu()
	else:
		show_pause_menu()


func show_pause_menu():
	get_tree().paused = true
	show()


func hide_pause_menu():
	get_tree().paused = false
	hide()


func _on_resume_pressed() -> void:
	hide_pause_menu()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://hud/main_menu/main_menu.tscn")


func _on_options_pressed() -> void:
	options_menu._update_ui_state()
	
	pause_container.hide()
	options_menu.show()
	

func _on_back_button_pressed() -> void:
	if SettingsManager.is_modified:
		save_changes_dialog.popup_centered()
		return
	
	options_menu.hide()
	pause_container.show()


func _on_save_changes_dialog_canceled() -> void:
	SettingsManager.load_settings()
	_on_back_button_pressed()


func _on_save_changes_dialog_confirmed() -> void:
	SettingsManager.save_settings()
	_on_back_button_pressed()
