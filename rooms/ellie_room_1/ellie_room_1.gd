extends BaseRoom

@onready var board_extended = $BoardExtended
@onready var board_sprite = $BoardExtended/Texture
@onready var background = $Background
@onready var riddle = $EllieCommunicationRiddle

const board_texture_without_pic = preload("res://assets/rooms/Ellie_room_1/pokoj_1_ellie_tablica_no_pic.png")
const background_texture_without_pic = preload("res://assets/rooms/Ellie_room_1/pokoj_ellie_bez_zdj.png")
const picture_texture = preload("res://assets/items/item_Ellie_zdjecie.png")

var picture_taken = false
var window_opened = false


func _ready() -> void:
	riddle.riddle_closed.connect(_on_close_riddle_button_pressed)


func _on_board_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
			
		window_opened = handle_window_operation(window_opened)
		board_extended.show()


func _on_board_close_button_pressed() -> void:
	board_extended.hide()
	window_opened = handle_window_operation(window_opened)


func _on_board_extended_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not picture_taken:
			var data = {"id": 'picture', "icon": picture_texture, "label": 'Picture', "multiuse": true}
			var equipment = get_tree().get_first_node_in_group("equipment")
			
			if equipment and equipment.has_method("add_item"):
				var success = equipment.add_item(data)
				if success:
					board_sprite.texture = board_texture_without_pic
					background.texture = background_texture_without_pic
					picture_taken = true


func _on_riddle_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if window_opened:
			return
		
		window_opened = handle_window_operation(window_opened)
		riddle.show()
		
		
func _on_close_riddle_button_pressed():
	window_opened = handle_window_operation(window_opened)
	riddle.hide()
