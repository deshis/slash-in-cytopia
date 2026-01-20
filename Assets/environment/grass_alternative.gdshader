shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D shape_texture : source_color, filter_nearest_mipmap;
uniform vec3 base_color : source_color;
uniform vec3 shadow_color : source_color;

uniform sampler2D wind_noise: source_color;
uniform float noise_scale = 1.0;
uniform float wind_strenght = 0.2;
uniform float wind_speed = 0.1;
uniform vec2 wind_direction = vec2(1,1);

varying vec3 world_pos;
varying float noise_value;

void vertex(){
	vec3 instance_pos = MODEL_MATRIX[3].xyz;
	vec4 world_vertex = MODEL_MATRIX * vec4(VERTEX, 1.0);
	
	vec2 scroll = TIME * wind_direction * wind_speed;
	vec2 noise_uv = (instance_pos.xz * noise_scale) + scroll;
	noise_value = texture(wind_noise, noise_uv).r;
	
	vec2 normalized_dir = normalize(wind_direction);
	float bend_factor = clamp(VERTEX.y, 0.0, 1.0);
	world_vertex.xyz += vec3(normalized_dir.x , 0, normalized_dir.y) * noise_value * wind_strenght * bend_factor;
	
	VERTEX = (inverse(MODEL_MATRIX) * world_vertex).xyz;
}

void fragment(){
	vec2 base_uv = clamp(UV, 0.0, 1.0);

	ALBEDO = mix(base_color, shadow_color, noise_value).rgb;
	ALPHA *= texture(shape_texture, vec2(base_uv.y, -base_uv.x)).r;
}