extends CharacterBody3D
class_name PickupableObject

@export var strength := 2.5
@export var duration := 0.3

var player: Player

var direction := Vector3.FORWARD
#var velocity := Vector3.ZERO
var time_left := 0.0
var active := false

func setup(p: Player, dir: Vector3, impulse: float = strength, dur: float = duration) -> void:
	player = p
	direction = dir
	strength = impulse
	duration = dur
	
	# quick hack to ensure loot stays on ground
	global_position.y = 0
	direction.y = 0
	apply_impulse()

func apply_impulse() -> void:
	randomize_impulse()
	
	velocity = direction.normalized() * strength
	time_left = duration
	active = true

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	move_and_slide()
	
	var decay = delta / duration
	velocity = velocity.lerp(Vector3.ZERO, decay)
	
	time_left -= delta
	if time_left <= 0.0:
		velocity = Vector3.ZERO
		active = false

func randomize_impulse() -> void:
	var min_str = strength * 0.8
	var max_str = strength * 1.2
	strength = randf_range(min_str, max_str)
	
	var min_dur = duration * 0.8
	var max_dur = duration * 1.2
	duration = randf_range(min_dur, max_dur)
	
	var rot_angle = 30.0
	var angle = deg_to_rad(randf_range(-rot_angle, rot_angle))
	direction = direction.rotated(Vector3.UP, angle)
