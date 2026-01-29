shader_type spatial;
render_mode unshaded;

uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 color : source_color;

uniform sampler2D erosion_noise : source_color;
uniform float fade : hint_range(0.0, 1.0);

uniform float shader_time;
uniform float life_time : hint_range(0.0, 1.0);

void fragment() {
	float offset = 1.0-life_time*2.0;
	vec2 uv = vec2(UV.x, offset+UV.y);
	vec4 value = texture(tex, uv);
	float erosion_value = smoothstep(-offset-0.25, -offset-0.25, texture(erosion_noise, UV).r);
	
	float minimum = step(0, offset)*(offset);
	float maximum = 1.0 + step(offset, 0.0)*(offset);
	float fade_val = smoothstep(minimum, minimum+fade, uv.y) * smoothstep(maximum, maximum - fade, uv.y);
	
	ALBEDO = color.rgb * value.rgb;
	ALPHA = color.a * value.a;
	ALPHA *= fade_val*erosion_value;
}