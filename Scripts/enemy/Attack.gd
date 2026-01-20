extends Node3D
class_name Attack

@export var damage := 2.0
@export var damage_per_level := 0.1
@export var duration := 0.1

@export var follow := true
@export var offset := Vector3.ZERO

@onready var area: Area3D = $Area3D
@onready var coll: CollisionShape3D = $Area3D/CollisionShape3D

signal attack_hit(target: Node, damage: float)
signal attack_removed(node: Node)

var parent = null

var timer : Timer

func _ready() -> void:
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
	for body in area.get_overlapping_areas():
		_on_area_3d_area_entered(body)
	
	timer = Timer.new()
	add_child(timer)
	timer.start(duration)
	
	await timer.timeout
	remove_attack()

func remove_attack() -> void:
	attack_removed.emit(self)
	queue_free()

func _on_area_3d_area_entered(_area: Area3D) -> void:
	attack_hit.emit(area, damage)
