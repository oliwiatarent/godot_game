extends PanelContainer
class_name InventorySlot

@onready var icon_node: TextureRect = $ItemIcon

var item_data: Dictionary = {}

func _get_drag_data(_at_position: Vector2):
	if item_data.is_empty() or icon_node.texture == null:
		return null
	
	var drag_data = {
		"origin_slot": self,
		"item_data": item_data
	}
	
	var preview_rect = TextureRect.new()
	preview_rect.texture = icon_node.texture
	preview_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_rect.custom_minimum_size = Vector2(40, 40)
	
	var preview = Control.new()
	preview.add_child(preview_rect)
	preview_rect.position = -preview_rect.custom_minimum_size / 2
	
	set_drag_preview(preview)
	return drag_data
	

func _can_drop_data(_at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("origin_slot")


func _drop_data(_at_position, data):
	var origin_slot = data["origin_slot"] as InventorySlot
	if origin_slot == self:
		return
		
	var temp_data = item_data
	self.set_item(origin_slot.item_data)
	origin_slot.set_item(temp_data)
	

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
