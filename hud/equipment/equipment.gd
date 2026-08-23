extends MarginContainer

@onready var slots_container: HBoxContainer = $EquipmentSmall/SlotsContainer

var active_slot_index = 1
var number_of_slots

func _ready():
	update_equipment_visuals()
	number_of_slots = len(slots_container.get_children())
	

func _process(_delta):
	handle_change_slot()
	handle_open_equipment()
	

func handle_change_slot():
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
	var slots = slots_container.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		if i + 1 == active_slot_index:
			slot.modulate = Color(1.3, 1.3, 1.3, 1.0)
		else:
			slot.modulate = Color(0.5, 0.5, 0.5, 0.8)


func handle_open_equipment():
	pass
	
	
func add_item(item_data):
	var slots = slots_container.get_children()
	
	for slot in slots:
		var icon_node = slot.get_node_or_null("ItemIcon") as TextureRect
		
		if icon_node and icon_node.texture == null:
			icon_node.texture = item_data["icon"]
			print("Dodano przedmiot: ", item_data["id"])
			return true
			
	print("Ekwipunek jest pełny!")
	return false
