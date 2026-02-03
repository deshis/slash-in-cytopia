extends Node

var consumer_items := [
	# SURVIVABILITY
	preload("res://Scripts/items/consumer/ChromaticChassis.tres"),
	preload("res://Scripts/items/consumer/CrystalShell.tres"),
	
	# MOVEMENT
	preload("res://Scripts/items/consumer/SpringedBoots.tres"),
	preload("res://Scripts/items/consumer/UnderclockedExoskeleton.tres"),
	
	# UTILITY
	preload("res://Scripts/items/consumer/DashInverter.tres"),
	preload("res://Scripts/items/consumer/OneLeafClover.tres"),
	preload("res://Scripts/items/consumer/QuantumGlove.tres"),
	
	# DAMAGE
	preload("res://Scripts/items/consumer/BrokenNeedle.tres"),
	
	# ACTIVE_ITEM
	preload("res://Scripts/items/consumer/TestActiveItem.tres"),
	preload("res://Scripts/items/consumer/UsedNeuroblockers.tres"),
	preload("res://Scripts/items/consumer/Brick.tres"),
	
	# PRIMARY_ATTACK
	preload("res://Scripts/items/consumer/ChromeTippedSpear.tres"),
	preload("res://Scripts/items/consumer/Dagger.tres"),
	preload("res://Scripts/items/consumer/Slapstick.tres"),
	
	# SECONDARY_ATTACK
	preload("res://Scripts/items/consumer/Axe.tres"),
	preload("res://Scripts/items/consumer/Maul.tres"),
]

var military_items := [
	# SURVIVABILITY
	preload("res://Scripts/items/military/NanoShell.tres"),
	preload("res://Scripts/items/military/PlasteelChassis.tres"),
	preload("res://Scripts/items/military/SecondHeart.tres"),
	
	# MOVEMENT
	preload("res://Scripts/items/military/Exoskeleton.tres"),
	preload("res://Scripts/items/military/SpringedPlasteelBoots.tres"),
	
	# UTILITY
	preload("res://Scripts/items/military/DashLimiter.tres"),
	preload("res://Scripts/items/military/MilitaryClover.tres"),
	preload("res://Scripts/items/military/PlasteelToolbelt.tres"),
	preload("res://Scripts/items/military/SingularityGlove.tres"),
	
	# DAMAGE
	preload("res://Scripts/items/military/BlackBurner.tres"),
	preload("res://Scripts/items/military/EnergyConverter.tres"),
	preload("res://Scripts/items/military/LaserSensor.tres"),
	preload("res://Scripts/items/military/NanomendedNeedle.tres"),
	
	# ACTIVE_ITEM
	preload("res://Scripts/items/military/DashReplicator.tres"),
	preload("res://Scripts/items/military/EMP.tres"),
	preload("res://Scripts/items/military/QualityNeuroblockers.tres"),
	
	# PRIMARY_ATTACK
	preload("res://Scripts/items/military/Katana.tres"),
	preload("res://Scripts/items/military/NanoSpear.tres"),
	
	# SECONDARY_ATTACK
	preload("res://Scripts/items/military/AbsoluteZero.tres"),
	preload("res://Scripts/items/military/LaserFlail.tres"),
]

var prototype_items := [
	# SURVIVABILITY
	preload("res://Scripts/items/prototype/SpectriteChassis.tres"),
	preload("res://Scripts/items/prototype/SpectriteShell.tres"),
	
	# MOVEMENT
	preload("res://Scripts/items/prototype/Arievistan.tres"),
	preload("res://Scripts/items/prototype/OverclockedExoskeleton.tres"),
	
	# UTILITY
	preload("res://Scripts/items/prototype/CloverLOA.tres"),
	preload("res://Scripts/items/prototype/PlasmiumToolbelt.tres"),
	
	# DAMAGE
	preload("res://Scripts/items/prototype/EnergyConverterMk2.tres"),
	preload("res://Scripts/items/prototype/PlasmiumSensor.tres"),
	preload("res://Scripts/items/prototype/SpectriteNeedle.tres"),
	
	# ACTIVE_ITEM
	preload("res://Scripts/items/prototype/RealityFracture.tres"),
	preload("res://Scripts/items/prototype/Vampirism.tres"),
	
	# PRIMARY_ATTACK
	preload("res://Scripts/items/prototype/ArcFlash.tres"),
	preload("res://Scripts/items/prototype/Statstick.tres"),
	
	# SECONDARY_ATTACK
	preload("res://Scripts/items/prototype/Dawn.tres"),
	preload("res://Scripts/items/prototype/Dusk.tres"),
	preload("res://Scripts/items/prototype/Labrys.tres"),
]

var apex_anomaly_items := [
	preload("res://Scripts/items/apex_anomaly/SingularityCircuit.tres"),
]

