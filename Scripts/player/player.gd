class_name Player extends CharacterBody3D

signal update_health_bar

signal dash_used

signal primary_attack_used
signal secondary_attack_used
signal active_item_used
signal throwable_used

signal item_picked_up(node: Node3D)

signal game_over

var interactables := []

# PLAYER STATS
@export var max_health := 100.0
var health := max_health
var is_dead := false
var health_regen:= 0.0

var percent_damage_reduction := 0
var flat_damage_reduction := 0

var life_steal := 0.0
var life_stolen := 0.0

# DOT / DEBUFF ODDS

var rng = RandomNumberGenerator.new()
var rng_dot_roll := 0.0
var rng_debuff_roll := 0.0
var light_dot_chance := 0.0
var heavy_dot_chance := 0.0
var light_debuff_chance := 0.0
var heavy_debuff_chance := 0.0

# MOVEMENT
@export var movement_speed := 5.0
@export var acceleration := 15.0
var default_speed = movement_speed
var current_speed := movement_speed
var input: Vector2

# DASH
@onready var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer

@export var dash_speed_mult := 5.0
@export var dash_duration:= 0.15
@export var dash_cooldown:= 3.0
var can_dash := true
var second_dash := false
var move_during_dash := false
var attack_during_dash := false
var dash_attack_mult := 0.0

# ATTACKS
@export var attack_light_damage := 10.0
@export var attack_heavy_damage := 20.0
@export var crit_chance := 1.0

var attack_light_move_speed_mult := 0.33

@onready var light_attack = $LightAttack
@onready var heavy_attack = $HeavyAttack

@onready var hitbox_light_attack_default = $LightAttack/Default
@onready var hitbox_light_attack_dagger = $LightAttack/Dagger
@onready var hitbox_light_attack_sword = $LightAttack/Sword
@onready var hitbox_heavy_attack_default = $HeavyAttack/Default
@onready var hitbox_heavy_attack_axe = $HeavyAttack/Axe
@onready var hitbox_heavy_attack_maul = $HeavyAttack/Maul

var light_attack_duration := 1.0
var heavy_attack_duration := 1.0

var light_attack_speed_scale := 1.0
var heavy_attack_speed_scale := 1.0

var light_attack_shape: Shape3D
var heavy_attack_shape: Shape3D

var light_attack_visual_shape: Sprite2D
var heavy_attack_visual_shape: Sprite2D

var heavy_attack_dash_speed_mult := 10
var heavy_attack_dash_decay := 0.6

var light_attack_windup_duration := 0.333
var heavy_attack_windup_duration := 0.333

var primary_attack_active_dot: DotResource = null
var secondary_attack_active_dot: DotResource = null

var primary_attack_active_debuff: DebuffResource = null
var secondary_attack_active_debuff: DebuffResource = null

var active_item_effect: ActiveEffectResource = null

var picked_animation := false

# ACTIVE ABILITY
@onready var active_item_cooldown_timer: Timer = $Timers/ItemActiveCooldownTimer
#@onready var active_item_icon
var can_active_item := true


# THROW 
@onready var throwable_cooldown_timer: Timer = $Timers/ThrowableCooldownTimer
@onready var throw_point = $"ThrowPoint"
@onready var orbital_throw_point = $"OrbitalThrowPoint"
var brick_scene = preload("res://Scenes/items/brick.tscn")
var can_throwable_item := true
var active_throwable_resource: ThrowableResource = null


# MODEL
@onready var animator = $"model/AnimationPlayer"
@onready var weapon_mesh = $model/rig/Skeleton3D/BoneAttachment3D/Weapon/Mesh

# DAMAGE MODEL
var area_damage_indicator = preload("res://Scenes/items/AreaDamageIndicator.tscn")



# TAKING DAMAGE
@export var hitstop_duration := 0.2
@onready var hit_flash = $"model/rig/Skeleton3D/Char".mesh.surface_get_material(0).get_next_pass()
@onready var hit_flash_timer = $Timers/HitFlash
var hit_flash_duration := 0.6
var hit_flash_blink_speed := 0.1

@export var trails : Array[MeshInstance3D]

var thorns_percent := 0.0

