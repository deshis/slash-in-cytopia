extends PanelContainer

@onready var slots = {
	"survivability": $MarginContainer/VBoxContainer/MainLayout/TopRow/SurvivabilityGroup/Slots/Survivability,
	"survivability2": $MarginContainer/VBoxContainer/MainLayout/TopRow/SurvivabilityGroup/Slots/Survivability2,
	"damage": $MarginContainer/VBoxContainer/MainLayout/TopRow/DamageGroup/Slots/Damage,
	"damage2": $MarginContainer/VBoxContainer/MainLayout/TopRow/DamageGroup/Slots/Damage2,
	"active_item": $MarginContainer/VBoxContainer/MainLayout/TopRow/ActiveItemGroup/ActiveItem,
	"primary_attack": $MarginContainer/VBoxContainer/MainLayout/MiddleRow/PrimaryAttackGroup/PrimaryAttack,
	"secondary_attack": $MarginContainer/VBoxContainer/MainLayout/MiddleRow/RightColumn/SecondaryAttackGroup/SecondaryAttack,
	"throwable": $MarginContainer/VBoxContainer/MainLayout/MiddleRow/RightColumn/ThrowableGroup/ThrowableItem,
	"utility": $MarginContainer/VBoxContainer/MainLayout/BottomRow/UtilityGroup/Utility,
	"movement": $MarginContainer/VBoxContainer/MainLayout/BottomRow/MovementGroup/Slots/Movement,
	"movement2": $MarginContainer/VBoxContainer/MainLayout/BottomRow/MovementGroup/Slots/Movement2,
}

@onready var time_label = $MarginContainer/VBoxContainer/StatsSection/HeaderContainer/TimeLabel
@onready var duration_label = $MarginContainer/VBoxContainer/StatsSection/HeaderContainer/DurationLabel

@onready var stage_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/StageValue
@onready var enemies_killed_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/EnemiesKilledValue
@onready var damage_dealt_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/DamageDealtValue
@onready var damage_taken_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/GearsValue
@onready var items_picked_up_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/ItemsPickedUpValue
@onready var killed_by_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/KilledByValue
@onready var throwables_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/ThrowablesValue
@onready var apex_value = $MarginContainer/VBoxContainer/StatsSection/StatsGrid/ApexValue


func set_match_data(data: Dictionary) -> void:
	_set_header_stats(data)
	_set_grid_stats(data)
	_populate_inventory(data.get("equipped_items", []))


func _set_header_stats(data: Dictionary) -> void:
	time_label.text = _format_timestamp(data.get("timestamp", ""))
	duration_label.text = _format_duration(int(data.get("duration_seconds", 0)))


func _set_grid_stats(data: Dictionary) -> void:
	stage_value.text = str(int(data.get("stages_cleared", 0)))
	enemies_killed_value.text = str(int(data.get("enemies_killed", 0)))
	damage_dealt_value.text = _format_number(data.get("damage_dealt", 0.0))
	damage_taken_value.text = _format_number(data.get("damage_taken", 0.0))
	items_picked_up_value.text = str(int(data.get("items_picked_up", 0)))
	throwables_value.text = str(int(data.get("throwables_used", 0)))
	apex_value.text = "Yes" if data.get("had_apex", false) else "No"

	var killed_by = data.get("killed_by", "")
	killed_by_value.text = killed_by if killed_by != "" else "-"
	if killed_by == "Ragequit":
		killed_by_value.add_theme_color_override("font_color", Color.RED)
	else:
		killed_by_value.remove_theme_color_override("font_color")


func _format_number(value) -> String:
	var num = int(value)
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	return str(num)


func _format_timestamp(timestamp: String) -> String:
	if timestamp == "":
		return "Unknown"

	var datetime_dict = Time.get_datetime_dict_from_datetime_string(timestamp, false)
	if datetime_dict.is_empty():
		return timestamp

	return "%02d.%02d.%04d %02d:%02d" % [
		datetime_dict["day"],
		datetime_dict["month"],
		datetime_dict["year"],
		datetime_dict["hour"],
		datetime_dict["minute"]
	]


func _format_duration(seconds: int) -> String:
	if seconds < 0:
		return "0:00"

	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60

	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	return "%d:%02d" % [minutes, secs]


func _populate_inventory(equipped_items: Array) -> void:
	var filled_slots = {}

	for item_data in equipped_items:
		var item_path: String
		var item_type: int

		if item_data is String:
			if item_data == "":
				continue
			var item_res = load(item_data)
			if not item_res:
				continue
			item_path = item_data
			item_type = item_res.type
		elif item_data is Dictionary:
			item_path = item_data.get("path", "")
			item_type = int(item_data.get("type", ItemType.Type.NONE))
			if item_path == "":
				continue
		else:
			continue

		var item_res = load(item_path)
		if not item_res:
			continue

		var slot_key = _get_slot_key(item_type, filled_slots)
		if slot_key != "" and slots.has(slot_key):
			_fill_slot(slots[slot_key], item_res)
			filled_slots[slot_key] = true


func _get_slot_key(item_type: int, filled_slots: Dictionary) -> String:
	match item_type:
		ItemType.Type.SURVIVABILITY:
			if not filled_slots.has("survivability"):
				return "survivability"
			elif not filled_slots.has("survivability2"):
				return "survivability2"
		ItemType.Type.DAMAGE:
			if not filled_slots.has("damage"):
				return "damage"
			elif not filled_slots.has("damage2"):
				return "damage2"
		ItemType.Type.MOVEMENT:
			if not filled_slots.has("movement"):
				return "movement"
			elif not filled_slots.has("movement2"):
				return "movement2"
		ItemType.Type.UTILITY:
			return "utility"
		ItemType.Type.PRIMARY_ATTACK:
			return "primary_attack"
		ItemType.Type.SECONDARY_ATTACK:
			return "secondary_attack"
		ItemType.Type.ACTIVE_ITEM:
			return "active_item"
		ItemType.Type.THROWABLE:
			return "throwable"
	return ""


func _fill_slot(slot: Control, item_res) -> void:
	var icon_node = slot.get_node_or_null("ItemSlot/Icon")
	if icon_node:
		icon_node.texture = item_res.icon
		icon_node.self_modulate = Color(1, 1, 1, 1)
	slot.tooltip_text = item_res.item_name
