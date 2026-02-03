extends MarginContainer

signal items_combined

@export var slots: Array[Control]
var grade = null

func _ready() -> void:
	for slot in slots:
		slot.handler = self


func item_count() -> int:
	var items = 0
	for slot in slots:
		if slot.get_item():
			items += 1
	return items


func combine_items() -> void:
	MenuManager.close_menu(MenuManager.MENU.COMBINER)
	
	for slot in slots:
		slot.get_item().queue_free()


func move_items_from_combiner() -> void:
	for slot in slots:
		InventoryManager.move_item(slot)


func _on_button_pressed() -> void:
	if item_count() == 3:
		items_combined.emit(grade)
