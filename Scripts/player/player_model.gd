extends Node3D

@onready var cam = $CameraPoint
@onready var anim = $AnimationPlayer

@export var trail_objects : Array[Node3D]

func reset_trails():
	for trail in trail_objects:
		trail.visible = false

func rotate_cam(direction):
	if direction.length() > 0:
		cam.rotation.y = atan2(-direction.x, direction.y)

func set_cam_rotation(rot):
	cam.rotation.y = rot + PI
