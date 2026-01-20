extends Control

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
var character: Node
var is_static := true

func setup(c: Node, value: float, max_value: float) -> void:
	character = c
	progress_bar.max_value = max_value
	progress_bar.value = value
	
	visible = true
	character.update_health_bar.connect(update_health)

func remove_health_bar() -> void:
	visible = false
	character.update_health_bar.disconnect(update_health)

func update_health(health:float, max_health:float = progress_bar.max_value)->void:
	progress_bar.value = health
	progress_bar.max_value = max_health


func _physics_process(_delta: float) -> void:
	if character and not is_static:
		var world_pos = get_viewport().get_camera_3d().unproject_position(character.global_position) + Vector2(0, -125)
		var screen_pos = get_viewport().get_canvas_transform() * world_pos
		global_position = screen_pos - size / 2
