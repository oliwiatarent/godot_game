extends Control

@onready var radar_stripe: TextureRect = $RadarStripe
@onready var radar_dot: TextureRect = $RadarDot

var dot_angle: float = 0.0
var fade_speed: float = 1.5

func _ready() -> void:
	radar_stripe.pivot_offset = Vector2(0, radar_stripe.size.y)
	
	var stripe_center = radar_stripe.global_position + radar_stripe.pivot_offset
	var dot_center = radar_dot.global_position + (radar_dot.size / 2.0)
	dot_angle = rad_to_deg((dot_center - stripe_center).angle())
	
	radar_dot.modulate.a = 0.0


func _process(delta: float) -> void:
	radar_stripe.rotation_degrees += 90.0 * delta
	
	var current = wrapf(radar_stripe.rotation_degrees - 45.0, 0.0, 360.0)
	var target = wrapf(dot_angle, 0.0, 360.0)
	
	var diff = wrapf(current - target, -180.0, 180.0)
	
	if diff >= -5.0 and diff <= 50.0:
		radar_dot.modulate.a = 1.0
	else:
		radar_dot.modulate.a = move_toward(radar_dot.modulate.a, 0.0, delta * fade_speed)
