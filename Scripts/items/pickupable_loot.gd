extends PickupableObject
class_name PickupableLoot

@export var interact_area: Area3D

@export var container: LootContainer

@export var item_scene: PackedScene

var items := [ItemResource]


func _physics_process(delta: float) -> void:
	if player.interactables.front() == self:
		container.update_highlight(true)
	else:
		container.update_highlight(false)


func set_loot(rarity: ItemType.Grade) -> void:
	var color = LootDatabase.grade_colors[rarity]
	container.is_apex = rarity == ItemType.Grade.APEX_ANOMALY
	container.update_colors(color)
	
	items = []
	var item_list = LootDatabase.get_items_by_rarity(rarity)
	
	for res in item_list:
		var new_item = res.duplicate(true)
		new_item.original_path = res.resource_path
		items.append(new_item)

func get_item(index:int) -> ItemResource:
	return items[index]


func on_interaction_area_entered():
	container.update_highlight(true)

func on_interaction_area_exited():
	container.update_highlight(false)
