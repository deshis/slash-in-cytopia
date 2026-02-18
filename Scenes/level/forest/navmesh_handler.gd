extends NavigationRegion3D
class_name NavHandler

func rebake() -> void:
	await get_tree().physics_frame
	if not is_baking():
		bake_navigation_mesh()
