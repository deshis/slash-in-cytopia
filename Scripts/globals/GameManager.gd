extends Node

var player: Player = null

var open_menu_count := 0

var current_stage: Node = null
var current_stage_ind  := 0
var stage_root: Node = null
var starting_difficulty := 0.0

var HUD: HudManager = null
var particles: ParticleManager = null
var spawner: EnemySpawner = null

var portaldoor = preload("res://Assets/portal/portal.tscn")

var area_damage_indicator = preload("res://Scenes/items/AreaDamageIndicator.tscn")

var stages := [
	preload("res://Scenes/level/forest/forest_test_variety.tscn"),
	preload("res://Scenes/level/indoor/indoor.tscn"),
	preload("res://Scenes/level/indoor/boss_lab.tscn")
]

func _ready() -> void:
	InventoryManager.process_mode = Node.PROCESS_MODE_DISABLED

func start_game() -> void:
	stage_root = Node.new()
	stage_root.name = "StageRoot"
	add_child(stage_root)
	
	# init hud
	HUD = preload("res://Scenes/ui/hud.tscn").instantiate() as HudManager
	add_child(HUD)
	
	# init particle manager
	particles = preload("res://Scenes/particles/particle_manager.tscn").instantiate() as ParticleManager
	add_child(particles)
	
	load_stage(0)
	
	Engine.time_scale = 1.0
	
	InventoryManager.process_mode = Node.PROCESS_MODE_ALWAYS
	InventoryManager.init()

func load_stage(num: int) -> void:
	for child in stage_root.get_children():
		child.queue_free()
	
	GameStats.stages_cleared = num
	
	var ind_mod = num % stages.size()
	current_stage = stages[ind_mod].instantiate()
	current_stage_ind = num
	
	stage_root.add_child(current_stage)
	player.global_position = Vector3.ZERO
	player.interactables.clear()
	
	HUD.remove_all_bars()
	
	spawner = current_stage.get_child(2)
	spawner.start_spawner.call_deferred()

func load_next_stage() -> void:
	starting_difficulty = spawner.diff.difficulty
	load_stage(current_stage_ind + 1)

func boss_killed(boss: EnemyController) -> void:
	var exit = portaldoor.instantiate()
	current_stage.add_child(exit)
	var location = boss.global_position + Vector3(0,0,-5)
	exit.global_position = location
	
	spawner.credits_cooldown_timer.stop()
	spawner.wave_cooldown_timer.stop()
	
	GameStats.bosses_killed_by_type[boss.enemy.name] = GameStats.bosses_killed_by_type.get(boss.enemy.name, 0) + 1
	AchievementManager.check_achievements()


func new_game() -> void:
	GameStats.reset_game_stats()
	_setup_game()

func restart() -> void:
	GameStats.reset_game_stats()
	_setup_game()

func _setup_game() -> void:
	for child in get_children():
		child.queue_free()

	player = preload("res://Scenes/player/player.tscn").instantiate() as Player
	add_child(player)

	starting_difficulty = 0.0
	InventoryManager.reset_inventory()
	LootDatabase.reset_loot_database()
	start_game()
	AchievementManager.start_checking()


func quit_to_menu()->void:
	AchievementManager.stop_checking()
	ProfileManager.update_stats_from_run()
	GameStats.reset_game_stats()
	
	open_menu_count = 0
	get_tree().paused = false
	InventoryManager.process_mode = Node.PROCESS_MODE_DISABLED
	
	for child in get_children():
		child.queue_free()
	
	var main_menu = preload("res://Scenes/main_menu/main_menu.tscn").instantiate()
	add_child(main_menu)
