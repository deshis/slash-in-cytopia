extends EnemyController
class_name AugSlasherRanged

@export var face_player_duration := 0.667
@export var dash_speed := 6.5
@export var dash_duration := 5.5
@export var strafe_speed := 4.0
@export var strafe_duration := 2.0
@export var charge_up_duration := 1.0
@export var target_range := 6.0
@export var range_variance := 1.0
@export var fire_rate := 0.2
@export var burst_count := 1

@onready var attack_duration = $"model/AnimationPlayer".get_animation("Attack").length 
@onready var slash_trail = $"model/SlashMesh"
@onready var sword_mesh = $model/rig/Skeleton3D/BoneAttachment3D/Offset/MeshInstance3D
@onready var helmet = $model/rig/Skeleton3D/Helmet
@onready var weapon_mesh = $Weapon

var current_target_range: float
var strafe_direction := 1

const FACE_PLAYER = "face_player"
const DASH = "dash"
const ATTACK_WRAP_UP = "attack_wrap_up"
const STRAFE = "strafe"
const SHOOT = "shoot"
const CHARGE_UP = "charge_up"

var is_ranged: bool = true
var charging_up: bool = false
var charge_up_overhead := 1.0

var i := 0
var shots_fired := 0

var strafe_speed_og := 0.0
var current_speed_og := 0.0

var mat
var charge_color_og
var charge_emission_og

func _ready() -> void:
	super._ready()

	sword_mesh.mesh = weapon_mesh.mesh
	
	sword_mesh.rotation = Vector3(-0.6,160,0)
	sword_mesh.scale = Vector3(0.08, 0.095, 0.095)
	sword_mesh.transform.origin.z += 0.1
	sword_mesh.transform.origin.y += 0.1
	
	mat = sword_mesh.get_active_material(1).duplicate()
	sword_mesh.set_surface_override_material(1, mat)
	
	helmet.set_visible(true)
	
	strafe_speed_og = strafe_speed
	current_speed_og = self.current_speed
	
	charge_color_og = mat.albedo_color
	charge_emission_og = mat.emission_energy_multiplier
	
func change_sword_mesh(new_mesh_path: String):
	pass
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	match state:
		FACE_PLAYER:
			process_face_player(delta)
		
		DASH:
			process_dash(delta)
		
		ATTACK_WRAP_UP:
			process_attack_wrap_up(delta)
			
		STRAFE:
			process_strafe(delta)
			
		SHOOT:
			process_attack()
			
		CHARGE_UP:
			process_strafe(delta)
			
			
func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		COOLDOWN:
			animator.play("Idle")
		
		STUN:
			animator.play("Stun")
		
		NAVIGATE:
			animator.play("Walk")
			current_speed = enemy.speed
		
		FACE_PLAYER:
			#animator.play("Attack")
			target_provider = TargetSelf.new()
		
		DASH:
			current_speed = dash_speed
		
		ATTACK_WRAP_UP:
			current_speed = 0
			
		STRAFE:
			animator.play("Walk")
			current_speed = strafe_speed
			
			#doesn't seem to do shit
			current_target_range = target_range + randf_range(-range_variance, range_variance)
			
		CHARGE_UP:
			if charging_up:
				return
				
			SoundManager.play_sfx("charge_up", self.global_position)
			animator.play("Walk")
			current_speed = strafe_speed
			
			self.current_speed *= 0.5
			self.strafe_speed *= 0.5
			
			#doesn't seem to do shit
			current_target_range = target_range + randf_range(-range_variance, range_variance)

func process_face_player(delta: float) -> void:

	if not player:
		return
	
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	## Charge-up
	if state_timer < 0:
		print("Charging up")
		change_state(CHARGE_UP, charge_up_duration + charge_up_overhead)
		charging_up = true

func process_attack() -> void:
	
	self.current_speed *= 0.35
	self.strafe_speed *= 0.35
	
	change_state(STRAFE, cooldown_duration)
	
	var shots_fired := 0
	
	if strafe_direction == 0:
		#lmao
		strafe_direction = randf_range(-5000,5000)
	else:
		strafe_direction = randf_range(-2,2)
	
	#perform_attack(attack)
	#change_state(STRAFE, strafe_duration)
	
	start_burst()
	
func process_dash(delta: float) -> void:
	var dash_dir = Vector3(sin(rotation.y), 0, cos(rotation.y)).normalized()
	apply_movement(delta, dash_dir)
	
	if state_timer < 0:
		change_state(ATTACK_WRAP_UP, attack_duration-face_player_duration-dash_duration)

func process_attack_wrap_up(_delta: float) -> void:
	if state_timer < 0:
		change_state(COOLDOWN, cooldown_duration)

func _on_navigation_agent_3d_target_reached() -> void:
	#change_state(FACE_PLAYER, face_player_duration)

	change_state(FACE_PLAYER, 0.25)

func charge_up():
	pass

##NOTE:
#Handles both strafing and partial charge-up logic
func process_strafe(delta: float) -> void:
	
	if charging_up:
		mat.emission_energy_multiplier += 0.05
		mat.albedo_color += Color(0.05,0.05,0.05)
		
	#ensuring the attack goes off with a generous trigger
	if charging_up && state_timer < charge_up_overhead:
		charging_up = false
		
		self.current_speed = current_speed_og
		self.strafe_speed = strafe_speed_og
		
		print("Charged up")
		change_state(SHOOT, attack_windup_duration)
		
	if not player:
		change_state(IDLE)
		return
		
	if state_timer < 0:            
		change_state(IDLE)
		return
				
	var dist = global_position.distance_to(player.global_position)
	
	var dir_to_player = (player.global_position - global_position).normalized()
	var desired_pos = player.global_position - dir_to_player * current_target_range
	
	#circular strafe
	var strafe_offset = dir_to_player.cross(Vector3.UP) #* randf_range(-1,1)

	if strafe_direction > 0:
		desired_pos += strafe_offset
	if strafe_direction < 0: 
		desired_pos -= strafe_offset
		
	nav_agent.set_target_position(desired_pos)
	var next_pos = nav_agent.get_next_path_position()
	var move_dir = (next_pos - global_position).normalized()
	velocity = move_dir * current_speed
	
	#face player while strafing
	update_facing_dir(delta, dir_to_player)  
	
	move_and_slide()
	
func start_burst():

	if shots_fired < burst_count:
		perform_attack(attack)
		shots_fired += 1
		get_tree().create_timer(fire_rate).timeout.connect(start_burst)
		
		mat.emission_energy_multiplier -= 0.5
		mat.albedo_color -= Color(0.4,0.4,0.4)
		
		if shots_fired > burst_count-1:
			mat.albedo_color += Color(5,0,1)

	else:

		mat.emission_energy_multiplier = charge_emission_og
		mat.albedo_color = charge_color_og
		
		shots_fired = 0
		self.current_speed = current_speed_og
		self.strafe_speed = strafe_speed_og
		change_state(STRAFE, strafe_duration)

func _on_shoot_cooldown_timeout() -> void:
	pass
	#perform_attack(attack)

	
	
