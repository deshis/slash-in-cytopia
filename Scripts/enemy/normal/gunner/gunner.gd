extends EnemyController
class_name SlasherRanged

@export var face_player_duration := 0.667
@export var dash_speed := 6.5
@export var dash_duration := 5.5
@export var strafe_speed := 4.0
@export var strafe_duration := 2.0
@export var charge_up_duration := 0.25
@export var target_range := 6.0
@export var range_variance := 1.0
@export var fire_rate := 0.25
@export var burst_count := 1
@export var laser_pointer_direction: Node3D
@export var laser_pointer_mesh: Node3D

@onready var attack_duration = $"model/AnimationPlayer".get_animation("Attack").length
@onready var weapon_mesh = $Weapon
@onready var attachment_weapon_mesh = $model/rig/Skeleton3D/WeaponAttachment/Offset/MeshInstance3D
@onready var laser_pointer_location = $model/rig/Skeleton3D/WeaponAttachment/LaserPointerAttach
var mat

var current_target_range: float
var strafe_direction := 1

const FACE_PLAYER = "face_player"
const DASH = "dash"
const ATTACK_WRAP_UP = "attack_wrap_up"
const STRAFE = "strafe"
const SHOOT = "shoot"
const CHARGE_UP = "charge_up"

var shot_burst: bool = false
var is_stuck: bool = false
var is_ranged: bool = true
var charging_up: bool = false
var charge_up_overhead := 1.0

var i := 0
var shots_fired := 0

var strafe_speed_og := 0.0
var current_speed_og := 0.0

## Laser pointer

var parent = null
var shooter: Node3D
var hit_pos
var effect: Node3D

func _ready() -> void:
	super._ready()
	shooter = get_parent()
	
	is_dead = false
	
	attachment_weapon_mesh.mesh = weapon_mesh.mesh
	
	attachment_weapon_mesh.rotation = Vector3(-0.6,160,0)
	attachment_weapon_mesh.scale = Vector3(0.08, 0.095, 0.090)
	attachment_weapon_mesh.transform.origin.z += 0.1
	attachment_weapon_mesh.transform.origin.y += 0.1
	
	#laser_pointer_location.transform = attachment_weapon_mesh.transform
	#laser_pointer_location.transform.origin.x += 0.05

	
	mat = attachment_weapon_mesh.get_active_material(1).duplicate()
	attachment_weapon_mesh.set_surface_override_material(1, mat)
	
	strafe_speed_og = strafe_speed
	current_speed_og = self.current_speed
	
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
			target_provider = TargetSelf.new()
		
		DASH:
			current_speed = dash_speed
		
		ATTACK_WRAP_UP:
			current_speed = 0
			
		STRAFE:
			shot_burst = false
			
			##NOTE: forcing to shoot if stuck jerking off for seemingly no reason
			get_tree().create_timer(strafe_duration + 0.25).timeout.connect(charged_up)
			current_target_range = target_range
			
			animator.play("Walk")
			current_speed = strafe_speed

			current_target_range = target_range + randf_range(-range_variance, range_variance)

			
		CHARGE_UP:
			if charging_up:
				return
				
			#SoundManager.play_sfx("charge_up", self.global_position)
			animator.play("Walk")
			current_speed = strafe_speed
			
			#self.current_speed *= 0.5
			#self.strafe_speed *= 0.5
			
			#doesn't seem to do shit
			current_target_range = target_range + randf_range(-range_variance, range_variance)
			
		SHOOT:
			shoot()
		

func process_face_player(delta: float) -> void:

	if not player:
		return
	
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	## Charge-up
	if state_timer < 0:
		#print("Charging up")
		change_state(CHARGE_UP, charge_up_duration + charge_up_overhead)
		charging_up = true
		
func _process(_delta: float) -> void:
	
	if self.state == DEAD:
		laser_pointer_mesh.visible = false
		return
		
	var shoot_pos = laser_pointer_location.global_position
	var target_pos = laser_pointer_direction.global_position
	var direction = (target_pos - shoot_pos).normalized()
	var space = shooter.get_world_3d().direct_space_state
		
	var distance = shoot_pos.distance_to(target_pos)
	var to = shoot_pos + (direction.normalized() * (distance*8))
	var query = PhysicsRayQueryParameters3D.create(shoot_pos, to)
	
	query.exclude = [shooter] + shooter.get_children()

	var result = space.intersect_ray(query)
	var beam_end_pos: Vector3

	if !result:
		beam_end_pos = query.to
		laser_pointer(shoot_pos, beam_end_pos)
		return
		
	var hit_pos = result.position
	laser_pointer(shoot_pos, hit_pos)

func laser_pointer(from: Vector3, to: Vector3) -> void:
	
	if !laser_pointer_mesh:
		print("no mesh")
		return
		
	var dist = from.distance_to(to)
	var dir = (to - from).normalized()
	
	laser_pointer_mesh.global_position = (from + to)/2.0
	laser_pointer_mesh.look_at(to, Vector3.UP)
	laser_pointer_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
	laser_pointer_mesh.mesh.height = dist
	
func shoot() -> void:
	
	self.current_speed *= 0.35
	self.strafe_speed *= 0.35
	
	var shots_fired := 0
	
	if strafe_direction == 0:
		#lmao
		strafe_direction = randf_range(-5000,5000)
	else:
		strafe_direction = randf_range(-2,2)
	
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
	##NOTE: Makes them play a suffed animation
	change_state(FACE_PLAYER, 0.25)
	
func charged_up() -> void:
	
	if is_stuck:
		is_stuck = false
		charging_up = false
		
		self.current_speed = current_speed_og
		self.strafe_speed = strafe_speed_og
		
		#print("Charged up")
		change_state(SHOOT, attack_windup_duration)
		return
		
	is_stuck = false
	charging_up = false
	
	self.current_speed = current_speed_og
	self.strafe_speed = strafe_speed_og
	
	#print("Charged up")
	change_state(SHOOT, attack_windup_duration)

##NOTE:
#Handles both strafing and partial charge-up logic
func process_strafe(delta: float) -> void:
	if not player:
		change_state(IDLE)
		return

	if charging_up && !shot_burst && state_timer < 0:
		shot_burst = true
		is_stuck = false
		charged_up()
		
	is_stuck = true

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
	
func charge_up():
	pass
	
func start_burst():
	
	if shots_fired < burst_count:
		perform_attack(attack)
		shots_fired += 1
		get_tree().create_timer(fire_rate).timeout.connect(start_burst)
		
	else:
		if shots_fired == burst_count:
			shots_fired = 0
			self.current_speed = current_speed_og
			self.strafe_speed = strafe_speed_og
			change_state(STRAFE, strafe_duration)
			return
			
		perform_attack(attack)
		shots_fired = 0
		self.current_speed = current_speed_og
		self.strafe_speed = strafe_speed_og
		change_state(STRAFE, strafe_duration)

func _on_shoot_cooldown_timeout() -> void:
	pass
	#perform_attack(attack)

	
