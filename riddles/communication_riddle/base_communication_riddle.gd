extends CanvasLayer
class_name BaseCommunicationRiddle

signal riddle_closed

func calculate_radar_properties(radar_stripe, radar_dot, pivot_offset_x):
	radar_stripe.pivot_offset = Vector2(pivot_offset_x, radar_stripe.size.y)
	
	var stripe_center = radar_stripe.global_position + radar_stripe.pivot_offset
	var dot_center = radar_dot.global_position + (radar_dot.size / 2.0)
	
	radar_dot.modulate.a = 0.0
	
	return rad_to_deg((dot_center - stripe_center).angle())


func change_radar_objects(radar_stripe, radar_dot, dot_angle, delta, fade_speed, diff_1, diff_2):
	radar_stripe.rotation_degrees += 90.0 * delta
	
	var current = wrapf(radar_stripe.rotation_degrees - 45.0, 0.0, 360.0)
	var target = wrapf(dot_angle, 0.0, 360.0)
	
	var diff = wrapf(current - target, -180.0, 180.0)
	
	if diff >= diff_1 and diff <= diff_2:
		radar_dot.modulate.a = 1.0
	else:
		radar_dot.modulate.a = move_toward(radar_dot.modulate.a, 0.0, delta * fade_speed)
		
		
func _on_close_button_pressed() -> void:
	riddle_closed.emit()
	
