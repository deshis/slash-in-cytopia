extends Node3D

@onready var player: Player = GameManager.player

@export var cam: Camera3D
@export var spin_speed: float = 0.5
@export var zoom_duration: float = 1.5

var death_effect_started = false
var death_spin = false

func _process(_delta: float) -> void:
	if death_spin:
		rotate_y(spin_speed * _delta)
	
	if not player:
		player = GameManager.player

	if player and !death_effect_started:
		global_position = Vector3(player.global_position.x, player.global_position.y + 1.0, player.global_position.z + 0.2)
		
func play_death_camera_effect():
	if death_effect_started: return
	death_effect_started = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "rotation:x", deg_to_rad(50.0), zoom_duration).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", 0.0, zoom_duration).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(cam, "position:y", cam.position.y - 3.0, zoom_duration).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	death_spin = true
