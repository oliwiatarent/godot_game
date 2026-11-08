extends Control

@export_file("*.tscn") var game_scene_path: String = "res://main.tscn"

@onready var main_panel: VBoxContainer = $CenterContainer/MainPanel
@onready var lobby_panel: VBoxContainer = $CenterContainer/LobbyPanel
@onready var options_panel = $CenterContainer/OptionsMenu
@onready var host_panel = $CenterContainer/HostPanel
@onready var join_panel = $CenterContainer/JoinPanel
@onready var panels: Array[Control] = [
	main_panel, lobby_panel, options_panel, host_panel, join_panel
]

@onready var host_code_label = $CenterContainer/HostPanel/CodeLabel
@onready var host_status_label = $CenterContainer/HostPanel/StatusLabel
@onready var join_status_label = $CenterContainer/JoinPanel/StatusLabel
@onready var start_game_button = $CenterContainer/HostPanel/Buttons/StartGameButton
@onready var code_input = $CenterContainer/JoinPanel/Input/CodeInput

func _ready() -> void:
	show_panel(main_panel)
	start_game_button.disabled = true
	
	MultiplayerManager.connection_failed.connect(_on_connection_failed)
	MultiplayerManager.connection_started.connect(_on_connection_started)
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	MultiplayerManager.host_code_received.connect(_on_host_code_received)
	MultiplayerManager.api_error.connect(_on_api_error)
	
	multiplayer.peer_connected.connect(_on_player_connected)
	
	options_panel.closed.connect(_on_options_closed)

func show_panel(target_panel: Control) -> void:
	for panel in panels:
		if panel != target_panel:
			panel.visible = false
			continue
		panel.visible = true

# Main Panel

func _on_play_button_pressed() -> void:
	show_panel(lobby_panel)

func _on_options_button_pressed() -> void:
	options_panel._update_ui_state()
	show_panel(options_panel)

func _on_options_closed() -> void:
	show_panel(main_panel)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Lobby Panel

func _on_host_button_pressed() -> void:
	show_panel(host_panel)
	host_status_label.text = "Awaiting server response..."
	start_game_button.disabled = true
	MultiplayerManager.host_game_with_code(game_scene_path)

func _on_join_button_pressed() -> void:
	show_panel(join_panel)

func _on_lobby_back_button_pressed() -> void:
	show_panel(main_panel)

# Host Panel

func _on_start_game_button_pressed() -> void:
	MultiplayerManager.start_multiplayer_game()

func _on_cancel_host_button_pressed() -> void:
	MultiplayerManager.close_game()
	show_panel(lobby_panel)

# Join Panel

func _on_connect_button_pressed() -> void:
	var code = code_input.text.strip_edges()
	if code.is_empty():
		return
	
	join_status_label.text = "Connecting..."
	MultiplayerManager.join_game_with_code(code, game_scene_path)

func _on_join_back_button_pressed() -> void:
	MultiplayerManager.close_game()
	show_panel(lobby_panel)

# Signals

func _on_connection_started() -> void:
	join_status_label.text = "Connecting to host..."

func _on_connection_failed(reason: String) -> void:
	join_status_label.text = "Error: " + reason

func _on_host_code_received(code: String) -> void:
	host_code_label.text = "Room code: " + code
	host_status_label.text = "Waiting for player..."

func _on_api_error(reason: String) -> void:
	host_status_label.text = reason
	join_status_label.text = reason

func _on_player_connected(_id: int) -> void:
	if multiplayer.is_server():
		host_status_label.text = "Player connected. Ready to start."
		start_game_button.disabled = false
	else:
		join_status_label.text = "Connected. Waiting for host to start..."

func _on_player_disconnected() -> void:
	if multiplayer.is_server():
		host_status_label.text = "Player left. Room is open again."
		start_game_button.disabled = true
