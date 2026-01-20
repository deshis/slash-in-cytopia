extends Node3D

@export var label: Label3D

var player = GameManager.player
var player_on_portal := false

func _ready() -> void:
	if not label:
		return
	
	var interact = InputMap.action_get_events("interact")
	var button_name = interact[0].as_text()
	label.text = button_name + " interact"

func _physics_process(_delta: float) -> void:
	if not player or not label:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist < 2.0:
		label.visible = true
	else:
		label.visible = false
	
	if Input.is_action_just_pressed("interact") and player_on_portal:
		GameManager.load_next_stage()

func _on_area_3d_area_entered(_area: Area3D) -> void:
	player_on_portal = true

func _on_area_3d_area_exited(_area: Area3D) -> void:
	player_on_portal = false
