extends Node
class_name BaseRoom

func handle_window_operation(window_opened):
	if window_opened:
		EventBus.enable_walking.emit()
		return false
	else:
		EventBus.disable_walking.emit()
		return true
