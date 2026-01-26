extends Control

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
@onready var rich_text_label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var orange_bar: ProgressBar = $MarginContainer/OrangeBar
@onready var green_bar: ProgressBar = $MarginContainer/GreenBar

var tween

var character: Node
var is_static := true

func setup(c: Node, value: float, max_value: float) -> void:
	character = c
	
	initialise_bars(value, max_value)
	
	rich_text_label.text = "%.1f / %.1f" % [clampf(value, 0.1, max_value), max_value]
	
	visible = true
	character.update_health_bar.connect(update_health)

func remove_health_bar() -> void:
	visible = false
	character.update_health_bar.disconnect(update_health)

func update_health(health:float, max_health:float = progress_bar.max_value)->void:
	if tween:
		tween.kill()
	tween = create_tween()
	
	if progress_bar.value >= health: #taking damage
		tween.tween_property(orange_bar, "value", health, 0.5)
		progress_bar.value = health
		green_bar.value = health
	else: #healing
		tween.tween_property(progress_bar, "value", health, 0.5)
		green_bar.value = health
		orange_bar.value = health
	
	progress_bar.max_value = max_health
	green_bar.max_value = max_health
	orange_bar.max_value = max_health
	
	rich_text_label.text = "%.1f / %.1f" % [clampf(health, 0.1, max_health) , max_health]


func _physics_process(_delta: float) -> void:
	if character and not is_static:
		var world_pos = get_viewport().get_camera_3d().unproject_position(character.global_position) + Vector2(0, -125)
		var screen_pos = get_viewport().get_canvas_transform() * world_pos
		global_position = screen_pos - size / 2

func initialise_bars(health:float, max_health:float)->void:
	progress_bar.max_value = max_health
	progress_bar.value = health
	orange_bar.max_value = max_health
	orange_bar.value = health
	green_bar.max_value = max_health
	green_bar.value = health
