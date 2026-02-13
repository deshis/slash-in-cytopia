extends MarginContainer

signal items_recycled

@export var slot: Control

func _ready() -> void:
	slot.handler = self


func recycle_items() -> void:
	GameStats.items_recycled += 1
	MenuManager.close_menu(MenuManager.MENU.RECYCLER)
	slot.get_item().queue_free()
	
	items_recycled.emit(slot.get_item().item.grade)


func move_items_from_recycler() -> void:
	InventoryManager.move_item(slot)


func _on_button_pressed() -> void:
	var item = slot.get_item()
	if item:
		recycle_items()
