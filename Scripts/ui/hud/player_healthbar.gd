extends Control

@onready var rich_text_label: RichTextLabel = $PlayerHpBar/HealthNumberContainer/RichTextLabel
@onready var hp_bar_segment = preload("res://Scenes/ui/hp_bar_segment.tscn")
@onready var hp_bar_segment_half = preload("res://Scenes/ui/hp_bar_segment_half.tscn")

var hp_per_segment = 10.0
@onready var hp_bar_segment_container: HBoxContainer = $PlayerHpBarRectangleSkew/MarginContainer/HpBarSegmentContainer

@onready var glitch_mask: Sprite2D = $PlayerHpBarRectangleSkew/GlitchMask
@onready var glitch_timer: Timer = $GlitchTimer
var glitch_time = 0.2

var previous_health = 0

func setup(c: Node, value: float, max_value: float) -> void:
	update_segments(value, max_value)
	c.update_health_bar.connect(update_health)
	previous_health = c.health

func update_health(health:float, max_health:float=GameManager.player.max_health)->void:
	update_segments(health, max_health)
	rich_text_label.text = Helper.get_snapped_string(clampf(health, 0.0, max_health)) + " / " + Helper.get_snapped_string(max_health)

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
			var s = hp_bar_segment.instantiate()
			hp_bar_segment_container.add_child(s)
		if overflow>0: #if hp is not cleanly divisible by hp_per_segment
			var s = hp_bar_segment_half.instantiate()
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
		glitch_mask.visible = true
		glitch_timer.start(glitch_time)
	
	previous_health = value


func _on_glitch_timer_timeout() -> void:
	glitch_mask.visible = false
	
