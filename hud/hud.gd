extends CanvasLayer

@onready var room_code_label = $RoomCodeLabel
@onready var activity_feed = $ActivityFeed

func _ready() -> void:
	if multiplayer.is_server():
		MultiplayerManager.player_connected.connect(_on_player_connected)
		MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	
	if MultiplayerManager.is_network_active() and MultiplayerManager.current_code != "":
		room_code_label.text = MultiplayerManager.current_code
		room_code_label.show()
	else:
		room_code_label.hide()

func _on_player_connected() -> void:
	activity_feed.add_feed_message("Player connected")

func _on_player_disconnected() -> void:
	activity_feed.add_feed_message("Player disconnected")
