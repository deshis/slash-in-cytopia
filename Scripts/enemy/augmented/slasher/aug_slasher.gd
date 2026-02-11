extends Slasher
class_name AugSlasher

@export var max_dist_from_player := 600
@export var dash_chance := 0.4
@export var max_dash_cooldown := 0.5
var dash_cooldown := 0.0

@export var max_dash_amount := 3
@export var min_dash_amount := 2
var dash_amount := 0
var current_dash := 0

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		IDLE:
			current_dash = 0
			dash_amount = randi_range(min_dash_amount, max_dash_amount)

func process_navigation(delta: float) -> void:
	dash_cooldown -= delta
	
	var dist = global_position.distance_to(player.global_position)
	if dist > max_dist_from_player and dash_cooldown < 0:
		dash_cooldown = max_dash_cooldown
		
		if randf() < dash_chance:
			change_state(FACE_PLAYER, face_player_duration)
			return
	
	super.process_navigation(delta)

func process_dash(delta: float) -> void:
	var dash_dir = Vector3(sin(rotation.y), 0, cos(rotation.y)).normalized()
	apply_movement(delta, dash_dir)
	
	if state_timer < 0:
		current_dash += 1
		
		if current_dash < dash_amount:
			change_state(FACE_PLAYER, face_player_duration)
		else:
			change_state(COOLDOWN, cooldown_duration)
