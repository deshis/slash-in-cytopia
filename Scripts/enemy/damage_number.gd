extends Node3D

@onready var timer: Timer = $Timer
@onready var label_3d: Label3D = $Label3D

func initialise(dmg:float, pos:Vector3) -> void:
	position = pos
	label_3d.text = str(dmg)
	timer.start(1.0)
	
	position.x += randf_range(-0.5, 0.5)
	position.y += randf_range(-0.5, 0.5)
	
	var tween = create_tween()
	tween.tween_property(label_3d, "scale", Vector3(1.3,1.3,1.3), 0.2)
	tween.tween_property(label_3d, "scale", Vector3(0.3,0.3,0.3), 0.8)
	tween.parallel().tween_property(label_3d, "modulate", Color(1, 1, 1, 0), 0.8)


func _on_timer_timeout() -> void:
	queue_free()
