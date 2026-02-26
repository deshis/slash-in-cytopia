extends Attack
class_name MicrobotAttackExplosion

@export var start_size := Vector3.ZERO
var end_size := Vector3.ONE

func _ready() -> void:
	super._ready()
	end_size = scale
	scale = start_size
	
	var particle = ParticleManager.emit_particles("microbot_attack",global_position)
	var anim_player = particle.get_node("AnimationPlayer")
	anim_player.play("explosion_light_fade")
	
func _process(delta: float) -> void:
	super._process(delta)
	scale += delta / duration * (end_size - start_size)
