extends Node3D

@onready var menu_container: MarginContainer = $Menu/MainHBox/MenuMargin
@onready var profile_container: MarginContainer = $Menu/MainHBox/ProfileMargin
@onready var settings_container: MarginContainer = $Menu/SettingsMargin
@onready var credits_container: MarginContainer = $Menu/CreditsMargin
@onready var tutorial_container: MarginContainer = $Menu/TutorialMargin
@onready var welcome_label: Label = $Menu/WelcomeMargin/WelcomeLabel

@onready var profiles_button:= $Menu/MainHBox/ProfileMargin/VBoxContainer/Profiles
@onready var stats_button:= $Menu/MainHBox/ProfileMargin/VBoxContainer/Stats
@onready var achievements_button:= $Menu/MainHBox/ProfileMargin/VBoxContainer/Achievements
@onready var match_history_button:= $Menu/MainHBox/ProfileMargin/VBoxContainer/MatchHistory


@onready var play_button: TextureButton = $Menu/MainHBox/MenuMargin/VBoxContainer/Play
@onready var settings_button: TextureButton = $Menu/MainHBox/MenuMargin/VBoxContainer/Settings
@onready var tutorial_button: TextureButton = $Menu/MainHBox/MenuMargin/VBoxContainer/Tutorial
@onready var credits_button: TextureButton = $Menu/MainHBox/MenuMargin/VBoxContainer/Credits
@onready var quit_button: TextureButton = $Menu/MainHBox/MenuMargin/VBoxContainer/Quit





const CREATE_PROFILE_MENU = preload("res://Scenes/main_menu/profile/create_profile_window.tscn")
const PROFILE_MENU = preload("res://Scenes/main_menu/profile/profile_menu.tscn")
const STATS_MENU = preload("res://Scenes/main_menu/profile/stats_menu.tscn")
const ACHIEVEMENTS_MENU = preload("res://Scenes/main_menu/profile/achievements_menu.tscn")
const MATCH_HISTORY_MENU = preload("res://Scenes/main_menu/profile/match_history_menu.tscn")

var active_profile_menu: Control = null
var active_stats_menu: Control = null
var active_achievements_menu: Control = null
var active_match_history_menu: Control = null

func _ready() -> void:
	
	Engine.time_scale = 1.0
	
	welcome_label.visible = false
	menu_container.visible = false
	profile_container.visible = false

	if not ProfileManager.has_any_profile():
		_show_create_profile_dialog()
	else:
		var last_profile = ProfileManager.get_last_loaded_profile()
		if last_profile != "" and ProfileManager.profile_exists(last_profile.replace(".json", "")):
			ProfileManager.load_profile(last_profile)
			_setup_main_menu()
		else:
			_show_profile_selection(true)
	
	# Add SFX to buttons
	play_button.add_to_group("start_button")
	profiles_button.add_to_group("ui_button")
	stats_button.add_to_group("ui_button")
	achievements_button.add_to_group("ui_button")
	match_history_button.add_to_group("ui_button")
	settings_button.add_to_group("ui_button")
	tutorial_button.add_to_group("ui_button")
	credits_button.add_to_group("ui_button")
	quit_button.add_to_group("ui_button")
	
	$Menu/CreditsMargin/Panel/MarginContainer/close_credits.add_to_group("ui_button")
	$Menu/TutorialMargin/Panel/MarginContainer/close_tutorial.add_to_group("ui_button")

################ Profile creation ####################

func _show_create_profile_dialog() -> void:
	menu_container.visible = false
	profile_container.visible = false
	welcome_label.visible = false
	
	var profile_menu = CREATE_PROFILE_MENU.instantiate()
	add_child(profile_menu)
	
	profile_menu.profile_created.connect(_on_profile_created)

func _on_profile_created(filename: String) -> void:
	ProfileManager.load_profile(filename)
	_setup_main_menu()

