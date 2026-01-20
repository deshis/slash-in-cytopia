extends TargetProvider
class_name TargetSelf

func get_target(enemy: Node3D) -> Vector3:
	return enemy.global_position
