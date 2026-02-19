extends Node3D
class_name Destroyable

@export var health := 40.0

@export var body : Node3D

@export var knockback_strength := 0.35
@export var knockback_duration := 0.2
@export var shake_strength := 0.1
@export var shake_duration := 0.1
@export var shake_interval := 0.02

@export var loot_table: LootTable

var shaking = false
var shake_timer := 0.0
var interval_timer := 0.0

var current_pos = Vector3.ZERO


func _physics_process(delta: float) -> void:
	shake_timer -= delta
	interval_timer -= delta
	
	if shake_timer > 0:
		shake()
	
	if shake_timer <= 0 and shaking:
		reset_shake()
	
	if current_pos != global_position and GameManager.nav_handler:
		GameManager.nav_handler.rebake()


func shake() -> void:
	if interval_timer > 0:
		return
	
	interval_timer = shake_interval
	
	var pos_offset = Vector2(
		sin(randf_range(0, TAU)),
		cos(randf_range(0, TAU)),
	).normalized() * shake_strength
	
	body.position = Vector3(
		pos_offset.x,
		body.position.y,
		pos_offset.y
	)


func reset_shake() -> void:
	shaking = false
	body.position = Vector3(0, body.position.y, 0)


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
	GameManager.nav_handler.rebake()
	queue_free()
