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
	var profile_data = {
		"username": username,
		"created_at": Time.get_datetime_string_from_system(),
		"filename": filename,
		"stats": {
			"game_count": 0,
			"playing_time": 0,
			"total_damage_dealt": 0.0,
			"total_damage_taken": 0.0,
			"damage_mitigated": 0.0,
			"critical_hits": 0,
			"highest_single_hit": 0.0,
			"thorns_damage": 0.0,
			"frozen_enemies_shattered": 0,
			"enemies_killed": 0,
			"bosses_killed": 0,
			"enemies_killed_by_type": {},
			"bosses_killed_by_type": {},
			"dashes_used": 0,
			"active_items_used": 0,
			"throwables_used": 0,
			"items_picked_up": 0,
			"items_trashed": 0,
			"player_deaths": 0,
			"total_healing": 0.0,
			"health_stolen": 0.0,
			"longest_run_time": 0
		},
		"achievements": []
	}

	var full_path = PROFILE_DIR + filename
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(profile_data, "\t"))
	file.close()
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
		if not current_profile.has("achievements"):
			current_profile["achievements"] = []
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

func update_stats_from_run() -> void:
	if current_profile.is_empty():
		return
		
	if not current_profile.has("stats"):
		current_profile["stats"] = {
			"game_count": 0,
			"playing_time": 0,
			"total_damage_dealt": 0.0,
			"total_damage_taken": 0.0,
			"damage_mitigated": 0.0,
			"critical_hits": 0,
			"highest_single_hit": 0.0,
			"thorns_damage": 0.0,
			"frozen_enemies_shattered": 0,
			"enemies_killed": 0,
			"bosses_killed": 0,
			"enemies_killed_by_type": {},
			"bosses_killed_by_type": {},
			"dashes_used": 0,
			"active_items_used": 0,
			"throwables_used": 0,
			"items_picked_up": 0,
			"items_trashed": 0,
			"player_deaths": 0,
			"total_healing": 0.0,
			"health_stolen": 0.0,
			"longest_run_time": 0
		}
	
	var stats = current_profile["stats"]
	
	stats["game_count"] += 1
	stats["playing_time"] += GameStats.time_alive_seconds
	
	stats["total_damage_dealt"] += GameStats.total_damage_dealt
	stats["total_damage_taken"] += GameStats.total_damage_taken
	stats["damage_mitigated"] += GameStats.damage_mitigated
	stats["critical_hits"] += GameStats.critical_hits
	
	if GameStats.highest_single_hit > stats.get("highest_single_hit", 0.0):
		stats["highest_single_hit"] = GameStats.highest_single_hit
		
	stats["thorns_damage"] += GameStats.thorns_damage
	stats["frozen_enemies_shattered"] += GameStats.frozen_enemies_shattered
	
	stats["enemies_killed"] += GameStats.enemies_killed
	
	# Merge enemy kills by type
	for enemy_type in GameStats.enemies_killed_by_type:
		if not stats["enemies_killed_by_type"].has(enemy_type):
			stats["enemies_killed_by_type"][enemy_type] = 0
		stats["enemies_killed_by_type"][enemy_type] += GameStats.enemies_killed_by_type[enemy_type]
	
	# Merge boss kills by type
	var boss_kills_this_run = 0
	for boss_type in GameStats.bosses_killed_by_type:
		var count = GameStats.bosses_killed_by_type[boss_type]
		boss_kills_this_run += count
		
		if not stats["bosses_killed_by_type"].has(boss_type):
			stats["bosses_killed_by_type"][boss_type] = 0
		stats["bosses_killed_by_type"][boss_type] += count
		
	stats["bosses_killed"] += boss_kills_this_run
	
	stats["dashes_used"] += GameStats.dashes_used
	stats["active_items_used"] += GameStats.active_items_used
	stats["throwables_used"] += GameStats.throwables_used
	stats["items_picked_up"] += GameStats.items_picked_up
	stats["items_trashed"] += GameStats.items_trashed
	
	if GameManager.player and GameManager.player.is_dead:
		stats["player_deaths"] += 1
		
	stats["total_healing"] += GameStats.total_healing
	stats["health_stolen"] += GameStats.health_stolen
		
	if GameStats.time_alive_seconds > stats.get("longest_run_time", 0):
		stats["longest_run_time"] = GameStats.time_alive_seconds
		
	save_profile()

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
