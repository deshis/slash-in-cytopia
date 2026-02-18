extends Destroyable

@export var baseTop : MeshInstance3D
@export var physicsTop: RigidBody3D

@export var hitbox : StaticBody3D
@export var hurtbox : Area3D

@export var top_pop_force := 8.0
@export var top_spin_force := 6.5


func die() -> void:
	baseTop.queue_free()
	hitbox.queue_free()
	hurtbox.queue_free()
	
	physicsTop.visible = true
	physicsTop.freeze = false
	
	var crate_pos = body.global_position
	var player_pos = GameManager.player.global_position
	var dir = (crate_pos - player_pos).normalized()
	dir.y = 2.0
	dir = dir.normalized()
	
	physicsTop.linear_velocity = dir * top_pop_force
	physicsTop.angular_velocity = -dir.cross(Vector3.UP) * top_spin_force
	
	await get_tree().create_timer(0.2).timeout
	LootDatabase.drop_loot(self, loot_table, 0.0, 0.0)
	await get_tree().create_timer(3.0).timeout
	fade_and_remove(0.4)

func fade_and_remove(duration: float):
	var tween = create_tween().set_parallel(true)
	
	for instance in find_children("*", "MeshInstance3D"):
		var surface_count = instance.mesh.get_surface_count()
		for i in surface_count:
			var og = instance.get_active_material(i)
			var mat = og.duplicate()
			instance.set_surface_override_material(i, mat)
			tween.tween_property(mat, "shader_parameter/fade_alpha", 0.0, duration)
			
	await tween.finished
	
	GameManager.nav_handler.rebake()
	queue_free()
