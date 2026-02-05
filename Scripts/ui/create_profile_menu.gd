extends Control

signal profile_created(filename: String)

@onready var username_input: LineEdit = $Panel/VBoxContainer/UsernameInput
@onready var create_button: Button = $Panel/VBoxContainer/CreateButton
@onready var cancel_button: Button = $Panel/VBoxContainer/CancelButton
@onready var accept_dialog: AcceptDialog = $AcceptDialog


func _ready() -> void:
	$Panel/VBoxContainer/CreateButton.add_to_group("ui_button")
	$Panel/VBoxContainer/CancelButton.add_to_group("ui_button")
	
	create_button.pressed.connect(_on_create_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	username_input.text_submitted.connect(_on_text_submitted)

	username_input.grab_focus()
	
	if not ProfileManager.has_any_profile():
		cancel_button.visible = false

func _on_create_button_pressed() -> void:
	submit_profile()

func _on_cancel_button_pressed() -> void:
	queue_free()

func _on_text_submitted(_new_text: String) -> void:
	submit_profile()

func submit_profile() -> void:
	var username = username_input.text.strip_edges()
	
	if username.is_empty():
		print("Username cannot be empty")
		return
		
	if ProfileManager.create_profile(username):
		profile_created.emit(username + ".json")
		queue_free()
	else:
		accept_dialog.dialog_text = "Profile with name '" + username + "' already exists."
		accept_dialog.popup_centered()
