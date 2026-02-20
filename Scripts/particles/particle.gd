extends Node
class_name Particle

var particles := []

func start(duration: float) -> void:
	await get_tree().physics_frame
	
	get_all_particles()
	emit_all_particles()
	
	if duration <= 0.0:
		duration = get_max_lifetime()
	
	await get_tree().create_timer(duration, false).timeout
	queue_free()


func get_all_particles() -> void:
	for child in get_children():
		if child is GPUParticles3D or child is CPUParticles3D:
			particles.append(child)


func get_max_lifetime() -> float:
	var lifetimes = []
	var lifetime = 0.0
	
	for child in get_children():
		if child is GPUParticles3D or child is CPUParticles3D:
			lifetime = child.lifetime
			
			for particle in child.get_children():
				if particle is GPUParticles3D or child is CPUParticles3D:
					lifetime += particle.lifetime
			lifetimes.append(lifetime)
	
	if lifetimes.size() == 0:
		return 0
	
	return lifetimes.max()


func emit_all_particles() -> void:
	for child in particles:
		if child is not GPUParticles3D and child is not CPUParticles3D:
			continue
	
		if child is GPUParticles3D:
			child.process_material = child.process_material.duplicate(true)
		
		child.restart()
