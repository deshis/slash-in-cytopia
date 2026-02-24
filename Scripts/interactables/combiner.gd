extends Node3D

@export var use_amount := 1

@export var highlight_material : Material
@export var light_shader : Shader
@export var force_field_shader : Shader
@export var compartments : Array[MeshInstance3D]
@export var container : PackedScene

@export var interact_area : Area3D

var loot_impulse_strength := -12.0

var highlight_mat : Material
var light_mat : Material

var compartment_force_field : Material
var base_force_field : Material

func _ready() -> void:
	highlight_mat = highlight_material.duplicate(true)
	
	for instance in find_children("*", "MeshInstance3D"):
		for surface in instance.mesh.get_surface_count():
			var mat = instance.mesh.surface_get_material(surface)
			if instance in compartments:
				if mat.shader == force_field_shader:
					if !compartment_force_field:
						compartment_force_field = mat.duplicate(true)
					
					instance.set_surface_override_material(surface, compartment_force_field)
				if mat.shader == light_shader:
					if !light_mat:
						light_mat = mat.duplicate(true)
						
					instance.set_surface_override_material(surface, light_mat)
			else:
				if mat.shader == light_shader:
					if !light_mat:
						light_mat = mat.duplicate(true)
						light_mat.next_pass = highlight_mat
						
					instance.set_surface_override_material(surface, light_mat)
				elif mat.shader == force_field_shader:
					if !base_force_field:
						base_force_field = mat.duplicate(true)
					
					instance.set_surface_override_material(surface, base_force_field)
				else:
					var unique_mat = mat.duplicate(true)
					instance.set_surface_override_material(surface, unique_mat)
					unique_mat.next_pass = highlight_mat

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if MenuManager.active_menu == MenuManager.MENU.COMBINER:
			var combiner_menu = MenuManager.menus[MenuManager.MENU.COMBINER]
			combiner_menu.move_items_from_combiner()
			MenuManager.close_menu(MenuManager.MENU.COMBINER)
			MenuManager.menus[MenuManager.MENU.COMBINER].items_combined.disconnect(combine_items)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if GameManager.player.interactables.front() == self:
			MenuManager.open_menu(MenuManager.MENU.COMBINER)
			MenuManager.menus[MenuManager.MENU.COMBINER].items_combined.connect(combine_items)


func combine_items(rarity: ItemType.Grade) -> void:
	var loot_containers = []
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BOUNCE)
	for compartment in compartments:
		var loot = container.instantiate()
		compartment.add_child(loot)
		loot_containers.append(loot)
		loot.init(LootDatabase.grade_colors[rarity], rarity == ItemType.Grade.APEX_ANOMALY)
		tween.tween_property(loot, "position", Vector3(0, -0.5, 0.0), 1.0)
		tween.tween_property(compartment_force_field, "shader_parameter/dissolve_val", 1.0, 0.5)
	
	MenuManager.close_menu(MenuManager.MENU.COMBINER)
	update_highlight(false)
	interact_area.monitoring = false
	
	await tween.finished
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(compartment_force_field, "shader_parameter/dissolve_val", 0.0, 0.5)
	tween.tween_property(light_mat, "shader_parameter/neon_intensity", 6.0, 1.0)
	await tween.finished
	
	for loot_container in loot_containers:
		loot_container.queue_free()
	
	var loot_table = generate_loot_table(clamp(rarity + 1, 0, ItemType.Grade.size()))
	var final_loot = LootDatabase.drop_loot(self, loot_table, 0.0, 0.0)
	final_loot.reparent(self)
	final_loot.position = Vector3.ZERO
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(base_force_field, "shader_parameter/dissolve_val", 1.0, 0.5)
	tween.tween_property(final_loot, "position", Vector3(0, 1.0, 0.0), 1.0)
	tween.tween_property(light_mat, "shader_parameter/neon_intensity", 3.0, 0.5)
	
	await tween.finished
	
	use_amount -= 1
	interact_area.monitoring = true
	if use_amount <= 0:
		get_node("InteractLabel").queue_free()
		tween = create_tween().set_parallel(true)
		tween.tween_property(light_mat, "shader_parameter/flicker_value", 0.0, 1.0)
		tween.tween_property(base_force_field, "shader_parameter/dissolve_val", 1.0, 0.5)
		tween.tween_property(compartment_force_field, "shader_parameter/dissolve_val", 1.0, 0.5)
		await tween.finished
		set_script(null)


func generate_loot_table(rarity: ItemType.Grade) -> LootTable:
	var loot_table = LootTable.new()
	var military = 0
	var prototype = 0
	var apex_anomaly = 0
	
	match rarity:
		ItemType.Grade.MILITARY:
			military = 1
		ItemType.Grade.PROTOTYPE:
			prototype = 1
		ItemType.Grade.APEX_ANOMALY:
			apex_anomaly = 1
	
	loot_table.loot_rarity_weights = {
		"consumer": 0,
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
