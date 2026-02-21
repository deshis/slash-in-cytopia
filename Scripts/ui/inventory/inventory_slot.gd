extends Control
class_name InventorySlot

@export var icon: CompressedTexture2D
@export var icon_color: Color = Color(1.0, 1.0, 1.0, 0.5)

@export var slot_name: String
@export var slot_type: SLOT

@export var sfx: String = "equip"

@onready var item_slot = $ItemSlot
@onready var icon_node = $ItemSlot/Icon

@export var cartridge_icons: Array[CompressedTexture2D]
var current_cartridge := 0.0
var tween : Tween

enum SLOT {
	NONE,
	BACKPACK,
	AUGMENT,
	PICKUP,
	COMBINER,
	TRASH,
	RECYCLER,
}


func setup() -> void:
	get_child(0).text = slot_name
	icon_node.texture = icon
	icon_node.self_modulate = icon_color


func get_item() -> Control:
	for child in item_slot.get_children():
		if child is Item:
			return child
	return null


func set_item(item: Control, play_sfx: bool = true) -> void:
	if item.get_parent():
		item.get_parent().remove_child(item)
	item_slot.add_child(item)
	item.slot = self
	icon_node.visible = false
	set_cartridge_icon(item.item.grade + 1)
	
	if sfx == "" or InventoryManager.is_equipping_starter_items:
		return
	
	if play_sfx:
		SoundManager.play_ui_sfx(sfx)


func clear() -> void:
	for child in item_slot.get_children():
		if child is Item:
			child.queue_free()


func slot_right_clicked() -> void:
	InventoryManager.move_item(self)


func set_cartridge_icon(new_ind: int) -> void:
	var step_time = 0.015 if new_ind > current_cartridge else 0.05
	var duration = abs(new_ind - current_cartridge) * step_time
	
	if tween:
		tween.stop()
	
	tween = create_tween()
	tween.tween_method(
		Callable(self, "_set_index"),
		current_cartridge,
		new_ind,
		duration
	)


func _set_index(value: float) -> void:
	current_cartridge = int(round(value))
	$TextureRect.texture = cartridge_icons[current_cartridge]


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		slot_right_clicked()


func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
	return true


func _drop_data(_pos: Vector2, data: Variant) -> void:
	var origin_slot: InventorySlot = data
	InventoryManager.move_item(origin_slot, self)
