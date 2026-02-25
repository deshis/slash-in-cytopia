extends Node3D
class_name EnemySpawner

var player: Player = GameManager.player
@export var enemy_list: Array[EnemyPrefab]
@export var augmented_list: Array[EnemyPrefab]
@export var boss_list: Array[EnemyPrefab]
@export var target_dummy: EnemyPrefab

@export var wave_cooldown_timer: Timer
@export var wave_cooldown_min := 3.0
@export var wave_cooldown_max := 5.0
@export var min_enemy_spawn_amount := 1
@export var max_enemy_spawn_amount := 2

@export var credits_cooldown_timer: Timer
@export var credits_gain_min := 2.0
@export var credits_gain_max := 4.0

@export var augment_enemy_chance := 0.15

@export var boss_cooldown_timer: Timer
@export var boss_cooldown_time := 120.0

var credits := 0.0

@export var diff: DifficultyManager
@export var navigation_region: NavigationRegion3D

var enemy_pools := {}
var init_pool_size := 8


func start_spawner() -> void:
	player = GameManager.player
	init_pools()
	
	if target_dummy:
		await get_tree().create_timer(0.5).timeout
		spawn_target_dummy()
	
	_on_credits_cooldown_timer_timeout()
	_on_wave_cooldown_timer_timeout()
	boss_cooldown_timer.start(boss_cooldown_time)
	
func spawn_target_dummy() -> void:
	pass
	#spawn_enemy(target_dummy, Vector3(2,0,-2))
	
	#GL
	#spawn_enemy(target_dummy, Vector3(5,0,-5))
	#spawn_enemy(target_dummy, Vector3(5,0,5))
	#spawn_enemy(target_dummy, Vector3(-5,0,5))
	
func init_pools() -> void:
	var all_prefabs = enemy_list + augmented_list + boss_list
	
	for prefab in all_prefabs:
		var scene_key = prefab.scene.resource_path
		enemy_pools[scene_key] = []
		
		for i in range(init_pool_size):
			var instance = instantiate_enemy(prefab)
			enemy_pools[scene_key].append(instance)


func instantiate_enemy(prefab: EnemyPrefab) -> EnemyController:
	var instance = prefab.scene.instantiate() as EnemyController
	
	instance.visible = false
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	
	add_child(instance)
	return instance


func get_from_pool(prefab: EnemyPrefab) -> EnemyController:
	var key = prefab.scene.resource_path
	
	if not enemy_pools.has(key):
		enemy_pools[key] = []
	
	var pool = enemy_pools[key]
	
	for enemy in pool:
		if not enemy.visible:
			return enemy
	
	var new_instance = instantiate_enemy(prefab)
	pool.append(new_instance)
	return new_instance


func spawn_enemy(prefab: EnemyPrefab, pos: Vector3 = Vector3.ZERO) -> void:
	var scene = get_from_pool(prefab)
	
	if not scene:
		scene = instantiate_enemy(prefab)
	
	if pos == Vector3.ZERO:
		scene.global_position = get_spawn_pos(scene)
	else:
		scene.global_position = Vector3(pos.x, 0.0, pos.z)
	
	scene.enemy = prefab.stats.duplicate(true)
	scene.particles = prefab.particles
	
	scene.enemy.setup(diff.get_difficulty())
	scene._activate()


func spawn_wave_of_enemies(amount: int) -> void:
	for i in range(amount):
		if credits == 0:
			return
		
		var enemy = null
		var augment_chance = augment_enemy_chance + diff.get_difficulty() * diff.augment_enemy_chance_per_level
		if randf() < augment_chance:
			enemy = get_random_enemy(augmented_list)
		else:
			enemy = get_random_enemy(enemy_list)
		
		var cost = enemy.stats.cost
		
		if cost <= credits:
			spawn_enemy(enemy)
			credits -= enemy.stats.cost


func get_spawn_pos(_enemy: EnemyController) -> Vector3:
	var vp_size = get_viewport().get_size()
	
	var screen_x
	var screen_y
	
	match randi() % 4:
		0:  # left
			screen_x = -1.0
			screen_y = randf()
		1:  # right
			screen_x = 1.0
			screen_y = randf()
		2:  # bottom
			screen_x = randf()
			screen_y = -1.0
		3:  # top
			screen_x = randf()
			screen_y = 1.0
	
	var pos = get_viewport().get_camera_3d().project_position(Vector2(screen_x, screen_y) * Vector2(vp_size.x, vp_size.y), 10)
	var nav_map = navigation_region.get_navigation_map()
	var fixed_pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
	return fixed_pos


func get_random_enemy(array: Array) -> EnemyPrefab:
	var choice = randi_range(0, array.size() - 1)
	var prefab = array[choice]
	
	return prefab


func _on_wave_cooldown_timer_timeout() -> void:
	if not player:
		return
	
	var min_amount = floor(min_enemy_spawn_amount + (diff.get_difficulty() * diff.enemy_spawn_amount_per_level / 2))
	var max_amount = floor(max_enemy_spawn_amount + diff.get_difficulty() * diff.enemy_spawn_amount_per_level)
	var enemy_amount = randi_range(min_amount, max_amount)
	
	spawn_wave_of_enemies(enemy_amount)
	
	var cooldown = randf_range(wave_cooldown_min, wave_cooldown_max)
	wave_cooldown_timer.start(cooldown)


func _on_boss_cooldown_timer_timeout() -> void:
	if not player:
		return
	
	var boss = get_random_enemy(boss_list)
	spawn_enemy(boss)
	
	var cost = boss.stats.cost
	credits -= cost


func _on_credits_cooldown_timer_timeout() -> void:
	if not player:
		return
	
	var min_credits = credits_gain_min + diff.get_difficulty() * diff.credits_per_level
	var max_credits = credits_gain_max + diff.get_difficulty() * diff.credits_per_level
	credits += randi_range(min_credits, max_credits)
	credits_cooldown_timer.start()
