extends Node3D
class_name DifficultyManager

@export var seconds_per_level := 20
@export var enemy_spawn_amount_per_level := 0.2
@export var credits_per_level := 0.3
@export var heal_amount_per_level := 0.2
@export var augment_enemy_chance_per_level := 0.015

var difficulty := 0.0

func _ready() -> void:
	difficulty = GameManager.starting_difficulty

func _physics_process(delta: float) -> void:
	difficulty += delta / seconds_per_level

func get_difficulty() -> int:
	return int(floor(difficulty))
