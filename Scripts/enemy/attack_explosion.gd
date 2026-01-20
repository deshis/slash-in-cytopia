extends Attack
class_name AttackExplosion

@export var start_size := Vector3.ZERO
var end_size := Vector3.ONE

func _ready() -> void:
	super._ready()
	end_size = scale
	scale = start_size

func _process(delta: float) -> void:
	super._process(delta)
	scale += delta / duration * (end_size - start_size)
