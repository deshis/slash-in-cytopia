extends InventorySlot
class_name BackpackSlot


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	var origin_slot: InventorySlot = data
	var item = origin_slot.get_item()
	
	if origin_slot.slot_type == SLOT.AUGMENT:
		if get_item():
			return get_item().item.type == item.item.type
	
	return true
