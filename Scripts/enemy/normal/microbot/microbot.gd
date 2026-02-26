extends EnemyController
class_name Microbot

@export var target_dist_min := 2.5
@export var target_dist_max := 5.0

@export var homing_jump := false
@export var jump_height := 2.25
@export var jump_speed := 8.0
@export var jump_windup_duration := 0.2
@export var jump_duration := 0.6
@export var jump_move_decay := 0.6
var jump_dir := Vector3.UP

@onready var trail = $"model/BlastWave"

const JUMP_WINDUP = "jump_attack_windup"
const JUMP = "jump_attack"

func _physics_process(delta: float) -> void:
	match state:
		JUMP_WINDUP:
			process_jump_windup()
		JUMP:
			current_speed = jump_speed
			process_jump(delta)
	
	super._physics_process(delta)


func _activate() -> void:
	super._activate()
	nav_agent.target_desired_distance = randf_range(target_dist_min, target_dist_max)


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		IDLE:
			trail.visible = false
			animator.play("Idle")
			animator.speed_scale = 1.0
			nav_agent.target_desired_distance = randf_range(target_dist_min, target_dist_max)
		NAVIGATE:
			trail.visible = false
			animator.play("Walk")
		STUN:
			trail.visible = false
			animator.play("Stun")
		ATTACK:
			ParticleManager.emit_particles("light_ray",global_position + Vector3(0,0.5,0))
			animator.play("Attack")
			animator.speed_scale = 2.0
		JUMP_WINDUP:
			nav_agent.set_velocity(Vector3.ZERO)
			jump_dir = global_position.direction_to(player.global_position).normalized()


func process_jump_windup() -> void:
	if state_timer > 0:
		return
	
	change_state(JUMP, jump_duration)



func process_jump(delta: float) -> void:
	var particle = ParticleManager.emit_particles("microbot_jump",global_position)
	var t = inverse_lerp(jump_duration, 0, state_timer)
	position.y = sin(PI * t) * jump_height
	current_speed *= jump_move_decay
	
	var dir = jump_dir
	if homing_jump:
		dir = global_position.direction_to(player.global_position).normalized()
	
	apply_movement(delta, dir)
	
	if state_timer < 0:
		print("guh")
		change_state(ATTACK, attack_windup_duration / 2.0)

func _on_navigation_agent_3d_target_reached() -> void:
	if GameManager.player and GameManager.player.is_dead:
		change_state(IDLE)
		return
	change_state(JUMP_WINDUP, jump_windup_duration)
