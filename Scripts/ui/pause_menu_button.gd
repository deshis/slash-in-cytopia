extends TextureButton

@onready var glitch: TextureRect = $shader_mask/shader_glitch
@onready var glitch_intense: TextureRect = $shader_mask/shader_glitch_intense
@onready var intense_glitch_timer: Timer = $IntenseGlitchTimer

var glitch_time:=0.15



func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	intense_glitch_timer.timeout.connect(_on_intense_glitch_timer_timeout)


#grab UI focus when hover over with mouse
func _on_mouse_entered() -> void:
	grab_focus()
	SoundManager.play_ui_sfx("menuHover")


func _on_focus_entered() -> void:
#	if tween:
#		tween.kill()
#	tween=create_tween()
#	tween.tween_property(self,"custom_minimum_size", selected_size, tween_time)
	
	glitch_intense.visible=true
	intense_glitch_timer.start(glitch_time)

	
	glitch.visible=true

func _on_focus_exited() -> void:
#	if tween:
#		tween.kill()
#	tween=create_tween()
#	tween.tween_property(self,"custom_minimum_size", normal_size, tween_time)
	
	glitch.visible=false


func _on_intense_glitch_timer_timeout() -> void:
	glitch_intense.visible=false
