extends Node

var sfx_players: Dictionary = {}
var ui_players: Dictionary = {}
var pitch_ranges: Dictionary = {}
var music_player: AudioStreamPlayer
var bgm_players: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# BGM part
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_players = {
		"common_bgm": load("res://Assets/audio/bgm.mp3")
		
		
	}
	
	# TODO Hard-coded bgm_player, go with this before we have a proper level system and bgm for different levels.
	music_player.stream = bgm_players["common_bgm"]
	music_player.stream.loop = true
	music_player.play()
	
	
	# SFX part
	sfx_players = {
		"light_attack_default": load("res://Assets/audio/effect_lightattack_default.wav"),
		"light_attack_sword": load("res://Assets/audio/effect_lightattack_sword.wav"),
		"light_attack_dagger": load("res://Assets/audio/effect_lightattack_dagger.wav"),
		"heavy_attack_default": load("res://Assets/audio/effect_heavyattack_default.wav"), 
		"heavy_attack_axe": load("res://Assets/audio/effect_heavyattack_axe.wav"),
		"heavy_attack_maul": load("res://Assets/audio/effect_heavyattack_maul.wav"),
		"dash": load("res://Assets/audio/effect_dash.wav"),
		"hit": load("res://Assets/audio/effect_hit.wav"),
		"hit_crit": load("res://Assets/audio/effect_hit_critical.wav"),
		"damage_taken": load("res://Assets/audio/effect_damage_Taken.wav"),
		"enemy_die": load("res://Assets/audio/effect_enemy_die.wav"),
		"dot_sfx": load("res://Assets/audio/effect_dot.wav"),
		"heal":load("res://Assets/audio/effect_heal.wav"),
		"freeze_sfx":load("res://Assets/audio/effect_freeze.wav"),
		"stun_sfx":load("res://Assets/audio/effect_stun.wav"),
		"invulnerability":load("res://Assets/audio/effect_invulnerability.wav"),
		"speed_buff":load("res://Assets/audio/effect_speedbuff.wav"),
		"explosion":load("res://Assets/audio/effect_explosion.wav"),
		"explosion_small":load("res://Assets/audio/effect_explosion2.mp3"),
		"explosion_medium":load("res://Assets/audio/effect_explosion2.mp3"),
	}
	
	ui_players = {
		"start": load("res://Assets/audio/effect_freeze.wav"),
		"button": load("res://Assets/audio/ui_button_click.wav")
	}
	
	pitch_ranges = {
		"light_attack_default": [0.8, 1.5],
		"light_attack_sword": [0.5, 1.5],
		"light_attack_dagger": [0.8, 1.2],
		"heavy_attack_default": [0.8, 1.2],
		"heavy_attack_axe": [0.9, 1.2],
		"heavy_attack_maul": [0.8, 1.0],
		"dash": [0.8, 1.5],
		"hit": [0.5, 1.2],
		"hit_crit": [1.0, 1.5],
		"damage_taken": [0.8, 1.2],
		"enemy_die": [0.5, 1.5],
		"dot_sfx": [0.5, 1.5],
		"heal": [0.5, 1.0],
		"freeze_sfx": [0.9, 1.1],
		"stun_sfx": [0.7,0.9],
		"explosion":[0.7,0.9],
		"explosion_small":[0.9,1.1],
		"explosion_medium":[0.8,0.9]
	}
	# Auto-connect to all buttons in the scene tree
	get_tree().node_added.connect(_on_node_added)
	

# Play one-shot sound effects
func play_sfx(name: String, position: Vector3 = Vector3.ZERO) -> void:
	
	if not sfx_players.has(name):
		push_warning("SFX not found: " + name)
		return
		
	var player := AudioStreamPlayer2D.new()
	player.stream = sfx_players[name]
	player.position = Vector2(position.x, position.z)
	
	player.bus = "SFX"
	
	# Pitch variation
	var pitch_range = pitch_ranges.get(name, [0.9, 1.1])
	player.pitch_scale = randf_range(pitch_range[0], pitch_range[1])
	
	add_child(player)
	player.play()
	
	player.finished.connect(player.queue_free)
	
# Automatically connect to any button that gets added to the scene
func _on_node_added(node: Node) -> void:
	if node is Button:
		if not node.pressed.is_connected(_on_button_pressed):
			node.pressed.connect(_on_button_pressed.bind(node))
	
func _on_button_pressed(button: Button) -> void:
	# Sounds are assigned separately in each menu (scene)
	if button.is_in_group("start_button"):
		play_ui_sfx("start")
	elif button.is_in_group("ui_button"):
		play_ui_sfx("button")

# Play UI sound effects
func play_ui_sfx(name: String) -> void:
	if not ui_players.has(name):
		push_warning("UI SFX not found: " + name)
		return
		
	var player := AudioStreamPlayer.new()
	player.stream = ui_players[name]
	player.bus = "SFX"
	
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
