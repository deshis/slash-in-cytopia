extends Node3D
class_name ParticleManager

@export var particles : Array[PackedScene]

func emit_particles(n: String, pos: Vector3, parent: Node = null, duration : float = 0.0):
	for scene in particles:
		if n == scene.resource_path.get_file().get_basename():
			var particle = scene.instantiate()
			particle.process_material = particle.process_material.duplicate(true)
			
			if duration > 0.0:
				particle.lifetime = duration;
			
			if parent:
				parent.add_child(particle)
			else:
				add_child(particle)
				
			particle.global_position = Vector3(
				pos.x,
				pos.y + 0.3,
				pos.z
			)
			particle.restart()
			
			return particle
