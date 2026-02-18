extends EnemyController
class_name Claw

@export var face_player_duration := 0.8

@export var grapple_windup_duration := 0.2
@export var grapple_duration := 0.133
@export var grapple_speed := 10

@export var spin_attack: PackedScene = null
@export var spin_attack_chance := 0.35
@export var spin_attack_windup_duration := 0.4
@export var spin_attack_duration := 1.2

@export var spin_attack_speed := 500.0

var spin_target := Vector3.ZERO
var spin_velocity

const FACE_PLAYER = "face_player"
const GRAPPLE_WINDUP = "grapple_windup"
const GRAPPLE = "grapple"
const SPIN_WINDUP = "spin_windup"
const SPIN_ATTACK = "spin_attack"
const SPIN = "spin"

@onready var trail = $model/rig/Skeleton3D/SpinTrail/SpinTrail

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match state:
		FACE_PLAYER:
			process_face_player(delta)
		
		GRAPPLE_WINDUP:
			process_grapple_windup()
		
		GRAPPLE:
			process_grapple(delta)
		
		SPIN_WINDUP:
			process_spin_windup()
		
		SPIN_ATTACK:
			process_spin_attack()
		
		SPIN:
			process_spin(delta)

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	trail.visible = false
	
	match state:
		ATTACK:
			animator.play("Attack")
		
		IDLE:
			animator.play("Idle")
			current_speed = 2 #enemy.speed
		
		FACE_PLAYER:
			nav_agent.set_velocity(Vector3.ZERO)
		
		GRAPPLE:
			var claw_dir = Vector3(
				sin(rotation.y),
				0,
				cos(rotation.y)
				).normalized()
			var claw_pos = global_position + claw_dir * 3.6 # rough distance estimate
			var dist_to_enemy = player.global_position.distance_to(global_position)
			var dist_to_claw = player.global_position.distance_to(claw_pos)
			
			# don't grapple if player is closer to enemy
			if dist_to_enemy < dist_to_claw:
				change_state(COOLDOWN, cooldown_duration) 
		
		SPIN_WINDUP:
			nav_agent.set_velocity(Vector3.ZERO)
			animator.play("SpinAttack")
		
		SPIN_ATTACK:
			target_provider = TargetPastPlayer.new()

func process_idle() -> void:
	if randf() < spin_attack_chance:
		change_state(SPIN_WINDUP, spin_attack_windup_duration)
		return
	
	change_state(NAVIGATE)

func process_face_player(delta: float) -> void:
	if not player:
		return
	
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	if state_timer < 0:
		change_state(ATTACK, attack_windup_duration)

func process_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(attack)
	change_state(GRAPPLE_WINDUP, grapple_windup_duration)

func process_grapple_windup() -> void:
	if state_timer > 0:
		return
	
	change_state(GRAPPLE, grapple_duration)

func process_grapple(delta: float) -> void:
	current_speed = grapple_speed
	var grapple_dir = Vector3(sin(rotation.y), 0, cos(rotation.y)).normalized()
	apply_movement(delta, grapple_dir)
	
	if state_timer > 0:
		return
	
	change_state(COOLDOWN, cooldown_duration)

func process_spin_windup() -> void:
	if state_timer < 0:
		change_state(SPIN_ATTACK, spin_attack_windup_duration)

func process_spin_attack() -> void:
	perform_attack(spin_attack)
	set_spin_target()
	change_state(SPIN, spin_attack_duration)

func process_spin(delta: float) -> void:
	current_speed = spin_velocity.length()
	apply_movement(delta, spin_velocity.normalized())
	
	if state_timer < 0:
		change_state(COOLDOWN, cooldown_duration)

func set_spin_target() -> void:
	spin_target = target_provider.get_target(self)
	var dir = (spin_target - global_position).normalized()
	spin_velocity = dir * spin_attack_speed

func die(drop_loot: bool = true) -> void:
	GameManager.boss_killed(self)
	super.die(drop_loot)

func apply_debuff_effect(debuff: DebuffResource) -> void:
	match debuff.debuff_type:
		DebuffResource.DebuffType.STUN:
			return
		DebuffResource.DebuffType.FREEZE:
			return
	
	super.apply_debuff_effect(debuff)

func _on_navigation_agent_3d_target_reached() -> void:
	if randf() < spin_attack_chance:
		change_state(SPIN_WINDUP, spin_attack_windup_duration)
	else:
		change_state(FACE_PLAYER, face_player_duration)
