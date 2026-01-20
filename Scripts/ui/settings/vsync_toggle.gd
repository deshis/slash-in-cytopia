extends CheckButton


func _ready() -> void:
	mouse_entered.connect(take_focus)
	var video_settings = CfgHandler.load_video_settings()
	
	if "vsync" not in video_settings:
		CfgHandler.create_new_preferences_file() 
		video_settings = CfgHandler.load_video_settings()
		
	button_pressed = video_settings["vsync"]
	if button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		CfgHandler.save_video_setting("vsync", true)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		CfgHandler.save_video_setting("vsync", false)


func take_focus() -> void:
	grab_focus()
