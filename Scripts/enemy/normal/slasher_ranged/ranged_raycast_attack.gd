extends Node3D
class_name RaycastAttack

@export var damage := 2.0
@export var spread := 0.08
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
var effect: Node3D


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

	var target_pos = player.global_position + (Vector3.UP * player_eye_height)
	var shoot_pos = shooting_location.global_position
	
	#simulate inaccuracy
	var direction = (target_pos - shoot_pos).normalized()
	direction.x += randf_range(-spread, spread)
	direction.y += randf_range(-spread, spread)
	direction.z += randf_range(-spread, spread)
	
	##raycast
	#var from = shooting_location.global_position
	var distance = shoot_pos.distance_to(target_pos)
	#var to = player.global_position + Vector3.UP * player_eye_height
	var to = shoot_pos + (direction.normalized() * (distance*5))
	#var query = PhysicsRayQueryParameters3D.create(from, to)
	var query = PhysicsRayQueryParameters3D.create(shoot_pos, to)
	
	query.exclude = [shooter] + shooter.get_children()
	#print(from," ",to)
	
	var result = space.intersect_ray(query)
	var beam_end_pos: Vector3
	
	#if beam goes to void
	if !result:
		beam_end_pos = query.to
		effect = beam_scene.instantiate()
		GameManager.current_stage.add_child(effect)
		effect.shoot_beam(shoot_pos, beam_end_pos)
		return
	
	var hit_pos = result.position #+ (randf_range(-inaccuracy,inaccuracy))
	
	var particle2 = ParticleManager.emit_particles(shooting_particle, hit_pos)
	var anim_player2 = particle.get_node("AnimationPlayer")
	anim_player.play("explosion_light_fade")
	
	effect = beam_scene.instantiate()
	GameManager.current_stage.add_child(effect)
	effect.shoot_beam(shoot_pos, hit_pos)
	
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

#func _on_area_3d_area_entered(_area: Area3D) -> void:
	#attack_hit.emit(area, damage)
