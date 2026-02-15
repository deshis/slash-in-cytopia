extends Resource
class_name EnemyStats

@export var name := "unnamed enemy"
@export var type: EnemyType.Type = EnemyType.Type.NORMAL
@export var speed := 250.0
@export var max_health := 4.0
var health := max_health
@export var cost := 2.0

@export var health_per_level := 0.2

var acceleration := 20.0
var rotation_speed := 8.0

var death_particles: PackedScene
var on_hit_particles: PackedScene

func setup(difficulty_level: int) -> void:
	max_health += difficulty_level * health_per_level
	health = max_health
