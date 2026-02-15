extends CharacterBody3D
class_name EnemyController

# HEALTH BAR
signal update_health_bar(float)
var health_bar

# ENEMY STATS
var enemy: EnemyStats
var target_provider: TargetProvider
var current_speed: float
@export var nav_agent: NavigationAgent3D

var player: Player = GameManager.player

var debuff_timer: Timer
var dot_timer: Timer

var active_dots: DotResource = null
var active_stat_debuffs: DebuffResource = null

var dot_tick_rate := 1.5
var remaining_dot_duration := 0.0
var current_tick_damage := 0.0
var current_debuff_tick_rate := 0.0
var current_dot_tick_rate := 0.0
var dot_lifesteal_multiplier := 0.0
var dot_life_stolen := 0.0

var current_stat_damage := 0.0
var remaining_debuff_duration := 0.0
var enemy_frozen := false
var is_dead := false

# 3D MODEL
@onready var animator = $"model/AnimationPlayer"

var hit_flash_timer: Timer
var hit_flash_duration := 0.15
var hit_flash
var hit_flash_material = preload("res://Assets/vfx/hit_flash/hit_flash.tres")

# ATTACK
@export var attack: PackedScene = null
@export var attack_windup_duration := 0.6
@export var attack_range := 200.0
@export var cooldown_duration := 1.0

var active_attacks: Array[Node3D] = []

# STATE MACHINE
var state = IDLE
var state_timer := 0.0

const IDLE = "idle"
const NAVIGATE = "navigate"
const ATTACK = "attack"
const STUN = "stun"
const COOLDOWN = "cooldown"
const RAGDOLL = "ragdoll"


var ragdoll
var model
var ragdoll_duration = 10.0
var hurtbox


func _ready() -> void:
	nav_agent.target_desired_distance = attack_range
	set_collision_layer_value(13, true)
	$Collision.disabled = true
	
	dot_timer = Timer.new()
	debuff_timer = Timer.new()
	hit_flash_timer = Timer.new()

	
	hit_flash = hit_flash_material.duplicate()
	if  $"model/rig/Skeleton3D/":
		for child in $"model/rig/Skeleton3D/".get_children():
			if child is MeshInstance3D:
				var base_mat = child.mesh.surface_get_material(0)
				var unique_mat = base_mat.duplicate()
				var next_pass_unique = hit_flash
				unique_mat.next_pass = next_pass_unique
				child.set_surface_override_material(0, unique_mat)
	
	hit_flash.set_shader_parameter('strength',0.0)
	
	dot_timer.timeout.connect(_on_dot_tick)
	debuff_timer.timeout.connect(_on_debuff_tick) 
	hit_flash_timer.timeout.connect(_on_hit_flash_end)
	
	add_child(dot_timer)
	add_child(debuff_timer)
	add_child(hit_flash_timer)
	
	change_state(IDLE)
	
	ragdoll = get_node_or_null("model/rig/Skeleton3D/PhysicalBoneSimulator3D")
	model = get_node_or_null("model/rig/Skeleton3D/Body")
	hurtbox = get_node_or_null("Hurtbox")


func _activate() -> void:
	is_dead = false
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	
	await get_tree().create_timer(0.1).timeout
	
	health_bar = GameManager.HUD.get_hp_bar(self)
	set_collision_layer_value(13, true)
	$Collision.disabled = false

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	state_timer -= delta
	
	
	match state:
		IDLE:
			process_idle()
		
		NAVIGATE:
			process_navigation(delta)
		
		ATTACK:
			process_attack()
		
		STUN:
			if state_timer <= 0:
				change_state(COOLDOWN, 0.2)
		
		COOLDOWN:
			if state_timer <= 0:
				change_state(IDLE)


func change_state(new_state: String, duration := 0.0):
	state = new_state
	state_timer = duration
	
	match state:
		NAVIGATE:
			current_speed = enemy.speed
			target_provider = TargetPlayer.new()
		
		STUN:
			for instance in active_attacks:
				instance.remove_attack()

