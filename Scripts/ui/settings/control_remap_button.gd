extends Button

@export var action: String

signal stop_taking_mouse_input
signal start_taking_mouse_input

func _init() -> void:
	toggle_mode = true


func _ready() -> void:
	mouse_entered.connect(take_focus)
	var keybinds = CfgHandler.load_keybinds()
	
	if action not in keybinds:
		CfgHandler.create_new_preferences_file()
		keybinds = CfgHandler.load_keybinds()
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, keybinds[action])
	
	set_process_unhandled_input(false)
	update_key_text()


func update_key_text():
	text = CfgHandler.load_keybinds()[action].as_text()


func _toggled(toggled_on: bool) -> void:
	set_process_unhandled_input(toggled_on)
	if toggled_on:
		text = "Press new button"
		stop_taking_mouse_input.emit()
		release_focus()
	else:
		update_key_text()
		start_taking_mouse_input.emit()
		grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	
	var input_is_scrollwheel:=false
	if event is InputEventMouseButton:
		if event.button_index == 4 or event.button_index == 5:
			input_is_scrollwheel=true
	
	if event.is_pressed():
		if event.is_action("ui_cancel"):
			button_pressed = false
		elif input_is_scrollwheel:
			pass
		else:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			CfgHandler.save_keybind(action, event)
			button_pressed = false

func take_focus()->void:
	grab_focus()
