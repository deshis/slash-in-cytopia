extends Node3D

@onready var menu_container: MarginContainer = $Menu/MenuMargin
@onready var settings_container: MarginContainer = $Menu/SettingsMargin
@onready var credits_container: MarginContainer = $Menu/CreditsMargin
@onready var tutorial_container: MarginContainer = $Menu/TutorialMargin


func _ready() -> void:
	
	$Menu/MenuMargin/VBoxContainer/Play.grab_focus()
	
	# Add SFX to buttons
	$Menu/MenuMargin/VBoxContainer/Play.add_to_group("start_button")
	$Menu/MenuMargin/VBoxContainer/Settings.add_to_group("ui_button")
	$Menu/MenuMargin/VBoxContainer/Tutorial.add_to_group("ui_button")
	$Menu/MenuMargin/VBoxContainer/Credits.add_to_group("ui_button")
	$Menu/MenuMargin/VBoxContainer/Quit.add_to_group("ui_button")
	
	$Menu/CreditsMargin/Panel/MarginContainer/close_credits.add_to_group("ui_button")
	$Menu/TutorialMargin/Panel/MarginContainer/close_tutorial.add_to_group("ui_button")



func _on_play_pressed() -> void:
	GameManager.restart()


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_settings_pressed() -> void:
	menu_container.visible = false
	settings_container.visible = true
	$Menu/SettingsMargin/SettingsMenu.take_focus()


func _on_settings_menu_relay_back_to_menu_signal() -> void:
	menu_container.visible = true
	settings_container.visible = false
	$Menu/MenuMargin/VBoxContainer/Play.grab_focus()


func _on_tutorial_pressed() -> void:
	menu_container.visible = false
	tutorial_container.visible = true
	$Menu/TutorialMargin/Panel/MarginContainer/close_tutorial.grab_focus()


func _on_close_tutorial_pressed() -> void:
	menu_container.visible = true
	tutorial_container.visible = false
	$Menu/MenuMargin/VBoxContainer/Play.grab_focus()


func _on_credits_pressed() -> void:
	menu_container.visible = false
	credits_container.visible = true
	$Menu/CreditsMargin/Panel/MarginContainer/close_credits.grab_focus()


func _on_close_credits_pressed() -> void:
	menu_container.visible = true
	credits_container.visible = false
	$Menu/MenuMargin/VBoxContainer/Play.grab_focus()
