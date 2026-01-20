extends TargetProvider
class_name TargetPlayer

func get_target(_enemy: Node3D) -> Vector3:
	return GameManager.player.global_position;
