extends Resource
class_name AoeResource

enum AoeShape {
	SPHERE,
	RECTANGLE
}

@export var shape: AoeShape = AoeShape.SPHERE
@export var radius: float = 5.0 
@export var size: Vector3 = Vector3(5, 2, 5)  

@export var offset: Vector3 = Vector3.ZERO
@export var spawn_at_cursor: bool = false

@export var indicator_scene: PackedScene
@export var indicator_duration: float = 0.5

func create_indicator() -> AoeIndicator:
	var indicator = indicator_scene.instantiate() as AoeIndicator
	indicator.setup(self)
	return indicator

func is_position_in_aoe(aoe_position: Vector3, target_position: Vector3) -> bool:
	match shape:
		AoeShape.SPHERE:
			return aoe_position.distance_to(target_position) < radius
		
		AoeShape.RECTANGLE:
			var local_pos = target_position - aoe_position
			
			var half_size = size / 2
			return (abs(local_pos.x) <= half_size.x and 
					abs(local_pos.y) <= half_size.y and 
					abs(local_pos.z) <= half_size.z)
	
	return false
