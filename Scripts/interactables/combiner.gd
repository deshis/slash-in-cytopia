extends Node3D

@export var use_amount := 1

var loot_impulse_strength := -12.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		var combiner_menu = MenuManager.menus[MenuManager.MENU.COMBINER]
		combiner_menu.move_items_from_combiner()
		MenuManager.close_menu(MenuManager.MENU.COMBINER)
		MenuManager.menus[MenuManager.MENU.COMBINER].items_combined.disconnect(combine_items)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if GameManager.player.interactables.front() == self:
			MenuManager.open_menu(MenuManager.MENU.COMBINER)
			MenuManager.menus[MenuManager.MENU.COMBINER].items_combined.connect(combine_items)


func combine_items(rarity: ItemType.Grade) -> void:
	var loot_table = generate_loot_table(clamp(rarity + 1, 0, ItemType.Grade.size()))
	LootDatabase.drop_loot(self, loot_table, loot_impulse_strength)
	
	MenuManager.close_menu(MenuManager.MENU.COMBINER)
	
	use_amount -= 1
	if use_amount <= 0:
		get_node("InteractLabel").queue_free()
		set_script(null)


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
