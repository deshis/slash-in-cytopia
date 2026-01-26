extends Node3D

var player = GameManager.player
var player_on_portal := false


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_on_portal:
		GameManager.load_next_stage()

func on_interaction_area_entered() -> void:
	player_on_portal = true

func on_interaction_area_exited() -> void:
	player_on_portal = false
