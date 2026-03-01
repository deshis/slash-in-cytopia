extends Control

@onready var damage_number = preload("res://Scenes/enemy/damage_number.tscn")

var character: Node
var is_static := true

var world_pos
var screen_pos

var previous_health:float

var hp_per_segment:= 10.0
@onready var hp_bar_segment_container: HBoxContainer = $PlayerHpBarRectangleSkew/MarginContainer/HpBarSegmentContainer
@onready var hp_bar_segment = preload("res://Scenes/ui/hp_bar_segment.tscn")
@onready var hp_bar_segment_half = preload("res://Scenes/ui/hp_bar_segment_half.tscn")
##NOTE: probably a better way to do  this tbh
@onready var aug_hp_bar_segment = preload("res://Scenes/ui/aug_hp_bar_segment.tscn")
@onready var aug_hp_bar_segment_half = preload("res://Scenes/ui/aug_hp_bar_segment_half.tscn")
@onready var boss_hp_bar_segment = preload("res://Scenes/ui/boss_hp_bar_segment.tscn")
@onready var boss_hp_bar_segment_half = preload("res://Scenes/ui/boss_hp_bar_segment_half.tscn")

@onready var glitch_timer: Timer = $GlitchTimer
var glitch_time=0.2

@onready var glitch_dmg: Sprite2D = $PlayerHpBarRectangleSkew/GlitchMask/GlitchDMG
@onready var glitch_heal: Sprite2D = $PlayerHpBarRectangleSkew/GlitchMask/GlitchHeal

var enemy_type
var chosen_hp_bar_segment
var chosen_hp_bar_segment_half

func setup(c: Node, value: float, max_value: float) -> void:
	character = c
	enemy_type = c.enemy.type 
	
	if enemy_type == 0:
		chosen_hp_bar_segment = hp_bar_segment
		chosen_hp_bar_segment_half = hp_bar_segment_half
	if enemy_type == 1:
		chosen_hp_bar_segment = aug_hp_bar_segment
		chosen_hp_bar_segment_half = aug_hp_bar_segment_half
	if enemy_type == 2:
		chosen_hp_bar_segment = boss_hp_bar_segment
		chosen_hp_bar_segment_half = boss_hp_bar_segment_half

	previous_health = value
	hp_bar_segment_container.set
	
	hp_bar_segment_container.size.x = 816 #has to be set  for the final segment to work properly (?)
	update_segments(value, max_value)
	character.update_health_bar.connect(update_segments)
	visible = true
	
func update_segments(value, max_value)->void:
	var segments_amount = max_value / hp_per_segment
	var overflow = segments_amount - int(segments_amount)
	var max_hp_changed = false
	
	#change max hp
	if segments_amount != hp_bar_segment_container.get_child_count():
		max_hp_changed=true
		for child in hp_bar_segment_container.get_children():
			child.free()
		for i in range(segments_amount):
			var s = chosen_hp_bar_segment.instantiate()
			hp_bar_segment_container.add_child(s)
		if overflow>0: #if hp is not cleanly divisible by hp_per_segment
			var s = chosen_hp_bar_segment_half.instantiate()
			hp_bar_segment_container.add_child(s)
			s.add_theme_constant_override("margin_right", int(hp_bar_segment_container.size.x / ceil(segments_amount) * (1.0 - overflow)))
			s.get_child(0).max_value = overflow * 100
	
	
	#set segment values
	var hp = value
	for segment in hp_bar_segment_container.get_children():
		var s
		if segment is ProgressBar:
			s = segment
		elif segment is MarginContainer:
			s = segment.get_child(0)
		
		if hp>=10:
			s.value = 100
		elif hp < 10 and hp > 0:
			s.value = hp*10
		else:
			s.value = 0
		hp-=10
	
	if max_hp_changed or previous_health != value:
		glitch_timer.start(glitch_time)
		if value > previous_health:
			if CfgHandler.load_gameplay_settings()["enemy_damage_numbers"]:
				damage_pop_up(value-previous_health, Color.GREEN)
			glitch_heal.visible=true
		else:
			if CfgHandler.load_gameplay_settings()["enemy_damage_numbers"]:
				damage_pop_up(value-previous_health, Color.RED)
			glitch_dmg.visible=true
	
	
	previous_health = value


func remove_health_bar() -> void:
	if visible:
		#reparent damage pop up to root so it doesn't disappear when enemy dies
		for child in get_children():
			if child is Label:
				child.reparent(get_tree().root)
		visible = false
		character.update_health_bar.disconnect(update_segments)
	


func _physics_process(_delta: float) -> void:
	if character and not is_static:
		world_pos = get_viewport().get_camera_3d().unproject_position(character.global_position) + Vector2(0, -125)
		screen_pos = get_viewport().get_canvas_transform() * world_pos
		global_position = screen_pos - size / 2
	


func damage_pop_up(dmg, color)->void:
	var instance = damage_number.instantiate()
	add_child(instance)
	instance.position = position
	instance.initialise(dmg, color, false)


func _on_glitch_timer_timeout() -> void:
	glitch_dmg.visible = false
	glitch_heal.visible = false
	
