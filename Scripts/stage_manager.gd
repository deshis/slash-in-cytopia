extends Node

func _ready() -> void:
	GameManager.quit_to_menu()
	queue_free()
