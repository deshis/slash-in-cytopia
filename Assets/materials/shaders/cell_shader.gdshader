shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_toon, specular_disabled, depth_prepass_alpha;

group_uniforms Shader.Albedo;
uniform vec4 albedo_color : source_color  = vec4(1.0);
uniform sampler2D albedo_texture : repeat_disable;

group_uniforms Shader.Alpha;
uniform float fade_alpha = 1.0;

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

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	vec4 albedo = texture(albedo_texture, UV) * albedo_color;
	float fresnel_value = fresnel(fresnel_amount, NORMAL, VIEW);
	vec3 fresnel_color = (texture(fresnel_gradient, vec2(fresnel_value, 0.0)) * fresnel_value).rgb * 1.0;
	ALBEDO = albedo.rgb;
	if(use_fresnel) 
		ALBEDO += fresnel_color;
	ALPHA *= fade_alpha;
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