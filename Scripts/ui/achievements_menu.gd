extends Control

signal back_pressed

const AchievementCard = preload("res://Scenes/main_menu/profile/achievement_row.tscn")

@onready var achievement_grid: GridContainer = $Panel/MarginContainer/HBoxContainer/ContentColumn/ScrollContainer/AchievementGrid

func focus() -> void:
	$Panel/MarginContainer/HBoxContainer/ButtonContainer/BackButton.grab_focus()

func _ready() -> void:
	update_achievements()

func update_achievements() -> void:
	for child in achievement_grid.get_children():
		child.queue_free()

	var achievements = AchievementManager.get_all_achievements()

	if achievements.is_empty():
		var label = Label.new()
		label.text = "No achievements available"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		achievement_grid.add_child(label)
		return

	for achievement in achievements:
		var card = AchievementCard.instantiate()
		var name_label: Label = card.get_node("MarginContainer/VBoxContainer/NameLabel")
		var desc_label: Label = card.get_node("MarginContainer/VBoxContainer/DescriptionLabel")

		if achievement["unlocked"]:
			name_label.text = achievement["name"]
			desc_label.text = achievement["description"]
		else:
			name_label.visible = false
			desc_label.visible = false
			card.get_node("MarginContainer/VBoxContainer/LockedLabel").visible = true

		achievement_grid.add_child(card)

func _on_back_button_pressed() -> void:
	back_pressed.emit()
