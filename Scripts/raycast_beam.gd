extends Node3D

@export var beam_material: StandardMaterial3D
@export var beam_duration: float = 0.1
@export var fade_duration: float = 0.05

@onready var beam_mesh: MeshInstance3D = $BeamMesh
@onready var muzzle_flash: String
@export var impact: String

func shoot_beam(from: Vector3, to: Vector3) -> void:
	var mat = beam_material.duplicate()
	beam_mesh.material_override = mat
	
	var mid = (from + to) / 2.0
	var dist = from.distance_to(to)
	var dir = (to - from).normalized()

	beam_mesh.global_position = mid
	beam_mesh.look_at(mid + dir, Vector3.UP)
	beam_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
	
	var mesh = CylinderMesh.new()
	mesh.height = dist
	mesh.top_radius = 0.02
	mesh.bottom_radius = 0.02
	mesh.material = mat 
	beam_mesh.mesh = mesh
	
	var tween = create_tween()
	tween.tween_property(mat, "emission_energy_multiplier", 2.0, fade_duration)
	tween.tween_interval(beam_duration)
	tween.tween_callback(queue_free)
