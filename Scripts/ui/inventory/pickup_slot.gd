extends InventorySlot
class_name PickupSlot

func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
	return false
