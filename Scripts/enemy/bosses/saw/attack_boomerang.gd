extends Attack

@export var arc_radius_min := 1.5
@export var arc_radius_max := 3.5
@export var arc_angle_min := 270.0
@export var arc_angle_max := 360.0

@export var rot_speed := 20

var previous_pos = null
var speed := 0.0

var center
var radius
var angle_start
var angle_end
var time = 0.0

var enemy

const ARC = "arc"
const RETURN = "return"
var state = ARC

func _ready() -> void:
	enemy = get_parent()
	
	var enemy_pos = enemy.global_position
	radius = randf_range(arc_radius_min, arc_radius_max)
	
	var forward = enemy.global_transform.basis.z
	center = enemy_pos + forward * radius
	
	var start_vec = Vector2(enemy_pos.x - center.x, enemy_pos.z - center.z)
	angle_start = start_vec.angle()
	angle_end = deg_to_rad(randf_range(arc_angle_min, arc_angle_max))
	
	super._ready()

func _physics_process(delta: float) -> void:
	rotate(Vector3.UP, rot_speed*delta)
	
	match state:
		ARC:
			process_arc()
		
		RETURN:
			process_return(delta)
	
	time += delta
	
	if previous_pos:
		speed = previous_pos.distance_to(global_position) / delta
	previous_pos = global_position

func process_arc() -> void:
	if time < duration:
		var t = time / duration
		var angle = lerp(angle_start, angle_start + angle_end, t)
		
		global_position =Vector3(
			center.x + cos(angle) * radius,
			global_position.y,
			center.z + sin(angle) * radius
		)

func process_return(delta: float) -> void:
	var enemy_pos = enemy.global_position
	
	var dir = (enemy_pos - global_position).normalized()
	global_position += dir * speed * delta
	
	if global_position.distance_to(enemy_pos) < 0.3:
		remove_attack()

func start_attack() -> void:
	for body in area.get_overlapping_areas():
		_on_area_3d_area_entered(body)
	
	await get_tree().create_timer(duration).timeout
	state = RETURN
