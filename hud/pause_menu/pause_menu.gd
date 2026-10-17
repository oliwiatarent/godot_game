extends CanvasLayer

func _ready():
	hide_pause_menu()


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
