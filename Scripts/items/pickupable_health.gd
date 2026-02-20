extends PickupableObject

@export var magnet_distance := 120.0
@export var magnet_speed := 400.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	if dist < magnet_distance and player.health < player.max_health:
		global_position = global_position.move_toward(player.global_position, magnet_speed * delta)
