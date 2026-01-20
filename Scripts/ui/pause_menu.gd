extends Control

@onready var panel: Panel = $Panel
@onready var settings_menu: Control = $SettingsMenu
@onready var tab_container: TabContainer = $SettingsMenu/TabContainer
@onready var master_volume_slider: HSlider = $SettingsMenu/TabContainer/Audio/VBoxContainer/MasterVolumeSlider
# Pause menu buttons
@onready var continue_button: Button = $Panel/MarginContainer/VBoxContainer/ContinueButton
@onready var settings_button: Button = $Panel/MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/MarginContainer/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false

	for b in [continue_button, settings_button, quit_button]:
		if b:
			b.add_to_group("ui_button")
		else:
			push_warning("Pause menu button missing")



func pause()->void:
	visible = true
	GameManager.set_menu(true)
	continue_button.grab_focus()


func unpause()->void:
	visible = false
	GameManager.set_menu(false)
	continue_button.grab_focus()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			if GameManager.open_menu_count < 1:
				pause()
			elif settings_menu.visible:
				toggle_settings_menu()
			else:
				unpause()


func _on_continue_button_pressed() -> void:
	unpause()


func _on_settings_button_pressed() -> void:
	toggle_settings_menu()


func toggle_settings_menu()->void:
	panel.visible=!panel.visible
	settings_menu.visible=!settings_menu.visible
	
	if settings_menu.visible:
		tab_container.current_tab = 0 
		tab_container.get_tab_bar().grab_focus()
	else:
		continue_button.grab_focus()


func _on_quit_button_pressed() -> void:
	GameManager.quit_to_menu()


func _on_settings_menu_relay_back_to_menu_signal() -> void:
	toggle_settings_menu()
