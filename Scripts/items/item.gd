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


func _get_drag_data(_pos: Vector2) -> Variant:
	if item != null:
		InventoryManager.item_description.deactivate()
	
	var preview := duplicate(true)
	preview.size = size
	set_drag_preview(preview)
	
	modulate = Color(1,1,1,0.5)
	
	return slot


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		modulate = Color(1,1,1,1)


func _on_mouse_entered() -> void:
	if item == null:
		return
	
	if not get_viewport().gui_is_dragging():
		InventoryManager.item_description.set_description(item)
		InventoryManager.item_description.activate()


func _on_mouse_exited() -> void:
	if item == null:
		return
	
	InventoryManager.item_description.deactivate()
