extends Node3D

@export var beam_material: StandardMaterial3D
@export var beam_duration: float = 0.1
@export var fade_duration: float = 0.05

@onready var beam_mesh2: MeshInstance3D = $BeamMesh
@onready var beam_mesh: MeshInstance3D = $BeamMesh
@onready var muzzle_flash: String
@export var impact: String

func shoot_beam(from: Vector3, to: Vector3) -> void:
	
	if !beam_mesh:
		print("no mesh")
		return
		
	var dist = from.distance_to(to)
	var dir = (to - from).normalized()
	
	beam_mesh.global_position = (from + to)/2.0
	beam_mesh.look_at(to, Vector3.UP)
	beam_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
	beam_mesh.mesh.height = dist
	
	var tween = create_tween()
	#tween.tween_property(mat, "emission_energy_multiplier", 2.0, fade_duration)
	tween.tween_interval(beam_duration)
	tween.tween_callback(queue_free)
