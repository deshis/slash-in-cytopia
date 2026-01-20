extends Resource
class_name ItemResource

@export var item_name: String
@export var item_stat_info: String #placeholder
@export var item_description: String
@export var type: ItemType.Type
@export var grade: ItemType.Grade
@export var attack_type: ItemType.AttackType
@export var weapon_type: ItemType.WeaponType
@export var weapon_mesh: Mesh
@export var icon: Texture2D
@export var effects: Array[Stats] = []

const DESC = "desc"
const RELATIVE = "relative"
const ATTACK_SIZE = "attack_size"
const PERCENT = "percent"
const INV_SCALE = "inverted_scale"
const DEBUFF = "debuff"
const DOT = "dot"

const STAT_BEHAVIOR := {
	Stats.Stat.HEALTH: { DESC: "health" },
	Stats.Stat.HEALTH_REGEN: { DESC: "health / sec" },
	Stats.Stat.FLAT_DAMAGE_REDUCTION: { DESC: "flat damage reduction" },
	Stats.Stat.PERCENT_DAMAGE_REDUCTION: { DESC: "damage reduction ", PERCENT: true },
	Stats.Stat.MOVEMENT_SPEED: { DESC: "move speed", PERCENT: true, RELATIVE: true },
	
	Stats.Stat.LIGHT_DAMAGE: { DESC: "light damage", PERCENT: true, RELATIVE: true },
	Stats.Stat.HEAVY_DAMAGE: { DESC: "heavy damage", PERCENT: true, RELATIVE: true },
	Stats.Stat.LIGHT_SPEED: { DESC: "light attack speed", PERCENT: true },
	Stats.Stat.HEAVY_SPEED: { DESC: "heavy attack speed", PERCENT: true },
	
	Stats.Stat.LIGHT_SIZE_X: { DESC: "light attack width", PERCENT: true, ATTACK_SIZE: true },
	Stats.Stat.LIGHT_SIZE_Y: { DESC: "light attack length", PERCENT: true, ATTACK_SIZE: true },
	Stats.Stat.HEAVY_SIZE_X: { DESC: "heavy attack width", PERCENT: true, ATTACK_SIZE: true },
	Stats.Stat.HEAVY_SIZE_Y: { DESC: "heavy attack length", PERCENT: true, ATTACK_SIZE: true },
	
	Stats.Stat.LIFESTEAL: { DESC: "lifesteal", PERCENT: true },
	Stats.Stat.DOT_EFFECT: { DOT: true },
	Stats.Stat.DEBUFF_EFFECT: { DEBUFF: true},
	
	Stats.Stat.DASH_COOLDOWN: { DESC: "dash cooldown", INV_SCALE: true, PERCENT: true, RELATIVE: true },
	Stats.Stat.DASH_LENGTH: { DESC: "dash duration", PERCENT: true, RELATIVE: true },
	
	Stats.Stat.CRIT_CHANCE: { DESC: "critical chance", PERCENT: true },
	Stats.Stat.THORNS_PERCENT: { DESC: "thorns damage ", PERCENT: true},
	
	Stats.Stat.LOOT_DROP_CHANCE: { DESC: "loot drop chance", PERCENT: true },
	Stats.Stat.LOOT_RARITY_INC_PERCENT: { DESC: "chance to upgrade loot", PERCENT: true },
	Stats.Stat.PICKUP_LOOT_AMOUNT: { DESC: "loot drop slots" },
}

#CRITICAL: DEFINITELY SYNC THESE WITH THE STATS
#var stat_name
var base_movement_speed := 5.0
var base_light_attack_damage := 1.0
var base_heavy_attack_damage := 2.0
var base_dash_cooldown := 3.0
var base_dash_length := 0.15
var base_dash_speed := 25

func set_primary_weapon_type_name() -> void:
	match weapon_type: 
		ItemType.WeaponType.NONE:
			ItemGlobals.primary_weapon_type = "Default"
		ItemType.WeaponType.DAGGER:
			ItemGlobals.primary_weapon_type = "Dagger"
		ItemType.WeaponType.SWORD:
			ItemGlobals.primary_weapon_type = "Sword"
		ItemType.WeaponType.MAUL:
			ItemGlobals.primary_weapon_type = "Maul"
		ItemType.WeaponType.AXE:
			ItemGlobals.secondary_weapon_type = "Axe"

func set_primary_attack_type_name() -> void:
	match attack_type: 
		ItemType.AttackType.PRIMARY:
			ItemGlobals.primary_attack_type = "Primary"
		ItemType.AttackType.SECONDARY:
			ItemGlobals.primary_attack_type = "Secondary"

func set_secondary_weapon_type_name() -> void:
	match weapon_type: 
		ItemType.WeaponType.NONE:
			ItemGlobals.secondary_weapon_type = "Dagger"
		ItemType.WeaponType.DAGGER:
			ItemGlobals.secondary_weapon_type = "Dagger"
		ItemType.WeaponType.SWORD:
			ItemGlobals.secondary_weapon_type = "Sword"
		ItemType.WeaponType.MAUL:
			ItemGlobals.secondary_weapon_type = "Maul"
		ItemType.WeaponType.AXE:
			ItemGlobals.secondary_weapon_type = "Axe"