func process_idle() -> void:
	if GameManager.player and GameManager.player.is_dead:
		return
	change_state(NAVIGATE)

func process_attack() -> void:
	if state_timer > 0:
		return
	
	perform_attack(attack)
	change_state(COOLDOWN, cooldown_duration)

func process_navigation(delta: float) -> void:
	if GameManager.player and GameManager.player.is_dead:
		change_state(IDLE)
		return
	var new_target_pos = target_provider.get_target(self)
	nav_agent.set_target_position(new_target_pos)
	var next_pos = nav_agent.get_next_path_position()
	
	var dir = (next_pos - global_transform.origin).normalized()
	update_facing_dir(delta, dir)
	
	apply_movement(delta, dir)

func apply_movement(delta: float, dir: Vector3) -> void:
	velocity = lerp(velocity, dir * current_speed, enemy.acceleration * delta)
	move_and_slide()

func update_facing_dir(delta: float, dir: Vector3) -> void:
	var target_angle = atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_angle, enemy.rotation_speed * delta)

func perform_attack(attack_scene: PackedScene, offset: Vector3 = Vector3.ZERO) -> void:
	var instance = attack_scene.instantiate()
	
	var spawner = GameManager.spawner
	var diff = spawner.diff.get_difficulty()
	var damage_mult = instance.damage_per_level
	instance.damage += diff * damage_mult
	
	if offset != Vector3.ZERO:
		instance.offset = offset
	
	add_child(instance)
	
	instance.attack_hit.connect(_on_attack_area_area_entered)
	instance.attack_removed.connect(_on_attack_removed)
	
	active_attacks.append(instance)

func take_dot_damage(dot: DotResource) -> void:

	#stacking dots would be nice
	active_dots = dot
	
	remaining_dot_duration = dot.dot_duration
	current_tick_damage = dot.dot_tick_damage
	current_dot_tick_rate = dot.dot_tick_rate
	
	dot_timer.set_wait_time(current_dot_tick_rate)
	
	if dot.dot_tick_lifesteal > 0:
		dot_lifesteal_multiplier = dot.dot_tick_lifesteal/100
		dot_life_stolen = dot.dot_tick_damage * dot_lifesteal_multiplier
	 
	if dot.dot_duration <= 0.0:
		dot_timer.stop()
		dot.dot_tick_damage = 0
		dot.dot_duration = 0
		return
			
	if enemy.health <= 0.0:
		die(false)
		
		return
		
	dot_timer.start()
			
func _on_dot_tick() -> void:
	
	if remaining_dot_duration > 0.0:
		enemy.health -= current_tick_damage
		update_health_bar.emit(enemy.health)
		
		SoundManager.play_sfx("dot_sfx", global_position)  #Might want DoT SFX here, maybe even separate depending on DoT (From resource)
		
		if active_dots.particle_scene:
			instantiate_particles(active_dots.particle_scene)
			
		remaining_dot_duration -= current_dot_tick_rate
		
		GameStats.total_damage_dealt += current_tick_damage
		
		if dot_lifesteal_multiplier > 0:
			
			dot_life_stolen = current_tick_damage * dot_lifesteal_multiplier
			snappedf(dot_life_stolen,3)	
			
			##NOTE: Player object isn't removed when you die, the script is detached
			if player is not Player:
				return 
			
			player.health += dot_life_stolen
			
			if player.health > player.max_health:
				player.health = player.max_health
			
			#In case of negative dmg, don't heal the enemies!
			if current_tick_damage < 0:
				current_tick_damage = 0
		
		if remaining_dot_duration <= 0.0:
			dot_timer.stop()
			remaining_dot_duration = 0
			current_tick_damage = 0
			active_dots = null
			
		if enemy.health <= 0.0:
			die()
			return
		
		dot_timer.start()
		
