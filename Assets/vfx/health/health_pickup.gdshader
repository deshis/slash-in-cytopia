shader_type spatial;

uniform vec4 base_color : source_color;
uniform vec4 pulse_color : source_color;

uniform float base_power : hint_range(0.0, 1.0) = 0.4;
uniform float rim_power : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_frequency : hint_range(0.1, 10.0) = 2.0;

uniform float emission_intensity : hint_range(0.0, 5.0);

void fragment()
{
	float dir = 1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel = pow(dir, rim_power);
	
	float intensity = mix(base_power, 1.0, fresnel);
	float pulse = (sin(TIME * pulse_frequency) + 1.0) * 0.5;
	intensity *= mix(0.9, 1.1, pulse);
	
	vec3 final_color = mix(base_color, pulse_color, pulse * 0.5).rgb * intensity;
	ALBEDO = final_color.rgb;
	EMISSION = final_color.rgb * intensity * emission_intensity;
	ALPHA = clamp(intensity * 1.5, 0.0, 1.0);
}