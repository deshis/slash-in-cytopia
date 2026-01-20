extends TargetProvider
class_name TargetPastPlayer

@export var length := 2

func get_target(enemy: Node3D) -> Vector3:
	var dir = (GameManager.player.global_position - enemy.global_position).normalized()
	return GameManager.player.global_position + dir * length