# DAMAGE CHROMATIC ABERRATION
var chromatic_aberration_scene = preload("res://Scenes/particles/on_hit_chromaticaberration.tscn")
var chromatic_aberration = null

# STATE MACHINE
var state = IDLE
var state_timer := 0.0

const IDLE = "idle"
const MOVE = "move"
const DASH = "dash"
const LIGHT_ATTACK_WINDUP = "light_attack_windup"
const LIGHT_ATTACK = "light_attack"
const HEAVY_ATTACK_WINDUP = "heavy_attack_windup"
const HEAVY_ATTACK = "heavy_attack"

func _ready() -> void:
	hit_flash.set_shader_parameter('strength',0.0)
	animator.animation_finished.connect(_on_animation_finished)
	
	update_light_attack_hitbox()
	update_heavy_attack_hitbox()
	
	ItemGlobals.reset()
	
	chromatic_aberration = chromatic_aberration_scene.instantiate()
	get_tree().root.add_child(chromatic_aberration)
	
	change_state(IDLE)


func _physics_process(delta: float) -> void:
	state_timer -= delta
	
	if state != DASH or move_during_dash:
		update_input()
	update_state()
	process_state(delta)
	
	update_closest_interactable()
	if Input.is_action_just_pressed("interact"):
		perform_interact()
	
	if Input.is_action_just_pressed("active_item") and active_item_effect and can_active_item:
		use_active_item(active_item_effect)
		
	if Input.is_action_just_pressed("throwable_item") and active_throwable_resource and can_throwable_item:
		use_throwable_item(active_throwable_resource)
	
	if hit_flash_timer.time_left > 0:
		blink()
	else:
		hit_flash.set_shader_parameter('strength', 0.0)
	
	move_and_slide()

func update_state() -> void:
	match state:
		IDLE:
			if Input.is_action_just_pressed("movement_ability") and input.length() > 0 and can_dash:
				change_state(DASH)
				return
			
			if Input.is_action_pressed("light_attack"):
				change_state(LIGHT_ATTACK_WINDUP)
			
			if Input.is_action_just_pressed("heavy_attack"):
				change_state(HEAVY_ATTACK_WINDUP)
				return
				
			if input.length() > 0:
				change_state(MOVE)
				return
		
		MOVE:
			if Input.is_action_just_pressed("movement_ability") and input.length() > 0 and can_dash:
				change_state(DASH)
				return
			
			if Input.is_action_pressed("light_attack"):
				change_state(LIGHT_ATTACK_WINDUP)
				return
			
			if Input.is_action_just_pressed("heavy_attack"):
				change_state(HEAVY_ATTACK_WINDUP)
				return
			
			if input.length() <= 0:
				change_state(IDLE)
				return
		
		DASH:
			if Input.is_action_just_pressed("light_attack"):
				change_state(LIGHT_ATTACK_WINDUP)
				return
			
			if Input.is_action_just_pressed("heavy_attack"):
				change_state(HEAVY_ATTACK_WINDUP)
				return
		
		LIGHT_ATTACK_WINDUP, LIGHT_ATTACK, HEAVY_ATTACK_WINDUP, HEAVY_ATTACK:
			if Input.is_action_just_pressed("movement_ability") and input.length() > 0 and can_dash:
				change_state(DASH)
				return

func change_state(new_state) -> void:
	exit_state(state, new_state)
	enter_state(new_state)

