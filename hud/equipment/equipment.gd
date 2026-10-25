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
@onready var icon_button: TextureButton = $EquipmentIcon

var is_equipment_open = false
var active_slot_index = 1
var number_of_slots
var is_animating = false

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
	
	var i = 0
	for slot in slots:
		i += 1
		if slot.item_data.is_empty():
			slot.set_item(item_data)
			
			animate_equipment_icon()
			
			# Dodatkowy rzad slotow, jesli wszystkie zapelnimy
			if i == leq_number_of_slots:
				for j in range(len(seq_slots_container.get_children())):
					add_new_slot()
			
			return true
			
	animate_equipment_icon()
	
	# Dodatkowy rzad slotow, jesli wszystkie zapelnimy
	var leq_len = len(leq_slots_container.get_children())
	var seq_len = len(seq_slots_container.get_children())
	
	if leq_len > leq_number_of_slots and leq_len % seq_len == 0:
		for j in range(seq_len):	
			add_new_slot()
		
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
		
		
func animate_equipment_icon():
	if not is_equipment_open:
		if icon_button == null or not is_instance_valid(icon_button) or is_animating:
			return
			
		is_animating = true
		
		var original_y = icon_button.position.y
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property(icon_button, "position:y", original_y - 15, 0.12)
		
		await tween.finished
		
		var tween_fall = create_tween().set_parallel(true)
		tween_fall.tween_property(icon_button, "position:y", original_y, 0.12)
		
		await tween_fall.finished
		
		is_animating = false
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("equipment_action"):
		open_equipment()
	
	#if event.is_action_pressed("use_item"):
		#use_item()
		
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
					
					if temp_data.is_empty():
						selected_slot.clear_slot()
					else:
						selected_slot.set_item(temp_data)
				
				clear_active_item()
				get_viewport().set_input_as_handled()
			else:
				if selected_slot:
					selected_slot.clear_slot()
				
				# TODO: Logika sprawdzenia gdzie kliknęlismy
				
				clear_active_item()
				get_viewport().set_input_as_handled()


func _on_slot_clicked(slot):
	selected_item = slot.item_data
	selected_slot = slot

	if is_equipment_open:
		open_equipment()

	if selected_item.has("icon") and selected_item["icon"] is Texture2D:
		setup_following_icon(selected_item["icon"])
	
	
func _on_dragging_started(item_data):
	selected_item = item_data
	setup_following_icon(item_data["icon"])
	
	
func _on_dragging_ended():
	clear_active_item()


#func use_item():
	#var active_slot = seq_slots_container.get_children()[active_slot_index - 1]
	#
	#if active_slot.item_data.is_empty():
		#return
		#
	#print("Uzyto przedmiot: " + active_slot.item_data["id"])
	#active_slot.clear_slot()


func _on_equipment_icon_pressed() -> void:
	open_equipment()
