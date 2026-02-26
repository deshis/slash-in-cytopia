extends Attack

var circle_mat : ShaderMaterial
var blast_mat : ShaderMaterial

@export var pulse_speed : float

@export var anticipation_duration = 0.75
var anticipation_timer : Timer

func _ready() -> void:
	var world_pos = offset
	get_parent().remove_child(self)
	GameManager.current_stage.add_child(self)
	global_position = world_pos
	
	circle_mat = $Circle.material_override.duplicate()
	$Circle.material_override = circle_mat
	blast_mat = $Blast.material_override.duplicate()
	$Blast.material_override = blast_mat
	
	anticipation_timer = Timer.new()
	anticipation_timer.timeout.connect(anticipation_end)
	anticipation_timer.one_shot = true
	add_child(anticipation_timer)
	anticipation_timer.start(anticipation_duration)
	
	circle_mat.set_shader_parameter("stop", false)

func _process(_delta: float) -> void:
	super._process(_delta)
	if !anticipation_timer.is_stopped():
		circle_mat.set_shader_parameter("shader_time", _delta)
		circle_mat.set_shader_parameter("life_time", (anticipation_duration-anticipation_timer.time_left) / anticipation_duration)
	else:
		circle_mat.set_shader_parameter("erosion", (duration-timer.time_left) / duration)
		blast_mat.set_shader_parameter("erosion", ((duration-timer.time_left) / duration) * 0.5)

func anticipation_end():
	##TODO:
	##SCALE PARTICLE TO FIT THE SIZE OF THE AOE
	#ParticleManager.emit_particles("loot_upgrade_beam", global_position)
	circle_mat.set_shader_parameter("stop", true)
	$Blast.visible = true
	start_attack()
