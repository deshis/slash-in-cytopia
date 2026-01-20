extends InventorySlot

func set_item(item: Control) -> void:
	item.queue_free()
