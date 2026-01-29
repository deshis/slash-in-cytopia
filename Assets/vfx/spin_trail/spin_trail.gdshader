shader_type spatial;
render_mode blend_add, unshaded;

uniform vec4 base_color : source_color;
uniform vec4 highlight_color : source_color;

uniform sampler2D base_tex : source_color;
uniform sampler2D highlight_tex : source_color;
uniform sampler2D erosion_texture : source_color;

uniform float smoothness : hint_range(0.0, 1.0, 0.001);
uniform float erosion : hint_range(0.0, 1.0, 0.001);

uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset;

void fragment() {
	vec2 base_uv = UV * uv_scale + uv_offset;

	float tex_hi = smoothstep(smoothness, smoothness, texture(highlight_tex, vec2(base_uv.x, -base_uv.y)).r);
	float tex_main = smoothstep(smoothness, smoothness, texture(base_tex, vec2(base_uv.x, -base_uv.y)).r);

	float tex = smoothstep(smoothness, smoothness, tex_main - tex_hi);

	float erosion_val = smoothstep(erosion, erosion, texture(erosion_texture, UV).r);

    // Final Composition
	ALBEDO = tex_hi * highlight_color.rgb + tex * base_color.rgb;
	ALPHA = (tex_hi * highlight_color.a + tex * base_color.a) * erosion_val;
}