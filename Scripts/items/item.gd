extends Control
class_name Item

var slot = null

var item : ItemResource
@onready var item_icon = $TextureRect

func _ready() -> void:
	update_item_display(item)


func update_item_display(res: ItemResource) -> void:
	item = res
	item_icon.texture = item.icon
	$shader_mask.texture = item.icon


func get_type() -> int:
	return item.type


func get_grade() -> ItemType.Grade:
	return item.grade
