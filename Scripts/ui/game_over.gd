extends Control

@onready var cause_of_death: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/cause_of_death
@onready var time_alive: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/time_alive
@onready var stages_cleared: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/stages_cleared
@onready var enemies_killed: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/enemies_killed
@onready var damage_dealt: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/damage_dealt
@onready var damage_taken: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/damage_taken
@onready var items_picked_up: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/items_picked_up

@onready var restart_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer2/restart_button

func _ready() -> void:
	# Add audio to buttons
	$Panel/MarginContainer/VBoxContainer/HBoxContainer2/restart_button.add_to_group("ui_button")
	$Panel/MarginContainer/VBoxContainer/HBoxContainer2/quit_button.add_to_group("ui_button")

var player:Player


func setup(p: Player) -> void:
	player = p
	player.game_over.connect(player_dead)


func player_dead()->void:
	visible=true
	time_alive.append_text(yellow_text(seconds_to_minute_and_seconds(GameStats.time_alive_seconds)))
	stages_cleared.append_text(yellow_text(str(GameStats.stages_cleared)))
	enemies_killed.append_text(yellow_text(str(GameStats.enemies_killed)))
	damage_dealt.append_text(yellow_text(str(snapped(GameStats.total_damage_dealt, 0.01))))
	damage_taken.append_text(yellow_text(str(snapped(GameStats.total_damage_taken, 0.01))))
	items_picked_up.append_text(yellow_text(str(GameStats.items_picked_up)))
	
	cause_of_death.append_text(red_text(GameStats.player_last_hit_by))
	
	restart_button.grab_focus()


func seconds_to_minute_and_seconds(seconds:int)->String:
	var minutes := 0
	while seconds > 59:
		minutes += 1
		seconds -= 60
	return "%02d:%02d" % [minutes, seconds]


func yellow_text(s:String)->String:
	return "[color=yellow]%s[/color]" % s


func red_text(s:String)->String:
	return "[color=red]%s[/color]" % s


func _on_restart_button_pressed() -> void:
	GameManager.restart()
	#get_tree().change_scene_to_file("res://Scenes/main.tscn")
	#visible = false


func _on_quit_button_pressed() -> void:
	GameManager.quit_to_menu()
