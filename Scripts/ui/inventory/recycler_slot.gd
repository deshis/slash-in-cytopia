extends InventorySlot
class_name RecyclerSlot

var handler = null

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	var origin_slot: InventorySlot = data
	var item = origin_slot.get_item()
	
	if get_item():
		# backpack -> can replace
		if origin_slot.slot_type == SLOT.BACKPACK:
			return true
		
		# augment -> can replace if same type
		elif origin_slot.slot_type == SLOT.AUGMENT:
			if item.item.type != get_item().item.type:
				return false
	
	return true
