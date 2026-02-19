class_name EnemyPrefab
extends Resource

@export var stats: EnemyStats
@export var scene: PackedScene
@export var particles: Dictionary[String, String] = {
	"on_hit": "on_hit_electric",
	"on_death": "on_death_electric",
}
@export var target_provider: TargetProvider
