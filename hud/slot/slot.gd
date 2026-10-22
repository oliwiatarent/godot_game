extends PanelContainer
class_name InventorySlot

@onready var icon_node: TextureRect = $ItemIcon

var item_data: Dictionary = {}
var is_dragging = false
var is_being_dragged = false

signal slot_clicked(slot)
signal dragging_started(item_data)
signal dragging_ended()
signal item_dropped_outside()


func _process(_delta):
	#change_slot()
	pass


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
	
	
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = false 
			else:
				if not is_dragging and not item_data.is_empty():
					slot_clicked.emit(self)
				is_dragging = false
	
	
func _get_drag_data(_at_position: Vector2):
	if item_data.is_empty() or icon_node.texture == null:
		return null
		
	is_dragging = true
	
	var drag_data = {
		"origin_slot": self,
		"item_data": item_data
	}
	
	if item_data.has("icon") and item_data["icon"] is Texture2D:
		dragging_started.emit(drag_data)
	
	return drag_data
	
	
func _can_drop_data(_at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("origin_slot")


func _drop_data(_at_position, data):
	var origin_slot = data["origin_slot"] as InventorySlot
	if origin_slot == self:
		dragging_ended.emit()
		return
		
	var temp_data = item_data
	self.set_item(origin_slot.item_data)
	origin_slot.set_item(temp_data)
	
	dragging_ended.emit()
	
	
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if is_dragging:
			is_dragging = false
			
			if not get_viewport().gui_is_drag_successful():
				_on_item_dropped_outside()
				
				
func _on_item_dropped_outside():
	item_dropped_outside.emit()
	
