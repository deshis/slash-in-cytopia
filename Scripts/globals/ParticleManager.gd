extends Node3D

const particles = {
	# ON HIT
	"on_hit_player": preload("res://Scenes/particles/player_on_hit.tscn"),
	#"on_hit_chromatic_aberration": preload("res://Scenes/particles/on_hit_chromaticaberration.tscn"), # idk what to do with this
	"on_hit_bloody": preload("res://Scenes/particles/bloody_on_hit_particles.tscn"),
	"on_hit_electric": preload("res://Scenes/particles/electric_on_hit_particles.tscn"),
	"?": preload("res://Scenes/particles/on_hit.tscn"), # DEPRECATED?
	
	# DEATH
	#"on_death_player":
	"on_death_bloody": preload("res://Scenes/particles/death_particle_humanoid.tscn"),
	"on_death_electric": preload("res://Scenes/particles/death_particles_1.tscn"),
	
	# ENEMY
	"stun": preload("res://Scenes/particles/stun.tscn"),
	"kheel_teleport": preload("res://Scenes/particles/teleport.tscn"),
	
	# BRAINCHIPS
	"heal": preload("res://Scenes/particles/heal.tscn"),
	"vampirism_activate": preload("res://Scenes/particles/vampirism_ability_particle.tscn"),
	"vampirism_bleed": preload("res://Scenes/particles/vampirism_bleed_dot_particles.tscn"),
	
	# WEAPONS
	"electric_dot": preload("res://Scenes/particles/electric_dot_particles_3d.tscn"),
	"??": preload("res://Scenes/particles/electric_dot_particles3D.tscn"), # DEPRECATED?
	"freeze": preload("res://Scenes/particles/freeze_particles_3D.tscn"),
	"freeze_shatter": preload("res://Scenes/particles/freeze_shatter_particles_3D.tscn"),
	"reality_fracture": preload("res://Scenes/particles/reality_fracture_particles.tscn"),
	"smite": preload("res://Scenes/particles/smite_particle.tscn"),
	
	# THROWABLES
	"impact_dust": preload("res://Scenes/particles/impact_dust.tscn"),
	"explosion": preload("res://Scenes/particles/explosion_particles.tscn"),
	"explosion_medium": preload("res://Scenes/particles/expl_particles_medium.tscn"),
	
	# AUGMENTS
	"loot_upgrade_light_ray": preload("res://Scenes/particles/light_ray_particles.tscn"), # DEPRECATED
	"loot_upgrade_beam": preload("res://Scenes/particles/loot_upgrade.tscn"),
}


const all_particles = [
	preload("res://Scenes/particles/bloody_on_hit_particles.tscn"),
	preload("res://Scenes/particles/death_particles_1.tscn"),
	preload("res://Scenes/particles/death_particle_humanoid.tscn"),
	preload("res://Scenes/particles/electric_dot_particles3D.tscn"),
	#preload("res://Scenes/particles/electric_dot_particles.tscn"), # DEPRECATED 2D
	#preload("res://Scenes/particles/electric_dot_particles_3d.tscn"), # DEPRECATED
	preload("res://Scenes/particles/electric_on_hit_particles.tscn"),
	#preload("res://Scenes/particles/enemy_bleed_dot_particles.tscn"), # DEPRECATED 2D
	preload("res://Scenes/particles/explosion_particles.tscn"),
	preload("res://Scenes/particles/expl_particles_medium.tscn"),
	#preload("res://Scenes/particles/freeze_particles.tscn"), # DEPRECATED 2D
	preload("res://Scenes/particles/freeze_particles_3D.tscn"),
	#preload("res://Scenes/particles/freeze_shatter_particles.tscn"), # DEPRECATED 2D
	preload("res://Scenes/particles/freeze_shatter_particles_3D.tscn"),
	preload("res://Scenes/particles/heal.tscn"),
	preload("res://Scenes/particles/impact_dust.tscn"),
	preload("res://Scenes/particles/light_ray_particles.tscn"),
	preload("res://Scenes/particles/loot_upgrade.tscn"),
	#preload("res://Scenes/particles/old_enemy_on_death.tscn"), # DEPRECATED
	#preload("res://Scenes/particles/on_death_particles.tscn"), # DEPRECATED 2D
	preload("res://Scenes/particles/on_hit.tscn"),
	preload("res://Scenes/particles/on_hit_chromaticaberration.tscn"),
	#preload("res://Scenes/particles/particle_manager.tscn"),
	preload("res://Scenes/particles/player_on_hit.tscn"),
	#preload("res://Scenes/particles/reality_fracture_particles2.tscn"), # DEPRECATED?
	preload("res://Scenes/particles/reality_fracture_particles.tscn"),
	preload("res://Scenes/particles/smite_particle.tscn"),
	preload("res://Scenes/particles/stun.tscn"),
	preload("res://Scenes/particles/teleport.tscn"),
	preload("res://Scenes/particles/vampirism_ability_particle.tscn"),
	preload("res://Scenes/particles/vampirism_bleed_dot_particles.tscn"),
]


func _ready() -> void:
	for key in particles.keys():
		emit_particles(key, Vector3(0, -100, 0))


func emit_particles(particle_name: String, pos: Vector3, parent: Node = null, duration : float = 0.0):
	var scene = particles.get(particle_name, null)
	if not scene:
		push_warning("particle not found: ", particle_name)
		return
	
	scene = scene.instantiate()
	
	if parent:
		parent.add_child(scene)
	else:
		add_child(scene)
	
	scene.global_position = Vector3(pos.x, pos.y, pos.z)
	scene.start(duration)
	#breakpoint
	return scene


#func emit_particles(n: String, pos: Vector3, parent: Node = null, duration : float = 0.0):
	#for scene in particles:
		#if n == scene.resource_path.get_file().get_basename():
			#var particle = scene.instantiate()
			#particle.process_material = particle.process_material.duplicate(true)
			#
			#if duration > 0.0:
				#particle.lifetime = duration;
			#
			#if parent:
				#parent.add_child(particle)
			#else:
				#add_child(particle)
				#
			#particle.global_position = Vector3(
				#pos.x,
				#pos.y,
				#pos.z
			#)
			#particle.restart()
			#
			#return particle
