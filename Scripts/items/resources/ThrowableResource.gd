extends Resource
class_name ThrowableResource

@export var throwable_object: PackedScene
@export var impact_particle: String
@export var explosion_particle: String
@export var status_effect: DebuffResource
@export var dot_effect: DebuffResource
@export var aoe_indicator: bool
@export var projectile_from_sky: bool
@export var set_facing_direction: bool
@export var pierce: bool
@export var stick: bool
@export var fuse: bool
@export var fuse_on_hit: bool
@export var fuse_duration: float
@export var aoe_radius: float
@export var aoe_damage: float
@export var on_contact_damage: bool
@export var contact_damage: float
@export var contact_aoe_radius: float = 1.2
@export var throwable_cooldown: float
@export var throw_force: float
@export var upward_arc: float

#@export var dot_resource: DotResource
#@export var particle_scene: PackedScene
