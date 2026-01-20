extends Node

var time_alive_seconds := 0
var stages_cleared := 0
var enemies_killed := 0
var total_damage_dealt:=0.0
var total_damage_taken:=0.0
var items_picked_up:=0

var player_last_hit_by: String


func reset_game_stats()->void:
	time_alive_seconds = 0
	stages_cleared = 0
	enemies_killed = 0
	total_damage_dealt = 0.0
	total_damage_taken = 0.0
	items_picked_up = 0
	player_last_hit_by = "null"
