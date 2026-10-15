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
		slot.slot_clicked.connect(_on_slot_clicked)
		
	#update_equipment_visuals()
	number_of_slots = len(seq_slots_container.get_children())
	

func _process(_delta):
	#change_slot()
	
	if not selected_item.is_empty():
		var mouse_pos = get_viewport().get_mouse_position()
		following_icon.global_position = mouse_pos + Vector2(-16, -45)
	
	
func reset_cursor():
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equipment_action"):
		open_equipment()
	
	#if event.is_action_pressed("use_item"):
		#use_item()
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if not selected_item.is_empty():
			selected_item = {}
			selected_slot = null
			following_icon.texture = null
			following_icon.hide()
			
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not selected_item.is_empty():
			# TODO: Logika sprawdzania co jest pod kursorem
			
			if selected_slot:
				selected_slot.clear_slot()
			
			selected_item = {}
			selected_slot = null
			following_icon.texture = null
			following_icon.hide()


func _on_slot_clicked(slot):
	selected_item = slot.item_data
	selected_slot = slot

	if is_equipment_open:
		open_equipment()

	if selected_item.has("icon") and selected_item["icon"] is Texture2D:
		following_icon.texture = selected_item["icon"]
		following_icon.show()


func add_new_slot(item_data = null):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_clicked.connect(_on_slot_clicked)
	leq_grid.add_child(new_slot)
	
	if item_data:
		new_slot.set_item(item_data)


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


#func use_item():
	#var active_slot = seq_slots_container.get_children()[active_slot_index - 1]
	#
	#if active_slot.item_data.is_empty():
		#return
		#
	#print("Uzyto przedmiot: " + active_slot.item_data["id"])
	#active_slot.clear_slot()
