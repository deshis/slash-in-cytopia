extends Node3D
class_name Interactable

@export var health := 4.0
@export var loot_table: LootTable

func take_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		die()

func die() -> void:
	LootDatabase.drop_loot(self, loot_table)
	queue_free()
