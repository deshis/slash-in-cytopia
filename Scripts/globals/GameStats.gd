extends Node

var time_alive_seconds := 0
var stages_cleared := 0
var enemies_killed := 0
var total_damage_dealt := 0.0
var total_damage_taken := 0.0
var items_picked_up := 0
var player_last_hit_by: String = ""

var damage_mitigated := 0.0
var critical_hits := 0
var highest_single_hit := 0.0
var thorns_damage := 0.0
var frozen_enemies_shattered := 0

var total_healing := 0.0
var health_stolen := 0.0

var dashes_used := 0
var active_items_used := 0
var throwables_used := 0
var items_trashed := 0
var items_recycled := 0
var items_combined := 0

var enemies_killed_by_type := {}
var bosses_killed_by_type := {}

func reset_game_stats()->void:
	time_alive_seconds = 0
	stages_cleared = 0
	enemies_killed = 0
	total_damage_dealt = 0.0
	total_damage_taken = 0.0
	items_picked_up = 0
	player_last_hit_by = ""
	
	damage_mitigated = 0.0
	critical_hits = 0
	highest_single_hit = 0.0
	thorns_damage = 0.0
	frozen_enemies_shattered = 0
	
	total_healing = 0.0
	health_stolen = 0.0
	
	dashes_used = 0
	active_items_used = 0
	throwables_used = 0
	items_trashed = 0
	items_recycled = 0
	items_combined = 0
	
	enemies_killed_by_type.clear()
	bosses_killed_by_type.clear()
