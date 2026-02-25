extends Node

var trans = preload("res://Scenes/ui/transition.tscn").instantiate()
var loading_screen = preload("res://Scenes/loading_screen.tscn").instantiate()
var animation_player

var is_transitioning = false

var scene_name = ""
var progress = 0
var scene_load_status = 0


const all_throwables := {
	"brick": "res://Scenes/items/brick.tscn",
	"nade": "res://Scenes/items/grenade.tscn",
	"nade2": "res://Scenes/items/grenade2.tscn",
	"shuriken": "res://Scenes/items/shuriken.tscn",
	"javelin": "res://Scenes/items/javelin.tscn",
}


func _ready() -> void:
	add_child(trans)
	animation_player = trans.get_child(0)
	
	add_child(loading_screen)
	loading_screen.visible = false


func transition(
	scene: PackedScene,
	fade_out: String = "fade_out",
	dur_out: float = 0.25,
	fade_in: String = "fade_in",
	dur_in: float = dur_out
	) -> Node:
	
	is_transitioning = true
	
	await fade_out_anim(fade_out, dur_out)
	animation_player.play("RESET")
	
	# ASYNC LOADING
	var new_scene = await load_scene_async(scene.resource_path)
	
	# SYNC LOADING
	#clear_scene()
	#var new_scene = scene.instantiate()
	#GameManager.add_child(new_scene)
	
	fade_in_anim(fade_in, dur_in)
	
	is_transitioning = false
	return new_scene


func fade_out_anim(anim: String, dur: float) -> void:
	if dur <= 0:
		return
	animation_player.play(anim, -1, 1.0 / dur)
	await animation_player.animation_finished


func fade_in_anim(anim: String, dur: float) -> void:
	loading_screen.visible = false
	if dur <= 0:
		return
	animation_player.play(anim, -1, 1.0 / dur)
	await animation_player.animation_finished
	animation_player.play("RESET")


func load_scene_async(path: String) -> Node:
	loading_screen.visible = true
	progress = 0
	await get_tree().process_frame
	
	clear_scene()
	
	for particle_path in ParticleManager.particle_paths.values():
		ResourceLoader.load_threaded_request(particle_path)
	
	for throwable_path in all_throwables.values():
		ResourceLoader.load_threaded_request(throwable_path)
	
	ResourceLoader.load_threaded_request(path, "", true)
	
	var total_resources = ParticleManager.particle_paths.size() + all_throwables.size() + 1
	
	var scene: Node = null
	var packed_scene: PackedScene
	var progress_display = $LoadingScreen/MarginContainer/RichTextLabel
	
	var instantiated_particles = {}
	var instantiated_throwables = {}
	
	while true:
		var loaded_count = 0
		
		# TODO: load stuff per scene/stage instead of every time here
		# LOADING PARTICLES
		for particle_name in ParticleManager.particle_paths.keys():
			var particle_path = ParticleManager.particle_paths[particle_name]
			var status = ResourceLoader.load_threaded_get_status(particle_path)
			
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				loaded_count += 1
				
				if not instantiated_particles.has(particle_name):
					ParticleManager.emit_particles(particle_name, Vector3(0, -100, 0))
					instantiated_particles[particle_name] = true
		
		
		# LOADING THROWABLES
		for throwable_name in all_throwables.keys():
			var throwable_path = all_throwables[throwable_name]
			var throwable_status = ResourceLoader.load_threaded_get_status(throwable_path)
			
			if throwable_status == ResourceLoader.THREAD_LOAD_LOADED:
				loaded_count += 1
				
				if not instantiated_throwables.has(throwable_name):
					var throwable_scene: PackedScene = ResourceLoader.load_threaded_get(throwable_path)
					var throwable_instance = throwable_scene.instantiate()
					throwable_instance.preload_mode = true
					throwable_instance.visible = false
					GameManager.add_child(throwable_instance)
					await get_tree().process_frame
					throwable_instance.queue_free()
					instantiated_throwables[throwable_name] = true
		
		
		# LOADING SCENE
		var scene_status = ResourceLoader.load_threaded_get_status(path)
		if scene_status == ResourceLoader.THREAD_LOAD_LOADED:
			loaded_count += 1
		
		#var load_progress = float(loaded_count) / float(total_resources)
		#progress_display.text = "Loading\n" + str(floor(load_progress * 100)) + "%"
		
		if loaded_count == total_resources:
			#progress_display.text = "Loading\n100%"
			await get_tree().process_frame
			
			packed_scene = ResourceLoader.load_threaded_get(path)
			scene = packed_scene.instantiate()
			GameManager.add_child(scene)
			
			return scene
		
		await get_tree().process_frame
	
	return null


func clear_scene() -> void:
	for child in GameManager.get_children():
		child.queue_free()
