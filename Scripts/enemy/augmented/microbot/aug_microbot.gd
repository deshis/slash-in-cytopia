extends Microbot
class_name AugmentedMicrobot



func _ready() -> void:
	trail = $"model/AugmentedBlastWave"
	mesh = $model/rig/Skeleton3D/AugMicrobot
	super._ready()
	

func change_state(new_state: String, duration := 0.0):
	super.change_state(new_state, duration)
	
	match state:
		ATTACK:
			animator.play("Augmented_attack")
