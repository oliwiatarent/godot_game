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

var is_equipment_open = false
var active_slot_index = 1
var number_of_slots

func _ready():
	for i in range(leq_number_of_slots):
		var new_slot = slot_scene.instantiate()
		leq_grid.add_child(new_slot)
	
	update_equipment_visuals()
	number_of_slots = len(seq_slots_container.get_children())
	

func _process(_delta):
	change_slot()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equipment_action"):
		open_equipment()
	
	if event.is_action_pressed("use_item"):
		use_item()
		
		
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
			#print("Dodano przedmiot do SEQ: ", item_data.get("id"))
			return true
			
	slots = leq_slots_container.get_children()
	for slot in slots:
		if slot.item_data.is_empty():
			slot.set_item(item_data)
			#print("Dodano przedmiot do LEQ: ", item_data.get("id"))
			return true
			
	var new_slot = slot_scene.instantiate()
	leq_grid.add_child(new_slot)
	new_slot.set_item(item_data)
	#print("Dodano przedmiot do nowego slotu LEQ: ", item_data.get("id"))
	return true
	

func use_item():
	var active_slot = seq_slots_container.get_children()[active_slot_index - 1]
	print("Uzyto przedmiot: " + active_slot.item_data["id"])
	active_slot.clear_slot()
