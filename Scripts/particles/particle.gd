extends Node
class_name Particle

@export var particles : GPUParticles3D

func _ready():
	particles.restart()  # ensure it starts playing
	particles.finished.connect(queue_free)  # delete when done
