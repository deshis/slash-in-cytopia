extends OptionButton

var current_resolution

func _ready() -> void:
	mouse_entered.connect(take_focus)
	var video_settings = CfgHandler.load_video_settings()
	
	if "resolution" not in video_settings:
		CfgHandler.create_new_preferences_file() 
		video_settings = CfgHandler.load_video_settings()
	
	current_resolution = CfgHandler.Resolutions[video_settings.resolution]
	get_window().set_size(current_resolution)
	add_resolutions()


func add_resolutions()->void:
	var ID = 0
	for res in CfgHandler.Resolutions:
		add_item(res, ID)
		if CfgHandler.Resolutions[res] == current_resolution:
			select(ID)
		ID+=1


func _on_item_selected(index: int) -> void:
	var ID = get_item_text(index)
	current_resolution=CfgHandler.Resolutions[ID]
	CfgHandler.save_video_setting("resolution", ID)
	get_window().set_size(current_resolution)
	center_window()


func center_window()->void:
	var center_screen = DisplayServer.screen_get_position()+DisplayServer.screen_get_size()/2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(center_screen-window_size/2)


func set_resolution_text()->void:
	var res_text = str(get_window().get_size().x)+"x"+str(get_window().get_size().y)
	set_text(res_text)


func handle_full_screen_toggle(fullscreen:bool)->void:
	set_disabled(fullscreen)
	get_tree().create_timer(0.05).timeout.connect(set_resolution_text)
	
	if not fullscreen:
		var ID = 0
		for res in CfgHandler.Resolutions:
			if CfgHandler.Resolutions[res] == current_resolution:
				select(ID)
				get_window().set_size(CfgHandler.Resolutions[res])
			ID+=1
		center_window()


func take_focus() -> void:
	grab_focus()
