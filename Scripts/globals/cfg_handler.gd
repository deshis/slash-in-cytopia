extends Node

var cfg = ConfigFile.new()

const CFG_PATH = ("user://preferences.cfg")

enum AntiAliasing {
	OFF,
	TAA,
	MSAA2X,
	MSAA4X,
	MSAA8X,
}


var Resolutions: Dictionary = {
	"3840x2160": Vector2i(3840, 2160),
	"2560x1440": Vector2i(2560, 1440),
	"1920x1080": Vector2i(1920, 1080),
	"1600x900": Vector2i(1600, 900),
	"1366x768": Vector2i(1366, 768),
	"1280x720": Vector2i(1280, 720),
}

func _ready() -> void:
	if FileAccess.file_exists(CFG_PATH):
		cfg.load(CFG_PATH)
	else:
		create_new_preferences_file()


func create_new_preferences_file() -> void:
	print("missing setting detected, creating new preferences file")
	
	cfg.clear()
	
	cfg.set_value("keybinds", "move_up", "W")
	cfg.set_value("keybinds", "move_left", "A")
	cfg.set_value("keybinds", "move_down", "S")
	cfg.set_value("keybinds", "move_right", "D")
	cfg.set_value("keybinds", "movement_ability", "Shift")
	cfg.set_value("keybinds", "inventory", "Tab")
	cfg.set_value("keybinds", "light_attack", "Left Mouse Button")
	cfg.set_value("keybinds", "heavy_attack", "Right Mouse Button")
	cfg.set_value("keybinds", "interact", "F")
	cfg.set_value("keybinds", "active_item", "Q")
	
	cfg.set_value("video", "antialiasing", AntiAliasing.TAA)
	cfg.set_value("video", "resolution", "1920x1080")
	cfg.set_value("video", "vsync", true)
	cfg.set_value("video", "fullscreen", false)
	
	cfg.set_value ("audio", "Master", 1.0)
	cfg.set_value ("audio", "Music", 1.0)
	cfg.set_value ("audio", "SFX", 1.0)
	
	cfg.save(CFG_PATH)


func save_video_setting(key:String, val)->void:
	cfg.set_value("video", key, val)
	cfg.save(CFG_PATH)


func load_video_settings() -> Dictionary:
	var video_settings:= {}
	for key in cfg.get_section_keys("video"):
		video_settings[key] = cfg.get_value("video", key)
	return video_settings


func save_audio_setting(key:String, val)->void:
	cfg.set_value("audio", key, val)
	cfg.save(CFG_PATH)


func load_audio_settings() -> Dictionary:
	var audio_settings:= {}
	for key in cfg.get_section_keys("audio"):
		audio_settings[key] = cfg.get_value("audio", key)
	return audio_settings


func save_keybind(action:StringName, event:InputEvent)->void:
	var event_str = event.as_text()
	if " (Double Click)" in event_str:
		event_str = event_str.rstrip((" (Double Click)"))
	cfg.set_value("keybinds", action, event_str)
	cfg.save(CFG_PATH)


func mouse_str_to_button_index(str:String)->int:
	match str:
		"Left Mouse Button":
			return 1
		"Right Mouse Button":
			return 2
		"Middle Mouse Button":
			return 3
		"Mouse Thumb Button 1":
			return 8
		"Mouse Thumb Button 2":
			return 9
	return -1


func load_keybinds() -> Dictionary:
	var keybinds:= {}
	var keys = cfg.get_section_keys("keybinds")
	for key in keys:
		var event_str = cfg.get_value("keybinds", key)
		var input_event
		if "Mouse" in event_str:
			input_event = InputEventMouseButton.new()
			input_event.button_index = mouse_str_to_button_index(event_str)
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		keybinds[key] = input_event
	return keybinds
