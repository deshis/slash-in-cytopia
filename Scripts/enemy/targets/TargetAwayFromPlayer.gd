extends TargetProvider
class_name TargetAwayFromPlayer

func get_target(enemy: Node3D) -> Vector3:
	var enemy_pos = enemy.global_position
	var player_pos = GameManager.player.global_position
	
	enemy_pos.y = 0
	player_pos.y = 0
	
	var dir = (enemy_pos - player_pos).normalized()
	return enemy.global_position + dir * 16
