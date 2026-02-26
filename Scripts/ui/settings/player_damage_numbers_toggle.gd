extends CheckButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(grab_focus)
	
	var settings = CfgHandler.load_gameplay_settings()
	if "player_damage_numbers" not in settings:
		CfgHandler.create_new_preferences_file() 
		settings = CfgHandler.load_gameplay_settings()
	
	set_pressed( settings["player_damage_numbers"] )

func _toggled(toggled_on: bool) -> void:
	CfgHandler.save_gameplay_setting("player_damage_numbers", toggled_on)
	
