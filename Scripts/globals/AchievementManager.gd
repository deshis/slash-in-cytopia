extends Node

signal achievement_unlocked(achievement_data: Dictionary)

var achievements: Array[Dictionary] = [
	{
		"id": "enemies_killed_1",
		"name": "1",
		"description": "Kill 1 enemies",
		"stat": "enemies_killed",
		"threshold": 1,
	},
	{
		"id": "enemies_killed_2",
		"name": "2",
		"description": "Kill 2 enemies",
		"stat": "enemies_killed",
		"threshold": 2,
	},
	{
		"id": "enemies_killed_5",
		"name": "3",
		"description": "Kill 5 enemies",
		"stat": "enemies_killed",
		"threshold": 5,
	},
	{
		"id": "bosses_killed_1",
		"name": "4",
		"description": "Kill 1 boss",
		"stat": "bosses_killed",
		"threshold": 1,
	},
	{
		"id": "bosses_killed_5",
		"name": "5",
		"description": "Kill 5 bosses",
		"stat": "bosses_killed",
		"threshold": 5,
	},
	{
		"id": "damage_dealt_100",
		"name": "6",
		"description": "Deal 100 total damage",
		"stat": "total_damage_dealt",
		"threshold": 100,
	},
	{
		"id": "damage_dealt_500",
		"name": "7",
		"description": "Deal 500 total damage",
		"stat": "total_damage_dealt",
		"threshold": 500,
	},
	{
		"id": "stages_cleared_1",
		"name": "8",
		"description": "Clear 1 stages",
		"stat": "stages_cleared",
		"threshold": 1,
	},
	{
		"id": "stages_cleared_20",
		"name": "9",
		"description": "Clear 20 stages",
		"stat": "stages_cleared",
		"threshold": 20,
	},
	{
		"id": "dashes_used_10",
		"name": "10",
		"description": "Use dash 10 times",
		"stat": "dashes_used",
		"threshold": 10,
	},
	{
		"id": "items_picked_10",
		"name": "11",
		"description": "Pick up 10 items",
		"stat": "items_picked_up",
		"threshold": 10,
	},
	{
		"id": "critical_hits_100",
		"name": "12",
		"description": "Land 100 critical hits",
		"stat": "critical_hits",
		"threshold": 100,
	},
	{
		"id": "games_played_2",
		"name": "13",
		"description": "Play 2 games",
		"stat": "game_count",
		"threshold": 2,
	},
]

var _unlocked_ids: Array[String] = []
var _check_timer: Timer = null


func _ready() -> void:
	_check_timer = Timer.new()
	_check_timer.wait_time = 1.0
	_check_timer.timeout.connect(check_achievements)
	add_child(_check_timer)
	_load_unlocked()


func start_checking() -> void:
	_load_unlocked()
	_check_timer.start()


func stop_checking() -> void:
	_check_timer.stop()


func is_unlocked(achievement_id: String) -> bool:
	return achievement_id in _unlocked_ids


func get_all_achievements() -> Array[Dictionary]:
	_load_unlocked()
	var result: Array[Dictionary] = []
	for achievement in achievements:
		var data = achievement.duplicate()
		data["unlocked"] = is_unlocked(achievement["id"])
		result.append(data)
	return result


func check_achievements() -> void:
	for achievement in achievements:
		var id: String = achievement["id"]
		if is_unlocked(id):
			continue

		var effective_stat = _get_effective_stat(achievement["stat"])
		if effective_stat >= achievement["threshold"]:
			_unlock(achievement)


func _get_effective_stat(stat_key: String) -> float:
	var profile_value: float = 0.0
	if not ProfileManager.current_profile.is_empty() and ProfileManager.current_profile.has("stats"):
		profile_value = float(ProfileManager.current_profile["stats"].get(stat_key, 0))

	var run_value: float = 0.0
	if stat_key == "bosses_killed":
		for boss_type in GameStats.bosses_killed_by_type:
			run_value += GameStats.bosses_killed_by_type[boss_type]
	elif stat_key == "game_count":
		pass
	else:
		var raw = GameStats.get(stat_key)
		if raw != null:
			run_value = float(raw)

	return profile_value + run_value


func _unlock(achievement: Dictionary) -> void:
	var id: String = achievement["id"]
	_unlocked_ids.append(id)
	_save_unlocked(id)
	print("[Achievement Unlocked] ", achievement["name"], ": ", achievement["description"])
	achievement_unlocked.emit(achievement)


func _load_unlocked() -> void:
	_unlocked_ids.clear()
	if not ProfileManager.current_profile.is_empty():
		var saved: Array = ProfileManager.current_profile.get("achievements", [])
		for id in saved:
			_unlocked_ids.append(id)


func _save_unlocked(achievement_id: String) -> void:
	if ProfileManager.current_profile.is_empty():
		return
	if not ProfileManager.current_profile.has("achievements"):
		ProfileManager.current_profile["achievements"] = []
	var arr: Array = ProfileManager.current_profile["achievements"]
	if achievement_id not in arr:
		arr.append(achievement_id)
	ProfileManager.save_profile()
