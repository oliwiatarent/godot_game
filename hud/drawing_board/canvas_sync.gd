extends Node

@onready var canvas: Canvas = get_parent()
var active_lines: Dictionary = {}


func start_line(pos: Vector2, color: Color, width: float):
	var my_id = multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else 1
	rpc("rpc_create_line", color, width, my_id)
	rpc("rpc_add_point", pos, multiplayer.get_unique_id())

func add_point(pos: Vector2):
	var my_id = multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else 1
	rpc("rpc_add_point", pos, my_id)

func request_clear():
	rpc("rpc_clear")

func request_undo():
	rpc("rpc_undo")


@rpc("any_peer", "call_local", "reliable")
func rpc_create_line(color: Color, width: float, sender_id: int):
	var l_name = "Line_%d_%d" % [sender_id, Time.get_ticks_msec()]
	var line = canvas.create_line(color, width, l_name)
	active_lines[sender_id] = line

@rpc("any_peer", "call_local", "unreliable_ordered")
func rpc_add_point(pos: Vector2, sender_id: int):
	if active_lines.has(sender_id) and is_instance_valid(active_lines[sender_id]):
		active_lines[sender_id].add_point(pos)

@rpc("any_peer", "call_local", "reliable")
func rpc_clear():
	canvas.clear()
	active_lines.clear()

@rpc("any_peer", "call_local", "reliable")
func rpc_undo():
	canvas.undo()
	for peer_id in active_lines.keys():
		if not is_instance_valid(active_lines[peer_id]):
			active_lines.erase(peer_id)
