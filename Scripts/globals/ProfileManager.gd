extends Node

var current_profile: Dictionary = {}
const PROFILE_DIR = "user://profiles/"
const SETTINGS_FILE = "user://profile_settings.json"

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(PROFILE_DIR):
		DirAccess.make_dir_absolute(PROFILE_DIR)

func get_last_loaded_profile() -> String:
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data and data.has("last_profile"):
			return data["last_profile"]
	return ""

func set_last_loaded_profile(filename: String) -> void:
	var data = {}
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		var existing_data = JSON.parse_string(file.get_as_text())
		file.close()
		if existing_data:
			data = existing_data
	
	data["last_profile"] = filename
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func has_any_profile() -> bool:
	var dir = DirAccess.open(PROFILE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				return true
			file_name = dir.get_next()
	return false

func get_all_profiles() -> Array[Dictionary]:
	var profiles: Array[Dictionary] = []
	var dir = DirAccess.open(PROFILE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var full_path = PROFILE_DIR + file_name
				var file = FileAccess.open(full_path, FileAccess.READ)
				if file:
					var data = JSON.parse_string(file.get_as_text())
					if data and data is Dictionary:
						data["filename"] = file_name
						profiles.append(data)
					file.close()
			file_name = dir.get_next()
	return profiles

func profile_exists(username: String) -> bool:
	var filename = username + ".json"
	var full_path = PROFILE_DIR + filename
	return FileAccess.file_exists(full_path)

func create_profile(username: String) -> bool:
	if profile_exists(username):
		printerr("Profile with name " + username + " already exists.")
		return false
		
	var filename = username + ".json"
	current_profile = {
		"username": username,
		"created_at": Time.get_datetime_string_from_system(),
		"filename": filename
	}
	
	save_profile() 
	return true

func save_profile() -> void:
	if not current_profile.has("username"):
		printerr("Cannot save profile without username")
		return
		
	var filename = current_profile.get("filename", current_profile["username"] + ".json")
	var full_path = PROFILE_DIR + filename
	
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(current_profile, "\t"))
	file.close()

func load_profile(filename: String) -> void:
	var full_path = PROFILE_DIR + filename
	if FileAccess.file_exists(full_path):
		var file = FileAccess.open(full_path, FileAccess.READ)
		current_profile = JSON.parse_string(file.get_as_text())
		current_profile["filename"] = filename
		file.close()
		set_last_loaded_profile(filename)
	else:
		printerr("Profile not found: " + filename)

func delete_profile(filename: String) -> void:
	var full_path = PROFILE_DIR + filename
	if FileAccess.file_exists(full_path):
		DirAccess.remove_absolute(full_path)
		if current_profile.get("filename") == filename:
			current_profile = {}
		
		if get_last_loaded_profile() == filename:
			set_last_loaded_profile("")

func rename_profile(old_filename: String, new_username: String) -> bool:
	var old_path = PROFILE_DIR + old_filename
	var new_filename = new_username + ".json"
	var new_path = PROFILE_DIR + new_filename
	
	if FileAccess.file_exists(new_path):
		printerr("Profile with name " + new_username + " already exists.")
		return false
		
	if FileAccess.file_exists(old_path):
		var file = FileAccess.open(old_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if data:
			data["username"] = new_username
			data["filename"] = new_filename
			
			var new_file = FileAccess.open(new_path, FileAccess.WRITE)
			new_file.store_string(JSON.stringify(data, "\t"))
			new_file.close()
			
			DirAccess.remove_absolute(old_path)
			
			if current_profile.get("filename") == old_filename:
				current_profile = data
			
			if get_last_loaded_profile() == old_filename:
				set_last_loaded_profile(new_filename)
			
			return true
			
	return false
