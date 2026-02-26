extends TextureButton

var tween: Tween
var tween_time := 0.15
var shift_amount := 20.0
var original_position_x: float

@onready var intense_glitch_timer: Timer = $IntenseGlitchTimer
@onready var glitch = get_node_or_null("shader_mask/shader_glitch")
@onready var glitch_intense = get_node_or_null("shader_mask/shader_glitch_intense")

@export var label_text := "Button"
@onready var label: Label = $MarginContainer/Label

func _ready() -> void:
	label.text = label_text
	original_position_x = position.x
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	glitch.visible = false
	glitch_intense.visible = false

func _on_mouse_entered() -> void:
	grab_focus()
	SoundManager.play_ui_sfx("menuHover")

func _on_focus_entered() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position:x", original_position_x + shift_amount, tween_time)
	glitch.visible = true
	glitch_intense.visible = true
	intense_glitch_timer.start(tween_time)

func _on_focus_exited() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position:x", original_position_x, tween_time)
	glitch.visible = false
	intense_glitch_timer.stop()
	glitch_intense.visible = false

func _on_intense_glitch_timer_timeout() -> void:
	glitch_intense.visible = false
