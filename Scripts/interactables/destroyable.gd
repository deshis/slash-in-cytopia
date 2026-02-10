extends Node3D
class_name Destroyable

@export var health := 40.0

@export var chest : Node3D
@export var baseTop : MeshInstance3D
@export var physicsTop: RigidBody3D

@export var hitbox : StaticBody3D
@export var hurtbox : Area3D

@export var knockback_strength := 0.35
@export var knockback_duration := 0.2
@export var shake_strength := 0.1
@export var shake_duration := 0.1
@export var shake_interval := 0.02

@export var top_pop_force := 7.0
@export var top_spin_force := 5.0

@export var loot_table: LootTable

var shaking = false
var shake_timer := 0.0
var interval_timer := 0.0


func _physics_process(delta: float) -> void:
	shake_timer -= delta
	interval_timer -= delta
	
	if shake_timer > 0:
		shake()
	
	if shake_timer <= 0 and shaking:
		reset_shake()


func shake() -> void:
	if interval_timer > 0:
		return
	
	interval_timer = shake_interval
	
	var pos_offset = Vector2(
		sin(randf_range(0, TAU)),
		cos(randf_range(0, TAU)),
	).normalized() * shake_strength
	
	chest.position = Vector3(
		pos_offset.x,
		chest.position.y,
		pos_offset.y
	)


func reset_shake() -> void:
	shaking = false
	chest.position = Vector3(0, chest.position.y, 0)


func take_damage(amount: float, damage_dealer = null) -> void:
	health -= amount
	shake_timer = shake_duration
	shaking = true
	
	var dir = damage_dealer.global_position.direction_to(global_position)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + knockback_strength * dir, knockback_duration)
	
	if health <= 0:
		die()

func die() -> void:
	LootDatabase.drop_loot(self, loot_table)
	baseTop.queue_free()
	hitbox.queue_free()
	hurtbox.queue_free()
	
	physicsTop.visible = true
	physicsTop.freeze = false
	
	var crate_pos = chest.global_position
	var player_pos = GameManager.player.global_position
	var dir = (crate_pos - player_pos).normalized()
	dir.y = 1.5
	dir = dir.normalized()
	
	physicsTop.linear_velocity = dir * top_pop_force
	physicsTop.angular_velocity = dir.cross(Vector3.UP) * top_spin_force
	await get_tree().create_timer(6.0).timeout
	queue_free()
