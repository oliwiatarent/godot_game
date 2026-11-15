extends BaseCommunicationRiddle

@onready var radar_stripe: TextureRect = $RadarStripe
@onready var radar_dot: TextureRect = $RadarDot
@onready var close_button: TextureButton = $CloseButton

var dot_angle: float = 0.0
var fade_speed: float = 1.5
var sam_waiting_for_response = false

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	dot_angle = calculate_radar_properties(radar_stripe, radar_dot, 5)
	EventBus.communication_riddle.connect(_on_message_received)


func _process(delta: float) -> void:
	change_radar_objects(radar_stripe, radar_dot, dot_angle, delta, fade_speed, 15.0, 50.0)
	
	waiting_log(delta, 'Establishing connection...')
	
	
func _unhandled_input(event: InputEvent) -> void:
	if not sam_waiting_for_response:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Y:
			sam_waiting_for_response = false
			append_log('Y')
			waiting_for_response = true
			MultiplayerManager.send_message('CommunicationRiddle;ellie_responded')
	
	
func _on_message_received(message: String):
	if message == 'sam_button_pressed':
		append_log('Attempt to establish communication [Y]')
		sam_waiting_for_response = true
		
	if message == 'sam_second_button_pressed':
		append_log('Voice transmission established')
		waiting_for_response = false
		EventBus.enable_objects.emit()
		MultiplayerManager.send_message('CommunicationRiddle;ellie_connection_established')
