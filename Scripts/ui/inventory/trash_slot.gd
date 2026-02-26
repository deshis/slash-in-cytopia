extends InventorySlot
class_name TrashSlot

@export var opened_icon: CompressedTexture2D

func set_item(item: Control, play_sfx: bool = false) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
	item_slot.add_child(item)
	
	GameStats.items_trashed += 1
	SoundManager.play_ui_sfx(sfx)
	item.queue_free()


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		icon_node.visible = true
		if hovered:
			InventoryManager.item_description.deactivate()


func set_cartridge(item_node: Control) -> void:
	pass

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
	hovered = false
