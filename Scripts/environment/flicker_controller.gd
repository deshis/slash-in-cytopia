extends Node3D

@export var light: Light3D
@export var meshInstance: MeshInstance3D
@export var shader: Shader  

@export var max_energy := 6.0
@export var min_energy := 0.0

@export var off_time_min := 2.0
@export var off_time_max := 6.0

@export var on_time_min := 0.5
@export var on_time_max := 2.0

@export var flicker_speed := 0.05
@export var jitter_strength := 0.2

enum { OFF, FLICKER_ON }
var state := OFF

var state_timer := 0.0
var state_duration := 0.0

var flicker_timer := 0.0
var flicker_value := 0.0

var material_instance: ShaderMaterial

func _ready():
	_make_neon_materials_unique()
	randomize()
	_enter_off()

func _make_neon_materials_unique():
	if not meshInstance or not meshInstance.mesh:
		return

	var surface_count := meshInstance.mesh.get_surface_count()
	for i in range(surface_count):
		var mat := meshInstance.get_active_material(i)
		if mat is ShaderMaterial and mat.shader == shader:
			material_instance = mat.duplicate()
			material_instance.resource_local_to_scene = true
			meshInstance.set_surface_override_material(i, material_instance)

func _process(delta):
	state_timer += delta

	match state:
		OFF:
			_update_off()

		FLICKER_ON:
			_update_flicker_on(delta)

	if state_timer >= state_duration:
		_switch_state()

func _enter_off():
	state = OFF
	state_timer = 0.0
	state_duration = randf_range(off_time_min, off_time_max)
	flicker_value = 0.0

func _enter_flicker_on():
	state = FLICKER_ON
	state_timer = 0.0
	state_duration = randf_range(on_time_min, on_time_max)
	flicker_timer = 0.0

func _switch_state():
	if state == OFF:
		_enter_flicker_on()
	else:
		_enter_off()

func _update_off():
	_apply_output(0.0)

func _update_flicker_on(delta):
	flicker_timer += delta

	if flicker_timer >= flicker_speed:
		flicker_timer = 0.0
		flicker_value = randf()

	var value = clamp(flicker_value + randf_range(-jitter_strength, jitter_strength), 0.0, 1.0)
	_apply_output(value)

func _apply_output(value):
	if material_instance:
		material_instance.set_shader_parameter("flicker_value", value)

	if light:
		light.light_energy = lerp(min_energy, max_energy, value)
		light.visible = value > 0.05
