extends Button

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)

#grab UI focus when hover over with mouse
func _on_mouse_entered() -> void:
	grab_focus()
