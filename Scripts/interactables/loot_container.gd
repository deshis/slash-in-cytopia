extends Node3D
class_name LootContainer

@export var meshInstance : MeshInstance3D
@export var base_material : Material
@export var light_material : Material
@export var highlight_material : Material
@export var light : Light3D

var base_mat : Material
var light_mat : Material
var highlight_mat : Material

var isApexGrade = true

func _ready() -> void:
	highlight_mat = highlight_material.duplicate(true)
	
	for surface in meshInstance.mesh.get_surface_count():
		var mat = meshInstance.mesh.surface_get_material(surface)
		if mat:
			if surface == 0:
				base_mat = base_material.duplicate(true)
				meshInstance.set_surface_override_material(surface, base_mat)
				base_mat.next_pass = highlight_mat

			elif surface == 2:
				light_mat = light_material.duplicate(true)
				meshInstance.set_surface_override_material(surface, light_mat)
				light_mat.next_pass = highlight_mat

			else:
				var unique_mat = mat.duplicate(true)
				meshInstance.set_surface_override_material(surface, unique_mat)
				unique_mat.next_pass = highlight_mat

func update_colors(color: Color, isApex: bool) -> void:
	if isApex: start_rainbow_tween(3.5)
	
	light_mat.set_shader_parameter("neon_color", color)
	base_mat.set_shader_parameter("albedo_color", color)
	light.light_color = color

func start_rainbow_tween(cycle_time) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_LINEAR)

	tween.tween_method(
		func(hue):
			var color = Color.from_hsv(hue, 1.0, 1.0)
			light_mat.set_shader_parameter("neon_color", color)
			base_mat.set_shader_parameter("albedo_color", color)
			light.light_color = color,
		0.0,
		1.0,
		cycle_time
	)

func update_highlight(value: bool):
	highlight_mat.set_shader_parameter("highlight", value)
