extends Control

@onready var inventory: Control = $".."
@onready var container: Control = $VBoxContainer/HBoxContainer

var item_on_ground:Area3D

func setup() -> void:
	if GameManager.player:
		GameManager.player.item_picked_up.connect(open_item_selection)

func open_item_selection(area:Area3D):
	item_on_ground = area
	inventory.visible = true
	visible = true
	
	for i in range(container.get_child_count()):
		var slot = container.get_child(i)
		clear_slot(slot)
		slot.visible = false
		
		if i < area.items.size():
			var item = area.get_item(i).duplicate()
			slot.add_child(InventoryManager.create_item_control(item))
			slot.visible = true
	
	visible = true
	GameManager.open_menu()


func clear_slot(slot: Control)->void:
	for child in slot.get_children():
		if child is Item:
			child.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = false

func close_menu() -> void:
	visible = false
	item_on_ground.queue_free()
