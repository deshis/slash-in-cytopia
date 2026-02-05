shader_type spatial;
render_mode specular_disabled;

uniform sampler2D base_texture : source_color;
uniform sampler2D moss_texture : source_color;
uniform sampler2D noise_texture : source_color;

uniform float noise_scale = 4.0;
uniform float moss_threshold = 0.4;
uniform float upward_bias = 0.4;

uniform float light_steps = 3.0;

varying float occlusion;
varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	occlusion = round(COLOR.r * light_steps) / light_steps; // Using vertex color for additional shadows
	

	float dir_bias = dot(world_normal, vec3(0.0, 1.0, 0.0));
	// Lift walls, reward tops
	float up_bias = dir_bias * upward_bias + (1.0-upward_bias);
	// Kill undersides
	up_bias *= smoothstep(-0.2, 0.1, dir_bias);
	// Clamp for safety
	up_bias = clamp(up_bias, 0.0, 1.0);
	
	vec3 n = abs(world_normal);
	n = pow(n, vec3(4.0));
	n /= (n.x + n.y + n.z);

	// Triplanar noise
	float noise_x = texture(noise_texture, world_pos.yz * noise_scale).r;
	float noise_y = texture(noise_texture, world_pos.xz * noise_scale).r;
	float noise_z = texture(noise_texture, world_pos.xy * noise_scale).r;

	float noise =
	    noise_x * n.x +
	    noise_y * n.y +
	    noise_z * n.z;

	// Bias
	float biased_noise = noise * up_bias;
    // Threshold after bias
    float moss_mask = smoothstep(moss_threshold, moss_threshold, biased_noise);

	
	vec3 base = texture(base_texture, UV).rgb;
	vec3 moss = texture(moss_texture, UV).rgb;
	
	ALBEDO = mix(base, moss, moss_mask);
}

void light() {
	float light = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	light = ceil(light * light_steps) / light_steps;
	DIFFUSE_LIGHT += light * ATTENUATION * occlusion * LIGHT_COLOR / PI;
}
