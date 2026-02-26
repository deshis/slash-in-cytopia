extends Label

var decimal_step := 0.1

func initialise(dmg:float, color:Color, is_player:bool) -> void:
	
	text = Helper.get_snapped_string(dmg, decimal_step)
	var tween = create_tween()
	
	add_theme_color_override("font_color", color)
	
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.8)
	if is_player:
		tween.parallel().tween_property(self, "position", position+Vector2(0, 100), 0.8)
	else:
		position.x += randf_range(-100, 0)
		tween.parallel().tween_property(self, "position", position+Vector2(randf_range(-20, 20), -100), 0.8)
	
	
	tween.finished.connect(delete)
	
	if dmg >= 0:
		text = "+" + text
	

func delete() -> void:
	queue_free()
