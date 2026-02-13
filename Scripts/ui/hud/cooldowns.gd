extends Control

var player: Player = GameManager.player

@export var light_attack_node: Control
@export var heavy_attack_node: Control
@export var dash_node: Control
@export var brainchip_node: Control
@export var throwable_node: Control

@onready var container = $MarginContainer/HBoxContainer


func _ready() -> void:
	if not player:
		return
	
	player.primary_attack_used.connect(light_attack_node.update_cooldown)
	player.secondary_attack_used.connect(heavy_attack_node.update_cooldown)
	player.dash_used.connect(dash_node.update_cooldown)
	player.active_item_used.connect(brainchip_node.update_cooldown)
	player.throwable_used.connect(throwable_node.update_cooldown)


func set_icon(icon: Texture2D, item_type: ItemType.Type) -> void:
	match item_type:
		ItemType.Type.PRIMARY_ATTACK:
			light_attack_node.set_icon(icon)
		ItemType.Type.SECONDARY_ATTACK:
			heavy_attack_node.set_icon(icon)
		ItemType.Type.ACTIVE_ITEM:
			brainchip_node.set_icon(icon)
		ItemType.Type.THROWABLE:
			throwable_node.set_icon(icon)
