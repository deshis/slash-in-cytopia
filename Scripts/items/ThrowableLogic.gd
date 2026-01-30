extends RigidBody3D
class_name ThrowableLogic

var aoe_damage := 0.0
var aoe_radius := 0.0
var pierce := false
var fuse := false
var fuse_duration := 0.0
var primed := false ##Multiple _on_body_entered calls shouldn't call fuse_delay function repeatedly

func fuse_delay() -> void:
	get_tree().create_timer(fuse_duration).timeout.connect(explosion)	
	pass
	
func _on_body_entered(body: Node):
	
	if primed:
		return
		
	if !pierce:
		primed = true
		
	##Could be redundant. One option is to just have the fuse_duration without the fuse check
	if fuse:
		fuse_delay()
		return
		
	explosion()

		
##CRITICAL Update this to utilize Area3D for finding enemies 	
func explosion() -> void:
	
	for enemy in GameManager.spawner.get_children():
		if enemy is not EnemyController or not enemy.visible:
			continue
			
		if global_position.distance_to(enemy.global_position) < aoe_radius:
			if aoe_damage != 0:
				GameManager.player.deal_damage(null, aoe_damage, enemy)
				
	var area_damage_indicator_copy = GameManager.area_damage_indicator.instantiate()
	get_tree().root.add_child(area_damage_indicator_copy)
	area_damage_indicator_copy.global_position = global_position
	area_damage_indicator_copy.scale = Vector3(aoe_radius, aoe_radius, aoe_radius)
	
	get_tree().create_timer(1).timeout.connect(queue_free)
	get_tree().create_timer(0.5).timeout.connect(area_damage_indicator_copy.queue_free)
	
	SoundManager.play_sfx("explosion", self.global_position)
	
#func fused_explosion() -> void:
#print("ass")
