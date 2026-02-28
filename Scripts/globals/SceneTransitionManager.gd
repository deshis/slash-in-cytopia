extends Node

var trans = preload("res://Scenes/ui/transition.tscn").instantiate()
var loading_screen = preload("res://Scenes/loading_screen.tscn").instantiate()
var animation_player

var is_transitioning = false

var scene_name = ""
var progress := 0.0
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


func _process(delta: float) -> void:
	if not is_transitioning:
		return
	
	var progress_display = $LoadingScreen/MarginContainer/RichTextLabel
	if progress_display:
		if progress < 1.0:
			progress_display.text = "Loading\n" + str(int(progress * 100)) + "%"
		else:
			progress_display.text = "Initializing..."


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


func load_scene_async(scene_path: String) -> Node:
	loading_screen.visible = true
	progress = 0.0
	
	clear_scene()

	var total_assets = ParticleManager.particle_paths.size() + all_throwables.size()
	var instantiated_assets = []
	var assets = []
	
	# populate assets
	for asset in ParticleManager.particle_paths.keys():
		assets.append(ParticleManager.particle_paths[asset])
	
	for asset in all_throwables.keys():
		assets.append(all_throwables[asset])
	
	# start requests
	for asset in assets:
		ResourceLoader.load_threaded_request(asset, "", true)
	ResourceLoader.load_threaded_request(scene_path, "", true)
	
	# load all assets
	while true:
		var loaded = 0
		
		for asset in assets:
			var status = ResourceLoader.load_threaded_get_status(asset)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				loaded += 1
		
		progress = float(loaded) / float(total_assets)
		if loaded == total_assets:
			break
		
		await get_tree().process_frame
		
		#for asset in assets:
			#var status = ResourceLoader.load_threaded_get_status(asset)
			#if status == ResourceLoader.THREAD_LOAD_LOADED:
				##var packed = ResourceLoader.load_threaded_get(asset)
				##packed.instantiate()
				#instantiated_assets.append(asset)
				#progress = float(instantiated_assets.size()) / total_assets
				#await get_tree().process_frame
		#
		## remove loaded assets from the checklist
		#for asset in instantiated_assets:
			#assets.erase(asset)
		#
		#if instantiated_assets.size() == total_assets:
			#break
	
	var packed_scene = ResourceLoader.load_threaded_get(scene_path)
	var scene = packed_scene.instantiate()
	GameManager.add_child(scene)
	return scene


func clear_scene() -> void:
	var children = GameManager.find_children("*", "MeshInstance3D", true, false)
	for child in children:
		for i in range(0, child.get_surface_override_material_count()):
			child.set_surface_override_material(i, null)
	
	for child in GameManager.get_children():
		child.queue_free()
	
	
	# reset surface material overrides
	#for child in GameManager.get_children(true):
		#if child.is_class("MeshInstance3D"):
			#for i in range(0, child.get_surface_override_material_count()):
				#child.set_surface_override_material(i, null)
	#
	#for child in GameManager.get_children():
		#child.queue_free()
