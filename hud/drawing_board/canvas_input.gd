extends Node

@onready var canvas: Canvas = get_parent()
@onready var net_sync = $"../CanvasSync"

var is_drawing: bool = false
var last_pos: Vector2

var drawer_peer_id: int = 1 # tylko host może rysować

func _ready():
	canvas.gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):	
	var is_network_active = multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
	if is_network_active and multiplayer.get_unique_id() != drawer_peer_id:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_drawing = true
			last_pos = event.position.clamp(Vector2.ZERO, canvas.size)
			
			net_sync.start_line(last_pos, canvas.line_color, canvas.line_width)
		else:
			is_drawing = false

	elif event is InputEventMouseMotion and is_drawing:
		var current_pos = event.position.clamp(Vector2.ZERO, canvas.size)
		if current_pos != last_pos:
			net_sync.add_point(current_pos)
			last_pos = current_pos
