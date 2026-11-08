extends Node

signal connection_failed(reason: String)
signal connection_started
signal host_code_received(code: String)
signal api_error(reason: String)

@export var voice_chat: PackedScene

const PORT: int = 25565
const RELAY_URL = "http://127.0.0.1:8000"

var host_http: HTTPRequest
var join_http: HTTPRequest
var target_scene_path: String = ""
var drawer_peer_id: int = 1 # tylko host może rysować
var vc: Node = null

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	host_http = HTTPRequest.new()
	add_child(host_http)
	host_http.request_completed.connect(_on_host_request_completed)
	join_http = HTTPRequest.new()
	add_child(join_http)
	join_http.request_completed.connect(_on_join_request_completed)

func host_game() -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 1)
	if error != OK:
		return error
		
	multiplayer.multiplayer_peer = peer
	vc = voice_chat.instantiate()
	add_child(vc)
	vc.setup_audio(multiplayer.get_unique_id(), false)
	
	return OK

func join_game(ip: String, scene_path: String) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, PORT)
	if error != OK:
		return error
			
	multiplayer.multiplayer_peer = peer
	vc = voice_chat.instantiate()
	add_child(vc)
	vc.setup_audio(multiplayer.get_unique_id(), true)
	
	target_scene_path = scene_path
	connection_started.emit()
	
	return OK

func close_game() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

func is_network_active() -> bool:
	return multiplayer.has_multiplayer_peer() and \
		   multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func is_player_drawing() -> bool:
	if not is_network_active():
		return true
	return multiplayer.get_unique_id() == drawer_peer_id

func _on_connected_to_server() -> void:
	pass

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	connection_failed.emit("Could not connect to server.")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://hud/main_menu/main_menu.tscn")

func host_game_with_code(scene_path: String) -> void:
	target_scene_path = scene_path
	var err = host_game()
	if err != OK:
		api_error.emit("ENet error: %d" % err)
		return
	
	var body = JSON.stringify({"port": PORT})
	var headers = ["Content-Type: application/json"]
	host_http.request(RELAY_URL + "/host", headers, HTTPClient.METHOD_POST, body)

func join_game_with_code(code: String, scene_path: String) -> void:
	target_scene_path = scene_path
	join_http.request(RELAY_URL + "/join/" + code, [], HTTPClient.METHOD_GET)

func _on_host_request_completed(
	_result: int, 
	response_code: int, 
	_headers: PackedStringArray, 
	body: PackedByteArray
) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		host_code_received.emit(json["code"])
	else:
		api_error.emit("Failed to register host.")

func _on_join_request_completed(
	_result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var ip = json["ip_address"]
		join_game(ip, target_scene_path)
	elif response_code == 404:
		api_error.emit("Wrong code.")
	else:
		api_error.emit("Connection timed out.")

func start_multiplayer_game() -> void:
	if multiplayer.is_server():
		rpc_load_game_scene.rpc(target_scene_path)

@rpc("call_local", "reliable")
func rpc_load_game_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
