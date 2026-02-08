extends CanvasLayer

@onready var chromatic_rect = $ChromaticRect
@onready var flash = $Control/Flash

var chromatic_material: ShaderMaterial
var is_active = false
var progress = 0.0

func _ready():
	# Setup the fullscreen rect with shader
	chromatic_rect.material = chromatic_rect.material.duplicate()
	chromatic_material = chromatic_rect.material
	chromatic_rect.visible = false
	flash.visible = false

func trigger_chromatic_aberration():
	
	is_active = true
	progress = 0.0
	
	chromatic_rect.visible = true

	start_chromatic_sequence()

func start_chromatic_sequence():

	flash.visible = true
	flash.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween().set_parallel(true)

	# flash fadein
	tween.tween_property(flash, "modulate:a", 1.0, 0.1) 
	# flash fadeout
	tween.tween_property(flash, "modulate:a", 0.0, 0.5).set_delay(0.1)
	
	# chromatic buildup
	tween.tween_property(chromatic_material, "shader_parameter/chromatic_progress", 2.0, 0.025)
	tween.tween_property(chromatic_material, "shader_parameter/chromatic_aberration", 0.5, 0.75)
	
	await tween.finished

	# chromatic return
	var fadeout_tween = create_tween().set_parallel(true)
	fadeout_tween.tween_property(chromatic_material, "shader_parameter/chromatic_progress", 0.0, 0.06)
	
	await fadeout_tween.finished
	
	await get_tree().create_timer(0.5).timeout

	end_chromatic()

func end_chromatic():
	is_active = false
	chromatic_rect.visible = false
	flash.visible = false
