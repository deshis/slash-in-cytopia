extends Control

signal profile_created

@onready var username_input: LineEdit = $Panel/VBoxContainer/UsernameInput
@onready var create_button: Button = $Panel/VBoxContainer/CreateButton


func _ready() -> void:
	$Panel/VBoxContainer/CreateButton.add_to_group("ui_button")
	
	create_button.pressed.connect(_on_create_button_pressed)
	username_input.text_submitted.connect(_on_text_submitted)

	username_input.grab_focus()

func _on_create_button_pressed() -> void:
	submit_profile()

func _on_text_submitted(_new_text: String) -> void:
	submit_profile()

func submit_profile() -> void:
	var username = username_input.text.strip_edges()
	
	if username.is_empty():
		print("Username cannot be empty")
		return
		
	ProfileManager.create_profile(username)
	
	
	profile_created.emit()
	queue_free()
