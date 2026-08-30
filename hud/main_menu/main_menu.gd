extends Control

@export_file("*.tscn") var game_scene_path: String = "res://main.tscn"

@onready var main_panel: VBoxContainer = $CenterContainer/MainPanel
@onready var lobby_panel: VBoxContainer = $CenterContainer/LobbyPanel
@onready var status_label: Label = $CenterContainer/LobbyPanel/StatusLabel
@onready var panels: Array[Control] = [main_panel, lobby_panel]

func _ready() -> void:
	show_panel(main_panel)
	MultiplayerManager.connection_failed.connect(_on_connection_failed)
	MultiplayerManager.connection_started.connect(_on_connection_started)

func show_panel(target_panel: Control) -> void:
	for panel in panels:
		if panel != target_panel:
			panel.visible = false
			continue
		panel.visible = true

func _on_play_button_pressed() -> void:
	show_panel(lobby_panel)

func _on_options_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_host_button_pressed() -> void:
	var err = MultiplayerManager.host_game(game_scene_path)
	if err != OK:
		status_label.text = "Could not create server (%d)" % err

func _on_join_button_pressed() -> void:
	var ip = "127.0.0.1"
	var err = MultiplayerManager.join_game(ip, game_scene_path)
	if err != OK:
		status_label.text = "Connection error (%d)" % err

func _on_lobby_back_button_pressed() -> void:
	show_panel(main_panel)

func _on_connection_started() -> void:
	status_label.text = "Connecting to server..."

func _on_connection_failed(reason: String) -> void:
	status_label.text = reason
