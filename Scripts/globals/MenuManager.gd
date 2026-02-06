extends Node

var active_menu = null
var menus := {}

enum MENU {
	PAUSE,
	INVENTORY,
	ITEM_SELECTION,
	COMBINER,
	RECYCLER,
}


func add_menu(menu_name: MENU, menu_node: Node) -> void:
	menus[menu_name] = menu_node


func open_menu(menu: MENU) -> void:
	match menu:
		MENU.PAUSE:
			close_menu(MENU.INVENTORY)
		
		MENU.INVENTORY:
			pass
		
		MENU.ITEM_SELECTION:
			menus[MENU.INVENTORY].visible = true
		
		MENU.COMBINER:
			menus[MENU.INVENTORY].visible = true
		
		MENU.RECYCLER:
			menus[MENU.INVENTORY].visible = true
	
	active_menu = menu
	menus[menu].visible = true
	get_tree().paused = true


func close_menu(menu: MENU) -> void:
	match menu:
		MENU.PAUSE:
			pass
		
		MENU.INVENTORY:
			menus[MENU.ITEM_SELECTION].visible = false
			menus[MENU.COMBINER].visible = false
			menus[MENU.RECYCLER].visible = false
		
		MENU.ITEM_SELECTION:
			menus[MENU.INVENTORY].visible = false
		
		MENU.COMBINER:
			menus[MENU.INVENTORY].visible = false
		
		MENU.RECYCLER:
			menus[MENU.INVENTORY].visible = false
	
	active_menu = null
	menus[menu].visible = false
	get_tree().paused = false


func set_menu(menu: MENU, status: bool) -> void:
	match status:
		true: open_menu(menu)
		false: close_menu(menu)
