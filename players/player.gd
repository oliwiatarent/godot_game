extends CharacterBody2D

@export_group("Movement")
@export var speed = 400
# Wykrywanie zablokowania postaci
@export var max_stuck_frames = 1
@export var min_movement_threshold = 0.001

@export_group("Perspective (Scaling)")
@export var min_scale = 0.5
@export var max_scale = 1.5

@onready var navigation_agent = $NavigationAgent2D
var screen_height
var is_navigating_with_mouse = false
var is_walking_disabled = false
var last_position = Vector2.ZERO
var stuck_frame_count = 0

func _ready():
	var screen_size = get_viewport_rect().size
	screen_height = screen_size.y
	
	EventBus.disable_walking.connect(_on_disable_walking)
	EventBus.enable_walking.connect(_on_enable_walking)
	
	#navigation_agent.path_desired_distance = 4.0
	#navigation_agent.target_desired_distance = 30.0
	

func _physics_process(_delta):
	movement_handler()
	action_handler()
	

func movement_handler():
	if is_walking_disabled:
		if $Animation.is_playing():
			$Animation.stop()
		return
		
	var keyboard_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
			
	if Input.is_action_just_pressed("left_mouse_click"):
		var mouse_pos = get_global_mouse_position()
		
		var map = get_world_2d().navigation_map
		var closest_point = NavigationServer2D.map_get_closest_point(map, mouse_pos)
		
		navigation_agent.target_position = closest_point
		is_navigating_with_mouse = true
		stuck_frame_count = 0


	if keyboard_input != Vector2.ZERO:
		is_navigating_with_mouse = false
		velocity = keyboard_input * speed
	elif is_navigating_with_mouse:
		if navigation_agent.is_navigation_finished():
			is_navigating_with_mouse = false
			velocity = Vector2.ZERO
		else:
			var next_path_position = navigation_agent.get_next_path_position()
			velocity = global_position.direction_to(next_path_position) * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	update_perspective_scale()
	
	if is_navigating_with_mouse:
		var moved_distance = global_position.distance_to(last_position)
		
		if moved_distance < min_movement_threshold:
			stuck_frame_count += 1
			if stuck_frame_count == max_stuck_frames:
				is_navigating_with_mouse = false
				velocity = Vector2.ZERO
				stuck_frame_count = 0
		else:
			stuck_frame_count = 0
			
	last_position = global_position

	if velocity.length() > 0:
		$Animation.play()
		$Animation.flip_h = velocity.x < 0
	else:
		$Animation.stop()
	
	
func update_perspective_scale():
	var factor = remap(global_position.y, 0.0, screen_height, 0.0, 1.0)
	factor = clamp(factor, 0.0, 1.0)
	var current_scale = lerp(min_scale, max_scale, factor)
	scale = Vector2(current_scale, current_scale)
	
	
func action_handler():
	if Input.is_action_just_pressed("action"):
		print("Nacisnieto przycisk akcji")


func _on_disable_walking():
	if is_walking_disabled != true:
		is_walking_disabled = true


func _on_enable_walking():
	if is_walking_disabled != false:
		is_walking_disabled = false
