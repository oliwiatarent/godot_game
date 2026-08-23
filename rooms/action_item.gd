extends Area2D

@export_group('Action')
@export var riddle_file_name = ""

var file_path

func _ready():
	file_path = "res://riddles/" + riddle_file_name + ".tscn"
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		open_riddle()

func open_riddle():
		if ResourceLoader.exists(file_path):
			var riddle_scene = load(file_path)
			var riddle_instance = riddle_scene.instantiate()
			get_tree().root.add_child(riddle_instance)
		else:
			print("Błąd: Nie znaleziono pliku zagadki pod ścieżką: ", file_path)
