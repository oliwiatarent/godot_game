extends Node

signal connection_failed(reason: String)
signal connection_started

@export var voice_chat: PackedScene

const PORT: int = 25565

var target_scene_path: String = ""
var drawer_peer_id: int = 1 # tylko host może rysować

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(scene_path: String) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 2)
	if error != OK:
		return error
		
	multiplayer.multiplayer_peer = peer
	var vc = voice_chat.instantiate()
	add_child(vc)
	vc.setup_audio(multiplayer.get_unique_id())
	
	get_tree().change_scene_to_file(scene_path)
	
	return OK

func join_game(ip: String, scene_path: String) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, PORT)
	if error != OK:
		return error
			
	multiplayer.multiplayer_peer = peer
	var vc = voice_chat.instantiate()
	add_child(vc)
	vc.setup_audio(multiplayer.get_unique_id())
	
	target_scene_path = scene_path
	connection_started.emit()
	
	return OK

func is_network_active() -> bool:
	return multiplayer.has_multiplayer_peer() and \
		   multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func is_player_drawing() -> bool:
	if not is_network_active():
		return true
	return multiplayer.get_unique_id() == drawer_peer_id

func _on_connected_to_server() -> void:
	if not target_scene_path.is_empty():
		get_tree().change_scene_to_file(target_scene_path)

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	connection_failed.emit("Could not connect to server.")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://hud/main_menu/main_menu.tscn")
