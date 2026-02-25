extends TabContainer


@onready var buttons := [
	$Controls/VBoxContainer/moveup/ControlRemapButton, 
	$Controls/VBoxContainer/movedown/ControlRemapButton, 
	$Controls/VBoxContainer/moveleft/ControlRemapButton,
	$Controls/VBoxContainer/moveright/ControlRemapButton,
	$Controls/VBoxContainer/dash/ControlRemapButton,
	$Controls/VBoxContainer/inventory/ControlRemapButton,
	$Controls/VBoxContainer/primary/ControlRemapButton,
	$Controls/VBoxContainer/secondary/ControlRemapButton,
	$Controls/VBoxContainer/interact/ControlRemapButton,
	$Controls/VBoxContainer/throwable/ControlRemapButton,
	$Controls/VBoxContainer/active/ControlRemapButton,
	]

func _ready() -> void:
	#tab_hovered.connect(tab_grab_focus)
	for button in buttons:
		button.stop_taking_mouse_input.connect(_stop_taking_mouse_input)
		button.start_taking_mouse_input.connect(_start_taking_mouse_input)
	
	$Audio/VBoxContainer/BackToMenuButton.add_to_group("ui_button")
	$Graphics/VBoxContainer/BackToMenuButton.add_to_group("ui_button")
	$Controls/VBoxContainer/BackToMenuButton.add_to_group("ui_button")
	$Gameplay/VBoxContainer/BackToMenuButton.add_to_group("ui_button")

func _stop_taking_mouse_input() -> void:
	set_mouse_behavior_recursive(MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED)

func _start_taking_mouse_input() -> void:
	set_mouse_behavior_recursive(MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED)

#func tab_grab_focus(i:int)->void:
#	get_tab_bar().grab_focus()
#	set_current_tab(i)
	
