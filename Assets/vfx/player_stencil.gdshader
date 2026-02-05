shader_type spatial;
render_mode unshaded, depth_test_inverted, depth_draw_never;
stencil_mode read, write, compare_not_equal, 1;

uniform sampler2D dither_image: repeat_enable;

void fragment() {
	float aspect = VIEWPORT_SIZE.y / VIEWPORT_SIZE.x;
	ALBEDO = vec3(0.1, 0.2, 0.9) * 0.2;
	ALPHA = 0.7 - 0.5 * texture(dither_image, 32.0 * UV / vec2(aspect, 1.0)).r;
}
