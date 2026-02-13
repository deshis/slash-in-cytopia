extends Node

var trans = preload("res://Scenes/ui/transition.tscn")
var animation_player

var is_transitioning = false

func _ready() -> void:
	trans = trans.instantiate()
	add_child(trans)
	animation_player = trans.get_child(0)


func transition(
	new_scene: PackedScene,
	anim_in: String = "fade_out",
	dur_in: float = 0.25,
	anim_out: String = "fade_in",
	dur_out: float = dur_in
	) -> Node:
	
	is_transitioning = true
	
	if dur_in > 0:
		animation_player.play(anim_in, -1, 1.0 / dur_in)
		await animation_player.animation_finished
	
	for child in GameManager.get_children():
		child.queue_free()
	
	var scene = new_scene.instantiate()
	GameManager.add_child(scene)
	
	await get_tree().process_frame
	
	if dur_out > 0:
		animation_player.stop()
		animation_player.play(anim_out, -1, 1.0 / dur_out)
	
	is_transitioning = false
	return scene
