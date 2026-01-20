extends Resource
class_name Stats 

@export var stat_type: Stat = Stat.HEALTH
@export var value: float = 0.0
@export var dot_resource: DotResource
@export var debuff_resource: DebuffResource
@export var active_effect_resource: ActiveEffectResource

signal update_health_bar

var primary
var secondary

#NOTE: Might want a separate damage stat for clarity?
#NOTE: Bloated! Too bad.
enum Stat { 
	HEALTH, 
	HEALTH_REGEN,
	FLAT_DAMAGE_REDUCTION,
	PERCENT_DAMAGE_REDUCTION,
	MOVEMENT_SPEED, 
	
	LIGHT_DAMAGE,
	HEAVY_DAMAGE,
	
	LIGHT_SPEED,
	HEAVY_SPEED,
	
	LIGHT_SIZE_X,
	LIGHT_SIZE_Y,
	HEAVY_SIZE_X,
	HEAVY_SIZE_Y,
	
	LIFESTEAL,
	DOT_EFFECT,
	PRIMARY_CHECK,
	DEBUFF_EFFECT,
	DASH_COOLDOWN,
	DASH_LENGTH,
	DASH_SPEED,
	
	CRIT_CHANCE,
	THORNS_PERCENT,
	
	LOOT_DROP_CHANCE,
	LOOT_RARITY_INC_PERCENT,
	PICKUP_LOOT_AMOUNT,
	
	ACTIVE_EFFECT,
	
	LIGHT_DOT_CHANCE,
	HEAVY_DOT_CHANCE,
	LIGHT_DEBUFF_CHANCE,
	HEAVY_DEBUFF_CHANCE,
	
	DASH_TURNING,
	DASH_ATTACK,
	}

func apply_effect(player) -> void:
	match stat_type:
		Stat.FLAT_DAMAGE_REDUCTION:
			player.flat_damage_reduction += value
		Stat.PERCENT_DAMAGE_REDUCTION:
			player.percent_damage_reduction += value
			
		Stat.HEALTH:
			player.max_health += value
			player.emit_signal("update_health_bar", player.health, player.max_health)
		Stat.HEALTH_REGEN:
			player.health_regen += value
		Stat.MOVEMENT_SPEED:
			player.current_speed += value
			player.movement_speed += value
			
		Stat.LIGHT_SPEED:
			player.light_attack_speed_scale += value * 0.01
		Stat.HEAVY_SPEED:
			player.heavy_attack_speed_scale += value * 0.01

		Stat.LIGHT_DAMAGE:
			player.attack_light_damage += value 
		Stat.HEAVY_DAMAGE:
			player.attack_heavy_damage += value
		
		Stat.LIGHT_SIZE_X:
			#NOTE: Scaling is a bit off?
			player.light_attack.scale.x *= value * 0.01
		Stat.LIGHT_SIZE_Y:
			player.light_attack.scale.z *= value * 0.01
		Stat.HEAVY_SIZE_X:
			player.heavy_attack.scale.x *= value * 0.01
		Stat.HEAVY_SIZE_Y:
			player.heavy_attack.scale.z *= value * 0.01
			
		Stat.LIFESTEAL:
			player.life_steal += value
			
		Stat.DOT_EFFECT:
			if dot_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_dot = dot_resource
					
				if ItemGlobals.secondary:
					player.secondary_attack_active_dot = dot_resource
					
		Stat.DEBUFF_EFFECT:
			if debuff_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_debuff = debuff_resource
					
				if ItemGlobals.secondary:
					player.secondary_attack_active_debuff = debuff_resource
					
		Stat.DASH_COOLDOWN:
			player.dash_cooldown += value
		Stat.DASH_LENGTH:
			player.dash_duration += value
		Stat.DASH_SPEED:
			player.dash_speed += value
		
		Stat.CRIT_CHANCE:
			player.crit_chance += value
		Stat.THORNS_PERCENT:
			player.thorns_percent += value
		
		Stat.LOOT_DROP_CHANCE:
			LootDatabase.update_loot_drop_chance(value)
		Stat.LOOT_RARITY_INC_PERCENT:
			LootDatabase.upgrade_loot_rarity_chance += value
		Stat.PICKUP_LOOT_AMOUNT:
			LootDatabase.pickup_slot_amount += int(value)
			
		Stat.ACTIVE_EFFECT:
			if active_effect_resource:
				player.active_item_effect = active_effect_resource
				
		Stat.LIGHT_DOT_CHANCE:
			player.light_dot_chance += value
		Stat.HEAVY_DOT_CHANCE:
			player.heavy_dot_chance += value
			
		Stat.LIGHT_DEBUFF_CHANCE:
			player.light_debuff_chance += value
		Stat.HEAVY_DEBUFF_CHANCE:
			player.heavy_debuff_chance += value
		
		Stat.DASH_TURNING:
			player.move_during_dash = true
		Stat.DASH_ATTACK:
			player.dash_attack_mult += value
			player.attack_during_dash = true

