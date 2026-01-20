extends CheckButton

@export var res_selection:OptionButton

func _ready() -> void:
	mouse_entered.connect(take_focus)
	var video_settings = CfgHandler.load_video_settings()
	
	if "fullscreen" not in video_settings:
		CfgHandler.create_new_preferences_file() 
		video_settings = CfgHandler.load_video_settings()
	
	button_pressed = video_settings["fullscreen"]
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		CfgHandler.save_video_setting("fullscreen", true)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		CfgHandler.save_video_setting("fullscreen", false)
	
	res_selection.handle_full_screen_toggle(toggled_on)

func take_focus() -> void:
	grab_focus()
