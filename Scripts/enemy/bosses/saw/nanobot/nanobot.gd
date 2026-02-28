extends Microbot
class_name Nanobot

func _ready() -> void:
	super._ready()
	change_state(COOLDOWN, cooldown_duration)
	#mesh = $model/rig/Skeleton3D/Microbot
func _on_attack_area_area_entered(_area: Area3D, damage: float = enemy.damage) -> void:
	GameStats.player_last_hit_by = enemy.name
	player.take_damage(damage, self, true)

func die(_drop_loot: bool = true) -> void:
	super.die(false)
