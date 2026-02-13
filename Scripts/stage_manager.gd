extends Node

func _ready() -> void:
	var main_menu = preload("res://Scenes/main_menu/main_menu.tscn")
	SceneTransitionManager.transition(main_menu, "fade_out", 0.0)
	queue_free()
