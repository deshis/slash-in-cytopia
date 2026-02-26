extends Control

signal back_pressed

const MatchHistoryRow = preload("res://Scenes/main_menu/profile/match_history_row.tscn")
const MATCHES_PER_PAGE = 4

@onready var match_list_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer/ContentColumn/ScrollContainer/CenterContainer/MatchListContainer
@onready var page_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer/ContentColumn/PageContainer
@onready var first_button: Button = $Panel/MarginContainer/HBoxContainer/ContentColumn/PageContainer/FirstButton
@onready var prev_button: Button = $Panel/MarginContainer/HBoxContainer/ContentColumn/PageContainer/PrevButton
@onready var next_button: Button = $Panel/MarginContainer/HBoxContainer/ContentColumn/PageContainer/NextButton
@onready var last_button: Button = $Panel/MarginContainer/HBoxContainer/ContentColumn/PageContainer/LastButton
@onready var page_label: Label = $Panel/MarginContainer/HBoxContainer/ContentColumn/PageContainer/PageLabel

var current_page: int = 0
var total_pages: int = 0
var match_history: Array = []

func focus() -> void:
	$Panel/MarginContainer/HBoxContainer/ButtonContainer/BackButton.grab_focus()

func _ready() -> void:
	$Panel/MarginContainer/HBoxContainer/ButtonContainer/BackButton.add_to_group("ui_button")
	first_button.add_to_group("ui_button")
	prev_button.add_to_group("ui_button")
	next_button.add_to_group("ui_button")
	last_button.add_to_group("ui_button")
	first_button.pressed.connect(_on_first_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	last_button.pressed.connect(_on_last_pressed)
	update_match_history()

func update_match_history() -> void:
	match_history = ProfileManager.current_profile.get("match_history", [])
	total_pages = max(1, ceili(float(match_history.size()) / MATCHES_PER_PAGE))
	current_page = 0
	_update_page_display()

func _update_page_display() -> void:
	for child in match_list_container.get_children():
		child.queue_free()

	if match_history.is_empty():
		var label = Label.new()
		label.text = "No match history yet. Play a game to see your runs here!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		match_list_container.add_child(label)
		page_container.visible = false
		return

	page_container.visible = true

	var start_idx = current_page * MATCHES_PER_PAGE
	var end_idx = min(start_idx + MATCHES_PER_PAGE, match_history.size())

	var total_matches = match_history.size()
	for i in range(start_idx, end_idx):
		var row = MatchHistoryRow.instantiate()
		match_list_container.add_child(row)
		# Match number: 1 = earliest, higher = more recent
		var match_number = total_matches - i
		row.set_match_data(match_history[i], match_number)

	page_label.text = "%d / %d" % [current_page + 1, total_pages]
	first_button.disabled = current_page == 0
	prev_button.disabled = current_page == 0
	next_button.disabled = current_page >= total_pages - 1
	last_button.disabled = current_page >= total_pages - 1

func _on_first_pressed() -> void:
	if current_page != 0:
		current_page = 0
		_update_page_display()

func _on_prev_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		_update_page_display()

func _on_next_pressed() -> void:
	if current_page < total_pages - 1:
		current_page += 1
		_update_page_display()

func _on_last_pressed() -> void:
	if current_page != total_pages - 1:
		current_page = total_pages - 1
		_update_page_display()

func _on_back_button_pressed() -> void:
	back_pressed.emit()
