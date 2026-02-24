extends Control

func init(res: ItemResource) -> void:
	$Control/TextureRect.self_modulate = LootDatabase.grade_colors.get(res.grade)
	$Control/ItemSlot/Item.update_item_display(res)
