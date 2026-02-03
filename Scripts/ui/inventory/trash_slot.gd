extends InventorySlot

@onready var icon: AnimatedSprite2D = $Sprite2D


func set_item(item: Control) -> void:
	item.queue_free()


func _can_drop_data(pos: Vector2, data: Variant) -> bool:
	icon.frame = 1
	
	return super._can_drop_data(pos, data)


func _drop_data(pos: Vector2, data: Variant) -> void:
	icon.frame = 0
	
	super._drop_data(pos, data)


func _on_mouse_exited() -> void:
	icon.frame = 0
