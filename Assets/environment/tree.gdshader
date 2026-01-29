shader_type spatial;
render_mode blend_mix, specular_disabled;

uniform sampler2D tex : source_color;
uniform float light_steps = 3.0;

uniform float wind_frequency = 1.0;
uniform float wind_strength = 0.2;
uniform float wind_speed = 0.1;
uniform vec3 wind_direction = vec3(1.0, 0.0, 1.0);

uniform float height = 0.75;
uniform float height_influence = 10.0;

varying float occlusion;

void fragment(){
	occlusion = round(COLOR.r * light_steps) / light_steps;
	ALBEDO = texture(tex, UV).rgb;
}

void vertex(){
	float time_factor = TIME * wind_speed;
	float sway = sin(VERTEX.y * wind_frequency + time_factor) * wind_strength;
	float height_factor = smoothstep(height, height*height_influence, VERTEX.y);
	VERTEX += wind_direction * sway * height_factor;
}

void light() {
	float light = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	light = ceil(light * light_steps) / light_steps;
	DIFFUSE_LIGHT += light * ATTENUATION * occlusion * LIGHT_COLOR / PI;
}