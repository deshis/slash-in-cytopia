extends Control
class_name InventorySlot

@export var slot_name: String
@export var slot_type: SLOT

enum SLOT {
	NONE,
	BACKPACK,
	AUGMENT,
	PICKUP,
	COMBINER,
	TRASH,
	RECYCLER,
}


func setup() -> void:
	get_child(0).text = slot_name


func get_item() -> Control:
	for child in get_children():
		if child is Item:
			return child
	return null


func set_item(item: Control) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
	add_child(item)


func clear_item() -> void:
	for child in get_children():
		if child is Item:
			child.queue_free()


func slot_right_clicked() -> void:
	InventoryManager.move_item(self)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		slot_right_clicked()


func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
	return true


func _drop_data(_pos: Vector2, data: Variant) -> void:
	if not (data is InventorySlot):
		return
	
	var origin_slot: InventorySlot = data
	InventoryManager.move_item(origin_slot, self)
