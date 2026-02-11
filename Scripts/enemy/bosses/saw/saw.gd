extends EnemyController
class_name Saw

@export var max_navigation_time := 3.0
var navigation_time := 0.0

@export var flee_min_dist_from_player := 5.0
@export var flee_max_dist_from_player := 6.0

@export var flee_duration_min := 1.0
@export var flee_duration_max := 6.0
var flee_duration := 0.0

@export var nanobot: EnemyPrefab

@export var summon_ad_chance = 0.7

@export var nanobot_min_amount := 2
@export var nanobot_max_amount := 5

@export var summon_dist_min := 2.0
@export var summon_dist_max := 3.0

@export var summon_ad_windup_duration := 1.6

@export var face_player_duration := 0.6

@export var boomerang_attack_scene: PackedScene
@export var boomerang_attack_windup_duration := 0.1
@export var boomerang_attack_duration := 0.1

@export var attack_duration := 0.5

@onready var right_saw = $model/rig/Skeleton3D/RightHand/Saw

var enemy_spawner = null

const ATTACK_WINDUP = "attack_windup"
const FLEE = "flee"
const SUMMON_ADS = "summon_ads"
const FACE_PLAYER = "face_player"
const BOOMERANG_WINDUP = "boomerang_windup"
const BOOMERANG_ATTACK = "boomerang_attack"

var attack_after_facing = ATTACK

func _ready() -> void:
	super._ready()
	enemy_spawner = GameManager.current_stage.get_node("EnemySpawner")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	flee_duration -= delta
	
	match state:
		ATTACK_WINDUP:
			process_attack_windup()
		FLEE:
			process_flee(delta)
		
		SUMMON_ADS:
			process_summon_ads()
		
		FACE_PLAYER:
			process_face_player(delta)
		
		BOOMERANG_ATTACK:
			process_boomerang_attack()
		
		BOOMERANG_WINDUP:
			process_boomerang_windup()

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		COOLDOWN, IDLE:
			animator.play("Idle")
		
		ATTACK_WINDUP:
			animator.play("Attack")
		
		BOOMERANG_WINDUP:
			animator.play("AttackBoomerang")
		
		NAVIGATE:
			animator.play("Track")
			navigation_time = 0
		
		FLEE:
			target_provider = TargetPlayer.new()
			animator.play("Track")
			flee_duration = randf_range(flee_duration_min, flee_duration_max)
			
		SUMMON_ADS, BOOMERANG_ATTACK:
			target_provider = TargetSelf.new()

func process_attack_windup():
	if state_timer > 0:
		return
	perform_attack(attack)
	change_state(ATTACK, attack_duration)

func process_idle() -> void:
	var rng = randi() % 2
	
	if rng == 0:
		change_state(NAVIGATE)
	elif rng == 1:
		change_state(FLEE)

func process_navigation(delta: float) -> void:
	navigation_time += delta
	
	if navigation_time > max_navigation_time:
		perform_ranged_attack()
		return
	
	super.process_navigation(delta)

func process_flee(delta):
	if flee_duration < 0:
		perform_ranged_attack()
		return
	
	var dist_to_player = global_position.distance_to(player.global_position)
	
	if dist_to_player < attack_range and flee_duration < flee_duration_min * 2:
		perform_melee_attack()
		return
	
	if target_provider is not TargetAwayFromPlayer:
		if dist_to_player < flee_min_dist_from_player:
			target_provider = TargetAwayFromPlayer.new()
	
	elif target_provider is not TargetPlayer:
		if dist_to_player >= flee_max_dist_from_player:
			target_provider = TargetPlayer.new()
	
	super.process_navigation(delta)

func process_summon_ads() -> void:
	if state_timer > 0:
		return
	
	spawn_ads()
	change_state(COOLDOWN, cooldown_duration)

func process_face_player(delta: float) -> void:
	var dir = (player.global_position - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	if state_timer < 0:
		match attack_after_facing:
			ATTACK:
				change_state(BOOMERANG_WINDUP, boomerang_attack_windup_duration)
				return
				
			BOOMERANG_ATTACK:
				change_state(ATTACK_WINDUP, attack_windup_duration)
				return
		
		change_state(IDLE)

func process_boomerang_windup() -> void:
	if state_timer > 0:
		return
	
	right_saw.visible = false
	perform_attack(boomerang_attack_scene, Vector3(right_saw.get_parent().global_position.x, 0, right_saw.get_parent().global_position.z))
	change_state(BOOMERANG_ATTACK, boomerang_attack_duration)

func process_boomerang_attack() -> void:
	if state_timer > 0:
		return
	
	right_saw.visible = true
	change_state(COOLDOWN, cooldown_duration)


func perform_melee_attack() -> void:
	if randi() % 2 == 0:
		attack_after_facing = ATTACK
	else:
		attack_after_facing = BOOMERANG_ATTACK
	
	change_state(FACE_PLAYER, face_player_duration)

func perform_ranged_attack() -> void:
	if randf() < summon_ad_chance:
		change_state(SUMMON_ADS, summon_ad_windup_duration)
	else:
		attack_after_facing = BOOMERANG_ATTACK
		change_state(FACE_PLAYER, face_player_duration)

func spawn_ads() -> void:
	var horde_spawn_pos = get_pos(global_position, summon_dist_min, summon_dist_max)
	var summon_amount = randi_range(nanobot_min_amount, nanobot_max_amount)
	
	for i in range(summon_amount):
		var spawn_pos = get_pos(horde_spawn_pos, 1.5, 3.0)
		enemy_spawner.spawn_enemy(nanobot, spawn_pos)
		
		var wait_timer = randf_range(0.05, 0.3)
		await get_tree().create_timer(wait_timer).timeout

func get_pos(start_pos: Vector3, radius_min: float, radius_max: float) -> Vector3:
	var dist = randf_range(radius_min, radius_max)
	var angle = randf_range(0, TAU)
	var dir = Vector3(cos(angle), 0, sin(angle))
	
	start_pos += dir * dist
	return start_pos

func die(drop_loot: bool = true) -> void:
	GameManager.boss_killed(self)
	super.die(drop_loot)


func apply_debuff_effect(debuff: DebuffResource) -> void:
	match debuff.debuff_type:
		DebuffResource.DebuffType.STUN:
			return
		DebuffResource.DebuffType.FREEZE:
			return
	
	super.apply_debuff_effect(debuff)


func _on_navigation_agent_3d_target_reached() -> void:
	perform_melee_attack()