func enter_state(new_state) -> void:
	picked_animation = false

	state = new_state
	
	match state:
		IDLE:
			animator.play("Idle")
			current_speed = movement_speed
		
		MOVE:
			animator.play("Run")
			current_speed = movement_speed
		
		DASH:
			animator.play("Dash")
			state_timer = dash_duration
			perform_dash()
		
		LIGHT_ATTACK_WINDUP:
			current_speed = movement_speed * attack_light_move_speed_mult
			
			animator.speed_scale = light_attack_speed_scale
			weapon_mesh.mesh = ItemGlobals.primary_weapon_mesh
			
			set_facing_dir()
			
			if ItemGlobals.primary_weapon_type == "Dagger":
				picked_animation = true
				animator.play("Light_attack_dagger")
				light_attack_windup_duration = 0.17 / light_attack_speed_scale
				light_attack_duration = 0.333 / light_attack_speed_scale
			
			if ItemGlobals.primary_weapon_type == "Sword":
				picked_animation = true
				animator.play("Light_attack_sword")
				light_attack_windup_duration = 0.333 / light_attack_speed_scale
				light_attack_duration = 0.5833 / light_attack_speed_scale
			
			else:
				if !picked_animation:
					pass
					animator.play("Light_attack_default")
					light_attack_windup_duration = 0.25 / light_attack_speed_scale
					light_attack_duration = 0.5833 / light_attack_speed_scale
			
			tween_weapon_hologram_effect(light_attack_windup_duration)
			primary_attack_used.emit(light_attack_duration)
			state_timer = light_attack_windup_duration
		
		LIGHT_ATTACK:
			perform_light_attack()
		
		HEAVY_ATTACK_WINDUP:
			weapon_mesh.mesh = ItemGlobals.secondary_weapon_mesh
			
			current_speed = movement_speed * heavy_attack_dash_speed_mult
			animator.speed_scale = heavy_attack_speed_scale
			set_facing_dir()
			
			if ItemGlobals.secondary_weapon_type == "Maul":
				animator.play("Heavy_attack_maul")
				heavy_attack_windup_duration = 0.5 / heavy_attack_speed_scale
				heavy_attack_duration = 1.1667 / heavy_attack_speed_scale
			
			elif ItemGlobals.secondary_weapon_type == "Axe":
				animator.play("Heavy_attack_axe")
				heavy_attack_windup_duration = 0.5 / heavy_attack_speed_scale
				heavy_attack_duration = 1.25 / heavy_attack_speed_scale
			
			else:
				animator.play("Heavy_attack_default")
				heavy_attack_windup_duration = 0.333 / heavy_attack_speed_scale
				heavy_attack_duration = 0.75 / heavy_attack_speed_scale
			
			
			tween_weapon_hologram_effect(heavy_attack_windup_duration)
			secondary_attack_used.emit(heavy_attack_duration)
			state_timer = heavy_attack_windup_duration
		
		HEAVY_ATTACK:
			perform_heavy_attack()

func exit_state(s: String, new_state: String) -> void:
	match s:
		LIGHT_ATTACK_WINDUP:
			if new_state != LIGHT_ATTACK:
				disable_trails()
				stop_light_attack()
		
		LIGHT_ATTACK:
			disable_trails()
			stop_light_attack()
		
		HEAVY_ATTACK_WINDUP:
			if new_state != HEAVY_ATTACK:
				disable_trails()
				stop_heavy_attack()
		
		HEAVY_ATTACK:
			disable_trails()
			stop_heavy_attack()
		
		DASH:
			stop_dash()

func process_state(delta: float) -> void:
	match state:
		IDLE, MOVE:
			process_move(delta)
		
		DASH:
			process_dash(delta)
		
		LIGHT_ATTACK_WINDUP:
			process_light_attack_windup(delta)
		
		LIGHT_ATTACK:
			process_light_attack(delta)
		
		HEAVY_ATTACK_WINDUP:
			process_heavy_attack_windup(delta)
		
		HEAVY_ATTACK:
			process_heavy_attack(delta)

func update_light_attack_hitbox(enabled_type: String = ""):
	hitbox_light_attack_default.disabled = true
	hitbox_light_attack_dagger.disabled = true
	hitbox_light_attack_sword.disabled = true
	
	match enabled_type:
		"Default":
			hitbox_light_attack_default.disabled = false
		"Dagger":
			hitbox_light_attack_dagger.disabled = false
		"Sword":
			hitbox_light_attack_sword.disabled = false

func update_heavy_attack_hitbox(enabled_type: String = ""):
	hitbox_heavy_attack_default.disabled = true
	hitbox_heavy_attack_axe.disabled = true
	hitbox_heavy_attack_maul.disabled = true
	
	match enabled_type:
		"Default":
			hitbox_heavy_attack_default.disabled = false
		"Axe":
			hitbox_heavy_attack_axe.disabled = false
		"Maul":
			hitbox_heavy_attack_maul.disabled = false

