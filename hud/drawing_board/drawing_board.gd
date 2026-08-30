extends Control

@export var animation_duration: float = 0.3

@onready var panel_container: Control = $OuterMarginContainer/PanelContainer
@onready var toggle_button: Button = $ToggleBoardButton
@onready var canvas_toolbar: Control = %CanvasToolbar

var is_open: bool = true
var tween: Tween
var visible_y: float
var hidden_y: float

func _ready() -> void:
	var my_id = multiplayer.get_unique_id()
	if my_id != 1:
		for child in canvas_toolbar.get_children():
			child.visible = false
		
	visible_y = panel_container.position.y
	hidden_y = get_viewport_rect().size.y
	

func _on_canvas_undo_button_pressed() -> void:
	%CanvasSync.request_undo()

func _on_canvas_clear_button_pressed() -> void:
	%CanvasSync.request_clear()

func _on_toggle_board_button_pressed() -> void:
	is_open = !is_open

	if tween:
		tween.kill()

	var target_y = visible_y if is_open else hidden_y

	var total_distance = abs(hidden_y - visible_y)
	var current_distance = abs(panel_container.position.y - target_y)
	
	var dynamic_duration = animation_duration * (current_distance / total_distance)

	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_container, "position:y", target_y, dynamic_duration)
