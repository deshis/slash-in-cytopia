extends RichTextLabel

var keybinds

func update() -> void:
	
	keybinds = CfgHandler.load_keybinds()
	
	text = "[center]Move around with [[color=orange]%s[/color]], [[color=orange]%s[/color]], [[color=orange]%s[/color]], [[color=orange]%s[/color]] and dodge attacks with your DASH [[color=orange]%s[/color]]!
	
	Use your LIGHT ATTACK [[color=orange]%s[/color]] and HEAVY ATTACK [[color=orange]%s[/color]] to defeat enemies!
	
	Enemies have a chance to be [color=red]AUGMENTED[/color], increasing their lethality!
	
	Defeating enemies has a chance to drop loot, which can be [color=gray]CONSUMER[/color], [color=purple]MILITARY[/color] or [color=yellow]PROTOTYPE[/color]. Items can be equipped in the INVENTORY [[color=orange]%s[/color]].
	
	[color=lightgreen]BRAINCHIP[/color] [[color=orange]%s[/color]] and [color=lightgreen]THROWABLE[/color] [[color=orange]%s[/color]] items have to be activated manually.
	
	Defeating the [color=red]BOSS[/color] will unlock a door to the next [color=green]STAGE[/color]...
	" %[
		keybinds["move_up"].as_text(), 
		keybinds["move_left"].as_text(), 
		keybinds["move_down"].as_text(), 
		keybinds["move_right"].as_text(),
		keybinds["movement_ability"].as_text(),
		keybinds["light_attack"].as_text(),
		keybinds["heavy_attack"].as_text(),
		keybinds["inventory"].as_text(),
		keybinds["active_item"].as_text(),
		keybinds["throwable_item"].as_text(),
		]
