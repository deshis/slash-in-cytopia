extends InventorySlot
class_name CombinerSlot

var handler = null

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	var origin_slot: InventorySlot = data
	var item = origin_slot.get_item()
	var item_count = handler.item_count
	
	if item_count == 0:
		return true
	
	elif item_count == 1:
		if get_item():
			# backpack -> can replace
			if origin_slot.slot_type == SLOT.BACKPACK:
				return true
			
			# augment -> can replace if same type
			elif origin_slot.slot_type == SLOT.AUGMENT:
				if item.item.type == get_item().item.type:
					return true
				else:
					return false
	
	return item.get_grade() == handler.grade


func _drop_data(pos: Vector2, data: Variant) -> void:
	super._drop_data(pos, data)
	handler.update_state()
