extends Node

func get_snapped_string(damage: float, decimal_step: float = 0.1) -> String:
	if snappedf(damage, decimal_step) == int(damage):
		return str(int(damage))
	return str(snappedf(damage, decimal_step))


func to_hex(c: Color) -> String:
	return "#" + c.to_html(false)


func get_keybind(keybind_name: String) -> String:
	var input = InputMap.action_get_events(keybind_name)
	if not input:
		return "no keybind"
	
	return input[0].as_text()
