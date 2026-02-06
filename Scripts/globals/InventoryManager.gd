extends Control

var inventory_node: Node = null

var backpack_node: Node
var augments_node: Node
var item_selection_node: Node
var combiner_node: Node
var recycler_node: Node
var trash_slot_node: Node

var slot_type = InventorySlot.SLOT

var starter_items: Array[ItemResource] =  [load("res://Scripts/items/prototype/CloverLOA.tres"),load("res://Scripts/items/military/Katana.tres"),load("res://Scripts/items/prototype/Javelin.tres"),load("res://Scripts/items/military/PlasteelChassis.tres"), load("res://Scripts/items/prototype/Arievistan.tres"), load("res://Scripts/items/prototype/Vampirism.tres"), load("res://Scripts/items/consumer/Brick_Throwable.tres"), load("res://Scripts/items/military/Shuriken.tres")] #, load("res://Scripts/items/prototype/Vampirism.tres")]#[preload("res://Scripts/items/military/DashReplicator.tres"), preload("res://Scripts/items/prototype/Dawn.tres"),preload("res://Scripts/items/military/BlackBurner.tres"), preload("res://Scripts/items/military/DashLimiter.tres"),preload("res://Scripts/items/prototype/Arievistan.tres")]#[preload("res://Scripts/items/prototype/ArcFlash.tres"),preload("res://Scripts/items/prototype/Labrys.tres"),preload("res://Scripts/items/military/DashLimiter.tres"),preload("res://Scripts/items/consumer/UnderclockedExoskeleton.tres"),preload("res://Scripts/items/military/SecondHeart.tres"),preload("res://Scripts/items/prototype/RealityFracture.tres")]
var augment_items: Array[ItemResource] = []
var backpack_items: Array[ItemResource] = [] # pls don't clean me! [preload("res://Scripts/items/prototype/Item6.tres"),preload("res://Scripts/items/consumer/Item4.tres")] #[preload("res://Scripts/items/prototype/Item6.tres")]

var item_scene: PackedScene = preload("res://Scenes/items/item.tscn")

var extra_augment_nodes = []
var extra_augment_slots := false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if inventory_node.visible:
			MenuManager.close_menu(MenuManager.MENU.INVENTORY)
		elif MenuManager.active_menu != MenuManager.MENU.PAUSE:
			MenuManager.open_menu(MenuManager.MENU.INVENTORY)
	
	if event.is_action_pressed("ui_cancel") and inventory_node.visible:
		get_viewport().set_input_as_handled()
		MenuManager.close_menu(MenuManager.MENU.INVENTORY)


func init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# setup inventory
	inventory_node = GameManager.HUD.get_node("Inventory")
	backpack_node = inventory_node.backpack_node
	trash_slot_node = inventory_node.trash_slot_node
	augments_node = inventory_node.augments_node
	item_selection_node = inventory_node.item_selection_node
	combiner_node = inventory_node.combiner_node
	recycler_node = inventory_node.recycler_node
	extra_augment_nodes = inventory_node.extra_augment_nodes
	init_slots()
	
	# setup menu manager
	MenuManager.add_menu(MenuManager.MENU.INVENTORY, inventory_node)
	MenuManager.add_menu(MenuManager.MENU.ITEM_SELECTION, item_selection_node)
	MenuManager.add_menu(MenuManager.MENU.COMBINER, combiner_node)
	MenuManager.add_menu(MenuManager.MENU.RECYCLER, recycler_node)
	
	# setup backpack
	backpack_items.resize(backpack_node.get_child_count())
	for i in range(backpack_items.size()):
		var slot = backpack_node.get_child(i)
		var item_res = backpack_items[i]
		
		if backpack_items[i]:
			var item_control = create_item_control(item_res)
			slot.set_item(item_control)
	
	# setup augments
	augment_items.resize(augments_node.get_child_count())
	for i in range(augment_items.size()):
		var slot = augments_node.get_child(i)
		var item_res = augment_items[i]
		
		if augment_items[i]:
			var item_control = create_item_control(item_res)
			slot.set_item(item_control)
	
	equip_starter_items()


func init_slots() -> void:
	for i in range(backpack_node.get_child_count()):
		var slot = backpack_node.get_child(i)
		slot.setup()
	
	for i in range(augments_node.get_child_count()):
		var slot = augments_node.get_child(i)
		slot.setup()
	
	trash_slot_node.setup()
	item_selection_node.setup()


