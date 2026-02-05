extends RigidBody3D
class_name ThrowableLogic

var aoe_damage := 0.0
var aoe_damage_og := 0.0
var aoe_radius := 0.0
var aoe_radius_og := 0.0
var pierce := false
var fuse := false
var stick := false
var on_contact_damage := false
var contact_damage := 0.0
var contact_aoe_radius := 0.0
var fuse_duration := 0.0
var primed := false ##Multiple _on_body_entered calls shouldn't call fuse_delay function repeatedly

func _ready() -> void:
	aoe_damage_og = aoe_damage
	aoe_radius_og = aoe_radius

func fuse_delay() -> void:
	get_tree().create_timer(fuse_duration).timeout.connect(func(): explosion(aoe_damage, aoe_radius, true, true))
	pass
	
func _on_body_entered(body: Node):

	if on_contact_damage:
		explosion(contact_damage,contact_aoe_radius,false, false)
		
	if primed:
		return
		
	if !pierce:
		primed = true
			
	if stick:
		self.freeze = true
		
		$CollisionShape3D.set_deferred("disabled", true)
		reparent_to_target(body)
		
	##Could be redundant. One option is to just have the fuse_duration without the fuse check
	if fuse:
		fuse_delay()
		return
		
	explosion(aoe_damage,aoe_radius,true, true)

func reparent_to_target(target: Node):

	var current_transform = global_transform
	
	get_parent().remove_child(self)
	target.add_child(self)
	
	#restore the global transform so it doesn't warp to the new parent's origin
	global_transform = current_transform

##CRITICAL Update this to utilize Area3D for finding enemies 	
func explosion(damage: float, aoe: float, clean: bool, area_damage_indicator: bool) -> void:
	
	for enemy in GameManager.spawner.get_children():
		if enemy is not EnemyController or not enemy.visible:
			continue
			
		if global_position.distance_to(enemy.global_position) < aoe_radius:
			if damage != 0:
				GameManager.player.deal_damage(null, damage, enemy)
				
	if area_damage_indicator:
		var area_damage_indicator_copy = GameManager.area_damage_indicator.instantiate()
		get_tree().root.add_child(area_damage_indicator_copy)
		area_damage_indicator_copy.global_position = global_position
		area_damage_indicator_copy.scale = Vector3(aoe, aoe, aoe)
		get_tree().create_timer(0.5).timeout.connect(area_damage_indicator_copy.queue_free)
		SoundManager.play_sfx("explosion", self.global_position)
		
	if clean:
		get_tree().create_timer(1).timeout.connect(queue_free)
	
	##Contact damage somewhere?
	#SoundManager.play_sfx("explosion", self.global_position)
	
#func fused_explosion() -> void:
#print("ass")
