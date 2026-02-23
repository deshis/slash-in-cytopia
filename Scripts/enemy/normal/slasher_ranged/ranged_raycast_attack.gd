extends Node3D
class_name RaycastAttack

@export var damage := 2.0
@export var damage_per_level := 0.1
@export var player_eye_height := 1.35

@export var follow := true
@export var offset := Vector3.ZERO
@export var shooting_particle: String
@export var beam_scene: PackedScene

@onready var area: Area3D = $Area3D
@onready var coll: CollisionShape3D = $Area3D/CollisionShape3D

signal attack_hit(target: Node, damage: float)
signal attack_removed(node: Node)

var parent = null
var shooter: Node3D
var hit_pos

var shooting_location: Node3D

func _ready() -> void:
	shooter = get_parent()
	shooting_location = shooter.get_node("ShootingLocation")

	if follow:
		parent = get_parent()
		position = offset
	else:
		var world_pos = global_position + offset
		get_parent().remove_child(self)
		GameManager.current_stage.add_child(self)
		global_position = world_pos
	
	start_attack()

func _process(_delta: float) -> void:
	if follow:
		global_position = parent.global_position + offset.rotated(Vector3.UP, parent.global_rotation.y)

func start_attack() -> void:
	if not shooter: #or GameManager.player.health <= 0:
		remove_attack()
		return
		
	var particle = ParticleManager.emit_particles(shooting_particle, shooting_location.global_position)
	var anim_player = particle.get_node("AnimationPlayer")
	anim_player.play("explosion_light_fade")
	SoundManager.play_sfx("plasma_shot", self.global_position)
		
	var player = GameManager.player
	var space = shooter.get_world_3d().direct_space_state
	
	##raycast
	var from = shooting_location.global_position
	var to = player.global_position + Vector3.UP * player_eye_height
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [shooter] + shooter.get_children()
	#print(from," ",to)
	
	var result = space.intersect_ray(query)

	var hit_pos = result.position
	
	var particle2 = ParticleManager.emit_particles(shooting_particle, hit_pos)
	var anim_player2 = particle.get_node("AnimationPlayer")
	anim_player.play("explosion_light_fade")
	
	var effect = beam_scene.instantiate()
	GameManager.current_stage.add_child(effect)
	effect.shoot_beam(from, hit_pos)
	
	if result.is_empty():
		print("miss")
		remove_attack()
		return
		
	if result.collider == player:
		player.take_damage(damage,shooter)

	remove_attack()

func remove_attack() -> void:
	attack_removed.emit(self)
	queue_free()

func _on_area_3d_area_entered(_area: Area3D) -> void:
	attack_hit.emit(area, damage)
