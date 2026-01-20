extends Attack

var attack_mat : ShaderMaterial

func _ready() -> void:
	super._ready()
	
	attack_mat = $Circle.material_override.duplicate()
	$Circle.material_override = attack_mat
	
	$Area3D.visible = false
	$Area3D.monitoring = false
	
	var hitbox_timer = Timer.new()
	hitbox_timer.one_shot = true;
	hitbox_timer.timeout.connect(enable_hitbox)
	add_child(hitbox_timer)
	hitbox_timer.start(duration * 0.5)

func _process(_delta: float) -> void:
	super._process(_delta)
	
	attack_mat.set_shader_parameter("life_time", (duration-timer.time_left) / duration)

func enable_hitbox():
	$Area3D.visible = true
	$Area3D.monitoring = true
