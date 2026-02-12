extends CanvasLayer

@onready var chromatic_rect = $ChromaticRect
@onready var flash = $Control/Flash

var chromatic_material: ShaderMaterial
var is_active = false
var progress = 0.0
var extension_count: int = 0
var active_tween: Tween = null
var base_duration: float = 0.5

func _ready():
	# Setup the fullscreen rect with shader
	chromatic_rect.material = chromatic_rect.material.duplicate()
	chromatic_material = chromatic_rect.material
	chromatic_rect.visible = false
	flash.visible = false

func trigger_chromatic_aberration():
	
	if is_active:
		# Extend the current sequence
		extend_chromatic_sequence()
	else:
		is_active = true
		progress = 0.0
		extension_count = 0
		chromatic_rect.visible = true
		start_chromatic_sequence()
	
func extend_chromatic_sequence():
	extension_count += 1
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	# Keep the aberration at peak intensity
	chromatic_material.set_shader_parameter("chromatic_progress", 2.5)
	chromatic_material.set_shader_parameter("chromatic_aberration", 0.5)
	
	# Restart the countdown to fadeout
	await get_tree().create_timer(base_duration).timeout
	
	extension_count -= 1
	#print(extension_count)
	if extension_count <= 0:
		end_chromatic()

func start_chromatic_sequence():
	#flash.visible = true
	#flash.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween().set_parallel(true)
	## flash fadein
	#tween.tween_property(flash, "modulate:a", 1.0, 0.1) 
	## flash fadeout
	#tween.tween_property(flash, "modulate:a", 0.0, 0.5).set_delay(0.1)
	
	# chromatic buildup
	tween.tween_property(chromatic_material, "shader_parameter/chromatic_progress", 2.5, 0.025)
	tween.tween_property(chromatic_material, "shader_parameter/chromatic_aberration", 0.5, 0.1)
	
	await tween.finished
	
	await get_tree().create_timer(base_duration).timeout
	
	if extension_count <= 0:
		end_chromatic()

func end_chromatic():
	is_active = false
	extension_count = 0
	chromatic_rect.visible = false
	flash.visible = false
