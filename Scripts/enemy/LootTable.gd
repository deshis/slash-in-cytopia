extends Resource
class_name LootTable

@export var loot_drop_chance: float
@export var loot_rarity_weights = {
	"consumer": 0,
	"military": 0,
	"prototype": 0,
	"apex_anomaly": 0,
}

@export var health_drop_chance: float
@export var health_drop_amount: int
