extends InventorySlot
class_name AugmentSlot

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not (data is InventorySlot):
		return false
	
	var origin_slot: InventorySlot = data
	var item = origin_slot.get_item()
	
	return item.get_type() == type
