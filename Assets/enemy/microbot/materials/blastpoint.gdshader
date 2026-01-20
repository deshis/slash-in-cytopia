shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 color_a : source_color;
uniform vec4 color_b : source_color;
uniform float blend : hint_range(0.0, 1.0);

void fragment() {
    ALBEDO = mix(color_a, color_b, blend).rgb;
}
