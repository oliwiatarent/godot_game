extends Node

@onready var arrow_img = preload("res://assets/cursors/cursor_idle.png")
@onready var hand_img = preload("res://assets/cursors/cursor_interact.png")
@onready var hand_clicked_img = preload("res://assets/cursors/cursor_interact_click.png")

var is_hand_active: bool = false
var is_mouse_button_pressed: bool = false


func _ready() -> void:
	arrow_img = arrow_img.get_image()
	arrow_img.resize(32, 32, Image.INTERPOLATE_LANCZOS)
	
	hand_img = hand_img.get_image()
	hand_img.resize(40, 40, Image.INTERPOLATE_LANCZOS)
	
	hand_clicked_img = hand_clicked_img.get_image()
	hand_clicked_img.resize(50, 50, Image.INTERPOLATE_LANCZOS)
	
	Input.set_custom_mouse_cursor(arrow_img, Input.CURSOR_ARROW, Vector2(0, 0))
	Input.set_custom_mouse_cursor(hand_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
	
	change_default_cursor(get_tree().root)
	get_tree().node_added.connect(_on_node_added)


func _process(_delta: float) -> void:
	check_intersection()


func check_intersection() -> bool:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var found_interactable = false
	
	var hovered_control = viewport.gui_get_hovered_control()
	if hovered_control:
		var parent = hovered_control
		while parent:
			if parent is BaseButton or parent.is_in_group("interactive"):
				found_interactable = true
				break
			parent = parent.get_parent()
	
	if not found_interactable:
		var canvas_transform = viewport.get_canvas_transform()
		var world_mouse_pos = canvas_transform.affine_inverse() * mouse_pos
		
		var space_state = viewport.get_world_2d().direct_space_state
		var parameters = PhysicsPointQueryParameters2D.new()
		parameters.position = world_mouse_pos
		parameters.collide_with_areas = true
		parameters.collide_with_bodies = false
		
		var results = space_state.intersect_point(parameters)
		
		for result in results:
			var collider = result["collider"]
			if collider is PickableItem or \
				collider is ActionItem or \
				collider is InventorySlot or \
				collider.is_in_group("interactive"):
					
				found_interactable = true
				break
				
	if found_interactable != is_hand_active:
		is_hand_active = found_interactable
		
		if not is_mouse_button_pressed:
			if is_hand_active:
				Input.set_custom_mouse_cursor(hand_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			else:
				Input.set_custom_mouse_cursor(arrow_img, Input.CURSOR_ARROW, Vector2(0, 0))
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				
	return found_interactable


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_mouse_button_pressed = event.pressed
		
		if is_mouse_button_pressed:
			if is_hand_active:
				Input.set_custom_mouse_cursor(hand_clicked_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
		else:
			if is_hand_active:
				Input.set_custom_mouse_cursor(hand_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
			_reset_cursor_delayed()


func _reset_cursor_delayed() -> void:
	await get_tree().create_timer(0.08).timeout
	
	if is_mouse_button_pressed:
		return
	
	if check_intersection():
		Input.set_custom_mouse_cursor(hand_img, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_custom_mouse_cursor(arrow_img, Input.CURSOR_ARROW, Vector2(0, 0))
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		
		
func change_default_cursor(node: Node) -> void:
	if node is BaseButton:
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for child in node.get_children():
		change_default_cursor(child)
		
		
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
