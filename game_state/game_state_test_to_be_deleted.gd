extends Control

func _on_load_pressed() -> void:
	GameState.load_game()
	get_tree().change_scene_to_file(GameState.save_data.current_scene_path)
	print(GameState.save_data.puzzle_flags.get("test"))

func _on_save_pressed() -> void:
	GameState.save_data.current_scene_path = get_tree().current_scene.scene_file_path
	GameState.save_data.puzzle_flags["test"] = true
	GameState.save_game()
	print("saved")
