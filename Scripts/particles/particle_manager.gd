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

func prebake() -> void:
	for scene in particles:
		var particle = scene.instantiate()
		var all_particles = particle.find_children("*", "GPUParticles3D")
		
		for particle_instance in all_particles:
			particle_instance.process_material = particle_instance.process_material.duplicate(true)
			particle_instance.lifetime = 0.1;
			add_child(particle_instance)
			particle_instance.restart()
			
			
			
			
