extends PickupableObject

@export var magnet_distance := 120.0
@export var magnet_speed := 400.0

var on_health_pickup

func _ready() -> void:
	ParticleManager.emit_particles("health_pickup", global_position, self, 0.0, true)
	print("asd")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not player:
		return
	
	if player.health < player.max_health:
		if on_health_pickup:
			heal_player()
			queue_free()
		
		var dist = global_position.distance_to(player.global_position)
		if dist < magnet_distance:
			global_position = global_position.move_toward(player.global_position, magnet_speed * delta)


func heal_player() -> void:
	var diff = GameManager.spawner.diff
	var heal_amount = 15.0 + diff.get_difficulty() * diff.heal_amount_per_level
	player.heal(heal_amount)
	
	ParticleManager.emit_particles("heal", global_position)
	SoundManager.play_sfx("heal", global_position)
	queue_free()


func _on_detection_area_area_entered(_area: Area3D) -> void:
	on_health_pickup = true


func _on_detection_area_area_exited(_area: Area3D) -> void:
	on_health_pickup = false
