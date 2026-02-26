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
	"kheel_teleport": preload("res://Scenes/particles/teleport.tscn"), # DEPRECATED
	"ranged_slasher_shoot": preload("res://Scenes/particles/enemy_plasma_shooting_particles.tscn"),
	"ranged_slasher_shoot_green": preload("res://Scenes/particles/enemy_green_plasma_shooting_particles.tscn"),
	"kheel_teleport2": preload("res://Scenes/particles/teleport2.tscn"),
	
	# BRAINCHIPS
	"heal": preload("res://Scenes/particles/heal.tscn"),
	"vampirism_activate": preload("res://Scenes/particles/vampirism_ability_particle.tscn"),
	"vampirism_bleed": preload("res://Scenes/particles/vampirism_bleed_dot_particles.tscn"),
	"emp_activate": preload("res://Scenes/particles/emp_particles.tscn"),
	"reality_fracture_activate": preload("res://Scenes/particles/reality_fracture_active_particles.tscn"),
	
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
	"explosion_frozen": preload("res://Scenes/particles/freeze_explosion_particles.tscn"),
	
	# AUGMENTS
	"loot_upgrade_light_ray": preload("res://Scenes/particles/light_ray_particles.tscn"), # DEPRECATED
	"loot_upgrade_beam": preload("res://Scenes/particles/loot_upgrade.tscn"),
	
	# OTHER
	"health_pickup": preload("res://Scenes/particles/health_pickup_particles.tscn"),
}

# TODO: this was here to check stuff, should delete deprecated particles and remove this
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
	#preload("res://Scenes/particles/teleport.tscn"), # DEPRECATED
	preload("res://Scenes/particles/vampirism_ability_particle.tscn"),
	preload("res://Scenes/particles/vampirism_bleed_dot_particles.tscn"),
	preload("res://Scenes/particles/emp_particles.tscn"),
	preload("res://Scenes/particles/freeze_explosion_particles.tscn"),
	preload("res://Scenes/particles/enemy_plasma_shooting_particles.tscn"),
	preload("res://Scenes/particles/enemy_green_plasma_shooting_particles.tscn"),
	preload("res://Scenes/particles/teleport2.tscn"),
]

# this is a scuffed version, this is what's used for particle warmping so add particles here too for now
# TODO: update loading stuff so we can remove this and make it smart
const particle_paths = {
	# ON HIT
	"on_hit_player": "res://Scenes/particles/player_on_hit.tscn",
	#"on_hit_chromatic_aberration": "res://Scenes/particles/on_hit_chromaticaberration.tscn", # idk what to do with this
	"on_hit_bloody": "res://Scenes/particles/bloody_on_hit_particles.tscn",
	"on_hit_electric": "res://Scenes/particles/electric_on_hit_particles.tscn",
	"?": "res://Scenes/particles/on_hit.tscn", # DEPRECATED?
	
	# DEATH
	#"on_death_player":
	"on_death_bloody": "res://Scenes/particles/death_particle_humanoid.tscn",
	"on_death_electric": "res://Scenes/particles/death_particles_1.tscn",
	
	# ENEMY
	"stun": "res://Scenes/particles/stun.tscn",
	"kheel_teleport": "res://Scenes/particles/teleport.tscn",
	"ranged_slasher_shoot": "res://Scenes/particles/enemy_plasma_shooting_particles.tscn",
	"ranged_slasher_shoot_green": "res://Scenes/particles/enemy_green_plasma_shooting_particles.tscn",
	"kheel_teleport2": "res://Scenes/particles/teleport2.tscn",
	
	# BRAINCHIPS
	"heal": "res://Scenes/particles/heal.tscn",
	"vampirism_activate": "res://Scenes/particles/vampirism_ability_particle.tscn",
	"vampirism_bleed": "res://Scenes/particles/vampirism_bleed_dot_particles.tscn",
	"emp_activate": "res://Scenes/particles/emp_particles.tscn",
	"reality_fracture_activate": "res://Scenes/particles/reality_fracture_active_particles.tscn",
	
	# WEAPONS
	"electric_dot": "res://Scenes/particles/electric_dot_particles_3d.tscn",
	"??": "res://Scenes/particles/electric_dot_particles3D.tscn", # DEPRECATED?
	"freeze": "res://Scenes/particles/freeze_particles_3D.tscn",
	"freeze_shatter": "res://Scenes/particles/freeze_shatter_particles_3D.tscn",
	"reality_fracture": "res://Scenes/particles/reality_fracture_particles.tscn",
	"smite": "res://Scenes/particles/smite_particle.tscn",
	
	# THROWABLES
	"impact_dust": "res://Scenes/particles/impact_dust.tscn",
	"explosion": "res://Scenes/particles/explosion_particles.tscn",
	"explosion_medium": "res://Scenes/particles/expl_particles_medium.tscn",
	"explosion_frozen": "res://Scenes/particles/freeze_explosion_particles.tscn",
	
	# AUGMENTS
	"loot_upgrade_light_ray": "res://Scenes/particles/light_ray_particles.tscn", # DEPRECATED
	"loot_upgrade_beam": "res://Scenes/particles/loot_upgrade.tscn",
	
	# OTHER
	"health_pickup": "res://Scenes/particles/health_pickup_particles.tscn",
}


func preload_particles() -> void:
	for path in particle_paths.values():
		ResourceLoader.load_threaded_request(path)
	
	while true:
		var done = true
		for path in particle_paths.values():
			var status = ResourceLoader.load_threaded_get_status(path)
			if status != ResourceLoader.THREAD_LOAD_LOADED:
				done = false
				break
		
		if done:
			break
		
		await RenderingServer.frame_post_draw
	
	await get_tree().create_timer(1.5).timeout


func emit_particles(particle_name: String, pos: Vector3, parent: Node = null, duration : float = 0.0, cleans_itself: bool = false):
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
	scene.start(duration, cleans_itself)
	return scene
