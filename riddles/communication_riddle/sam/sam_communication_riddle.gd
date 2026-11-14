extends BaseCommunicationRiddle

@onready var radar_stripe: TextureRect = $RadarStripe
@onready var radar_dot: TextureRect = $RadarDot
@onready var close_button: TextureButton = $CloseButton
@onready var button_on = $ButtonOn
@onready var button_off = $ButtonOff
@onready var button_gradient = $Gradient
@onready var display_off = $DisplayOff
@onready var display_on = $DisplayOn
@onready var display_long_off = $DisplayLongOff
@onready var display_long_on = $DisplayLongOn


var display_on_texture = preload("res://assets/rooms/Sam_room_1/radar_panel/ekran_on.png")
var display_long_texture = preload("res://assets/rooms/Sam_room_1/radar_panel/dlugi_ekran_Sam.png")

var dot_angle: float = 0.0
var fade_speed: float = 1.5
var flash_tween

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	dot_angle = calculate_radar_properties(radar_stripe, radar_dot, 0)
	
	start_flashing()


func _process(delta: float) -> void:
	change_radar_objects(radar_stripe, radar_dot, dot_angle, delta, fade_speed, -5.0, 50.0)
	
	
func start_flashing() -> void:
	flash_tween = create_tween().set_loops()
	flash_tween.tween_property(button_gradient, "modulate:a", 0.3, 0.6).from(1.0)
	flash_tween.tween_property(button_gradient, "modulate:a", 1.0, 0.6)


func _on_button_on_input_event(_viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		button_off.show()
		button_gradient.hide()
		button_on.hide()
		display_on.show()
		display_long_on.show()
		display_off.hide()
		display_long_off.hide()
