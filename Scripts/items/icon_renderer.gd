extends Sprite2D

@export var icon: Texture2D

func change_sprite():
	if icon != null:
		self.texture = icon
		
	else:
		return

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_sprite()
