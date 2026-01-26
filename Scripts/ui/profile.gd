extends Button

@onready var name_label: Label = $MarginContainer/HBoxContainer/NameLabel
@onready var date_label: Label = $MarginContainer/HBoxContainer/DateLabel

var _username: String = ""
var _created_at: String = ""

func _ready() -> void:
	if not _username.is_empty():
		name_label.text = _username
	if not _created_at.is_empty():
		date_label.text = _created_at

func set_profile_data(username: String, created_at: String) -> void:
	_username = username
	_created_at = created_at
	
	if is_inside_tree():
		name_label.text = username
		date_label.text = created_at