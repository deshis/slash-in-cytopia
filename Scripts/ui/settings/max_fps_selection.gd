extends OptionButton

func _ready():
	mouse_entered.connect(take_focus)
	
	var video_settings = CfgHandler.load_video_settings()
	if "framerate" not in video_settings:
		CfgHandler.create_new_preferences_file() 
		video_settings = CfgHandler.load_video_settings()
	
	var target_fps = int(video_settings.framerate)
	
	select(CfgHandler.framerates.find(target_fps))
	Engine.set_max_fps(CfgHandler.framerates[selected])


func _on_item_selected(index: int) -> void:
	CfgHandler.save_video_setting("framerate", get_item_text(index))
	Engine.set_max_fps(CfgHandler.framerates[selected])


func take_focus() -> void:
	grab_focus()
