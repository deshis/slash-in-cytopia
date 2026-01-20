extends HSlider

@export var bus_name:String

var bus_index:int

func _ready() -> void:
	mouse_entered.connect(take_focus)
	
	var audio_settings = CfgHandler.load_audio_settings()
	
	if bus_name not in audio_settings:
		CfgHandler.create_new_preferences_file()
		audio_settings = CfgHandler.load_audio_settings()
	
	value = audio_settings[bus_name]
	
	bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	value_changed.connect(_on_value_changed)

func _on_value_changed(val:float)->void:
	CfgHandler.save_audio_setting(bus_name, val)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(val))

func take_focus()->void:
	grab_focus()