func remove_effect(player) -> void:
	match stat_type:
		
		Stat.FLAT_DAMAGE_REDUCTION:
			player.flat_damage_reduction -= value
		Stat.PERCENT_DAMAGE_REDUCTION:
			player.percent_damage_reduction -= value
			
		Stat.HEALTH:
			player.max_health -= value
			if player.health > player.max_health:
				player.health = player.max_health
			player.emit_signal("update_health_bar", player.health, player.max_health)
		Stat.HEALTH_REGEN:
			player.health_regen -= value
		Stat.MOVEMENT_SPEED:
			player.current_speed -= value
			player.movement_speed -= value
			
		Stat.LIGHT_SPEED:
			player.light_attack_speed_scale -= value * 0.01
		Stat.HEAVY_SPEED:
			player.heavy_attack_speed_scale -= value * 0.01

		Stat.LIGHT_DAMAGE:
			player.attack_light_damage -= value 
		Stat.HEAVY_DAMAGE:
			player.attack_heavy_damage -= value
		
		Stat.LIGHT_SIZE_X:
			player.light_attack.scale.x /= value * 0.01
		Stat.LIGHT_SIZE_Y:
			player.light_attack.scale.z /= value * 0.01
		Stat.HEAVY_SIZE_X:
			player.heavy_attack.scale.x /= value * 0.01
		Stat.HEAVY_SIZE_Y:
			player.heavy_attack.scale.z /= value * 0.01
			
		Stat.LIFESTEAL:
			player.life_steal -= value
		Stat.DOT_EFFECT:
			if dot_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_dot = null
										
				if ItemGlobals.secondary:
					player.secondary_attack_active_dot = null
					
		Stat.DEBUFF_EFFECT:
			if debuff_resource: 
				if ItemGlobals.primary:
					player.primary_attack_active_debuff = null

				if ItemGlobals.secondary:
					player.secondary_attack_active_debuff = null
					
		Stat.DASH_COOLDOWN:
			player.dash_cooldown -= value
		Stat.DASH_LENGTH:
			player.dash_duration -= value
		Stat.DASH_SPEED:
			player.dash_speed -= value
		
		Stat.CRIT_CHANCE:
			player.crit_chance -= value
		Stat.THORNS_PERCENT:
			player.thorns_percent -= value
		
		Stat.LOOT_DROP_CHANCE:
			LootDatabase.update_loot_drop_chance(-value)
		Stat.LOOT_RARITY_INC_PERCENT:
			LootDatabase.upgrade_loot_rarity_chance -= value
		Stat.PICKUP_LOOT_AMOUNT:
			LootDatabase.pickup_slot_amount -= int(value)
			
		Stat.ACTIVE_EFFECT:
			if active_effect_resource:
				player.active_item_effect = null
				
		Stat.LIGHT_DOT_CHANCE:
			player.light_dot_chance -= value
		Stat.HEAVY_DOT_CHANCE:
			player.heavy_dot_chance -= value
			
		Stat.LIGHT_DEBUFF_CHANCE:
			player.light_debuff_chance -= value
		Stat.HEAVY_DEBUFF_CHANCE:
			player.heavy_debuff_chance -= value
		Stat.DASH_TURNING:
			player.move_during_dash = false
		Stat.DASH_ATTACK:
			player.dash_attack_mult -= value
			player.attack_during_dash = false
