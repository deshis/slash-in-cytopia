extends Resource
class_name ActiveEffectResource

@export var active_type: ActiveType
@export var set_facing_direction: bool
@export var active_effect_name: String
@export var active_effect_value: float
@export var aoe_radius: float
@export var aoe_damage: float
@export var active_effect_cooldown: float = 5
#@export var active_effect_desc_color: String = "#edc939"
@export var dot_resource: DotResource
@export var particle_effect: String
@export var aoe_resource: AoeResource

enum ActiveType { 
	HEAL,
	MOVEMENT_SPEED,
	STUN_AOE,
	SECOND_DASH,
	DAMAGE_AOE, 
	INVULNERABILITY,
	THROWABLE
	}
