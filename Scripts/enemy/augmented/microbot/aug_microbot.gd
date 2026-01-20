extends EnemyController
class_name AugmentedMicrobot

@export var target_dist_min := 100.0
@export var target_dist_max := 250.0

@onready var trail = $"model/AugmentedBlastWave"

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		IDLE:
			trail.visible = false
			animator.play("Idle")
			nav_agent.target_desired_distance = randf_range(target_dist_min, target_dist_max)
		NAVIGATE:
			trail.visible = false
			animator.play("Walk")
			current_speed = enemy.speed
		STUN:
			trail.visible = false
			animator.play("Stun")
		ATTACK:
			animator.play("Augmented_attack")
