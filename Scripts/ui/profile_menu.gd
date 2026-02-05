extends Control

signal profile_selected
signal back_pressed

@onready var profile_list_container: VBoxContainer = $Panel/MarginContainer/HBoxContainer/ProfileList/ScrollContainer/MarginContainer/VBoxContainer
@onready var create_button: Button = $Panel/MarginContainer/HBoxContainer/Actions/CreateButton
@onready var load_button: Button = $Panel/MarginContainer/HBoxContainer/Actions/LoadButton
@onready var delete_button: Button = $Panel/MarginContainer/HBoxContainer/Actions/DeleteButton
@onready var rename_button: Button = $Panel/MarginContainer/HBoxContainer/Actions/RenameButton
@onready var back_button: Button = $Panel/MarginContainer/HBoxContainer/Actions/BackButton

@onready var rename_dialog: ConfirmationDialog = $RenameDialog
@onready var rename_input: LineEdit = $RenameDialog/VBoxContainer/RenameInput

@onready var delete_confirm_dialog: ConfirmationDialog = $DeleteConfirmDialog
@onready var accept_dialog: AcceptDialog = $AcceptDialog

const CREATE_PROFILE_MENU = preload("res://Scenes/main_menu/profile/create_profile_window.tscn")
const PROFILE_ITEM_SCENE = preload("res://Scenes/main_menu/profile/profile.tscn")

var selected_profile_filename: String = ""
var profile_buttons: Array[Button] = []
var _is_startup: bool = false

func _ready() -> void:
	create_button.pressed.connect(_on_create_pressed)
	load_button.pressed.connect(_on_load_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	rename_button.pressed.connect(_on_rename_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	rename_dialog.confirmed.connect(_on_rename_confirmed)
	delete_confirm_dialog.confirmed.connect(_on_delete_confirmed)
	
	create_button.add_to_group("ui_button")
	load_button.add_to_group("ui_button")
	delete_button.add_to_group("ui_button")
	rename_button.add_to_group("ui_button")
	back_button.add_to_group("ui_button")

	for btn in [load_button, create_button, rename_button, delete_button, back_button]:
		btn.mouse_entered.connect(btn.grab_focus)
	
	refresh_profile_list()
	update_buttons_state()

func set_startup_mode(is_startup: bool) -> void:
	_is_startup = is_startup
	back_button.visible = !is_startup

func refresh_profile_list() -> void:

	for child in profile_list_container.get_children():
		child.queue_free()
	profile_buttons.clear()
	
	var profiles = ProfileManager.get_all_profiles()
	
	for profile in profiles:
		var btn = PROFILE_ITEM_SCENE.instantiate()
		var created_at = profile["created_at"].replace("T", " ")

		var display_name = profile["username"]
		if profile["filename"] == ProfileManager.current_profile.get("filename", ""):
			display_name += " (Current)"

		btn.set_profile_data(display_name, created_at)
		
		btn.set_meta("filename", profile["filename"])
		btn.pressed.connect(_on_profile_button_pressed.bind(btn))
		btn.add_to_group("ui_button")
		
		profile_list_container.add_child(btn)
		profile_buttons.append(btn)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	profile_list_container.add_child(spacer)
	
	if selected_profile_filename != "":
		var found = false
		for btn in profile_buttons:
			if btn.get_meta("filename") == selected_profile_filename:
				btn.set_pressed_no_signal(true)
				found = true
				break
		if not found:
			selected_profile_filename = ""
	
	update_buttons_state()

func _on_profile_button_pressed(pressed_btn: Button) -> void:
	for btn in profile_buttons:
		if btn != pressed_btn:
			btn.set_pressed_no_signal(false)
	
	if pressed_btn.button_pressed:
		selected_profile_filename = pressed_btn.get_meta("filename")
	else:

		pressed_btn.set_pressed_no_signal(true)
		selected_profile_filename = pressed_btn.get_meta("filename")
	
	update_buttons_state()

func update_buttons_state() -> void:
	var has_selection = selected_profile_filename != ""
	var is_current_profile = selected_profile_filename == ProfileManager.current_profile.get("filename", "")
	load_button.disabled = !has_selection or (is_current_profile and not _is_startup)
	delete_button.disabled = !has_selection
	rename_button.disabled = !has_selection

func _on_create_pressed() -> void:
	var create_menu = CREATE_PROFILE_MENU.instantiate()
	add_child(create_menu)
	create_menu.profile_created.connect(_on_profile_created_from_dialog)

func _on_profile_created_from_dialog(filename: String) -> void:
	selected_profile_filename = filename
	refresh_profile_list()

func _on_load_pressed() -> void:
	if selected_profile_filename != "":
		ProfileManager.load_profile(selected_profile_filename)
		profile_selected.emit()

func _on_delete_pressed() -> void:
	if selected_profile_filename != "":
		delete_confirm_dialog.popup_centered()

func _on_delete_confirmed() -> void:
	if selected_profile_filename != "":
		ProfileManager.delete_profile(selected_profile_filename)
		selected_profile_filename = ""
		refresh_profile_list()

func _on_rename_pressed() -> void:
	if selected_profile_filename != "":
		rename_input.text = ""
		rename_dialog.popup_centered()
		rename_input.grab_focus()

func _on_rename_confirmed() -> void:
	var new_name = rename_input.text.strip_edges()
	if new_name != "" and selected_profile_filename != "":
		if ProfileManager.profile_exists(new_name):
			accept_dialog.dialog_text = "Profile with name '" + new_name + "' already exists."
			accept_dialog.popup_centered()
			return
			
		if ProfileManager.rename_profile(selected_profile_filename, new_name):
			selected_profile_filename = new_name + ".json"
			refresh_profile_list()
		else:
			print("Rename failed: Name likely taken")

func _on_back_pressed() -> void:
	back_pressed.emit()
