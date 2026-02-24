extends Node

var player: Player = null

var current_stage: Node = null
var current_stage_ind  := 0
var stage_root: Node = null
var starting_difficulty := 0.0

var HUD: HudManager = null
var particles: ParticleManager = null
var spawner: EnemySpawner = null
var nav_handler: NavHandler = null

var portaldoor = preload("res://Assets/portal/portal.tscn")

var area_damage_indicator = preload("res://Scenes/items/AreaDamageIndicator.tscn")

var stages := [
	preload("res://Scenes/level/forest/forest_level.tscn"),
	preload("res://Scenes/level/indoor/indoor.tscn"),
	preload("res://Scenes/level/indoor/boss_lab.tscn")
]


func _ready() -> void:
	InventoryManager.process_mode = Node.PROCESS_MODE_DISABLED	
	Input.set_custom_mouse_cursor(preload("res://Assets/ui/cursor.png"), Input.CURSOR_CAN_DROP)
	Input.set_custom_mouse_cursor(preload("res://Assets/ui/cursor_forbidden.png"), Input.CURSOR_FORBIDDEN)

func start_game(init_player: bool = false) -> void:
	await load_stage(0)
	
	# init player
	if init_player:
		player = preload("res://Scenes/player/player.tscn").instantiate() as Player
		add_child(player)
		current_stage.get_node("CameraPoint").player = player
	
	player.global_position = Vector3.ZERO
	player.interactables.clear()
	
	starting_difficulty = 0.0
	
	# init hud
	HUD = preload("res://Scenes/ui/hud.tscn").instantiate() as HudManager
	add_child(HUD)
	HUD.remove_all_bars()
	
	# init particle manager
	#particles = preload("res://Scenes/particles/particle_manager.tscn").instantiate() as ParticleManager
	#add_child(particles)
	
	Engine.time_scale = 1.0
	
	LootDatabase.reset_loot_database()
	InventoryManager.reset_inventory()
	InventoryManager.process_mode = Node.PROCESS_MODE_ALWAYS
	InventoryManager.init()
	
	AchievementManager.start_checking()


func load_stage(num: int) -> void:
	GameStats.stages_cleared = num
	current_stage_ind = num
	var ind_mod = num % stages.size()
	current_stage = await SceneTransitionManager.transition(stages[ind_mod], "split_wipe", 0.35)
	
	stage_root = Node.new()
	stage_root.name = "StageRoot"
	add_child(stage_root)
	current_stage.reparent(stage_root)
	
	nav_handler = current_stage.get_node("NavigationRegion3D")
	
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
	#GameStats.player_last_hit_by = "Cyber Psychosis (You won!)"
	#player.die()
	
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
	start_game(true)


func quit_to_menu()->void:
	AchievementManager.stop_checking()
	InventoryManager.update_inventory_data()
	ProfileManager.update_stats_from_run()
	GameStats.reset_game_stats()
	MenuManager.active_menu = null
	
	var main_menu = preload("res://Scenes/main_menu/main_menu.tscn")
	SceneTransitionManager.transition(main_menu, "fade_out", 0.0)
	
	get_tree().paused = false
	InventoryManager.process_mode = Node.PROCESS_MODE_DISABLED
