extends Node3D
class_name AoeIndicator

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@export var base_size: Vector3 = Vector3.ONE 

func setup(aoe: AoeResource):

	var target_scale: Vector3
	
	match aoe.shape:
		AoeResource.AoeShape.SPHERE:
			target_scale = Vector3.ONE * (aoe.radius / base_size.x)
		AoeResource.AoeShape.RECTANGLE:
			target_scale = aoe.size / base_size
			
	scale = target_scale