func create_item_control(item_res: ItemResource) -> Control:
	var instance: Control = item_scene.instantiate() as Control
	instance.item = item_res.duplicate(true)
	return instance


func move_item(origin_slot: InventorySlot, new_slot: InventorySlot = null) -> void:
	var item = origin_slot.get_item()
	
	if not item:
		return
	
	match origin_slot.slot_type:
		slot_type.NONE:
			pass
		slot_type.BACKPACK:
			new_slot = handle_backpack_move(origin_slot, new_slot, item)
		slot_type.AUGMENT:
			new_slot = handle_augment_move(origin_slot, new_slot, item)
		slot_type.PICKUP:
			new_slot = handle_pickup_move(origin_slot, new_slot, item)
		slot_type.COMBINER:
			new_slot = handle_combiner_move(origin_slot, new_slot, item)
		slot_type.TRASH:
			pass
	
	place_or_swap(item, origin_slot, new_slot)
	update_inventory_data()
	
	if MenuManager.active_menu == MenuManager.MENU.COMBINER:
		combiner_node.update_state()


func can_replace_item(slot: InventorySlot) -> bool:
	if not slot.get_item():
		return true
	elif get_backpack_slot():
		return true
	return false


func handle_backpack_move(origin_slot: InventorySlot, new_slot: InventorySlot, item: Control) -> Control:
	if new_slot:
		return new_slot
	
	if MenuManager.active_menu == MenuManager.MENU.COMBINER:
		return get_combiner_slot(origin_slot, item)
	else:
		return get_augment_slot(item)


func handle_augment_move(origin_slot: AugmentSlot, new_slot: InventorySlot, item: Control) -> Control:
	if new_slot:
		return new_slot
	
	if MenuManager.active_menu == MenuManager.MENU.COMBINER:
		return get_combiner_slot(origin_slot, item)
	else:
		return get_backpack_slot()


func handle_pickup_move(_origin_slot: PickupSlot, new_slot: InventorySlot, item: Control) -> Control:
	if not new_slot:
		new_slot = get_augment_slot(item)
	
	if not can_replace_item(new_slot):
		return null
	
	move_item(new_slot)
	close_item_pickup_menu()
	return new_slot


func handle_combiner_move(_origin_slot: CombinerSlot, new_slot: InventorySlot, item: Control) -> Control:
	if not new_slot:
		new_slot = get_backpack_slot()
		
		if new_slot:
			return new_slot
	
	if new_slot.get_item():
		if not new_slot.get_item().item.grade == item.item.grade:
				return null
	
	combiner_node.update_state()
	return new_slot


func place_or_swap(item: Control, origin_slot: Control, new_slot: Control) -> void:
	if not new_slot:
		new_slot = origin_slot
	
	if new_slot.get_item():
		var item_to_swap = new_slot.get_item()
		new_slot.remove_child(item_to_swap)
		origin_slot.set_item(item_to_swap)
	
	new_slot.set_item(item)
	update_inventory_data()


func delete_item(item: Control):
	GameStats.items_trashed += 1
	item.queue_free()


func get_augment_slot(item) -> Control:
	var available_slots = []
	for slot in augments_node.get_children():
		if slot.item_type == item.item.type:
			available_slots.append(slot)
	
	# extra augment slot will return free slot if available
	if extra_augment_slots:
		for slot in available_slots:
			if not slot.get_item():
				return slot
	
	return available_slots[0]


func get_backpack_slot() -> Control:
	for slot in backpack_node.get_children():
		if not slot.get_item():
			return slot
	return null


func get_combiner_slot(origin_slot: InventorySlot, item: Control) -> Control:
	var item_count = combiner_node.item_count
	
	if item_count == 0:
		return combiner_node.get_empty_slot()
	
	elif item_count == 1:
		if item.item.grade == combiner_node.grade:
			return combiner_node.get_empty_slot()
		
		elif origin_slot.slot_type == slot_type.AUGMENT:
			var slot_with_item = combiner_node.get_slots_with_items()[0]
			var item_in_combiner = slot_with_item.get_item()
			if item.item.type == item_in_combiner.item.type:
				return slot_with_item
	
	elif item_count == 2:
		if item.item.grade == combiner_node.grade:
			return combiner_node.get_empty_slot()
	
	return null


