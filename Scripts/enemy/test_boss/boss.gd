extends EnemyController	
class_name Boss
var proj = preload("res://Scenes/enemy/test_boss/bullet.tscn")


@export var face_player_length_timer: Timer
var face_player = false

@export var dash_speed = 1000
var is_dashing = false

@export var nav:NavigationRegion2D


func _ready() -> void:
	# self.player=$"../../Player"
	# self.nav_agent.set_navigation_map(nav.get_rid())
	pass

func _physics_process(delta: float) -> void:
	if not player or not target_provider:
		return
	
	if is_dashing:
		var dash_dir = Vector2.UP.rotated(rotation)
		apply_movement(delta, dash_dir)
	else:
		process_navigation(delta)
	
	if face_player:
		face_towards_player(delta)


func perform_attack() -> void:
	shoot()
	attack_area.visible = true
	attack_area_hitbox.disabled = false
	is_dashing = true
	current_speed = dash_speed
	attack_length_timer.start()


func shoot():
	var ins:RigidBody2D = proj.instantiate()
	add_child(ins)
	ins.global_position = global_position
	var direction = (player.global_position - ins.global_position).normalized()
	var force_strength = 500.0
	ins.apply_impulse(Vector2.ZERO, direction * force_strength)



func face_towards_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)


func _on_navigation_agent_2d_target_reached() -> void:
	target_provider = TargetSelf.new()
	face_player = true
	face_player_length_timer.start()


func _on_face_player_length_timer_timeout() -> void:
	face_player = false
	wait_before_attack_timer.start()

func _on_wait_before_attack_timer_timeout() -> void:
	perform_attack()

func _on_attack_length_timer_timeout() -> void:
	attack_area.visible = false
	attack_area_hitbox.disabled = true

	is_dashing = false
	current_speed = enemy.speed
	
	wait_after_attack_timer.start()

func _on_wait_after_attack_timer_timeout() -> void:
	target_provider = TargetPlayer.new()
