extends PickupableObject

@export var mesh_instance := MeshInstance3D
@export var mesh_list: Array[Mesh]
@export var item_material : Material

@export var item_scene: PackedScene
@export var label : Label3D

var items := [ItemResource]
var material : Material

func _ready() -> void:
	var interact = InputMap.action_get_events("interact")
	var button_name = interact[0].as_text()
	label.text = button_name + " interact"
	
	material = item_material.duplicate()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist < 2.0:
		label.visible = true
	else:
		label.visible = false

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