func perform_dash():
	can_dash = false
	current_speed = movement_speed * dash_speed_mult
	if not second_dash:
		dash_cooldown_timer.start(dash_cooldown)
		dash_used.emit(dash_cooldown)
	
	if attack_during_dash:
		$DashAttackHitbox.monitoring = true
	
	GameStats.dashes_used += 1
	SoundManager.play_sfx("dash", global_position)

func perform_light_attack() -> void:
	update_light_attack_hitbox(ItemGlobals.primary_weapon_type)
	
	match ItemGlobals.primary_weapon_type:
		"Dagger":
			SoundManager.play_sfx("light_attack_dagger", global_position)
		"Sword":
			SoundManager.play_sfx("light_attack_sword", global_position)
		_:
			SoundManager.play_sfx("light_attack_default", global_position)

func perform_heavy_attack() -> void:
	update_heavy_attack_hitbox(ItemGlobals.secondary_weapon_type)
	
	match ItemGlobals.secondary_weapon_type:
		"Maul":
			SoundManager.play_sfx("heavy_attack_maul", global_position)
		"Axe":
			SoundManager.play_sfx("heavy_attack_axe", global_position)
		_:
			SoundManager.play_sfx("heavy_attack_default", global_position)
			
func trigger_chromatic_aberration():
	# Convert world position to screen position
	chromatic_aberration.trigger_chromatic_aberration()

func use_active_item(active_effect: ActiveEffectResource):
	var active_item_cooldown = active_effect.active_effect_cooldown
	
	#trigger_chromatic_aberration()
	
	can_active_item = false
	active_item_cooldown_timer.start(active_item_cooldown)
	active_item_used.emit(active_item_cooldown)
	
	GameStats.active_items_used += 1

	# Play SFX based on active item types, custom first
	if active_effect.active_sfx:
		SoundManager.play_sfx(active_effect.active_sfx, global_position)
	else:
		match active_effect.active_type:
			ActiveEffectResource.ActiveType.HEAL:
				SoundManager.play_sfx("heal", global_position)
			ActiveEffectResource.ActiveType.MOVEMENT_SPEED:
				SoundManager.play_sfx("speed_buff", global_position)
			ActiveEffectResource.ActiveType.STUN_AOE:
				SoundManager.play_sfx("emp", global_position)
			ActiveEffectResource.ActiveType.INVULNERABILITY:
				SoundManager.play_sfx("invulnerability", global_position)
			ActiveEffectResource.ActiveType.SECOND_DASH:
				SoundManager.play_sfx("dash", global_position)
			ActiveEffectResource.ActiveType.DAMAGE_AOE:
				SoundManager.play_sfx("explosion", global_position)
	
	apply_active_item_effect(active_item_effect)
	
