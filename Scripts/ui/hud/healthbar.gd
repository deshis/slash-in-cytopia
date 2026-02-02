extends Control

@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar
@onready var rich_text_label: RichTextLabel = $MarginContainer/RichTextLabel
@onready var orange_bar: ProgressBar = $MarginContainer/OrangeBar
@onready var green_bar: ProgressBar = $MarginContainer/GreenBar

@onready var margin_container: MarginContainer = $MarginContainer

@onready var damage_number = preload("res://Scenes/enemy/damage_number.tscn")

var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

var character: Node
var is_static := true

var world_pos
var screen_pos

var previous_health:float

func setup(c: Node, value: float, max_value: float) -> void:
	character = c
	
	reset_bar_max_values(max_value)
	reset_bar_values(value)
	previous_health=value
	
	visible = true
	character.update_health_bar.connect(update_health)
	

func remove_health_bar() -> void:
	
	#reparent damage pop up to root so it doesn't disappear when enemy dies
	for child in get_children():
		if child is Label:
			child.reparent(get_tree().root)
	
	visible = false
	character.update_health_bar.disconnect(update_health)

func update_health(health:float, max_health:float = progress_bar.max_value)->void:
	if tween and health != previous_health:
		tween.kill()
		tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	
	if previous_health != health:
		if progress_bar.value > health: #taking damage. set the red bit to the final value first and tween the orange bar to it
			tween.tween_property(orange_bar, "value", health, 0.6)
			progress_bar.value = health
			green_bar.value = health
			damage_pop_up(health-previous_health, Color.RED, character is Player)
		else: #same as above except red is tweened to green
			tween.tween_property(progress_bar, "value", health, 0.6)
			green_bar.value = health
			orange_bar.value = health
			damage_pop_up(health-previous_health, Color.GREEN, character is Player)
	
	reset_bar_max_values(max_health)
	previous_health = health
	rich_text_label.text = Helper.get_snapped_string(clampf(health, 0.0, max_health)) + " / " + Helper.get_snapped_string(max_health)


func _physics_process(_delta: float) -> void:
	if character and not is_static:
		world_pos = get_viewport().get_camera_3d().unproject_position(character.global_position) + Vector2(0, -125)
		screen_pos = get_viewport().get_canvas_transform() * world_pos
		global_position = screen_pos - size / 2
	

func reset_bar_values(health:float)->void:
	progress_bar.value = health
	orange_bar.value = health
	green_bar.value = health

func reset_bar_max_values(max_health:float)->void:
	progress_bar.max_value = max_health
	orange_bar.max_value = max_health
	green_bar.max_value = max_health

func damage_pop_up(dmg, color, going_down)->void:
	var instance = damage_number.instantiate()
	add_child(instance)
	instance.position = position + progress_bar.size / 2
	instance.initialise(dmg, color, going_down, progress_bar.size)
