extends RigidBody3D
class_name ThrowableLogic

var aoe_damage := 0.0
var aoe_radius := 0.0

func _on_body_entered(body: Node):
	
	##CRITICAL Update this to utilize Area3D for finding enemies 
	for enemy in GameManager.spawner.get_children():
		if enemy is not EnemyController or not enemy.visible:
			continue
			
		if global_position.distance_to(enemy.global_position) < aoe_radius:
			if aoe_damage != 0:
				GameManager.player.deal_damage(null, aoe_damage, enemy)
	
	queue_free()
