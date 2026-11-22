extends Control

@export var animation_duration: float = 0.3
@export var board_peek_height: float = 122.0
@export var is_open: bool = false

@onready var board_body: Control = %BoardBody
@onready var panel_container: Control = %PanelContainer
@onready var canvas_toolbar: Control = %CanvasToolbar

var tween: Tween
var visible_y: float
var hidden_y: float

func _ready() -> void:
	panel_container.visible = false
	
	var my_id = multiplayer.get_unique_id()
	if my_id != 1:
		for child in canvas_toolbar.get_children():
			if child.name == "CloseBoardButton":
				continue
			child.visible = false
	
	visible_y = get_viewport_rect().size.y * 0.35
	hidden_y = get_viewport_rect().size.y - board_peek_height
	board_body.position.y = visible_y if is_open else hidden_y
	
	panel_container.gui_input.connect(_on_panel_container_gui_input)
	EventBus.enable_communication.connect(_on_communication_established)

func set_board_open(open_state: bool) -> void:
	if is_open == open_state:
		return
	is_open = open_state
	
	if tween and tween.is_valid():
		tween.kill()
	
	var target_y = visible_y if is_open else hidden_y
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(board_body, "position:y", target_y, animation_duration)

func _on_panel_container_gui_input(event: InputEvent) -> void:
	if not is_open and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			set_board_open(true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			set_board_open(not is_open)
			get_viewport().set_input_as_handled()

func _on_communication_established():
	panel_container.visible = true
	pass

func _on_canvas_undo_button_pressed() -> void:
	%CanvasSync.request_undo()

func _on_canvas_clear_button_pressed() -> void:
	%CanvasSync.request_clear()

func _on_close_board_button_pressed() -> void:
	set_board_open(false)
