extends PanelContainer
class_name InventorySlot

@onready var icon_node: TextureRect = $ItemIcon

var item_data: Dictionary = {}

signal slot_clicked(slot)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not item_data.is_empty():
				slot_clicked.emit(self)


func set_item(data):
	item_data = data
	if icon_node:
		if item_data.has("icon") and item_data["icon"] != null:
			icon_node.texture = item_data["icon"]
		else:
			icon_node.texture = null


func clear_slot():
	item_data = {}
	if icon_node:
		icon_node.texture = null


func get_item_id():
	return item_data.get("id", "")
