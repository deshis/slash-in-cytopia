shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 base_color : source_color;

uniform sampler2D texture_albedo : source_color, repeat_disable, filter_nearest;
uniform sampler2D erosion_texture : source_color, repeat_disable;
uniform sampler2D gradient_texture : source_color, repeat_disable;

uniform float erosion : hint_range(0.0, 1.0, 0.001);
uniform float fade : hint_range(0.001, 1.0, 0.01);

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset;

void fragment() {
	vec2 base_uv = UV * uv_scale + uv_offset;
	base_uv = vec2(base_uv.x, clamp(base_uv.y, 0.0, 0.7));

	vec4 tex_main = texture(texture_albedo, base_uv);
	vec4 base_tex = tex_main;

	float minimum = step(0, uv_offset.y)*(uv_offset.y);
	float maximum = 1.0 + step(uv_offset.x, 0.0)*(uv_offset.y);
	float fade_val = smoothstep(minimum, minimum+fade, base_uv.y) * smoothstep(maximum, maximum - fade, base_uv.y);
	
	float erosion_val = smoothstep(erosion, erosion, texture(erosion_texture, base_uv).r);


	ALBEDO = base_tex.rgb * base_color.rgb;
	ALPHA = base_tex.r * base_color.a * fade_val * erosion_val;
}