func set_secondary_attack_type_name() -> void:
	match attack_type: 
		ItemType.AttackType.PRIMARY:
			ItemGlobals.secondary_attack_type = "Primary"
		ItemType.AttackType.SECONDARY:
			ItemGlobals.secondary_attack_type = "Secondary"

#NOTE: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html
func get_formatted_stats() -> String:
	var special_stats := ""
	var positive_stats := ""
	var negative_stats := ""
	
	for effect in effects:
		var behavior = STAT_BEHAVIOR.get(effect.stat_type)
		if not behavior:
			continue
		
		var stat_string = ""
		var value = effect.value
		
		if behavior.get(RELATIVE, false):
			value = get_relative_value(value, effect.stat_type)
		
		if behavior.get(ATTACK_SIZE, false):
			value = get_attack_size_value(value)
		
		if behavior.get(DOT, false):
			var dot = effect.dot_resource
			var dot_chance = 0.0
			
			for e in effects:
				if e.stat_type == Stats.Stat.LIGHT_DOT_CHANCE or e.stat_type == Stats.Stat.HEAVY_DOT_CHANCE:
					dot_chance = e.value
			
			stat_string += get_sign(dot_chance)
			stat_string += get_snapped_string(dot_chance)
			stat_string += get_percent(true)
			stat_string += " chance to "
			stat_string += dot.dot_name
			stat_string += " for\n"
			var damage = dot.dot_tick_damage * (dot.dot_duration / dot.dot_tick_rate)
			stat_string += get_snapped_string(damage)
			stat_string += " damage over "
			stat_string += get_snapped_string(dot.dot_duration)
			stat_string += " seconds"
			special_stats += colored_text(stat_string, dot.dot_item_desc_color) + "\n"
			continue
			
		if behavior.get(DEBUFF, false):
			var debuff = effect.debuff_resource
			var dot_chance = 0.0
			
			for e in effects:
				if e.stat_type == Stats.Stat.LIGHT_DEBUFF_CHANCE or e.stat_type == Stats.Stat.HEAVY_DEBUFF_CHANCE:
					dot_chance = e.value
			
			stat_string += get_sign(dot_chance)
			stat_string += get_snapped_string(dot_chance)
			stat_string += get_percent(true)
			stat_string += " chance to "
			stat_string += debuff.debuff_name
			stat_string += " for "
			stat_string += get_snapped_string(debuff.debuff_duration)
			stat_string += " seconds"
			special_stats += colored_text(stat_string, debuff.debuff_item_desc_color) + "\n"
			continue
		
		stat_string += get_sign(value) 
		stat_string += get_snapped_string(value)
		stat_string += get_percent(behavior.get(PERCENT, false)) + " "
		stat_string += behavior.get(DESC)
		
		var color = get_color(value, behavior.get(INV_SCALE, false))
		
		# add to correct stats (used so positive stats are above negative)
		if behavior.get(INV_SCALE, false):
			if value < 0:
				positive_stats += colored_text(stat_string, color) + "\n"
			else:
				negative_stats += colored_text(stat_string, color) + "\n"
		else:
			if value >= 0:
				positive_stats += colored_text(stat_string, color) + "\n"
			else:
				negative_stats += colored_text(stat_string, color) + "\n"
	
	return special_stats + positive_stats + negative_stats

func get_sign(value: float) -> String:
	if value > 0:
		return "+"
	else:
		return ""

func get_snapped_string(value: float) -> String:
	if value == int(value):
		return str(int(value))
	else:
		return str(snappedf(value, 0.1))

func get_relative_value(value, stat_type: Stats.Stat) -> float:
	match stat_type:
		Stats.Stat.MOVEMENT_SPEED:
			return value / base_movement_speed * 100
		
		Stats.Stat.LIGHT_DAMAGE:
			return value / base_light_attack_damage * 100
		Stats.Stat.HEAVY_DAMAGE:
			return value / base_heavy_attack_damage * 100
		
		Stats.Stat.DASH_COOLDOWN:
			return value / base_dash_cooldown * 100
		Stats.Stat.DASH_LENGTH:
			return value / base_dash_length * 100
	
	return 0.0

func get_attack_size_value(value: float) -> float:
	return value - 100

func get_percent(is_percent: bool) -> String:
	if is_percent:
		return "%"
	else:
		return ""

func get_color(value: float, is_inverted: bool) -> String:
	var positive_color := "#a0a3a1"
	var negative_color := "#b32a20"
	
	if is_inverted:
		return negative_color if value >= 0 else positive_color
	else:
		return positive_color if value >= 0 else negative_color

func colored_text(text: String, color: String) -> String:
	return "[color=" + color + "]" + text + "[/color]"
