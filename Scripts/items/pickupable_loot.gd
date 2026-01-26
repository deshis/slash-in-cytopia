extends PickupableObject
class_name PickupableLoot

@export var mesh_instance := MeshInstance3D
@export var mesh_list: Array[Mesh]
@export var item_material : Material

@export var item_scene: PackedScene

var items := [ItemResource]
var material : Material

func _ready() -> void:
	material = item_material.duplicate()


func set_loot(rarity: ItemType.Grade) -> void:
	mesh_instance.mesh = mesh_list[randi_range(0, mesh_list.size() - 1)]
	
	var mat = material.duplicate(true)
	mat.albedo_color = LootDatabase.grade_colors[rarity]
	mesh_instance.material_override = mat
	
	items = []
	var item_list = LootDatabase.get_items_by_rarity(rarity)
	
	for res in item_list:
		items.append(res.duplicate(true))


func get_item(index:int) -> ItemResource:
	return items[index]
