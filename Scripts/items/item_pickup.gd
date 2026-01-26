extends Control

@onready var inventory: Control = $".."
@onready var container: Control = $VBoxContainer/HBoxContainer

var item_on_ground: Node3D

func setup() -> void:
	if GameManager.player:
		GameManager.player.item_picked_up.connect(open_item_selection)

func open_item_selection(node: Node3D):
	item_on_ground = node
	inventory.visible = true
	visible = true
	
	for i in range(container.get_child_count()):
		var slot = container.get_child(i)
		clear_slot(slot)
		slot.visible = false
		
		if i < node.items.size():
			var item = node.get_item(i).duplicate()
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
