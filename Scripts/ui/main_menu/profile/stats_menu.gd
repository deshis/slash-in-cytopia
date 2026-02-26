extends Control

const StatRow = preload("res://Scenes/main_menu/profile/stat_row.tscn")

@onready var left_column: VBoxContainer = $Panel/MarginContainer/HBoxContainer/ContentColumn/ScrollContainer/MarginContainer/StatsContainer/LeftColumn
@onready var middle_column: VBoxContainer = $Panel/MarginContainer/HBoxContainer/ContentColumn/ScrollContainer/MarginContainer/StatsContainer/MiddleColumn
@onready var right_column: VBoxContainer = $Panel/MarginContainer/HBoxContainer/ContentColumn/ScrollContainer/MarginContainer/StatsContainer/RightColumn
@onready var header_template: VBoxContainer = $Panel/HeaderTemplate

signal back_pressed

func focus() -> void:
	$Panel/MarginContainer/HBoxContainer/ButtonContainer/BackButton.grab_focus()

func _ready() -> void:
	$Panel/MarginContainer/HBoxContainer/ButtonContainer/BackButton.add_to_group("ui_button")
	update_stats()

func update_stats() -> void:
	for child in left_column.get_children():
		child.queue_free()
	for child in middle_column.get_children():
		child.queue_free()
	for child in right_column.get_children():
		child.queue_free()

	var stats = ProfileManager.current_profile.get("stats", {})
	if stats.is_empty():
		add_header("No stats recorded yet", left_column)
		return

	# Left column
	add_header("General", left_column)
	add_stat("Games Played", str(int(stats.get("game_count", 0))), left_column)
	add_stat("Time Played", format_time(int(stats.get("playing_time", 0))), left_column)
	add_stat("Longest Run", format_time(int(stats.get("longest_run_time", 0))), left_column)
	add_stat("Highest Stage", str(int(stats.get("highest_stage_reached", 0))), left_column)
	add_stat("Stages Cleared", str(int(stats.get("stages_cleared", 0))), left_column)
	add_stat("Dashes Used", str(int(stats.get("dashes_used", 0))), left_column)
	add_stat("Items Picked Up", str(int(stats.get("items_picked_up", 0))), left_column)
	add_stat("Items Trashed", str(int(stats.get("items_trashed", 0))), left_column)
	add_stat("Active Items Used", str(int(stats.get("active_items_used", 0))), left_column)
	add_stat("Throwables Used", str(int(stats.get("throwables_used", 0))), left_column)

	# Middle column
	add_header("Combat", middle_column)
	add_stat("Damage Dealt", str(snappedf(stats.get("total_damage_dealt", 0.0), 0.1)), middle_column)
	add_stat("Highest Hit", str(snappedf(stats.get("highest_single_hit", 0.0), 0.1)), middle_column)
	add_stat("Critical Hits", str(int(stats.get("critical_hits", 0))), middle_column)
	add_stat("Thorns Damage", str(snappedf(stats.get("thorns_damage", 0.0), 0.1)), middle_column)
	add_stat("Enemies Shattered", str(int(stats.get("frozen_enemies_shattered", 0))), middle_column)
	add_stat("Enemies Killed", str(int(stats.get("enemies_killed", 0))), middle_column)
	add_stat("Bosses Killed", str(int(stats.get("bosses_killed", 0))), middle_column)
	add_subheader("Survival", middle_column)
	add_stat("Damage Taken", str(snappedf(stats.get("total_damage_taken", 0.0), 0.1)), middle_column)
	add_stat("Damage Mitigated", str(snappedf(stats.get("damage_mitigated", 0.0), 0.1)), middle_column)
	add_stat("Total Healing", str(snappedf(stats.get("total_healing", 0.0), 0.1)), middle_column)
	add_stat("Health Stolen", str(snappedf(stats.get("health_stolen", 0.0), 0.1)), middle_column)
	add_stat("Deaths", str(int(stats.get("player_deaths", 0))), middle_column)

	# Right column
	var enemy_kills = stats.get("enemies_killed_by_type", {})
	var boss_kills = stats.get("bosses_killed_by_type", {})

	if not enemy_kills.is_empty() or not boss_kills.is_empty():
		add_header("Kills by Type", right_column)

		if not enemy_kills.is_empty():
			add_subheader("Enemies", right_column)
			for enemy_name in enemy_kills:
				add_stat(enemy_name, str(int(enemy_kills[enemy_name])), right_column)

		if not boss_kills.is_empty():
			add_subheader("Bosses", right_column)
			for boss_name in boss_kills:
				add_stat(boss_name, str(int(boss_kills[boss_name])), right_column)

func add_header(text: String, container: VBoxContainer) -> void:
	var header = header_template.duplicate()
	header.get_node("Label").text = text
	header.visible = true
	container.add_child(header)

func add_subheader(text: String, container: VBoxContainer) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.GRAY)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(label)

func add_stat(stat_name: String, value: String, container: VBoxContainer) -> void:
	var stat_row = StatRow.instantiate()
	stat_row.get_node("NameLabel").text = stat_name
	stat_row.get_node("ValueLabel").text = value
	container.add_child(stat_row)

func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	var hours = minutes / 60
	var remaining_minutes = minutes % 60

	if hours > 0:
		return "%d:%02d:%02d" % [hours, remaining_minutes, remaining_seconds]
	else:
		return "%02d:%02d" % [remaining_minutes, remaining_seconds]

func _on_back_button_pressed() -> void:
	back_pressed.emit()
