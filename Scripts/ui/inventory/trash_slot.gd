extends InventorySlot
class_name TrashSlot

@export var opened_icon: CompressedTexture2D

func set_item(item: Control, play_sfx: bool = false) -> void:
	GameStats.items_trashed += 1
	SoundManager.play_ui_sfx(sfx)
	item.queue_free()
	
	await get_tree().physics_frame
	InventoryManager.update_inventory_data()


func set_open(state: bool) -> void:
	icon_node.texture = opened_icon if state else icon


func _can_drop_data(pos: Vector2, data: Variant) -> bool:
	set_open(true)
	
	return super._can_drop_data(pos, data)


func _drop_data(pos: Vector2, data: Variant) -> void:
	set_open(false)
	
	super._drop_data(pos, data)


func _on_mouse_exited() -> void:
	set_open(false)