func apply_active_item_effect(active_effect: ActiveEffectResource) -> void:
	var value = active_effect.active_effect_value
	var radius = active_effect.aoe_radius
	var set_facing_direction = active_effect.set_facing_direction
	#var particle = active_effect.particle_scene
	
	##TODO: Rotate character towards direction of activation in a more graceful manner
	##Probably pause movement for a bit
	if set_facing_direction == true:
		set_facing_dir() 
	
	match active_effect.active_type:
		ActiveEffectResource.ActiveType.HEAL:
			heal(value)
			ParticleManager.emit_particles("heal", global_position, self)

		ActiveEffectResource.ActiveType.MOVEMENT_SPEED:
			pass
		
		ActiveEffectResource.ActiveType.STUN_AOE:
			var stun_length = value
			
			var particle = active_effect.particle_effect
			if particle:
				ParticleManager.emit_particles(particle, global_position)
			
			var stun_dot = preload("res://Scripts/items/resources/StunDebuff.tres")
			stun_dot.debuff_duration = stun_length
			
			for enemy in GameManager.spawner.get_children():
				if enemy is not EnemyController or not enemy.visible:
					continue
				
				if global_position.distance_to(enemy.global_position) < radius:
					enemy.change_state(enemy.STUN, stun_length)
					deal_stat_damage(null, stun_dot, enemy)
		ActiveEffectResource.ActiveType.INVULNERABILITY:
			hit_flash_timer.start(value)

		ActiveEffectResource.ActiveType.SECOND_DASH:
			second_dash = true
			change_state(DASH)
			
		ActiveEffectResource.ActiveType.DAMAGE_AOE:
			
			var aoe = active_effect.aoe_resource
			
			var spawn_transform = throw_point.global_transform
			var aoe_position = spawn_transform.origin + (spawn_transform.basis * aoe.offset)
			var aoe_rotation = spawn_transform.basis.get_euler().y
			
			##indicator
	
			if active_effect.aoe_resource.indicator_scene:
				var indicator = aoe.create_indicator()
				get_tree().root.add_child(indicator)
				indicator.global_position = aoe_position
				indicator.rotation.y = aoe_rotation
				get_tree().create_timer(aoe.indicator_duration).timeout.connect(indicator.queue_free)
			
			##particles
			var particle = active_effect.particle_effect
			if particle:
				ParticleManager.emit_particles(particle, aoe_position)

			var aoe_damage = active_effect.aoe_damage
			var dot = active_effect.dot_resource.duplicate()
			
			for enemy in GameManager.spawner.get_children():
				if enemy is not EnemyController or not enemy.visible:
					continue
				if aoe.is_position_in_aoe(aoe_position, enemy.global_position):

					if active_item_effect.dot_resource:
						deal_dot_damage(null, dot, enemy)
	
					if active_effect.aoe_damage != 0:
						deal_damage(null, aoe_damage, enemy)
						
		##NOTE: Redundant?
		#ActiveEffectResource.ActiveType.THROWABLE:
			#var throw_force := 3.0
			#var upward_arc  := 1.0
			##var dot = active_effect.dot_resource.duplicate()
			#var brick = brick_scene.instantiate()
			#
			#brick.aoe_damage = active_item_effect.aoe_damage
			#brick.aoe_radius = active_item_effect.aoe_radius
			#
			#get_tree().root.add_child(brick)
			#
			#brick.global_position = throw_point.global_position
			#
			#var cam = get_viewport().get_camera_3d()
			#var mouse_pos = get_viewport().get_mouse_position()
			#var from = cam.project_ray_origin(mouse_pos)
			#var to = cam.project_ray_normal(mouse_pos)
			#
			#var plane = Plane(Vector3.UP, global_position.y)
			#var hit_pos = plane.intersects_ray(from, to)
#
			#if hit_pos:
			#
				##Normalize distance for throwables?
				##var direction = (hit_pos - global_position).normalized() 
				#var direction = (hit_pos - global_position)
				#var impulse = direction * throw_force
				#impulse.y = upward_arc
				#brick.apply_central_impulse(impulse)
				
func use_throwable_item(throw_resource: ThrowableResource):
	var throwable_cooldown = throw_resource.throwable_cooldown
	
	can_throwable_item = false
	throwable_cooldown_timer.start(throwable_cooldown)
	throwable_used.emit(throwable_cooldown)
	
	GameStats.throwables_used += 1
	throw(throw_resource)
	SoundManager.play_sfx("throw", global_position)
	
	
func throw(throw_resource: ThrowableResource):
	#var radius = throw_resource.aoe_radius
	var throwable_object = throw_resource.throwable_object.instantiate()
	var set_facing_direction = throw_resource.set_facing_direction
	var throwable_fuse = throw_resource.fuse
	var throwable_stick = throw_resource.stick
	var throwable_pierce = throw_resource.pierce

	var throw_force = throw_resource.throw_force
	var upward_arc = throw_resource.upward_arc
	
	if set_facing_direction == true:
		set_facing_dir() 
		
	#var dot = active_effect.dot_resource.duplicate()
	#var brick = brick_scene.instantiate()
	
	#bruh
	throwable_object.fuse = throwable_fuse
	throwable_object.fuse_start_on_hit = throw_resource.fuse_on_hit
	throwable_object.pierce = throwable_pierce
	throwable_object.stick = throwable_stick
	throwable_object.aoe_damage = throw_resource.aoe_damage
	throwable_object.aoe_radius = throw_resource.aoe_radius
	throwable_object.fuse_duration = throw_resource.fuse_duration
	throwable_object.on_contact_damage = throw_resource.on_contact_damage
	throwable_object.contact_damage = throw_resource.contact_damage
	throwable_object.contact_aoe_radius = throw_resource.contact_aoe_radius
	throwable_object.status_effect = throw_resource.status_effect
	throwable_object.dot_effect = throw_resource.dot_effect
	throwable_object.impact_particle = throw_resource.impact_particle
	throwable_object.explosion_particle = throw_resource.explosion_particle
	throwable_object.aoe_indicator = throw_resource.aoe_indicator
	GameManager.current_stage.add_child(throwable_object)
	
	if throw_resource.projectile_from_sky:
		throwable_object.global_position = orbital_throw_point.global_position
	else:
		throwable_object.global_position = throw_point.global_position
			
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var to = cam.project_ray_normal(mouse_pos)
			
	var plane = Plane(Vector3.UP, global_position.y)
	var hit_pos = plane.intersects_ray(from, to)
	

	
	if hit_pos:

		if throw_resource.projectile_from_sky:
			await get_tree().create_timer(1.5).timeout
			var direction = (hit_pos - throwable_object.global_position)
			var impulse = direction * throw_force
			throwable_object.apply_central_impulse(impulse)
			
		else:
			var direction = (hit_pos - global_position)
			var impulse = direction * throw_force
			impulse.y = upward_arc
			throwable_object.apply_central_impulse(impulse)
			throwable_object.apply_torque_impulse(Vector3(randf(), randf(), randf()) * 0.5)

