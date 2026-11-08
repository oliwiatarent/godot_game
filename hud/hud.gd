extends CanvasLayer

@onready var room_code_label = $RoomCodeLabel

func _ready() -> void:
	if MultiplayerManager.is_network_active() and MultiplayerManager.current_code != "":
		room_code_label.text = MultiplayerManager.current_code
		room_code_label.show()
	else:
		room_code_label.hide()
