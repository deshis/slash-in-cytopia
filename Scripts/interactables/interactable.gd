extends Node3D
class_name Interactable

@export var health := 4.0
@export var shake_duration := 0.1
@export var shake_strength := 0.1
@export var shake_interval := 0.02
@export var loot_table: LootTable

@onready var mesh = $Mesh

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
	
	mesh.position = Vector3(
		pos_offset.x,
		mesh.position.y,
		pos_offset.y
	)


func reset_shake() -> void:
	shaking = false
	mesh.position = Vector3(0, mesh.position.y, 0)


func take_damage(amount: float) -> void:
	health -= amount
	shake_timer = shake_duration
	shaking = true
	
	if health <= 0:
		die()

func die() -> void:
	LootDatabase.drop_loot(self, loot_table)
	queue_free()
