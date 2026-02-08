extends Control
class_name Item

var item : ItemResource
@export var grade_icons: Array[CompressedTexture2D]
@export var border_corners: Array[CompressedTexture2D]
var corner: CompressedTexture2D

@export var max_chars_per_line := 25

@onready var description = $Description
@onready var desc_text = $Description/MarginContainer/RichTextLabel
@onready var item_icon = $MarginContainer/TextureRect
@onready var grade_icon = $Description/Control/GradeIcon
@onready var border = $Description/Frame

var type_color = Color(0.6, 0.8, 0.6, 1.0)
var grade_color = "#"
var type_name = "?"
var grade_name = "?"
var stats = "?"


func _ready() -> void:
	update_item_display(item)

func _physics_process(_delta: float) -> void:
	if description.visible:
		_position_description()


func update_item_display(res: ItemResource) -> void:
	if not item:
		return
	
	item = res
	
	await self.ready
	_set_grade()
	_set_type_name()
	_create_description()
	choose_border_texture()
	
	item_icon.texture = item.icon


func _position_description() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var offset = Vector2(10, 10)
	var new_pos = mouse_pos + offset
	
	var viewport_size = get_viewport_rect().size
	var panel_size = description.size
	var padding = grade_icon.custom_minimum_size.y / 2
	
	new_pos.x = clamp(new_pos.x, 0, viewport_size.x - panel_size.x)
	new_pos.y = clamp(new_pos.y, 0, viewport_size.y - panel_size.y - padding)
	description.global_position = new_pos
	
	var min_description_size = min(panel_size.x, panel_size.y)
	var frame_size = Vector2(min_description_size, min_description_size) / 2
	for frame in border.get_children():
		frame.custom_minimum_size = frame_size


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


#Godot has switch statements with match
func _set_grade() -> void:
	grade_color = LootDatabase.grade_colors.get(item.grade)

	match item.grade: 
		ItemType.Grade.CONSUMER:
			grade_name = "Consumer"
		ItemType.Grade.MILITARY:
			grade_name = "Military"
		ItemType.Grade.PROTOTYPE:
			grade_name = "Prototype"
		ItemType.Grade.APEX_ANOMALY:
			grade_name = "Apex Anomaly"


func _set_type_name() -> void:
	##NOTE: uncomment for type-based coloring
	#type_color = LootDatabase.type_colors.get(item.type)
	
	match item.type: 
		ItemType.Type.SURVIVABILITY:
			type_name = "Survivability"
		ItemType.Type.MOVEMENT:
			type_name = "Movement"
		ItemType.Type.UTILITY:
			type_name = "Utility"
		ItemType.Type.DAMAGE:
			type_name = "Damage"
		ItemType.Type.ACTIVE_ITEM:
			type_name = "Brainchip"
		ItemType.Type.ACTIVE_ITEM:
			type_name = "Active Item"
		ItemType.Type.PRIMARY_ATTACK:
			type_name = "Light Attack"
		ItemType.Type.SECONDARY_ATTACK:
			type_name = "Heavy Attack"
		ItemType.Type.THROWABLE:
			type_name = "Throwable"


func _create_description() -> void:
	name = item.item_name
	var formatted_desc = ""

	#Item name
	var formatted_name = ""
	
	if grade_name == "Apex Anomaly":
		formatted_name += "[center]" + "[rainbow freq=0.2 sat=0.7 val=0.8 speed=1.0]" + "[b]" + wrap_text(item.item_name) + "[/b][/rainbow][/center]"
	else: formatted_name += "[center][color=" + hex(grade_color) + "][b]" + wrap_text(item.item_name) + "[/b][/color][/center]"
	
	formatted_desc += formatted_name
	
	#Item grade
	#formatted_desc += "\n[center][font_size=14][color=" + hex(grade_color) + "]---- " + grade_name + " ----[/color][/font_size][/center]"
	
	
	#Item type
	if type_color == null:
		type_color = "#777777"

	formatted_desc += "\n[center][font_size=12][color=" + hex(type_color) + "]" + type_name + "[/color][/font_size][/center]\n\n"
	change_panel_color()
	
	#Item stat info if one exists (for active items)
	if item.item_stat_info != "":
		formatted_desc += "[center][color=" + "#bdbbbb" + "]" + wrap_text(item.item_stat_info) + "[/color][/center]"
	
	formatted_desc += item.get_formatted_stats()
	
	#Item description
	if item.item_description != "":
		formatted_desc += "\n[center][color=" + "#777777" + "]" + wrap_text(item.item_description) + "[/color][/center]"
	
	formatted_desc += "\n\n"
	
	desc_text.set_text(formatted_desc)


func hex(c: Color) -> String:
	return "#" + c.to_html(false)


func change_panel_color() -> void:
	var stylebox = description.get("theme_override_styles/panel").duplicate()
	var c = grade_color
	
	var alpha = 0.9
	var brightness = 0.2
	c = Color(c.r * brightness, c.g * brightness, c.b * brightness, alpha)
	
	stylebox.bg_color = c
	description.add_theme_stylebox_override("panel", stylebox)


func wrap_text(text: String) -> String:
	var result = ""
	var current_line = ""
	var words = text.split(" ")
	
	for word in words:
		if current_line.length() + word.length() + 1 > max_chars_per_line:
			result += current_line + "\n"
			current_line = word + " "
		else:
			current_line += word + " "
	
	result += current_line
	return result


func choose_border_texture() -> void:
	if grade_name == "Consumer":
		grade_icon.texture = grade_icons[0]
		corner = border_corners[0]
	
	if grade_name == "Military":
		grade_icon.texture = grade_icons[1]
		corner = border_corners[1]
	
	if grade_name == "Prototype":
		grade_icon.texture = grade_icons[2]
		corner = border_corners[2]
	
	if grade_name == "Apex Anomaly":
		grade_icon.texture = grade_icons[3]
		corner = border_corners[3]
	
	for c in border.get_children():
		c.texture = corner


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		item_icon.modulate = Color(1,1,1,1)


func _on_mouse_entered() -> void:
	if item == null:
		return
	
	if not get_viewport().gui_is_dragging():
		description.visible = true


func _on_mouse_exited() -> void:
	if item == null:
		return
	
	description.visible = false
