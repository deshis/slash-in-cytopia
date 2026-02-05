shader_type spatial;

uniform vec3 window_color : source_color;
uniform vec3 top_gradient_color : source_color;
uniform vec3 reflection_color : source_color;
uniform float reflection_strength = 0.35;
uniform float top_gradient_strength : hint_range(0.0, 2.0);

uniform float light_steps = 3.0;


varying float occlusion;
varying vec3 world_normal;
varying vec3 view_dir;

void vertex() {
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_dir = normalize(CAMERA_POSITION_WORLD - (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz);
}

void fragment() {
	occlusion = round(COLOR.r * light_steps) / light_steps;
    // Fresnel-ish effect
    float fresnel = pow(1.0 - dot(world_normal, view_dir), 2.0);

    vec3 color = window_color;
    color += reflection_color * fresnel * reflection_strength;
	
	float grad = smoothstep(0.0, top_gradient_strength, UV.y);

    ALBEDO = mix(top_gradient_color, color, grad);
    ROUGHNESS = 0.6;
    METALLIC = 0.0;
}

void light() {
	float light = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	light = ceil(light * light_steps) / light_steps;
	DIFFUSE_LIGHT += light * ATTENUATION * occlusion * LIGHT_COLOR / PI;
}