func _show_profile_selection(is_startup: bool) -> void:
	menu_container.visible = false
	profile_container.visible = false
	welcome_label.visible = false
	
	if active_profile_menu:
		active_profile_menu.queue_free()
		
	active_profile_menu = PROFILE_MENU.instantiate()
	add_child(active_profile_menu)
	
	active_profile_menu.set_startup_mode(is_startup)
	active_profile_menu.profile_selected.connect(_on_profile_selected)
	active_profile_menu.back_pressed.connect(_on_profile_menu_back)

func _on_profile_selected() -> void:
	if active_profile_menu:
		active_profile_menu.queue_free()
		active_profile_menu = null
	_setup_main_menu()

func _on_profile_menu_back() -> void:
	if active_profile_menu:
		active_profile_menu.queue_free()
		active_profile_menu = null
	_setup_main_menu()

func _setup_main_menu() -> void:
	menu_container.visible = true
	profile_container.visible = true
	welcome_label.visible = true

	if ProfileManager.current_profile.has("username"):
		welcome_label.text = "Welcome, " + ProfileManager.current_profile["username"]
	
	play_button.grab_focus()

#######################################################

func _on_play_pressed() -> void:
	GameManager.new_game()


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_settings_pressed() -> void:
	menu_container.visible = false
	profile_container.visible = false
	settings_container.visible = true
	$Menu/SettingsMargin/SettingsMenu.take_focus()


func _on_settings_menu_relay_back_to_menu_signal() -> void:
	menu_container.visible = true
	profile_container.visible = true
	settings_container.visible = false
	play_button.grab_focus()


func _on_tutorial_pressed() -> void:
	menu_container.visible = false
	profile_container.visible = false
	tutorial_container.visible = true
	$Menu/TutorialMargin/Panel/MarginContainer/close_tutorial.grab_focus()
	$Menu/TutorialMargin/Panel/MarginContainer2/RichTextLabel.update()


func _on_close_tutorial_pressed() -> void:
	menu_container.visible = true
	profile_container.visible = true
	tutorial_container.visible = false
	play_button.grab_focus()


func _on_credits_pressed() -> void:
	menu_container.visible = false
	profile_container.visible = false
	credits_container.visible = true
	$Menu/CreditsMargin/Panel/MarginContainer/close_credits.grab_focus()


func _on_close_credits_pressed() -> void:
	menu_container.visible = true
	profile_container.visible = true
	credits_container.visible = false
	play_button.grab_focus()

func _on_profiles_pressed() -> void:
	_show_profile_selection(false)


func mainmenu() -> void:
	pass


func _on_stats_pressed() -> void:
	menu_container.visible = false
	profile_container.visible = false
	welcome_label.visible = false

	if active_stats_menu:
		active_stats_menu.queue_free()

	active_stats_menu = STATS_MENU.instantiate()
	add_child(active_stats_menu)

	active_stats_menu.back_pressed.connect(_on_stats_menu_back)
	active_stats_menu.focus()

func _on_stats_menu_back() -> void:
	if active_stats_menu:
		active_stats_menu.queue_free()
		active_stats_menu = null
	_setup_main_menu()


func _on_achievements_pressed() -> void:
	menu_container.visible = false
	profile_container.visible = false
	welcome_label.visible = false

	if active_achievements_menu:
		active_achievements_menu.queue_free()

	active_achievements_menu = ACHIEVEMENTS_MENU.instantiate()
	add_child(active_achievements_menu)

	active_achievements_menu.back_pressed.connect(_on_achievements_menu_back)
	active_achievements_menu.focus()

func _on_achievements_menu_back() -> void:
	if active_achievements_menu:
		active_achievements_menu.queue_free()
		active_achievements_menu = null
	_setup_main_menu()


func _on_match_history_pressed() -> void:
	menu_container.visible = false
	profile_container.visible = false
	welcome_label.visible = false

	if active_match_history_menu:
		active_match_history_menu.queue_free()

	active_match_history_menu = MATCH_HISTORY_MENU.instantiate()
	add_child(active_match_history_menu)

	active_match_history_menu.back_pressed.connect(_on_match_history_menu_back)
	active_match_history_menu.focus()

func _on_match_history_menu_back() -> void:
	if active_match_history_menu:
		active_match_history_menu.queue_free()
		active_match_history_menu = null
	_setup_main_menu()
