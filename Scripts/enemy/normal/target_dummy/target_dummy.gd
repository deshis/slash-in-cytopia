extends EnemyController
class_name target_dummy

@export var face_player_duration := 0.667
@export var dash_speed := 6.5
@export var dash_duration := 0.5

@onready var attack_duration = $"model/AnimationPlayer".get_animation("Attack").length 
@onready var slash_trail = $"model/SlashMesh"



const FACE_PLAYER = "face_player"
const DASH = "dash"
const ATTACK_WRAP_UP = "attack_wrap_up"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	match state:
		FACE_PLAYER:
			process_face_player(delta)
		
		DASH:
			process_dash(delta)
		
		ATTACK_WRAP_UP:
			process_attack_wrap_up(delta)


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		COOLDOWN:
			slash_trail.visible = false
			animator.play("Idle")
		
		STUN:
			slash_trail.visible = false
			animator.play("Stun")
		
		NAVIGATE:
			slash_trail.visible = false
			animator.play("Walk")
			current_speed = enemy.speed
		
		FACE_PLAYER:
			animator.play("Attack")
			target_provider = TargetSelf.new()
		
		DASH:
			current_speed = dash_speed
		
		ATTACK_WRAP_UP:
			current_speed = 0


func process_face_player(delta: float) -> void:
	if not player:
		return
	
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	#if state_timer < 0:
		#change_state(ATTACK, attack_windup_duration)

func process_attack() -> void:
	perform_attack(attack)
	change_state(DASH, dash_duration)

func process_dash(delta: float) -> void:
	var dash_dir = Vector3(sin(rotation.y), 0, cos(rotation.y)).normalized()
	apply_movement(delta, dash_dir)
	
	if state_timer < 0:
		change_state(ATTACK_WRAP_UP, attack_duration-face_player_duration-dash_duration)

func process_attack_wrap_up(_delta: float) -> void:
	if state_timer < 0:
		change_state(COOLDOWN, cooldown_duration)

func _on_navigation_agent_3d_target_reached() -> void:
	change_state(FACE_PLAYER, face_player_duration)