func take_stat_damage(debuff: DebuffResource) -> void:
	active_stat_debuffs = debuff
	#get_parent().take_stat_damage(debuff)
	
	#print("Taking stat damage")

	#active_stat_debuffs = debuff
	
	remaining_debuff_duration = debuff.debuff_duration
	current_stat_damage = debuff.debuff_stat_damage
	current_debuff_tick_rate = debuff.debuff_tick_rate
	
	apply_debuff_effect(debuff)
	
	debuff_timer.set_wait_time(current_debuff_tick_rate)
	
	if not debuff_timer.is_stopped():
		debuff_timer.stop()

	debuff_timer.start()
			
	if enemy.health <= 0.0:
		die()
		
		return
		
	debuff_timer.start()
	
func apply_debuff_effect(debuff: DebuffResource) -> void:
	#print("Applying debuff")
	match debuff.debuff_type:
		DebuffResource.DebuffType.STUN:
			GameManager.particles.emit_particles("stun", global_position + Vector3.UP*2.0, self)
			SoundManager.play_sfx("stun_sfx", global_position)
			change_state(STUN, remaining_debuff_duration)
		DebuffResource.DebuffType.FREEZE:
			GameManager.particles.emit_particles("freeze_particles_3D", global_position, self)
			SoundManager.play_sfx("freeze_sfx", global_position)
			enemy_frozen = true
			change_state(COOLDOWN, remaining_debuff_duration)
			
func remove_debuff_effect(debuff: DebuffResource) -> void:
	if debuff:
		match debuff.debuff_type:
			DebuffResource.DebuffType.STUN:
				pass
				
			DebuffResource.DebuffType.FREEZE:
				enemy_frozen = false

func _on_debuff_tick() -> void:

	if remaining_debuff_duration > 0.0:
		#print("Debuff applied: ", remaining_debuff_duration, " seconds left")
		
		if active_stat_debuffs.particle_scene:
			instantiate_particles(active_stat_debuffs.particle_scene)
		
		remaining_debuff_duration -= current_debuff_tick_rate
		
		if active_stat_debuffs.debuff_stat_damage > 0:
			#NOTE: Might be important, had to disable to make it work. I don't know why it broke.
			#enemy.take_stat_damage(active_stat_debuffs)
			pass
		
		#change_state(COOLDOWN, remaining_debuff_duration)
		
		if remaining_debuff_duration <= 0.0:
			remove_debuff_effect(active_stat_debuffs)
			debuff_timer.stop()
			remaining_debuff_duration = 0
			current_stat_damage = 0
			active_stat_debuffs = null
		
		#NOTE: Apply debuff particle again, doesn't work?
		elif DebuffResource.DebuffType.STUN:
			GameManager.particles.emit_particles("stun", global_position + global_position + Vector3.UP*2.0, self)
			
		if enemy.health <= 0.0:
			die()
			return
		
		debuff_timer.start()
			

func take_damage(damage:float, _damage_dealer = null) -> void:
	if damage <= 0:
		return
	
	if enemy_frozen:
		enemy_frozen = false
		shatter_ice()
	enemy.health -= damage
	update_health_bar.emit(enemy.health)
	
	hit_flash.set_shader_parameter('strength',1.0)
	hit_flash_timer.start(hit_flash_duration)
	
	#GameManager.particles.emit_particles("on_hit", global_position, self)
	
	if enemy.on_hit_particles:
		var particle_instance = enemy.on_hit_particles.instantiate()
		get_tree().root.add_child(particle_instance)
		particle_instance.global_position = global_position
		
		var all_particles = particle_instance.find_children("*", "GPUParticles3D")
		
		for particle_found in all_particles:
			particle_found.emitting = true
	
		get_tree().create_timer(4).timeout.connect(particle_instance.queue_free)
	
	GameStats.total_damage_dealt += damage
	
	if enemy.health <= 0.0:
		die()

