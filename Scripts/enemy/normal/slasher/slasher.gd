extends EnemyController
class_name Slasher

@export var face_player_duration := 0.5
@export var dash_range := 2.8
@export var dash_speed := 6.5
@export var dash_duration := 0.5

@export var attack_duration := 0.5

#@onready var slash_trail = $"model/SlashMesh"
var thruster

const FACE_PLAYER = "face_player"
const DASH = "dash"

func _ready() -> void:
	super._ready()
	thruster = find_children("*", "BoneAttachment3D")[0]
	thruster.visible = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match state:
		FACE_PLAYER:
			process_face_player(delta)
		
		DASH:
			process_dash(delta)


func _activate() -> void:
	super._activate()
	nav_agent.target_desired_distance = dash_range


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		COOLDOWN:
			#slash_trail.visible = false
			animator.play("Idle")
		
		STUN:
			#slash_trail.visible = false
			animator.play("Stun")
		
		NAVIGATE:
			#slash_trail.visible = false
			animator.play("Walk")
			current_speed = enemy.speed
		
		FACE_PLAYER:
			animator.play("DashAttackInit")
			target_provider = TargetSelf.new()
		
		DASH:
			current_speed = dash_speed
			thruster.visible = true
		
		ATTACK:
			perform_attack(attack)
			animator.play("DashAttack")
			current_speed = 0

func process_face_player(delta: float) -> void:
	if not player:
		return
	
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	if state_timer < 0:
		change_state(DASH, dash_duration)


func process_dash(delta: float) -> void:
	var dash_dir = Vector3(sin(rotation.y), 0, cos(rotation.y)).normalized()
	apply_movement(delta, dash_dir)
	
	var dist = global_position.distance_to(player.global_position)
	if state_timer < 0 or dist < attack_range:
		thruster.visible = false
		change_state(ATTACK, attack_duration)


func process_attack() -> void:
	if state_timer < 0:
		change_state(COOLDOWN, cooldown_duration)


func _on_navigation_agent_3d_target_reached() -> void:
	change_state(FACE_PLAYER, face_player_duration)
