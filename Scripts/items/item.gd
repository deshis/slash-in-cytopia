extends Control
class_name Item

var item : ItemResource
@onready var description = $Background
@onready var item_icon = $MarginContainer/TextureRect


var type_color = Color(0.6, 0.8, 0.6, 1.0)
var grade_color = "#"
var type_name = "?"
var grade_name = "?"
var stats = "?"


func _ready() -> void:
	update_item_display(item)


func update_item_display(res: ItemResource) -> void:
	if not item:
		return
	
	item = res
	
	await self.ready
	item_icon.texture = item.icon


func get_type() -> int:
	return item.type


func get_grade() -> ItemType.Grade:
	return item.grade


func _get_drag_data(_pos: Vector2) -> Variant:
	if item != null:
		description.visible = false
	
	var preview := duplicate(true)
	
	preview.anchor_left = 0
	preview.anchor_top = 0
	preview.anchor_right = 0
	preview.anchor_bottom = 0
	preview.size = size
	
	set_drag_preview(preview)
	
	item_icon.modulate = Color(1,1,1,0.5)
	
	return get_parent()


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		item_icon.modulate = Color(1,1,1,1)


func _on_mouse_entered() -> void:
	if item == null:
		return
	
	if not get_viewport().gui_is_dragging():
		description.set_description(item)
		description.visible = true


func _on_mouse_exited() -> void:
	if item == null:
		return
	
	description.visible = false