func process_move(delta: float) -> void:	
	apply_movement(delta)

func process_dash(delta: float) -> void:
	apply_movement(delta)
	
	if state_timer < 0:
		change_state(IDLE)

func process_light_attack_windup(delta: float) -> void:
	apply_movement(delta)
	
	if state_timer < 0:
		change_state(LIGHT_ATTACK)


func process_light_attack(delta: float) -> void:
	apply_movement(delta)


func process_heavy_attack_windup(delta: float) -> void:
	current_speed *= heavy_attack_dash_decay
	apply_movement(delta)
	
	if state_timer < 0:
		change_state(HEAVY_ATTACK)

func process_heavy_attack(delta: float) -> void:
	current_speed *= heavy_attack_dash_decay
	apply_movement(delta)


func stop_dash() -> void:
	current_speed = movement_speed
	second_dash = false
	$DashAttackHitbox.monitoring = false

func stop_light_attack() -> void:
	weapon_mesh.mesh = null
	update_light_attack_hitbox()
	light_attack.visible = false
	animator.speed_scale = 1.0

func stop_heavy_attack() -> void:
	weapon_mesh.mesh = null
	update_heavy_attack_hitbox()
	heavy_attack.visible = false
	animator.speed_scale = 1.0


func update_input() -> void:
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	input = input.normalized()

func apply_movement(delta: float) -> void:
	if state != HEAVY_ATTACK_WINDUP and state != HEAVY_ATTACK and state != IDLE and state != LIGHT_ATTACK_WINDUP and state != LIGHT_ATTACK:
		rotation.y = atan2(input.x, input.y)
	
	velocity = lerp(velocity, Vector3(input.x, 0.0, input.y)*current_speed, acceleration * delta)

func set_facing_dir() -> void:
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from = cam.project_ray_origin(mouse_pos)
	var to = cam.project_ray_normal(mouse_pos)
	
	var plane = Plane(Vector3.UP, global_position.y)
	var hit_pos = plane.intersects_ray(from, to)
	
	var dir = (hit_pos - global_position)
	dir.y = 0
	
	rotation.y = atan2(dir.x, dir.z)

func disable_trails():
	for trail in trails:
		trail.visible = false

func heal(amount: float) -> void:
	if health >= max_health:
		return
	
	health += amount
	GameStats.total_healing += amount
	update_health_bar.emit(health)
	
	if health > max_health:
		health = max_health

