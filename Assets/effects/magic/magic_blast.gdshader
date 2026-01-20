shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_linear_mipmap;
uniform vec4 color : source_color;
uniform vec4 highlight_color : source_color;


uniform sampler2D noise: source_color;
uniform float noise_scroll : hint_range(0.0, 2.0, 0.1);

uniform sampler2D erosion_noise: source_color;
uniform float erosion : hint_range(0.0, 1.0);

varying float offset;

void fragment() {
	vec4 noise_value = texture(noise, vec2(1.0, 1.0) * TIME * noise_scroll);
	float height_offset = clamp(noise_value.r, 0.4, 0.8);
	float xScale = 5.0+5.0*noise_value.r;
	vec2 uv = vec2(UV.x*xScale+xScale/2.0, clamp(UV.y*height_offset+(1.0-height_offset), 0.0, 1.0-erosion));
	vec4 base_value = texture(tex, uv);
	vec4 highlight_value = texture(tex, uv*0.9);
	float e = texture(erosion_noise, UV).g;
	float erosion_value = smoothstep(erosion, erosion, e);
	ALBEDO = color.rgb * base_value.rgb + highlight_color.rgb * highlight_value.rgb;
	ALPHA = color.a * base_value.r * erosion_value;
}