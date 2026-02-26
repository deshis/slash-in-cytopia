shader_type spatial;

render_mode depth_draw_always, blend_mix, cull_disabled;

uniform vec4 main_color: source_color;
uniform sampler2D scroll_texture: source_color, repeat_disable;
uniform float scroll_speed = 1.0;
uniform bool invert_boost_direction = false;
uniform sampler2D distort_texture: source_color;
uniform float distort_intensity = 0.5;
uniform float distort_scroll_speed = 1.0;
uniform float displacement_intensity = 0.5;
uniform float displacement_speed = 0.5;
uniform vec4 emission : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_energy = 1.0;
uniform float alpha_threshold = 0.0;
uniform bool use_threshold = false;

void vertex() {	
	vec4 scroll = texture(distort_texture, UV * displacement_speed * TIME);
	VERTEX += NORMAL * scroll.r * (1.0-UV.y) * displacement_intensity;
	VERTEX += BINORMAL * scroll.r * (1.0-UV.y) * displacement_intensity;
}

void fragment() {
	vec2 moving_uv = UV;
	
	if (invert_boost_direction) {
		moving_uv.y += TIME * scroll_speed;
	} else{
		moving_uv.y -= TIME * scroll_speed;
	}
	
	vec4 scroll = texture(scroll_texture, moving_uv + texture(distort_texture, UV + vec2(0, distort_scroll_speed * TIME)).r * distort_intensity);

	ALBEDO = main_color.rgb;
	EMISSION = emission.rgb * emission_energy;
	float alpha = main_color.a * scroll.a;

	if (use_threshold && alpha < alpha_threshold) {
		discard;
	} else {
		ALPHA = alpha;
	}
}