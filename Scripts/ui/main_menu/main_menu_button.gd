extends TextureButton

var tween

var normal_size := Vector2(280, 80)
var selected_size := Vector2(380, 80)

var tween_time = 0.15

@onready var intense_glitch_timer: Timer = $IntenseGlitchTimer

@onready var glitch = get_node_or_null("shader_mask/shader_glitch")
@onready var glitch_intense = get_node_or_null("shader_mask/shader_glitch_intense")

@export var label_text:="Play"
@onready var label: Label = $MarginContainer/Label

func _ready() -> void:
	label.text=label_text
	
	custom_minimum_size = normal_size
	
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	glitch.visible=false
	glitch_intense.visible=false
	
	

#grab UI focus when hover over with mouse
func _on_mouse_entered() -> void:
	grab_focus()
	SoundManager.play_ui_sfx("menuHover")


func _on_focus_entered() -> void:
	if tween:
		tween.kill()
	tween=create_tween()
	tween.tween_property(self,"custom_minimum_size", selected_size, tween_time)
	
	glitch_intense.visible=true
	intense_glitch_timer.start(tween_time)

	
	glitch.visible=true

func _on_focus_exited() -> void:
	if tween:
		tween.kill()
	tween=create_tween()
	tween.tween_property(self,"custom_minimum_size", normal_size, tween_time)
	
	glitch.visible=false


func _on_intense_glitch_timer_timeout() -> void:
	glitch_intense.visible=false
