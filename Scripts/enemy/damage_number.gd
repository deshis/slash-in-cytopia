extends Label

var decimal_step := 0.1

func initialise(dmg:float, color:Color, going_down:bool, bar_size:Vector2) -> void:
	text = Helper.get_snapped_string(dmg, decimal_step)
	var tween = create_tween()
	
	add_theme_color_override("font_color", color)
	
	
	
	tween.tween_property(self, "scale", Vector2(1.3,1.3), 0.2)
	tween.tween_property(self, "scale", Vector2(0.3,0.3), 0.8)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.8)
	if going_down:
		position.x += -0.25*bar_size.x
		tween.parallel().tween_property(self, "position", position+Vector2(0, 100), 0.8)
	else:
		position.x += randf_range(-0.3*bar_size.x, 0.3*bar_size.x)
		tween.parallel().tween_property(self, "position", position+Vector2(randf_range(-0.2*bar_size.x, 0.2*bar_size.x), -100), 0.8)
	
	
	tween.finished.connect(delete)
	
	if dmg >= 0:
		text = "+" + text
	

func delete() -> void:
	queue_free()
