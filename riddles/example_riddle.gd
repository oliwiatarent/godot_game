extends ColorRect

func _on_close_button_pressed():
	queue_free()
	EventBus.enable_walking.emit()