func get_closest_pickup() -> PickupableObject:
	var closest = null
	var min_dist = INF
	
	for item in interactables:
		var dist = global_position.distance_to(item.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = item
	
	return closest

func deal_damage(area: Area3D, amount: float, e: EnemyController = null) -> void:
	var enemy = null
	if e:
		enemy = e
	else:
		enemy = area.get_parent()
	
	# crit chance
	if randf() * 100 < crit_chance:
		amount *= 2
		GameStats.critical_hits += 1
		if enemy is EnemyController:
			SoundManager.play_sfx("hit_crit", enemy.global_position)
	else:
		if enemy is EnemyController:
			var hit_sfx = ["hit", "hit2"].pick_random()
			SoundManager.play_sfx(hit_sfx, enemy.global_position)
	
	if amount > GameStats.highest_single_hit:
		GameStats.highest_single_hit = amount
	
	#Lifesteal
	#NOTE: Might just want to make this flat
	life_stolen = amount * (life_steal/100)
	snappedf(life_stolen,3)
	health += life_stolen
	
	if life_stolen > 0:
		GameStats.health_stolen += life_stolen
		GameStats.total_healing += life_stolen
	
	if health > max_health:
		health = max_health
	
	#In case of negative dmg, don't heal the enemies!
	if amount < 0:
		amount = 0
	
	update_health_bar.emit(health)
	
	enemy.take_damage(amount, self)

func deal_dot_damage(area: Area3D, dot: DotResource, e: EnemyController = null) -> void:
	var enemy = null
	if e:
		enemy = e
	else:
		enemy = area.get_parent() as EnemyController
	
	if dot.dot_tick_damage > 0 and enemy:
		enemy.take_dot_damage(dot)

func deal_stat_damage(area: Area3D, debuff: DebuffResource, e: EnemyController = null) -> void:
	#print("Deal stat damage")
	
	var enemy = null
	if e:
		enemy = e
	else:
		enemy = area.get_parent() as EnemyController
	
	#print(enemy.current_speed)
	
	if debuff.debuff_stat_damage > 0 and enemy:
		#print("Take stat damage")
		enemy.take_stat_damage(debuff)

func take_damage(damage:float, enemy: EnemyController, ignore_invulnerability: bool = false) -> void:
	ParticleManager.emit_particles("on_hit_player", global_position)
	
	trigger_chromatic_aberration()
	
	# hit flash = invulnerability as well
	if hit_flash_timer.time_left > 0 and not ignore_invulnerability:
		return
	
	if not ignore_invulnerability:
		hit_flash_timer.start(hit_flash_duration)
		hit_flash.set_shader_parameter('strength', 1.0)
		hitstop(hitstop_duration)
	
	# thorns
	if thorns_percent > 0:
		var thorns_dmg = damage * (thorns_percent * 0.01)
		enemy.take_damage(thorns_dmg)
		GameStats.thorns_damage += thorns_dmg
	
	#Damage reduction
	#NOTE: Applying flat damage reduction before percent damage reduction results in less mitigation
	var original_damage = damage
	damage -= flat_damage_reduction
	damage *= (100.0 - percent_damage_reduction)/100
	damage = snappedf(damage,0.1)
	
	GameStats.damage_mitigated += (original_damage - damage)
	
	health -= damage
	update_health_bar.emit(health)
	
	SoundManager.play_sfx("damage_taken")
	
	GameStats.total_damage_taken += damage
	
	if health <= 0.0:
		die()

func die() -> void:
	is_dead = true
	Engine.time_scale = 1.0
	game_over.emit()
	animator.play("Death")
	$Hurtbox.set_collision_layer_value(10, false)
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	hit_flash.set_shader_parameter('strength', 0.0)
	set_physics_process(false)

func blink() -> void:
	var phase := int(Time.get_ticks_msec() / (hit_flash_blink_speed * 1000)) % 2
	hit_flash.set_shader_parameter('strength', phase)

func hitstop(duration: float) -> void:
	Engine.time_scale = 0.01
	await get_tree().create_timer(duration, false, false, true).timeout
	Engine.time_scale = 1.0


func update_closest_interactable() -> void:
	if interactables.size() < 1.5:
		return
	
	interactables.sort_custom(sort_dist_to_player)


func sort_dist_to_player(a, b) -> int:
	var da = a.global_position.distance_to(GameManager.player.global_position)
	var db = b.global_position.distance_to(GameManager.player.global_position)
	
	if da <= db:
		return true
	else:
		return false

func perform_interact() -> void:
	if interactables.size() == 0:
		return
	
	var item = interactables.front()
	
	if item is PickupableLoot:
		item_picked_up.emit(item)


func _on_animation_finished(anim_name):
	if state == DASH:
		return

	if is_dead:
		return

	change_state(IDLE)
	animator.speed_scale = 1


func _on_time_alive_timer_timeout() -> void:
	GameStats.time_alive_seconds += 1

func _on_health_regen_timer_timeout() -> void:
	heal(health_regen)

func _on_invulnerability_length_timer_timeout() -> void:
	pass # Replace with function body.

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_item_active_cooldown_timer_timeout() -> void:
	can_active_item = true
	
func _on_throwable_cooldown_timer_timeout() -> void:
	can_throwable_item = true

func _on_light_attack_area_entered(area: Area3D) -> void:
	deal_damage(area, attack_light_damage)
	
	#EMIT HIT PARTICLES
	#ParticleManager.emit_particles("on_hit", area.global_position)

	if primary_attack_active_dot != null:
		
		#Generate a random number between 0 and 100
		#If number generated smaller or equal than the odds of inflicting debuff/dot ; proceed
		
		rng_dot_roll = rng.randf_range(0,100)
		#print("Roll: ",rng_dot_roll)
		
		if light_dot_chance >= rng_dot_roll:
			deal_dot_damage(area, primary_attack_active_dot)

	if primary_attack_active_debuff != null:
		
		rng_debuff_roll = rng.randf_range(0,100)
		#print("Roll: ",rng_dot_roll)
		
		if light_debuff_chance >= rng_debuff_roll:
			deal_stat_damage(area, primary_attack_active_debuff)

func _on_heavy_attack_area_entered(area: Area3D) -> void:
	deal_damage(area, attack_heavy_damage)
	
	#EMIT HIT PARTICLES
	#ParticleManager.emit_particles("on_hit", area.global_position)

	if secondary_attack_active_dot != null:
		
		rng_dot_roll = rng.randf_range(0,100)
		#print("Roll: ",rng_dot_roll)
		
		if heavy_dot_chance >= rng_dot_roll:
			deal_dot_damage(area, secondary_attack_active_dot)

	if secondary_attack_active_debuff != null:
		
		rng_debuff_roll = rng.randf_range(0,100)
		#print("Roll: ",rng_dot_roll)
		
		if heavy_debuff_chance >= rng_debuff_roll:
			deal_stat_damage(area, secondary_attack_active_debuff)


func _on_health_radius_area_entered(area: Area3D) -> void:
	if health >= max_health:
		return
	
	var diff = GameManager.spawner.diff
	var heal_amount = 15.0 + diff.get_difficulty() * diff.heal_amount_per_level
	heal(heal_amount)
	
	GameStats.items_picked_up += 1
	
	ParticleManager.emit_particles("heal", global_position)
	SoundManager.play_sfx("heal", global_position)
	area.queue_free()


func _on_hit_flash_timeout() -> void:
	hit_flash.set_shader_parameter('strength',0.0)
	$Hurtbox/Box.disabled = true
	$Hurtbox/Box.disabled = false

func _on_dash_attack_hitbox_area_entered(area: Area3D) -> void:
	if attack_during_dash == false:
		return
	
	var damage = inverse_lerp(0, 30, velocity.length())
	damage *= dash_attack_mult
	deal_damage(area, damage)
	
	#EMIT HIT PARTICLES
	ParticleManager.emit_particles("on_hit_player", area.global_position)


func tween_weapon_hologram_effect(duration)->void:
	_create_shader_tween(weapon_mesh, "shake_power", 1.0, 0.15, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_create_shader_tween(weapon_mesh, "edge_power", 0.0, 1.0, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_create_shader_tween(weapon_mesh, "edge_intensity", 0.0, 2.0, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_create_shader_tween(weapon_mesh, "edge_size", 0.0, 5.0, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_create_shader_tween(weapon_mesh, "albedo_alpha", 0.0, 0.1, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_create_shader_tween(weapon_mesh, "scanline_thickness", 0.0, 2.0, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_create_shader_tween(weapon_mesh, "scanline_density", 10.0, 1.0, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func _create_shader_tween(node: Node, shader_property: String, value_start: float, value_end: float, duration: float) -> Tween:
	var tween = get_tree().create_tween()
	if node:
		tween.tween_method(
		func(value): node.material_override.set_shader_parameter(shader_property, value),  
			value_start,
			value_end,
			duration
		)
	return tween
