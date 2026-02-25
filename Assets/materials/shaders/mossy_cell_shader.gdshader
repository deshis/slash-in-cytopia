shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_disabled;

group_uniforms Shader.Albedo;
uniform vec4 albedo_color : source_color  = vec4(1.0);
uniform sampler2D albedo_texture : repeat_disable;

group_uniforms Shader.Light;
uniform sampler2D shading_gradient;

group_uniforms Shader.Fresnel;
uniform bool use_fresnel = true;
uniform sampler2D fresnel_gradient;
uniform float fresnel_amount : hint_range(0.0, 4.0) = 4.0;

group_uniforms Shader.Rim;
uniform bool use_rim = true;
uniform sampler2D rim_gradient;
uniform float rim_amount : hint_range(0.0, 4.0) = 4.0;

group_uniforms Shader.Moss;
uniform sampler2D moss_texture : source_color;
uniform sampler2D noise_texture : source_color;

uniform float noise_scale = 4.0;
uniform float moss_threshold = 0.4;
uniform float upward_bias = 0.4;

varying float occlusion;
varying vec3 world_pos;
varying vec3 world_normal;

float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
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
	vec4 moss = texture(moss_texture, UV);
	
	vec4 albedo = texture(albedo_texture, UV) * albedo_color;
	float fresnel_value = fresnel(fresnel_amount, NORMAL, VIEW);
	vec3 fresnel_color = (texture(fresnel_gradient, vec2(fresnel_value, 0.0)) * fresnel_value).rgb * 1.0;
	ALBEDO = mix(albedo.rgb, moss.rgb, moss_mask);
	if(use_fresnel) 
		ALBEDO += fresnel_color;
}

void light () {
	float dotproduct = clamp(dot(NORMAL,LIGHT), -0.9,0.9);
	float light = clamp((dotproduct + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);

	vec3 diffuse = ALBEDO * texture(shading_gradient, vec2(light, 0.0)).rgb;
	
	if(use_rim){
		float rim_value = fresnel(rim_amount, NORMAL, VIEW);
		rim_value = mix(rim_value, rim_value * light, 1.0);
		diffuse += texture(rim_gradient, vec2(rim_value, 0.0)).rgb * rim_value;
	}
	
	diffuse *= LIGHT_COLOR;
	DIFFUSE_LIGHT += diffuse;
}
