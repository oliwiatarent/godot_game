extends Area2D
class_name ItemDropArea

@export_group('Dropped Item Properties')
@export var required_item_id: String

func receive_dropped_item(item_id: String) -> bool:
	if item_id == required_item_id:
		print("Sukces! Użyto właściwego przedmiotu: ", item_id)
		return true
	else:
		print("To nie pasuje do tego obiektu. Próbowano użyć: ", item_id)
		return false
