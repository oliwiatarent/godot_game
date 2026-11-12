extends Node

@onready var board_extended = $BoardExtended
@onready var board_sprite = $BoardExtended/Texture

const board_texture_without_pic = preload("res://assets/rooms/Ellie_room_1/pokoj_1_ellie_tablica_no_pic.png")
const picture_texture = preload("res://assets/items/item_Ellie_zdjecie.png")

var picture_taken = false

func _on_board_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		EventBus.disable_walking.emit()
		board_extended.show()


func _on_board_close_button_pressed() -> void:
	EventBus.enable_walking.emit()
	board_extended.hide()


func _on_board_extended_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not picture_taken:
			var data = {"id": 'picture', "icon": picture_texture, "label": 'Picture', "multiuse": true}
			var equipment = get_tree().get_first_node_in_group("equipment")
			
			if equipment and equipment.has_method("add_item"):
				var success = equipment.add_item(data)
				if success:
					board_sprite.texture = board_texture_without_pic
					picture_taken = true
