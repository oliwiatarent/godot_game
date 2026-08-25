extends Control

@export_file("*.tscn") var game_scene_path: String = "res://main.tscn"

@onready var main_panel: VBoxContainer = $CenterContainer/MainPanel
@onready var lobby_panel: VBoxContainer = $CenterContainer/LobbyPanel

@onready var panels: Array[Control] = [main_panel, lobby_panel]

const PORT = 25565


func _ready() -> void:
	main_panel.visible = true
	lobby_panel.visible = false

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
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 2)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file(game_scene_path)

func _on_join_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", PORT)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_file(game_scene_path)

func _on_lobby_back_button_pressed() -> void:
	show_panel(main_panel)
