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
var first_button_pressed = false


func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	EventBus.communication_riddle.connect(_on_message_received)

	dot_angle = calculate_radar_properties(radar_stripe, radar_dot, 0)
	
	start_flashing()


func _process(delta: float) -> void:
	change_radar_objects(radar_stripe, radar_dot, dot_angle, delta, fade_speed, -5.0, 50.0)
	
	waiting_log(delta, 'Waiting for the response...')
	
	
func start_flashing() -> void:
	flash_tween = create_tween().set_loops()
	flash_tween.tween_property(button_gradient, "modulate:a", 0.3, 0.6).from(1.0)
	flash_tween.tween_property(button_gradient, "modulate:a", 1.0, 0.6)


func _on_button_on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		button_off.show()
		button_gradient.hide()
		button_on.hide()
		
		if not first_button_pressed:
			display_on.show()
			display_long_on.show()
			display_off.hide()
			display_long_off.hide()
			
			MultiplayerManager.send_message("CommunicationRiddle;sam_button_pressed")
			append_log('Sent distress call')
			waiting_for_response = true
			first_button_pressed = true
		else:
			append_log('Response sent')
			MultiplayerManager.send_message("CommunicationRiddle;sam_second_button_pressed")
		
		

func _on_message_received(message: String):
	if message == 'ellie_responded':
		waiting_for_response = false
		
		append_log('Connecting...')
		await get_tree().create_timer(4).timeout
		append_log('[color=red]ERROR[/color]')
		append_log('Communication system failure')
		append_log('Connect to the sound system?')
		
		button_on.show()
		button_gradient.show()
		button_off.hide()
		
	if message == 'ellie_connection_established':
		EventBus.enable_objects.emit()
