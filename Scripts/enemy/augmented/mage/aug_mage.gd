extends Mage
class_name AugMage

@export var ranged_attack_small: PackedScene = null
@export var small_aoe_max := 10
@export var small_aoe_min := 3
var aoe_amount := 0
@export var aoe_radius_max := 2.5
@export var aoe_radius_min := 1.0

func process_ranged_attack(delta: float) -> void:
	if aoe_amount > 0:
		aoe_amount -= 1
		
		var wait_time = randf_range(0.05, 0.25)
		var timer = Timer.new()
		get_parent().add_child(timer)
		timer.start(wait_time)
		await timer.timeout
		
		var pos = get_random_pos(ranged_attack_pos, aoe_radius_min, aoe_radius_max)
		
		if state != STUN:
			perform_attack(ranged_attack_small, pos)
	
	super.process_ranged_attack(delta)


func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		RANGED_ATTACK:
			aoe_amount = randi_range(small_aoe_min, small_aoe_max)


func get_random_pos(center: Vector3, min_radius: float, max_radius: float) -> Vector3:
	var angle = randf_range(0, TAU)
	var dir = Vector3(cos(angle), 0.0, sin(angle))
	var dist = randf_range(min_radius, max_radius)
	var pos = center + dir * dist
	pos.y = 0.0
	
	return pos


func _on_attack_area_area_entered(_area: Area3D, damage: float = enemy.damage) -> void:
	GameStats.player_last_hit_by = enemy.name
	
	# small ranged attack ignores i-frames
	if _area.get_parent().scene_file_path == ranged_attack_small.resource_path:
		player.take_damage(damage, self, true)
	else:
		player.take_damage(damage, self)
