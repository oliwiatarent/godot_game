extends Node

signal connection_failed(reason: String)
signal connection_started
signal connection_succeeded
signal host_code_received(code: String)
signal api_error(reason: String)
signal player_connected
signal player_disconnected

@export var voice_chat: PackedScene

@onready var heartbeat_timer = $HeartbeatTimer

const RELAY_URL = "http://127.0.0.1:8000"

var is_game_started: bool = false
var current_code: String = ""
var last_disconnect_reason = ""

var host_http: HTTPRequest
var join_http: HTTPRequest
var update_http: HTTPRequest
var heartbeat_http: HTTPRequest

var target_scene_path: String = ""
var drawer_peer_id: int = 1 # tylko host może rysować
var vc: Node = null

func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	host_http = _create_http_request(_on_host_request_completed)
	join_http = _create_http_request(_on_join_request_completed)
	update_http = _create_http_request()
	heartbeat_http = _create_http_request()

func _create_http_request(callback: Callable = Callable()) -> HTTPRequest:
	var req = HTTPRequest.new()
	add_child(req)
	if callback.is_valid():
		req.request_completed.connect(callback)
	return req

func _setup_voice_chat(is_client: bool) -> void:
	if vc:
		vc.queue_free()
	vc = voice_chat.instantiate()
	add_child(vc)
	vc.setup_audio(multiplayer.get_unique_id(), is_client)

func _cleanup_network() -> void:
	current_code = ""
	is_game_started = false
	heartbeat_timer.stop()
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	if vc:
		vc.queue_free()
		vc = null

# Network

func host_game() -> Error:
	_cleanup_network()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(0, 1)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	_setup_voice_chat(false)
	return OK

func join_game(ip: String, port: int, scene_path: String) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		return error
	
	multiplayer.multiplayer_peer = peer
	_setup_voice_chat(true)
	
	target_scene_path = scene_path
	connection_started.emit()
	return OK

func start_multiplayer_game() -> void:
	if multiplayer.is_server():
		is_game_started = true
		rpc_load_game_scene.rpc(target_scene_path)

func close_game() -> void:
	if not current_code.is_empty():
		if multiplayer.multiplayer_peer and multiplayer.is_server():
			update_http.request(RELAY_URL + "/close/" + current_code, [], HTTPClient.METHOD_DELETE)
		elif not is_network_active():
			update_http.request(RELAY_URL + "/leave/" + current_code, [], HTTPClient.METHOD_POST)
	
	_cleanup_network()

func is_network_active() -> bool:
	return multiplayer.has_multiplayer_peer() and \
		   multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func is_player_drawing() -> bool:
	if not is_network_active():
		return true
	return multiplayer.get_unique_id() == drawer_peer_id

# Session codes

func host_game_with_code(scene_path: String) -> void:
	target_scene_path = scene_path
	var err = host_game()
	if err != OK:
		api_error.emit("ENet error: %d" % err)
		return
	
	var port = multiplayer.multiplayer_peer.host.get_local_port()
	var body = JSON.stringify({"port": port})
	var headers = ["Content-Type: application/json"]
	host_http.request(RELAY_URL + "/host", headers, HTTPClient.METHOD_POST, body)

func join_game_with_code(code: String, scene_path: String) -> void:
	target_scene_path = scene_path
	current_code = code.to_upper()
	join_http.request(RELAY_URL + "/join/" + current_code, [], HTTPClient.METHOD_GET)

# Callbacks

@rpc("call_local", "reliable")
func rpc_load_game_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)

# Signals

func _on_connection_failed() -> void:
	_cleanup_network()
	connection_failed.emit("Could not connect to server.")

func _on_connected_to_server() -> void:
	connection_succeeded.emit()

func _on_server_disconnected() -> void:
	_cleanup_network()
	last_disconnect_reason = "Host closed the game."
	get_tree().paused = false
	get_tree().change_scene_to_file("res://hud/main_menu/main_menu.tscn")

func _on_host_request_completed(
	_result: int, 
	response_code: int, 
	_headers: PackedStringArray, 
	body: PackedByteArray
) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		current_code = json["code"]
		host_code_received.emit(json["code"])
		heartbeat_timer.start()
	else:
		_cleanup_network()
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
		var port = json["port"]
		var err = join_game(ip, port, target_scene_path)
		if err != OK:
			_cleanup_network()
			connection_failed.emit("ENet client error: %s" % error_string(err))
		return
	
	_cleanup_network()
	if response_code == 403:
		api_error.emit("Room is full.")
	elif response_code == 404:
		api_error.emit("Wrong code.")
	else:
		api_error.emit("Connection timed out.")

func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server() and is_game_started:
		rpc_load_game_scene.rpc_id(id, target_scene_path)
	player_connected.emit()

func _on_peer_disconnected(_id: int) -> void:
	if multiplayer.is_server() and not current_code.is_empty():
		update_http.request(RELAY_URL + "/leave/" + current_code, [], HTTPClient.METHOD_POST)
		player_disconnected.emit()

func _on_heartbeat_timer_timeout() -> void:
	if multiplayer.is_server() and not current_code.is_empty():
		heartbeat_http.request(RELAY_URL + "/heartbeat/" + current_code, [], HTTPClient.METHOD_POST)
