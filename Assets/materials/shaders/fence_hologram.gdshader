shader_type spatial;

uniform sampler2D pattern_texture : source_color;
uniform sampler2D scroll_noise: source_color;

uniform float cell_size = 8.0;
uniform vec2 uv_scale;

uniform vec4 hex_color : source_color;
uniform vec4 fill_color : source_color;

uniform float hex_glow = 3.0;
uniform float fill_glow = 0.5;

uniform float scroll_speed = 0.5;

void fragment() {
    vec2 uv = UV * cell_size * uv_scale;
    float h = texture(pattern_texture, uv).r;

	vec2 scroll = vec2(0, 1.0) * TIME * scroll_speed;
	float noise = texture(scroll_noise, UV + scroll).r;

    float hex = smoothstep(0.0, 1.0, h * noise);
    float fill = smoothstep(0.0, 1.0, 1.0-h);

    ALBEDO = hex_color.rgb * hex + fill_color.rgb * fill;
	ALPHA = hex_color.a * hex + fill_color.a * fill;

    EMISSION = hex_color.rgb * hex * hex_glow + fill_color.rgb * fill * fill_glow;
}