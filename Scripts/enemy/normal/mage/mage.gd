extends EnemyController
class_name Mage

const TP = "teleport"
const FACE_PLAYER = "face_player"
const RANGED_ATTACK = "ranged_attack"
const ATTACK_RECOVERY = "attack_recovery"

@export var ranged_attack: PackedScene = null
@export var ranged_attack_chance := 0.3
@export var ranged_attack_max_range := 10.0
@export var ranged_attack_windup_duration := 2.2
@export var ranged_attack_max_cooldown := 2.5
var ranged_attack_cooldown := 0.0
var ranged_attack_pos := Vector3.ZERO

@onready var tp_attack_area = $TeleportArea
@onready var tp_attack_hitbox = $TeleportArea/AttackAreaHitbox
@onready var particles = $model/rig/Skeleton3D/BoneAttachment3D/Mesh/Particles

@export var tp_windup_duration := 0.4
@export var tp_attack_duration := 0.8
@export var max_tp_dist := 5
@export var tp_chance := 0.4
@export var tp_max_cooldown := 2.5
var tp_cooldown := 0.0

@export var attack_duration = 0.75

@export var face_player_duration := 0.8

var tp_target = Vector3.ZERO

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	tp_cooldown -= delta
	ranged_attack_cooldown -= delta
	
	match state:
		FACE_PLAYER:
			process_face_player(delta)
		
		TP:
			GameManager.particles.emit_particles("teleport", global_position)
			process_tp()
		
		RANGED_ATTACK:
			process_ranged_attack(delta)
		
		ATTACK_RECOVERY:
			process_attack_recovery()


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		ATTACK:
			particles.emitting = true
			animator.play("Teleport_attack")
		FACE_PLAYER:
			animator.play("Idle")
			nav_agent.set_velocity(Vector3.ZERO)
		IDLE:
			particles.emitting = false
			animator.play("Idle")
			nav_agent.set_velocity(Vector3.ZERO)
		NAVIGATE:
			animator.play("Walk")
		TP:
			animator.play("Teleport")
			nav_agent.set_velocity(Vector3.ZERO)
		RANGED_ATTACK:
			ranged_attack_pos = get_ranged_attack_pos()
			perform_attack(ranged_attack, ranged_attack_pos)
			animator.play("Attack")
			nav_agent.set_velocity(Vector3.ZERO)
		COOLDOWN:
			particles.emitting = false
			animator.play("Idle")
		STUN:
			particles.emitting = false
			animator.play("Stun")


func process_navigation(delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	
	if tp_cooldown < 0:
		tp_cooldown = randf_range(0.5, tp_max_cooldown)
	
		if randf() < tp_chance:
			change_state(TP, tp_windup_duration)
			return
	
	elif ranged_attack_cooldown < 0:
		ranged_attack_cooldown = randf_range(0.5, ranged_attack_max_cooldown)
		
		if randf() < ranged_attack_chance:
			change_state(RANGED_ATTACK, ranged_attack_windup_duration)
			return
	
	elif dist < attack_range:
		change_state(FACE_PLAYER, face_player_duration)
		return
	
	super.process_navigation(delta)


func process_tp() -> void:
	if state_timer > 0:
		return
	
	tp_target = get_pos(global_position, player.global_position, max_tp_dist, attack_range)
	global_position = tp_target
	
	GameManager.particles.emit_particles("teleport", global_position)
	
	change_state(IDLE)


func process_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(attack)
	change_state(ATTACK_RECOVERY, attack_duration-attack_windup_duration)


func process_attack_recovery() -> void:
	if state_timer > 0:
		return
	change_state(COOLDOWN, cooldown_duration)


func process_face_player(delta: float) -> void:
	if not player:
		return
	
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	if state_timer < 0:
		change_state(ATTACK, attack_windup_duration)


func process_ranged_attack(delta: float) -> void:
	var dir = (ranged_attack_pos - global_position).normalized()
	update_facing_dir(delta, dir)
	
	if state_timer > 0:
		return
	
	change_state(COOLDOWN, ranged_attack_cooldown)


func get_ranged_attack_pos() -> Vector3:
	var variance = Vector2(0.0, 2.5)
	
	var attack_pos = get_pos(global_position, player.global_position, ranged_attack_max_range)
	var dist = global_position.distance_to(player.global_position)
	var weight = inverse_lerp(0, ranged_attack_max_range, dist)
	weight = clamp(weight, 0, 1)
	var accuracy = lerp(variance.x, variance.y, weight)
	
	var angle = randf_range(0, TAU)
	var dir = Vector3(cos(angle), 0.0, sin(angle))
	attack_pos += dir * accuracy
	attack_pos.y = 0.0
	
	return attack_pos


func get_pos(start_pos: Vector3, end_pos: Vector3, max_dist: float, overshoot: float = 0.0) -> Vector3:
	var dir = start_pos.direction_to(end_pos).normalized()
	var dist = start_pos.distance_to(end_pos)
	var pos = start_pos + dir * clamp(dist + overshoot, 0, max_dist)
	
	var nav_region = GameManager.nav_handler
	var nav_map = nav_region.get_navigation_map()
	var fixed_pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
	return fixed_pos

func _on_navigation_agent_3d_target_reached() -> void:
	if randf() < 0.5:
		change_state(FACE_PLAYER, face_player_duration)
	else:
		change_state(RANGED_ATTACK, ranged_attack_windup_duration)
