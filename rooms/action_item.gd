extends Area2D

@export_group('Action')
@export var riddle_file_name = ""

@export_group('Distance')
@export var open_distance: float = 100.0

var file_path

func _ready():
	file_path = "res://riddles/" + riddle_file_name + ".tscn"

func open_riddle():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance > open_distance:
			return

	if ResourceLoader.exists(file_path):
		var riddle_scene = load(file_path)
		var riddle_instance = riddle_scene.instantiate()
		EventBus.disable_walking.emit()
		get_tree().root.add_child(riddle_instance)
	else:
		print("Błąd: Nie znaleziono pliku zagadki pod ścieżką: ", file_path)
