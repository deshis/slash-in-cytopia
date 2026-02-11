extends Control

@export var slots: Array[Control]

var item_on_ground: Node3D

func setup() -> void:
	if GameManager.player:
		GameManager.player.item_picked_up.connect(open_item_selection)

func open_item_selection(node: Node3D):
	item_on_ground = node
	
	for i in range(slots.size()):
		var slot = slots[i]
		slot.clear()
		slot.visible = false
		
		if i < node.items.size():
			var item = node.get_item(i)
			slot.set_item(InventoryManager.create_item_control(item))
			slot.visible = true
	
	MenuManager.open_menu(MenuManager.MENU.ITEM_SELECTION)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = false

func close_menu() -> void:
	visible = false
	item_on_ground.queue_free()
