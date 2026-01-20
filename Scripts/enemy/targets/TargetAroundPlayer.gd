extends TargetProvider
class_name TargetAroundPlayer

@export var radius := 100.0

func get_target(_enemy: Node3D) -> Vector3:
	var random_offset = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
	return GameManager.player.global_position + random_offset
