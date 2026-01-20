extends Node
class_name HudManager

var player: Player = GameManager.player

@onready var inventory = $Inventory
@onready var cooldowns = $SkillCooldowns
@onready var health_bars := $HPBars
@onready var health_bar = $HPBarPlayer
@onready var game_over_screen: Control = $GameOverScreen

var health_bar_pool = []
var health_bar_pool_size := 16

func _ready() -> void:
	if player:
		health_bar.setup(player, player.health, player.max_health)
		game_over_screen.setup(player)
	
	for i in range(health_bar_pool_size):
		instantiate_hp_bar()

func instantiate_hp_bar() -> Control:
	var bar = preload("res://Scenes/HPBar.tscn").instantiate()
	bar.is_static = false
	bar.visible = false
	health_bars.add_child(bar)
	health_bar_pool.append(bar)
	
	return bar

func get_hp_bar(enemy: CharacterBody3D) -> Control:
	var bar = get_bar_from_pool()
	bar.setup(enemy, enemy.enemy.health, enemy.enemy.max_health)
	
	return bar

func get_bar_from_pool() -> Control:
	for bar in health_bar_pool:
		if not bar.visible:
			return bar
	
	return instantiate_hp_bar()

func set_cooldown_icon(icon: Texture2D, item_type: String) -> void:
	cooldowns.set_icon(icon, item_type)


func remove_all_bars() -> void:
	for bar in health_bar_pool:
		bar.visible = false
