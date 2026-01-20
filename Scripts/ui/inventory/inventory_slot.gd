extends Control
class_name InventorySlot

@export var slot_name: String
@export var type: ItemType.Type

func setup() -> void:
	get_child(0).text = slot_name

func get_item() -> Control:
	for child in get_children():
		if child is Item:
			return child
	return null

func set_item(item: Control) -> void:
	clear_item()
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

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not (data is InventorySlot):
		return false
	
	var origin_slot: InventorySlot = data
	var item = origin_slot.get_item()
	
	# dragged from a pickup slot
	if origin_slot.name.begins_with("SelectionSlot") and get_item():
		return false
	
	# generic slot
	if type == ItemType.Type.NONE:
		if origin_slot.type == ItemType.Type.NONE or not get_item():
			return true
		elif get_item() and item.item.type == get_item().item.type:
			return true
		else:
			return false
	
	return item.get_type() == type

func _drop_data(_pos: Vector2, data: Variant) -> void:
	if not (data is InventorySlot):
		return
	
	var origin_slot: InventorySlot = data
	InventoryManager.move_item(origin_slot, self)
