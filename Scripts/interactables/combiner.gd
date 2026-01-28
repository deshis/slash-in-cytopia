extends Node3D

@export var use_amount := 1
@export var item_combine_amount := 3

var loot_impulse_strength := -12.0

func _physics_process(_delta: float) -> void:
	if use_amount <= 0:
		return
	
	if Input.is_action_just_pressed("interact"):
		if GameManager.player.interactables.front() == self:
			combine_items()


func combine_items() -> void:
	var slots = get_slots_with_items()
	
	# consumer -> military
	if slots[0].size() >= item_combine_amount:
		use_amount -= 1
		destroy_items(slots[0])
		var loot_table = generate_loot_table(ItemType.Grade.MILITARY)
		LootDatabase.drop_loot(self, loot_table, loot_impulse_strength)
	
	# military -> prototype
	elif slots[1].size() >= item_combine_amount:
		use_amount -= 1
		destroy_items(slots[1])
		var loot_table = generate_loot_table(ItemType.Grade.PROTOTYPE)
		LootDatabase.drop_loot(self, loot_table, loot_impulse_strength)
	
	# prototype -> apex anomaly
	elif slots[2].size() >= item_combine_amount:
		use_amount -= 1
		destroy_items(slots[2])
		var loot_table = generate_loot_table(ItemType.Grade.APEX_ANOMALY)
		LootDatabase.drop_loot(self, loot_table, loot_impulse_strength)
	
	if use_amount <= 0:
		get_node("InteractLabel").queue_free()


func get_slots_with_items() -> Array:
	var inv = InventoryManager.backpack_node
	var slots = inv.get_children()
	
	var items := []
	items.resize(ItemType.Grade.size())
	for i in range(items.size()):
		items[i] = []
	
	for i in range(slots.size()):
		var slot = slots[i]
		var item_node = slot.get_item()
		if not item_node:
			continue
		
		items[item_node.item.grade].append(slot)
	
	return items


func destroy_items(slots: Array) -> void:
	var inv = InventoryManager
	var trash = InventoryManager.trash_slot_node
	for slot in slots:
		inv.move_item(slot, trash)


func generate_loot_table(rarity: ItemType.Grade) -> LootTable:
	var loot_table = LootTable.new()
	var military = 0
	var prototype = 0
	var apex_anomaly = 0
	
	match rarity:
		ItemType.Grade.MILITARY:
			military = 1
		ItemType.Grade.PROTOTYPE:
			prototype = 1
		ItemType.Grade.APEX_ANOMALY:
			apex_anomaly = 1
	
	loot_table.loot_rarity_weights = {
		"consumer": 0,
		"military": military,
		"prototype": prototype,
		"apex_anomaly": apex_anomaly,
	}
	
	loot_table.loot_drop_chance = 1
	return loot_table
