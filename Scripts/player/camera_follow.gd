extends Node3D

@onready var player: Player = GameManager.player

func _process(_delta: float) -> void:
	if not player:
		player = GameManager.player
	
	if player:
		global_position = Vector3(player.global_position.x, player.global_position.y + 1.0, player.global_position.z + 0.2)
