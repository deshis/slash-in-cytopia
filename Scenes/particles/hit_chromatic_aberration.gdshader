shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform float chromatic_progress;
uniform float chromatic_aberration;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    vec2 distorted_uv = uv;
    
    // Chromatic Aberration
    float aberration = chromatic_aberration * chromatic_progress;
    vec4 color;
    color.r = texture(SCREEN_TEXTURE, distorted_uv + vec2(aberration, 0.0)).r;
    color.g = texture(SCREEN_TEXTURE, distorted_uv).g;
    color.b = texture(SCREEN_TEXTURE, distorted_uv - vec2(aberration, 0.0)).b;
    color.a = 0.72;
    
    //color.r = texture(SCREEN_TEXTURE, distorted_uv + vec2(aberration, 0.0)).r;
    //color.r = texture(SCREEN_TEXTURE, distorted_uv - vec2(aberration, 0.0)).g;
    //color.b = texture(SCREEN_TEXTURE, distorted_uv).b;
    //color.a = 0.72;
	
    COLOR = color;
}