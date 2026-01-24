extends Node

var current_profile: Dictionary = {}
const PROFILE_PATH = "user://profiles/player_profile.json"

func _ready() -> void:
	if not DirAccess.dir_exists_absolute("user://profiles"):
		DirAccess.make_dir_absolute("user://profiles")

	# TEMPORARY: Uncomment this line to reset profile every time you run the game
	DirAccess.remove_absolute(PROFILE_PATH) 

func has_profile() -> bool:
	return FileAccess.file_exists(PROFILE_PATH)

func create_profile(username: String) -> void:
	current_profile = {
		"username": username,
		"created_at": Time.get_datetime_string_from_system(),
	}
	
	save_profile() 

func save_profile() -> void:
	var file = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(current_profile, "\t"))
	file.close()

func load_profile() -> void:
	if has_profile():
		var file = FileAccess.open(PROFILE_PATH, FileAccess.READ)
		current_profile = JSON.parse_string(file.get_as_text())
		file.close()
