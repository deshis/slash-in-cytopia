extends InventorySlot

var handler = null

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	var origin_slot: InventorySlot = data
	var item = origin_slot.get_item()
	var item_count = handler.item_count()
	
	if item_count == 0:
		return true
	
	# backpack -> can replace
	# augment -> can replace if same augment type
	elif item_count == 1:
		if get_item():
			if type == ItemType.Type.NONE:
				if origin_slot.type == ItemType.Type.NONE or not get_item():
					return true
				elif get_item() and item.item.type == get_item().item.type:
					return true
				else:
					return false
			return item.get_type() == type
	
	return item.get_grade() == handler.grade


func _drop_data(pos: Vector2, data: Variant) -> void:
	handler.grade = data.get_item().get_grade()
	return super._drop_data(pos, data)