func die(drop_loot: bool = true) -> void:

	if is_dead:
		return
	is_dead = true
	set_collision_layer_value(13, false)
	$Collision.set_deferred("disabled", true)
	
	SoundManager.play_sfx("enemy_die", global_position)
	
	if enemy.death_particles:
		var particle_instance = enemy.death_particles.instantiate()
		get_tree().root.add_child(particle_instance)
		particle_instance.global_position = global_position
		
		var all_particles = particle_instance.find_children("*", "GPUParticles3D")
		var anim_player = particle_instance.get_node("AnimationPlayer")
		
		anim_player.play("explosion_light_fade")
		for particle_found in all_particles:
			particle_found.emitting = true
		
			get_tree().create_timer(4).timeout.connect(particle_instance.queue_free)

	#Remove active particles
	for child in self.get_children():
		if child is Particle:
			child.queue_free()
	
	GameStats.enemies_killed +=1
	
	# Track enemy type kills
	var enemy_name = enemy.name
	if GameStats.enemies_killed_by_type.has(enemy_name):
		GameStats.enemies_killed_by_type[enemy_name] += 1
	else:
		GameStats.enemies_killed_by_type[enemy_name] = 1

	if drop_loot:
		LootDatabase.drop_loot(self)
	
	if ragdoll and model and hurtbox:
		spawn_ragdoll()
	else:
		return_to_pool()

func return_to_pool() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
	if not ragdoll: #removing the health bar twice breaks stuff, and ragdoll healthbars are removed earlier
		health_bar.remove_health_bar()
	
	hit_flash.set_shader_parameter('strength',0.0)
	dot_timer.stop()
	debuff_timer.stop()
	hit_flash_timer.stop()
	state_timer = 0.0
	
	for instance in active_attacks:
		instance.remove_attack()

func shatter_ice() -> void:

	print("Ice shattered")
	
	GameStats.frozen_enemies_shattered += 1

	#get_node("freeze_particles").process_material.set("lifetime", 1 )
	#Reset everything
	enemy_frozen = false
	remove_debuff_effect(active_stat_debuffs)
	debuff_timer.stop()
	remaining_debuff_duration = 0
	current_stat_damage = 0
	active_stat_debuffs = null
	
	#Interrupt the state
	if state_timer:
		state_timer = 0
		
	GameManager.particles.emit_particles("freeze_shatter_particles_3D", global_position, self)
	
func instantiate_particles(particle_scene: PackedScene):
	var particles = particle_scene.instantiate()
	
	get_parent().add_child(particles)
	#CRITICAL: Most particles are 2D, so this fucks up
	particles.global_position = global_position
	
	particles.finished.connect(_on_particles_finished.bind(particles))
	
	particles.restart()

func _on_particles_finished(particles_node: Node):
	particles_node.queue_free()

func _on_attack_area_area_entered(_area: Area3D, damage: float = enemy.damage) -> void:
	if player is not Player: return
	
	GameStats.player_last_hit_by = enemy.name
	player.take_damage(damage, self)

func _on_attack_removed(node: Node3D) -> void:
	active_attacks.erase(node)

func _on_navigation_agent_3d_target_reached() -> void:
	if GameManager.player and GameManager.player.is_dead:
		change_state(IDLE)
		return
	change_state(ATTACK, attack_windup_duration)

func _on_hit_flash_end():
	hit_flash.set_shader_parameter('strength',0.0)

func spawn_ragdoll()->void:
	ragdoll.physical_bones_start_simulation()
	
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(model, "transparency", 1.0, ragdoll_duration)
	tween.tween_callback(clean_up_ragdoll)
	
	hurtbox.set_collision_layer_value(14, false)
	health_bar.remove_health_bar()
	
	change_state(RAGDOLL, ragdoll_duration)


func clean_up_ragdoll()->void:
	ragdoll.physical_bones_stop_simulation()
	model.transparency = 0
	
	hurtbox.set_collision_layer_value(14, true)
	
	change_state(IDLE)
	
	return_to_pool()
