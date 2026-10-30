extends CanvasLayer

# Prefixes:
# seq - Small Equipment
# leq - Large Equipment

@export_group('Equipment Properties')
@export var slot_scene: PackedScene
@export var leq_number_of_slots = 10

@onready var seq_slots_container = $EquipmentSmallMargin/EquipmentSmall/SmallSlotsContainer
@onready var leq_slots_container = $EquipmentLargeMargin/EquipmentLarge/LargeSlotsContainer
@onready var leq_grid = $EquipmentLargeMargin/EquipmentLarge/LargeSlotsContainer
@onready var large_equipment = $EquipmentLargeMargin
@onready var following_icon: TextureRect = $FollowingIcon

var is_equipment_open = false
var active_slot_index = 1
var number_of_slots

var selected_item: Dictionary = {}
var selected_slot = null


func _ready():
	for i in range(leq_number_of_slots):
		add_new_slot()
		
	for slot in seq_slots_container.get_children():
		connect_slot_signals(slot)
		
	#update_equipment_visuals()
	number_of_slots = len(seq_slots_container.get_children())
	

func _process(_delta):
	#change_slot()
	
	if not selected_item.is_empty():
		var mouse_pos = get_viewport().get_mouse_position()
		following_icon.global_position = mouse_pos + Vector2(-16, -45)
	
	
func add_new_slot(item_data = null):
	var new_slot = slot_scene.instantiate()
	connect_slot_signals(new_slot)
	leq_grid.add_child(new_slot)
	
	if item_data:
		new_slot.set_item(item_data)


func connect_slot_signals(slot):
	slot.slot_clicked.connect(_on_slot_clicked)
	slot.dragging_started.connect(_on_dragging_started)
	slot.dragging_ended.connect(_on_dragging_ended)
	slot.item_dropped_outside.connect(_on_item_dropped_outside)


func reset_cursor():
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	
func update_equipment_visuals():
	var slots = seq_slots_container.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		if i + 1 == active_slot_index:
			slot.modulate = Color(1.3, 1.3, 1.3, 1.0)
		else:
			slot.modulate = Color(0.5, 0.5, 0.5, 0.8)


func open_equipment():
	if !is_equipment_open:
		large_equipment.show()
		is_equipment_open = true
	else:
		large_equipment.hide()
		is_equipment_open = false
	
	
func add_item(item_data):
	var slots = seq_slots_container.get_children()
	for slot in slots:
		if slot.item_data.is_empty():
			slot.set_item(item_data)
			return true
			
	slots = leq_slots_container.get_children()
	for slot in slots:
		if slot.item_data.is_empty():
			slot.set_item(item_data)
			return true
			
	add_new_slot(item_data)
	return true
	
	
func setup_following_icon(texture):
	following_icon.texture = texture
	following_icon.show()
	
	
func clear_active_item():
	if selected_slot != null:
		selected_slot = null
		
	selected_item = {}
	following_icon.texture = null
	following_icon.hide()
	

func find_slot_from_control(control):
	var current = control
	while current != null:
		if current is InventorySlot:
			return current as InventorySlot
		current = current.get_parent() as Control
	return null
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("equipment_action"):
		open_equipment()
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if not selected_item.is_empty():
			clear_active_item()
			get_viewport().set_input_as_handled()
			
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not selected_item.is_empty():
			var hovered_control = get_viewport().gui_get_hovered_control()
			
			var target_slot = find_slot_from_control(hovered_control)
			
			if target_slot != null:
				if target_slot != selected_slot:
					var temp_data = target_slot.item_data
					target_slot.set_item(selected_slot.item_data)
					selected_slot.set_item(temp_data)
				
				clear_active_item()
				get_viewport().set_input_as_handled()
			else:
				handle_item_usage()
				get_viewport().set_input_as_handled()


func _on_slot_clicked(slot):
	selected_item = slot.item_data
	selected_slot = slot

	if is_equipment_open:
		open_equipment()

	if selected_item.has("icon") and selected_item["icon"] is Texture2D:
		setup_following_icon(selected_item["icon"])


func change_slot():
	for i in range(1, number_of_slots + 1):
		if Input.is_action_just_pressed("slot_" + str(i)):
			active_slot_index = i
			update_equipment_visuals()
			
	if Input.is_action_just_pressed("next_item"):
		active_slot_index = clamp(active_slot_index + 1, 1, number_of_slots)
		update_equipment_visuals()
		
	if Input.is_action_just_pressed("prev_item"):
		active_slot_index = clamp(active_slot_index - 1, 1, number_of_slots)
		update_equipment_visuals()
	
	
func _on_dragging_started(slot_data):
	selected_slot = slot_data['origin_slot']
	selected_item = slot_data['item_data']
	setup_following_icon(slot_data['item_data']['icon'])
	
	
func _on_dragging_ended():
	clear_active_item()
	
	
func _on_item_dropped_outside():
	handle_item_usage()
	clear_active_item()
	
	
func handle_item_usage():
	var usage_info = try_use_item()
	var item_used = usage_info[0]
	var multiuse = usage_info[1]
	
	if item_used:
		if selected_slot:
			if not multiuse:
				selected_slot.clear_slot()
			clear_active_item()


func try_use_item():
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	
	var space_state = viewport.get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = mouse_pos
	parameters.collide_with_areas = true
	parameters.collide_with_bodies = false
	
	var results = space_state.intersect_point(parameters)
	
	for result in results:
		var collider = result["collider"]
		
		if collider is ItemDropArea:
			var item_id = selected_item.get("id", "")
			var multiuse = selected_item.get("multiuse", "")

			if collider.receive_dropped_item(item_id):
				if multiuse:
					return [true, true]
				else:
					return [true, false]
				
	return [false, false]
