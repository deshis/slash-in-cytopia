extends Node

func get_snapped_string(damage: float, decimal_step: float = 0.1) -> String:
	if snappedf(damage, decimal_step) == int(damage):
		return str(int(damage))
	return str(snappedf(damage, decimal_step))


func to_hex(c: Color) -> String:
	return "#" + c.to_html(false)
