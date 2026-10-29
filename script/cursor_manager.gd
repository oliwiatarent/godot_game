extends Node

@onready var arrow_img = preload("res://assets/cursors/cursor_idle.png")
@onready var hand_img = preload("res://assets/cursors/cursor_interact.png")
@onready var hand_clicked_img = preload("res://assets/cursors/cursor_interact_click.png")

func _ready() -> void:
	arrow_img = arrow_img.get_image()
	arrow_img.resize(32, 32, Image.INTERPOLATE_LANCZOS)
	
	hand_img = hand_img.get_image()
	hand_img.resize(40, 40, Image.INTERPOLATE_LANCZOS)
	
	hand_clicked_img = hand_clicked_img.get_image()
	hand_clicked_img.resize(50, 50, Image.INTERPOLATE_LANCZOS)
	
	Input.set_custom_mouse_cursor(arrow_img, Input.CURSOR_ARROW, Vector2(0, 0))
	Input.set_custom_mouse_cursor(hand_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))


func set_clicked_cursor():
	Input.set_custom_mouse_cursor(hand_clicked_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
	
func unset_clicked_cursor():
	await get_tree().create_timer(0.1).timeout
	Input.set_custom_mouse_cursor(hand_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
