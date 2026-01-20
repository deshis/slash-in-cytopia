extends StaticBody2D
@export var lifetime:Timer

func _ready() -> void:
	lifetime.start()	

func _on_lifetime_timeout() -> void:
	self.queue_free()
	pass # Replace with function body.
