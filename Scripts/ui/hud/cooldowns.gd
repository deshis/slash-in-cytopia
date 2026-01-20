extends Control

var player: Player = GameManager.player

@onready var dash_cooldown_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/DashCooldown/ProgressBar
@onready var dash_cooldown_timer: Timer = $MarginContainer/HBoxContainer/DashCooldown/Timer

@onready var primary_attack_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/PrimaryAttack/ProgressBar
@onready var primary_attack_timer: Timer = $MarginContainer/HBoxContainer/PrimaryAttack/Timer

@onready var secondary_attack_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/SecondaryAttack/ProgressBar
@onready var secondary_attack_timer: Timer = $MarginContainer/HBoxContainer/SecondaryAttack/Timer

@onready var active_item_progress_bar: ProgressBar = $MarginContainer/HBoxContainer/ActiveItem/ProgressBar
@onready var active_item_timer: Timer = $MarginContainer/HBoxContainer/ActiveItem/Timer

@onready var container = $MarginContainer/HBoxContainer
@export var default_primary_attack_icon : Texture2D
@export var default_secondary_attack_icon : Texture2D
@export var default_active_item_icon : Texture2D

func _ready() -> void:
	if not player:
		return
	
	player.dash_used.connect(update_dash_cooldown)
	player.primary_attack_used.connect(update_primary_cooldown)
	player.secondary_attack_used.connect(update_secondary_cooldown)
	player.active_item_used.connect(update_active_item_cooldown)
	
	set_icon(null, "PrimaryAttack")
	set_icon(null, "SecondaryAttack")
	set_icon(null, "ActiveItem")

func _process(_delta: float) -> void:
	dash_cooldown_progress_bar.value = dash_cooldown_timer.time_left
	primary_attack_progress_bar.value = primary_attack_timer.time_left
	secondary_attack_progress_bar.value = secondary_attack_timer.time_left
	active_item_progress_bar.value = active_item_timer.time_left
	
func update_dash_cooldown(cooldown:float)->void:
	dash_cooldown_progress_bar.max_value = cooldown
	dash_cooldown_progress_bar.value = cooldown
	dash_cooldown_timer.start(cooldown)

func update_primary_cooldown(cooldown:float)->void:
	primary_attack_progress_bar.max_value = cooldown
	primary_attack_progress_bar.value = cooldown
	primary_attack_timer.start(cooldown)

func update_secondary_cooldown(cooldown:float)->void:
	secondary_attack_progress_bar.max_value = cooldown
	secondary_attack_progress_bar.value = cooldown
	secondary_attack_timer.start(cooldown)
	
func update_active_item_cooldown(cooldown:float)->void:
	active_item_progress_bar.max_value = cooldown
	active_item_progress_bar.value = cooldown
	active_item_timer.start(cooldown)

func set_icon(icon: Texture2D, item_type: String) -> void:
	for i in range(container.get_child_count()):
		var child = container.get_child(i)
		if child.name == item_type:
			if icon:
				child.texture = icon
			else:
				child.texture = get_default_texture(item_type)
			return

func get_default_texture(item_type: String) -> Texture2D:
	match item_type:
		"PrimaryAttack":
			return default_primary_attack_icon
		"SecondaryAttack":
			return default_secondary_attack_icon
		"ActiveItem":
			return default_active_item_icon
	return null
