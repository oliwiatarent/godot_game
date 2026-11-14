extends BaseCommunicationRiddle

@onready var radar_stripe: TextureRect = $RadarStripe
@onready var radar_dot: TextureRect = $RadarDot
@onready var close_button: TextureButton = $CloseButton

var dot_angle: float = 0.0
var fade_speed: float = 1.5

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	dot_angle = calculate_radar_properties(radar_stripe, radar_dot, 5)


func _process(delta: float) -> void:
	change_radar_objects(radar_stripe, radar_dot, dot_angle, delta, fade_speed, 15.0, 50.0)
	
