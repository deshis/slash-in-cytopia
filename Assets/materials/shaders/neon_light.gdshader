shader_type spatial;
render_mode blend_mix, depth_prepass_alpha;

uniform vec3 tube_color : source_color = vec3(0.1, 0.6, 0.5);
uniform vec3 neon_color : source_color = vec3(0.2, 1.0, 0.9);

uniform float tube_brightness = 0.4;
uniform float neon_intensity = 4.0;

uniform float flicker_value : hint_range(0.0, 1.0) = 1.0;

uniform float fresnel_power = 3.0;
uniform float fresnel_strength = 0.5;

uniform float fade_alpha = 1.0;

varying vec3 world_pos;
varying vec3 world_normal;
varying vec3 view_dir;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);
}


void fragment() {
	float flicker = flicker_value;

    float fresnel = pow(1.0 - clamp(dot(world_normal, view_dir), 0.0, 1.0), fresnel_power);

    vec3 base_color = tube_color * tube_brightness + tube_color * fresnel * fresnel_strength;
    vec3 emission = neon_color * neon_intensity * flicker + neon_color * fresnel * 0.5 * flicker;

    ALBEDO = base_color;
    EMISSION = emission;
	ALPHA = fade_alpha;
}