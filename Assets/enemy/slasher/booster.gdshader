shader_type spatial;

render_mode depth_draw_always, blend_mix, cull_disabled;

group_uniforms Albedo;
uniform vec4 main_color: source_color;
uniform sampler2D base_texture: source_color, repeat_disable;
uniform vec2 base_uv_scale = vec2(1.0, 1.0);

group_uniforms Scroll;
uniform sampler2D scroll_texture: source_color;
uniform vec2 scroll_uv_scale = vec2(1.0, 1.0);
uniform float scroll_speed = 1.0;
uniform bool invert_direction = false;
group_uniforms Scroll.Distort;
uniform sampler2D distort_texture: source_color;
uniform float distort_intensity = 0.5;
uniform float distort_scroll_speed = 1.0;
group_uniforms Scroll.Displacement;
uniform float displacement_intensity = 0.5;
uniform float displacement_speed = 0.5;

group_uniforms Emission;
uniform vec4 emission : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_energy = 1.0;

void vertex() {	
	vec4 scroll = texture(distort_texture, UV * displacement_speed * TIME);
	VERTEX += NORMAL * scroll.r * (1.0-UV.y) * displacement_intensity;
	VERTEX += BINORMAL * scroll.r * (1.0-UV.y) * displacement_intensity;
}

void fragment() {
	vec2 scroll_uv = UV * scroll_uv_scale;
	scroll_uv.y += TIME * scroll_speed * (invert_direction ? -1.0 : 1.0);
	
	scroll_uv.y += texture(distort_texture, UV * distort_scroll_speed * TIME).r;
	
	vec4 scroll = texture(scroll_texture, scroll_uv);

	ALBEDO = main_color.rgb;
	EMISSION = emission.rgb * emission_energy;
	float alpha = main_color.a * scroll.a;
	ALPHA = texture(base_texture, UV * base_uv_scale).r * scroll.a * main_color.a;
}