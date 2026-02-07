extends TextureButton

var tween

var normal_size := Vector2(280, 80)
var selected_size := Vector2(380, 80)

var tween_time = 0.15

func _ready() -> void:
	custom_minimum_size = normal_size
	
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

#grab UI focus when hover over with mouse
func _on_mouse_entered() -> void:
	grab_focus()


func _on_focus_entered() -> void:
	if tween:
		tween.kill()
	tween=create_tween()
	tween.tween_property(self,"custom_minimum_size", selected_size, tween_time)
	
func _on_focus_exited() -> void:
	if tween:
		tween.kill()
	tween=create_tween()
	tween.tween_property(self,"custom_minimum_size", normal_size, tween_time)
