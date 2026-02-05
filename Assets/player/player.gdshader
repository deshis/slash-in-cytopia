shader_type spatial;
render_mode specular_disabled;
stencil_mode write, compare_always, 1;

uniform sampler2D albedo_texture : source_color;
uniform float light_steps = 3.0;

varying float occlusion;

void fragment() {
	occlusion = round(COLOR.r * light_steps) / light_steps; // Using vertex color for additional shadows
	ALBEDO = texture(albedo_texture, UV).rgb;
}

void light() {
	float light = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	light = ceil(light * light_steps) / light_steps;
	DIFFUSE_LIGHT += light * ATTENUATION * occlusion * LIGHT_COLOR / PI;
}
