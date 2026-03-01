extends Node3D

@export var use_amount := 1

@export var base_instance : MeshInstance3D
@export var entry_instance : MeshInstance3D
@export var exit_instance : MeshInstance3D
@export var highlight_material : Material
@export var light_shader : Shader

@export var container : PackedScene
@export var interact_area : Area3D

var highlight_mat : Material
var light_mat : Material

var entry_material : Material
var exit_material : Material

func _ready() -> void:
	highlight_mat = highlight_material.duplicate(true)
	
	for surface in base_instance.mesh.get_surface_count():
		var mat = base_instance.mesh.surface_get_material(surface)
		if mat.shader == light_shader:
			if !light_mat:
				light_mat = mat.duplicate(true)
				light_mat.next_pass = highlight_mat
				
			base_instance.set_surface_override_material(surface, light_mat)
		else:
			var unique_mat = mat.duplicate(true)
			base_instance.set_surface_override_material(surface, unique_mat)
			unique_mat.next_pass = highlight_mat
	
	entry_material = base_instance.mesh.surface_get_material(0).duplicate(true)
	entry_instance.set_surface_override_material(0, entry_material)
	exit_material = base_instance.mesh.surface_get_material(0).duplicate(true)
	exit_instance.set_surface_override_material(0, exit_material)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if MenuManager.active_menu == MenuManager.MENU.RECYCLER:
			var recycler_menu = MenuManager.menus[MenuManager.MENU.RECYCLER]
			recycler_menu.move_items_from_recycler()
			MenuManager.close_menu(MenuManager.MENU.RECYCLER)
			MenuManager.menus[MenuManager.MENU.RECYCLER].items_recycled.disconnect(recycle_items)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if GameManager.player.interactables.front() == self:
			MenuManager.open_menu(MenuManager.MENU.RECYCLER)
			MenuManager.menus[MenuManager.MENU.RECYCLER].items_recycled.connect(recycle_items)


func recycle_items(rarity: ItemType.Grade) -> void:
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	var loot = container.instantiate()
	base_instance.get_parent().add_child(loot)
	loot.position = Vector3(0.0 , 1.0, 0.0)
	loot.init(LootDatabase.grade_colors[rarity], rarity == ItemType.Grade.APEX_ANOMALY)
	tween.tween_property(loot, "position", Vector3(0, -0.5, 0.0), 1.0)
	tween.tween_property(entry_material, "shader_parameter/dissolve_val", 1.0, 0.5)
	
	MenuManager.close_menu(MenuManager.MENU.COMBINER)
	update_highlight(false)
	interact_area.monitoring = false
	
	await tween.finished
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(entry_material, "shader_parameter/dissolve_val", 0.0, 0.5)
	tween.tween_property(light_mat, "shader_parameter/neon_intensity", 6.0, 1.0)
	await tween.finished
	
	loot.queue_free()
	
	var loot_table = generate_loot_table(rarity)
	var final_loot = LootDatabase.drop_loot(self, loot_table, false)
	
	final_loot.reparent(self)
	final_loot.position = Vector3.ZERO
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(exit_material, "shader_parameter/dissolve_val", 1.0, 0.5)
	tween.tween_property(final_loot, "position", Vector3(-1.5, 0.0, 0.0), 1.0)
	tween.tween_property(light_mat, "shader_parameter/neon_intensity", 3.0, 0.5)
	
	await tween.finished
	
	use_amount -= 1
	interact_area.monitoring = true
	if use_amount <= 0:
		get_node("InteractLabel").queue_free()
		tween = create_tween().set_parallel(true)
		tween.tween_property(light_mat, "shader_parameter/flicker_value", 0.0, 1.0)
		tween.tween_property(entry_material, "shader_parameter/dissolve_val", 1.0, 0.5)
		tween.tween_property(exit_material, "shader_parameter/dissolve_val", 1.0, 0.5)
		await tween.finished
		set_script(null)


func generate_loot_table(rarity: ItemType.Grade) -> LootTable:
	var loot_table = LootTable.new()
	var consumer = 0
	var military = 0
	var prototype = 0
	var apex_anomaly = 0
	
	match rarity:
		ItemType.Grade.CONSUMER:
			consumer = 1
		ItemType.Grade.MILITARY:
			military = 1
		ItemType.Grade.PROTOTYPE:
			prototype = 1
		ItemType.Grade.APEX_ANOMALY:
			apex_anomaly = 1
	
	loot_table.loot_rarity_weights = {
		"consumer": consumer,
		"military": military,
		"prototype": prototype,
		"apex_anomaly": apex_anomaly,
	}
	
	loot_table.loot_drop_chance = 1
	return loot_table

func update_highlight(value: bool):
	highlight_mat.set_shader_parameter("highlight", value)
	
func on_interaction_area_entered():
	update_highlight(true)

func on_interaction_area_exited():
	update_highlight(false)