func close_item_pickup_menu() -> void:
	GameStats.items_picked_up += 1
	item_selection_node.close_menu()


func update_inventory_data() -> void:
	# update backpack
	for i in range(backpack_node.get_child_count()):
		var slot = backpack_node.get_child(i)
		var new_item = slot.get_item().item if slot.get_item() else null
		backpack_items[i] = new_item
	
	# update augments
	for i in range(augments_node.get_child_count()):
		var slot = augments_node.get_child(i)
		
		var old_item = augment_items[i]
		var new_item = slot.get_item().item if slot.get_item() else null
		
		update_item_effects(old_item, new_item)
		augment_items[i] = new_item


func update_item_effects(old_item: ItemResource, new_item: ItemResource) -> void:
	if old_item and old_item != new_item:
		remove_item_effects(old_item)
	
	if new_item and old_item != new_item:
		apply_item_effects(new_item)


func apply_item_effects(item: ItemResource) -> void:
	if not item:
		return
		
	#chaos, don't touch
	if item.weapon_type != ItemType.WeaponType.NONE:
		if item.attack_type == ItemType.AttackType.PRIMARY:
			ItemGlobals.primary_weapon_mesh = item.weapon_mesh
			ItemGlobals.primary = true
			item.set_primary_weapon_type_name()
			item.set_primary_attack_type_name()
			GameManager.HUD.set_cooldown_icon(item.icon, "PrimaryAttack")
			
		if item.attack_type == ItemType.AttackType.SECONDARY:
			ItemGlobals.secondary_weapon_mesh = item.weapon_mesh
			ItemGlobals.secondary = true
			item.set_secondary_weapon_type_name()
			item.set_secondary_attack_type_name()
			GameManager.HUD.set_cooldown_icon(item.icon, "SecondaryAttack")
	
	if item.type == ItemType.Type.ACTIVE_ITEM:
		GameManager.HUD.set_cooldown_icon(item.icon, "ActiveItem")
	
	if item.type == ItemType.Type.THROWABLE:
		GameManager.HUD.set_cooldown_icon(item.icon, "ThrowableItem")
	
	#print("Applying effects for: ", item.item_name)
	for effect in item.effects:
		effect.apply_effect(GameManager.player)
	
	#reset the check
	ItemGlobals.primary = false
	ItemGlobals.secondary = false


func remove_item_effects(item: ItemResource) -> void:

	#chaos, don't touch
	if item.weapon_type != ItemType.WeaponType.NONE:
		if item.attack_type == ItemType.AttackType.PRIMARY:
			ItemGlobals.primary_weapon_mesh = null
			ItemGlobals.primary = true
			ItemGlobals.primary_weapon_type = "Default"
			GameManager.HUD.set_cooldown_icon(null, "PrimaryAttack")
			
		if item.attack_type == ItemType.AttackType.SECONDARY:
			ItemGlobals.secondary_weapon_mesh = null
			ItemGlobals.secondary = true
			ItemGlobals.secondary_weapon_type = "Default"
			GameManager.HUD.set_cooldown_icon(null, "SecondaryAttack")
	
	if item.type == ItemType.Type.ACTIVE_ITEM:
		GameManager.HUD.set_cooldown_icon(null, "ActiveItem")
	
	#print("Removing effects for: ", item.item_name)
	for effect in item.effects:
		effect.remove_effect(GameManager.player)
			
	#reset the check
	ItemGlobals.primary = false
	ItemGlobals.secondary = false


func enable_extra_augment_slots() -> void:
	extra_augment_slots = true
	for node in extra_augment_nodes:
		node.visible = true


func disable_extra_augment_slots() -> void:
	extra_augment_slots = false
	for node in extra_augment_nodes:
		node.visible = false
		if node.get_item():
			move_item(node)


func reset_inventory() -> void:
	extra_augment_slots = false
	augment_items.clear()
	backpack_items.clear()


func equip_starter_items() -> void:
	if starter_items.size() == 0:
		return
	
	for item in starter_items:
		var item_control = create_item_control(item)
		var slot = backpack_node.get_child(0)
		slot.set_item(item_control)
		move_item(slot)
		
