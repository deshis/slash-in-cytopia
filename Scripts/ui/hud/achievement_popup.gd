extends PanelContainer

signal popup_finished

@onready var _name_label: Label = %NameLabel
@onready var _desc_label: Label = %DescLabel


func setup(data: Dictionary) -> void:
	_name_label.text = data.get("name", "")
	_desc_label.text = data.get("description", "")
	_animate()


func _animate() -> void:
	await get_tree().process_frame

	var final_x: float = get_viewport_rect().size.x - size.x
	var start_x: float = get_viewport_rect().size.x + 10

	position.x = start_x

	# Slide in
	var tween := create_tween()
	tween.tween_property(self, "position:x", final_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# Hold
	tween.tween_interval(3.0)

	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)

	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	popup_finished.emit()
	queue_free()
