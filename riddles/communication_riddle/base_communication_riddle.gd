extends CanvasLayer
class_name BaseCommunicationRiddle

@onready var prompts = $ScrollContainer/Prompts
@onready var scroll_container = $ScrollContainer

var waiting_for_response = false
var time_elapsed = 0.0

const SAM = 1

signal riddle_closed


func waiting_log(delta, message):
	if waiting_for_response:
		time_elapsed += delta

		if time_elapsed >= 2.0:
			time_elapsed = 0.0
			append_log(message)
	else:
		time_elapsed = 0.0


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
		
		
func append_log(new_message: String) -> void:
	if multiplayer.get_unique_id() == SAM:
		prompts.text += "[bgcolor=#19601a] > " + new_message + "[/bgcolor]\n"
	else:
		prompts.text += '> ' + new_message + '\n'
		
	await get_tree().process_frame
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
		
		
func _on_close_button_pressed() -> void:
	riddle_closed.emit()
	
