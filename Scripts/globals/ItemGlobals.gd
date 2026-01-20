extends Node

#Global values for distinguishing between primary & secondary attacks
#Accessed via ItemGlobals.

var primary_weapon_type = "Default"
var primary_attack_type = "Default"
var primary_weapon_mesh = null

var secondary_weapon_type = "Default"
var secondary_attack_type = "Default"
var secondary_weapon_mesh = null

var primary: bool = false
var secondary: bool = false

func reset() -> void:
	primary_weapon_type = "Default"
	primary_attack_type = "Default"
	primary_weapon_mesh = null
	
	secondary_weapon_type = "Default"
	secondary_attack_type = "Default"
	secondary_weapon_mesh = null
