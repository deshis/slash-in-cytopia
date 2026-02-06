extends MarginContainer

signal items_combined

@export var slots: Array[Control]
var grade = null
var item_count := 0

func _ready() -> void:
	for slot in slots:
		slot.handler = self


func get_slots_with_items() -> Array[Control]:
	var items: Array[Control] = []
	for slot in slots:
		if slot.get_item():
			items.append(slot)
	return items

func get_empty_slot() -> Control:
	for slot in slots:
		if not slot.get_item():
			return slot
	return null


func combine_items() -> void:
	MenuManager.close_menu(MenuManager.MENU.COMBINER)
	
	for slot in slots:
		slot.get_item().queue_free()
	
	items_combined.emit(grade)


func move_items_from_combiner() -> void:
	for slot in slots:
		InventoryManager.move_item(slot)
	
	update_state()


func update_state() -> void:
	item_count = 0
	grade = null
	
	for slot in slots:
		var item = slot.get_item()
		if item:
			item_count += 1
			grade = item.item.grade


func _on_button_pressed() -> void:
	if item_count == 3:
		combine_items()
