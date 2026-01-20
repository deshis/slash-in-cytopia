extends Control

signal relay_back_to_menu_signal

func _on_back_to_menu_button_pressed() -> void:
	relay_back_to_menu_signal.emit()

func take_focus()->void:
	$TabContainer.get_tab_bar().grab_focus()