var type_colors := {
	ItemType.Type.NONE: Color(0.78, 0.812, 0.8, 1.0),
	ItemType.Type.SURVIVABILITY: Color(0.659, 0.792, 0.345, 1.0),
	ItemType.Type.MOVEMENT: Color(0.871, 0.62, 0.255, 1.0),
	ItemType.Type.UTILITY: Color(0.451, 0.745, 0.827, 1.0),
	ItemType.Type.DAMAGE: Color(0.776, 0.318, 0.592, 1.0),
	ItemType.Type.ACTIVE_ITEM: Color(0.506, 0.592, 0.588, 1.0),
	ItemType.Type.PRIMARY_ATTACK: Color(0.812, 0.341, 0.235, 1.0),
	ItemType.Type.SECONDARY_ATTACK: Color(0.647, 0.188, 0.188, 1.0),
}

var grade_colors := {
	ItemType.Grade.CONSUMER: Color(0.922, 0.929, 0.914, 1.0),
	ItemType.Grade.MILITARY: Color(0.478, 0.212, 0.482, 1.0),
	ItemType.Grade.PROTOTYPE: Color(0.91, 0.757, 0.439, 1.0),
	ItemType.Grade.APEX_ANOMALY: Color(0.46, 0.622, 1.0, 1.0)
}

var enemy_loot_table = preload("res://Scripts/globals/loot_table_enemy.tres").duplicate(true)
var aug_enemy_loot_table = preload("res://Scripts/globals/loot_table_aug_enemy.tres").duplicate(true)
var boss_loot_table = preload("res://Scripts/globals/loot_table_boss.tres").duplicate(true)

var base_enemy_loot_table = preload("res://Scripts/globals/loot_table_enemy.tres")
var base_aug_enemy_loot_table = preload("res://Scripts/globals/loot_table_aug_enemy.tres")
var base_boss_loot_table = preload("res://Scripts/globals/loot_table_boss.tres")

var upgrade_loot_rarity_chance := 0.0
var pickup_slot_amount := 3

var pickupable_item = preload("res://Scenes/items/pickupable_loot.tscn")
var pickupable_health = preload("res://Scenes/items/pickupable_health.tscn")

func drop_loot(object: Node3D, loot_table: LootTable = null, loot_impulse_strength: float = 0.0) -> void:
	if not loot_table:
		loot_table = get_loot_table(object.enemy)
	
	var player = GameManager.player
	
	# ITEM
	if randf() < loot_table.loot_drop_chance:
		var loot = pickupable_item.instantiate()
		GameManager.stage_root.add_child(loot)
		loot.global_position = object.global_position
		loot.set_loot(LootDatabase.get_loot_rarity(loot_table.loot_rarity_weights))
		
		var dir = player.global_position.direction_to(object.global_position)
		loot.setup(player, dir, loot_impulse_strength)
	
	# HEALTH
	for i in range(loot_table.health_drop_amount):
		if randf() < loot_table.health_drop_chance:
			var pickup = LootDatabase.pickupable_health.instantiate()
			GameManager.stage_root.add_child(pickup)
			pickup.global_position = object.global_position
			
			var dir = player.global_position.direction_to(object.global_position)
			pickup.setup(player, dir, loot_impulse_strength)


func get_loot_table(enemy: EnemyStats) -> LootTable:
	match enemy.type:
		EnemyType.Type.NORMAL:
			return enemy_loot_table
		
		EnemyType.Type.AUGMENTED:
			return aug_enemy_loot_table
		
		EnemyType.Type.BOSS:
			return boss_loot_table
	
	return null

func get_loot_rarity(loot_weights: Dictionary) -> ItemType.Type:
	# set chances
	var consumer_chance = loot_weights.get("consumer")
	var military_chance = loot_weights.get("military")
	var prototype_chance = loot_weights.get("prototype")
	var apex_anomaly_chance = loot_weights.get("apex_anomaly")
	
	# pick weighted chance
	var rng = RandomNumberGenerator.new()
	var weights = PackedFloat32Array([consumer_chance, military_chance, prototype_chance, apex_anomaly_chance])
	var rarity = rng.rand_weighted(weights)
	
	if randf() * 100 < upgrade_loot_rarity_chance:
		rarity = clamp(rarity + 1, 0, ItemType.Grade.size() - 1)
	return ItemType.Type.values()[rarity]

func get_items_by_rarity(rarity: ItemType.Grade) -> Array:
	var list = []
	match rarity:
		ItemType.Grade.CONSUMER:
			list = consumer_items.duplicate()
		ItemType.Grade.MILITARY:
			list = military_items.duplicate()
		ItemType.Grade.PROTOTYPE:
			list = prototype_items.duplicate()
		ItemType.Grade.APEX_ANOMALY:
			list = apex_anomaly_items.duplicate()
	
	list.shuffle()
	return list.slice(0, pickup_slot_amount)

func update_loot_drop_chance(amount: float) -> void:
	enemy_loot_table.loot_drop_chance += base_enemy_loot_table.loot_drop_chance * amount * 0.01
	aug_enemy_loot_table.loot_drop_chance += base_aug_enemy_loot_table.loot_drop_chance * amount * 0.01

func reset_loot_database() -> void:
	upgrade_loot_rarity_chance = 0.0
	pickup_slot_amount = 3
	
	enemy_loot_table.loot_drop_chance = base_enemy_loot_table.loot_drop_chance
	aug_enemy_loot_table.loot_drop_chance = base_aug_enemy_loot_table.loot_drop_chance
