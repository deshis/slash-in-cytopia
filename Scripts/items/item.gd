extends Control
class_name Item

@export var item : ItemResource

@onready var description = $PanelContainer/RichTextLabel
@onready var texture_rect = $MarginContainer/TextureRect
@onready var panel_container1 = $PanelContainer
@onready var border_container = $BorderPanelContainer
@onready var border = $BorderPanelContainer/NinePatchRect

var max_chars_per_line := 25

var type_color = "#b5b5b5"
var grade_color = "#"
var type_name = "?"
var grade_name = "?"
var stats = "?"

func _ready() -> void:
	update_item_display(item)

func _physics_process(_delta: float) -> void:
	if panel_container1.visible:
		_position_description()

func update_item_display(res: ItemResource) -> void:
	if not item:
		return
	
	item = res
	
	await self.ready
	_set_grade()
	_set_type_name()
	_create_description()
	
	panel_container1.visible = false
	border_container.visible = false
	texture_rect.texture = item.icon

func _position_description() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var offset = Vector2(10, 10)
	var new_pos = mouse_pos + offset
	
	var viewport_size = get_viewport_rect().size
	var panel_size = panel_container1.size
	border_container.size = panel_container1.size
	
	new_pos.x = clamp(new_pos.x, 0, viewport_size.x - panel_size.x)
	new_pos.y = clamp(new_pos.y, 0, viewport_size.y - panel_size.y)
	panel_container1.global_position = new_pos
	border_container.global_position = new_pos
	
func get_type() -> int:
	return item.type

func _get_drag_data(_pos: Vector2) -> Variant:
	var preview := duplicate(true)
	
	preview.anchor_left = 0
	preview.anchor_top = 0
	preview.anchor_right = 0
	preview.anchor_bottom = 0
	preview.size = size
	
	set_drag_preview(preview)
	
	var texture = $MarginContainer/TextureRect
	texture.modulate = Color(1,1,1,0.5)
	
	if item != null:
		description.visible = false
		panel_container1.visible = false
		border_container.visible = false
	return get_parent()

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		texture_rect.modulate = Color(1,1,1,1)

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		pass
		var texture = $MarginContainer/TextureRect
		texture.modulate = Color(1,1,1,1)
		
	if event.is_action_pressed("click"):
		pass
		description.visible = false
		panel_container1.visible = false
		border_container.visible = false

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
			grade_name = "Apex_Anomaly"

func _set_type_name() -> void:
	type_color = LootDatabase.type_colors.get(item.type)
	
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

func _create_description() -> void:

	name = item.item_name
	var formatted_desc = ""

	#Item name
	var formatted_name = ""
	formatted_name += "[center][color=" + hex(grade_color) + "][b]" + wrap_text(item.item_name) + "[/b][/color][/center]"
	formatted_desc += formatted_name

	#Item grade
	formatted_desc += "\n[center][font_size=14][color=" + hex(grade_color) + "]---- " + grade_name + " ----[/color][/font_size][/center]"

		
	#Item type
	if type_color == null:
		type_color = "#777777"
	
	formatted_desc += "\n[center][color=" + hex(type_color) + "]" + type_name + "[/color][/center]\n\n"
	change_panel_color()
	
	#Item stat info if one exists (for active items)
	if item.item_stat_info != "":
		formatted_desc += "[center][color=" + "#bdbbbb" + "]" + wrap_text(item.item_stat_info) + "[/color][/center]\n"
	
	formatted_desc += item.get_formatted_stats()
	
	#Item description
	if item.item_description != "":
		formatted_desc += "\n[center][color=" + "#777777" + "]" + wrap_text(item.item_description) + "[/color][/center]"
	
	description.set_text(formatted_desc)

func hex(c: Color) -> String:
	return "#" + c.to_html(false)

func change_panel_color() -> void:
	var stylebox = panel_container1.get("theme_override_styles/panel").duplicate()
	var c = grade_color
	
	var alpha = 0.9
	var brightness = 0.2
	c = Color(c.r * brightness, c.g * brightness, c.b * brightness, alpha)
	#stylebox.border_color = grade_color
	
	stylebox.bg_color = c
	panel_container1.add_theme_stylebox_override("panel", stylebox)

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
	var border_texture: Texture2D
	
	if grade_name == "Consumer":
		border_texture = preload("res://Assets/ui/TestItemBorder3.png")
		
	if grade_name == "Military":
		border_texture = preload("res://Assets/ui/TestItemBorder2.png")
		
	if grade_name == "Prototype":
		border_texture = preload("res://Assets/ui/TestItemBorder.png")
		
	if grade_name == "Apex_Anomaly":
		border_texture = preload("res://Assets/ui/TestItemBorder.png")
	
	border.texture = border_texture

func _on_mouse_entered() -> void:
	if item == null:
		return
		
	choose_border_texture()
	
	description.visible = true
	panel_container1.visible = true
	border_container.visible = true

func _on_mouse_exited() -> void:
	if item == null:
		return
	
	description.visible = false
	panel_container1.visible = false
	border_container.visible = false
