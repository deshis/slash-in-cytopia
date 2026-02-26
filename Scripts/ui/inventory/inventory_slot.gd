extends Control
class_name InventorySlot

@export var icon: CompressedTexture2D
@export var icon_color: Color = Color(1.0, 1.0, 1.0, 0.5)

@export var slot_name: String
@export var slot_type: SLOT

@export var sfx: String = "equip"


@onready var lights: TextureRect = $CartridgeHolder/Lights
@onready var cartridge: TextureRect = $CartridgeHolder/Cartridge


@onready var item_slot = $ItemSlot
@onready var icon_node = $IconSlot/Icon

@export var cartridge_lights: Array[CompressedTexture2D]

var current_light := 0.0
var tween : Tween

var drag_preview: Control
var dragging_apex := false

var hovered := false

enum SLOT {
	NONE,
	BACKPACK,
	AUGMENT,
	PICKUP,
	COMBINER,
	TRASH,
	RECYCLER,
}


func _physics_process(delta: float) -> void:
	if not get_item():
		return
	
	if get_item().item.grade == ItemType.Grade.APEX_ANOMALY:
		apex_rainbow()
	
	if dragging_apex and drag_preview:
		var col = LootDatabase.get_apex_rainbow(drag_preview)
		var cart = drag_preview.get_node("Control/TextureRect")
		cart.self_modulate = col


func setup(show_name: bool = true) -> void:
	if show_name:
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
	set_cartridge(item)
	
	if sfx == "" or InventoryManager.is_equipping_starter_items:
		return
	
	if play_sfx:
		SoundManager.play_ui_sfx(sfx)


func clear() -> void:
	remove_cartridge()
	for child in item_slot.get_children():
		if child is Item:
			child.queue_free()


func slot_right_clicked() -> void:
	InventoryManager.move_item(self)


func set_cartridge(item_node: Control) -> void:
	cartridge.visible = true
	
	var item = item_node.item
	cartridge.self_modulate = LootDatabase.grade_colors.get(item.grade)
	
	set_lights(item.grade + 1)


func remove_cartridge() -> void:
	cartridge.visible = false
	set_lights(0)


func set_lights(amount: int) -> void:
	var step_time = 0.035 if amount > current_light else 0.05
	var duration = abs(amount - current_light) * step_time
	
	if tween:
		tween.stop()
	
	tween = create_tween()
	tween.tween_method(
		Callable(self, "_set_index"),
		current_light,
		amount,
		duration
	)


func _set_index(value: float) -> void:
	current_light = int(round(value))
	lights.texture = cartridge_lights[current_light]


func apex_rainbow() -> void:
	cartridge.self_modulate = LootDatabase.get_apex_rainbow(self)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		slot_right_clicked()
		
		if get_item():
			_on_mouse_entered()
		else:
			InventoryManager.item_description.deactivate()


func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
	return true


func _drop_data(_pos: Vector2, data: Variant) -> void:
	InventoryManager.move_item(data, self)


func _get_drag_data(_pos: Vector2) -> Variant:
	if not get_item():
		return
	
	InventoryManager.item_description.deactivate()
	
	icon_node.visible = true
	get_item().visible = false
	remove_cartridge()
	
	init_preview()
	return self


func init_preview() -> void:
	var preview = preload("res://Scenes/ui/item_drag_preview.tscn").instantiate()
	preview.init(get_item().item)
	
	drag_preview = preview
	dragging_apex = get_item().item.grade == ItemType.Grade.APEX_ANOMALY
	set_drag_preview(preview)


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		drag_preview = null
		dragging_apex = false
		
		if get_item():
			icon_node.visible = false
			get_item().visible = true
			set_cartridge(get_item())
			
			if hovered:
				InventoryManager.item_description.set_description(get_item().item)
				InventoryManager.item_description.activate()


func _on_mouse_entered() -> void:
	hovered = true
	
	if not get_item():
		return
	
	if not get_item().item:
		return
	
	if not get_viewport().gui_is_dragging():
		InventoryManager.item_description.set_description(get_item().item)
		InventoryManager.item_description.activate()


func _on_mouse_exited() -> void:
	hovered = false
	
	if not get_item():
		return
	
	if not get_item().item:
		return
	
	InventoryManager.item_description.deactivate()
