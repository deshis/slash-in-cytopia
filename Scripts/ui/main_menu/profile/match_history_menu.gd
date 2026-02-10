extends Control

signal back_pressed

const MatchHistoryRow = preload("res://Scenes/main_menu/profile/match_history_row.tscn")

@onready var match_list_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer/ContentColumn/ScrollContainer/CenterContainer/MatchListContainer

func focus() -> void:
	$Panel/MarginContainer/HBoxContainer/ButtonContainer/BackButton.grab_focus()

func _ready() -> void:
	$Panel/MarginContainer/HBoxContainer/ButtonContainer/BackButton.add_to_group("ui_button")
	update_match_history()

func update_match_history() -> void:
	for child in match_list_container.get_children():
		child.queue_free()

	var match_history = ProfileManager.current_profile.get("match_history", [])

	if match_history.is_empty():
		var label = Label.new()
		label.text = "No match history yet. Play a game to see your runs here!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		match_list_container.add_child(label)
		return

	# Create a row for each match
	for match_data in match_history:
		var row = MatchHistoryRow.instantiate()
		match_list_container.add_child(row)
		row.set_match_data(match_data)

func _on_back_button_pressed() -> void:
	back_pressed.emit()
