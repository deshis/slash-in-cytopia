shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, alpha_to_coverage_and_one, unshaded;

uniform vec4 base_color : source_color;
uniform sampler2D shape_texture : source_color, repeat_disable;
uniform sampler2D erosion_texture : source_color, repeat_disable;

uniform float emission_intensity : hint_range(1.0, 10.0, 0.1);

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset;

varying float lifetime;

void vertex() {
	lifetime = INSTANCE_CUSTOM.y;
}

void fragment() {
	vec2 base_uv = UV * uv_scale - vec2(lifetime*2.0, 0);

	float tex = texture(shape_texture, base_uv).r;

	float erosion_val = step(-0.5+lifetime*2.0, texture(erosion_texture, base_uv).r);

	float minimum = step(0, uv_offset.x*uv_scale.x)*(uv_offset.x);
	float maximum = (1.0*uv_scale.x + step(uv_offset.x, 0.0)*(uv_offset.x))*uv_scale.x;
	//float fade_val = smoothstep(minimum, minimum+fade, base_uv.x) * smoothstep(maximum, maximum - fade, base_uv.x);

	ALBEDO = tex * base_color.rgb * emission_intensity;
	ALPHA = tex * base_color.a * erosion_val;
}