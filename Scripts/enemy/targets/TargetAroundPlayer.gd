extends TargetProvider
class_name TargetAroundPlayer

@export var inner_radius := 5.0
@export var outer_radius := 6.0

func get_target(_enemy: Node3D) -> Vector3:
	
	var angle = randf() * (2*PI) 
	var distance = randf_range(inner_radius, outer_radius)
	
	var x = cos(angle) * distance
	var z = sin(angle) * distance
	
	var random_offset = Vector3(x, 0, z)
	return GameManager.player.global_position + random_offset
	
	
