shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_linear_mipmap;
uniform vec4 pulse_color : source_color;
uniform sampler2D color_range : source_color;

uniform sampler2D erosion_noise : source_color;
uniform float erosion : hint_range(0.0, 1.0);

uniform float shader_time;
uniform float life_time : hint_range(0.0, 1.0);
uniform sampler2D pulse_curve : source_color;
uniform float pulse_speed;
uniform bool stop;

void fragment() {
	float pulse_value = texture(pulse_curve, vec2(life_time, 0.5)).r;
	vec2 uv = vec2(UV.y + shader_time*pulse_value*pulse_speed, UV.x);
	vec4 value = texture(tex, uv);
	vec4 base_color = texture(color_range, vec2(clamp(life_time, 0.001, 1.0), 0.5));
	float erosion_value = smoothstep(erosion, erosion, texture(erosion_noise, UV).r);
	ALBEDO = base_color.rgb + pulse_color.rgb * value.rgb * float(!stop);
	ALPHA = base_color.a + pulse_color.a * value.a * float(!stop);
	ALPHA *= erosion_value;
}