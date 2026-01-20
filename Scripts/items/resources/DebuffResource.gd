extends Resource
class_name DebuffResource

@export var debuff_name: String = ""
@export var debuff_type: DebuffType 
@export var debuff_item_desc_color: String = "#edc939"
@export var debuff_stat_damage: float = 5.0
@export var debuff_tick_rate: float = 1.0 #Could ramp up?
@export var debuff_duration: float = 3.0
@export var particle_scene: PackedScene

enum DebuffType { 
	STUN,
	FREEZE
	}
