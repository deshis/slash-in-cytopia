extends MarginContainer

@export var keybind_name: String = ""
@export var default_icon: CompressedTexture2D

@onready var label = $VBoxContainer/Name

@onready var progress_bar = $VBoxContainer/MarginContainer/Skill/ProgressBar
@onready var timer = $Timer

@onready var glitch_mask: TextureRect = $GlitchMask

func _ready() -> void:
	set_icon(default_icon)
	update_keybind()


func _physics_process(_delta: float) -> void:
	update_keybind()


func _process(_delta: float) -> void:
	progress_bar.value = timer.time_left
	
	glitch_mask.visible = progress_bar.value > 0



func set_icon(texture: CompressedTexture2D) -> void:
	texture = default_icon if texture == null else texture
	$VBoxContainer/MarginContainer/Skill/Icon.texture = texture


func update_cooldown(cooldown: float) -> void:
	progress_bar.max_value = cooldown
	progress_bar.value = cooldown
	timer.start(cooldown)

func update_keybind() -> void:
	var keybind = Helper.get_keybind(keybind_name)
	
	if keybind == keybind_name:
		return
	
	if keybind == "Left Mouse Button":
		keybind = "LMB"
	elif keybind == "Right Mouse Button":
		keybind = "RMB"
	elif keybind == "E - Physical":
		keybind = "E"
	
	label.text = "[%s]" % keybind
