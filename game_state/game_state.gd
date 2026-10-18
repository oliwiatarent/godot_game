extends Node

signal game_loaded
signal state_updated

const SAVE_LOCATION = "user://saved.tres"

var save_data: GameStateData = GameStateData.new()

func save_game():
	ResourceSaver.save(save_data, SAVE_LOCATION)

func load_game():
	if not FileAccess.file_exists(SAVE_LOCATION):
		return
	save_data = ResourceLoader.load(SAVE_LOCATION).duplicate(true)

func set_puzzle_flag(flag_name: String, value: Variant) -> void:
	save_data.puzzle_flags[flag_name] = value

func get_puzzle_flag(flag_name: String) -> Variant:
	return save_data.puzzle_flags.get(flag_name)

func add_item(item_id: String) -> void:
	if not save_data.inventory.has(item_id):
		save_data.inventory.append(item_id)

func remove_item(item_id: String) -> void:
	if save_data.inventory.has(item_id):
		save_data.inventory.erase(item_id)
