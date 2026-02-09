extends PickupableObject
class_name PickupableLoot

@export var interact_area: Area3D

@export var mesh_instance : MeshInstance3D
@export var light_material : Material
@export var highlight_material : Material
@export var light : Light3D

@export var item_scene: PackedScene

var items := [ItemResource]
var light_mat : Material
var highlight_mat : Material

func _ready() -> void:
	highlight_mat = highlight_material.duplicate(true)
	
	for surface in mesh_instance.mesh.get_surface_count():
		var mat = mesh_instance.mesh.surface_get_material(surface)
		if mat:
			if surface == 2:
				light_mat = light_material.duplicate(true)
				mesh_instance.set_surface_override_material(surface, light_mat)
				light_mat.next_pass = highlight_mat
			else: 
				var unique_mat = mat.duplicate(true)
				mesh_instance.set_surface_override_material(surface, unique_mat)
				unique_mat.next_pass = highlight_mat

func set_loot(rarity: ItemType.Grade) -> void:
	var color = LootDatabase.grade_colors[rarity]
	light_mat.set_shader_parameter("neon_color", color)
	light.light_color = color
	
	items = []
	var item_list = LootDatabase.get_items_by_rarity(rarity)
	
	for res in item_list:
		items.append(res.duplicate(true))


func get_item(index:int) -> ItemResource:
	return items[index]
	
func update_highlight(value: bool):
	highlight_mat.set_shader_parameter("highlight", value)
	
func on_interaction_area_entered():
	update_highlight(true)

func on_interaction_area_exited():
	update_highlight(false)
