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

var _popup_queue: Array[Dictionary] = []
var _current_popup: Control = null
const AchievementPopupScene = preload("res://Scenes/ui/achievement_popup.tscn")

func _ready() -> void:
	if player:
		health_bar.setup(player, player.health, player.max_health)
		game_over_screen.setup(player)
	
	for i in range(health_bar_pool_size):
		instantiate_hp_bar()

	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)

func instantiate_hp_bar() -> Control:
	var bar = preload("res://Scenes/enemy/hp_bar_enemy.tscn").instantiate()
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


func _on_timer_timeout() -> void:
	pass # Replace with function body.


func _on_achievement_unlocked(data: Dictionary) -> void:
	_popup_queue.append(data)
	if _current_popup == null:
		_show_next_popup()


func _show_next_popup() -> void:
	if _popup_queue.is_empty():
		return
	var data := _popup_queue.pop_front() as Dictionary
	var popup := AchievementPopupScene.instantiate()
	add_child(popup)
	_current_popup = popup
	popup.popup_finished.connect(_on_popup_finished)
	popup.setup(data)


func _on_popup_finished() -> void:
	_current_popup = null
	_show_next_popup()
