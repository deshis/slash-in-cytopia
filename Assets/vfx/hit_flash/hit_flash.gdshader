shader_type spatial;
render_mode unshaded, blend_add;

uniform float strength : hint_range(0.0, 1.0) = 1.0;

void fragment(){
	ALBEDO.rgb = ALBEDO.rgb * strength;
}
