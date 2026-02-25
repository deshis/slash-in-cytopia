extends CanvasLayer

var item : ItemResource
@export var grade_icons: Dictionary[ItemType.Grade, CompressedTexture2D]
@export var border_corners: Dictionary[ItemType.Grade, CompressedTexture2D]
@export var item_types: Dictionary[ItemType.Type, CompressedTexture2D]

@export var max_chars_per_line := 25

@onready var grade_icon = $Background/Control/GradeIcon
@onready var border = $Background/Frame

@onready var item_name = $Background/Description/VBoxContainer/Name
@onready var item_type_icon = $Background/Description/VBoxContainer/Type/Icon
@onready var item_type = $Background/Description/VBoxContainer/Type/Type
@onready var item_stats = $Background/Description/VBoxContainer/Stats
@onready var item_desc = $Background/Description/VBoxContainer/Description

var type_color = Color(0.6, 0.8, 0.6, 1.0)
var type_name = ""


func _physics_process(_delta: float) -> void:
	if not item:
		return
	
	if item.grade == ItemType.Grade.APEX_ANOMALY:
		_set_panel_color(LootDatabase.get_apex_rainbow($Background))
	
	_reposition()


func set_description(i: ItemResource) -> void:
	item = i
	_set_type()
	_set_grade()
	_set_border_texture()
	_set_name()
	_set_stats()
	_set_description()
	_set_panel_color()
	_update_size()
	
	activate()


func activate() -> void:
	_reposition()
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true


func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false


func wrap_text(text: String) -> String:
	if text == "":
		return ""
	
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


func _set_type() -> void:
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
		ItemType.Type.PRIMARY_ATTACK:
			type_name = "Light Attack"
		ItemType.Type.SECONDARY_ATTACK:
			type_name = "Heavy Attack"
		ItemType.Type.THROWABLE:
			type_name = "Throwable"
	
	item_type.text = "[color=" + Helper.to_hex(type_color) + "]" + type_name + "[/color]"


func _set_grade() -> void:
	item_type_icon.texture = item_types.get(item.type, null)
	item_type_icon.modulate = type_color


func _set_border_texture() -> void:
	grade_icon.texture = grade_icons.get(item.grade, null)
	
	var corner = border_corners.get(item.grade, null)
	for c in border.get_children():
		c.texture = corner


func _set_name() -> void:
	var grade_color = LootDatabase.grade_colors.get(item.grade)
	
	if item.grade == ItemType.Grade.APEX_ANOMALY:
		item_name.text = "[rainbow freq=0.2 sat=0.7 val=0.8 speed=1.0]" + wrap_text(item.item_name) + "[/rainbow]"
	else:
		item_name.text = "[color=" + Helper.to_hex(grade_color) + "]" + wrap_text(item.item_name) + "[/color]"


func _set_stats() -> void:
	if item.item_stat_info == "":
		item_stats.text = item.get_formatted_stats()
	else:
		item_stats.text = "[center][color=#bdbbbb]" + wrap_text(item.item_stat_info)+ "[/color][/center]" + item.get_formatted_stats()


func _set_description() -> void:
	if item.item_description == "":
		item_desc.text = ""
		$Background/Description/VBoxContainer/PaddingStatsDesc.visible = false
	else:
		item_desc.text = "[color=#777777]" + wrap_text(item.item_description) + "[/color]"
		$Background/Description/VBoxContainer/PaddingStatsDesc.visible = true


func _set_panel_color(col = null) -> void:
	var stylebox = $Background.get("theme_override_styles/panel").duplicate()
	var grade_color = LootDatabase.grade_colors.get(item.grade)
	var c = col if col else grade_color
	
	var alpha = 0.9
	var brightness = 0.2
	c = Color(c.r * brightness, c.g * brightness, c.b * brightness, alpha)
	
	stylebox.bg_color = c
	$Background.add_theme_stylebox_override("panel", stylebox)


func _update_size() -> void:
	border.visible = false
	$Background.reset_size()
	
	var min_size = min($Background.size.x, $Background.size.y)
	var border_size = Vector2.ONE * min_size / 2
	for corner in border.get_children():
		corner.custom_minimum_size = border_size
	
	border.visible = true


func _reposition() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var offset = Vector2(10, 10)
	var new_pos = mouse_pos + offset
	
	var viewport_size = $Background.get_viewport_rect().size
	var padding = grade_icon.custom_minimum_size.y / 2
	
	new_pos.x = clamp(new_pos.x, 0, viewport_size.x - $Background.size.x)
	new_pos.y = clamp(new_pos.y, 0, viewport_size.y - $Background.size.y - padding)
	$Background.global_position = new_pos
