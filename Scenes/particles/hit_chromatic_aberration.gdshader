shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float chromatic_progress;
uniform float chromatic_aberration;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float time_scale = 1.0;

// Simple hash function for pseudo-random values
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float time = TIME * time_scale;
    
    // Random glitch blocks - creates horizontal displacement strips
    float block = floor(uv.y * 20.0 + time * 3.0);
    float random_shift = hash(vec2(block, floor(time * 2.0))) - 0.5;
    if (hash(vec2(block, floor(time))) > 0.85) {
        uv.x += random_shift * 0.1 * glitch_intensity;
    }
    
    // Scanline jitter - subtle vertical distortion
    float scanline = sin(uv.y * 300.0 + time * 10.0);
    uv.x += scanline * 0.003 * glitch_intensity;
    
    // Random pixel offset every few frames
    float frame_glitch = floor(time * 10.0);
    if (hash(vec2(frame_glitch, 0.0)) > 0.9) {
        uv += (hash(vec2(frame_glitch, 1.0)) - 0.5) * 0.02 * glitch_intensity;
    }
    
    vec2 distorted_uv = uv;
    
    // Enhanced Chromatic Aberration with glitch modulation
    float aberration = chromatic_aberration * chromatic_progress;
    // Add random spikes to aberration
    aberration += hash(vec2(floor(time * 5.0))) * 0.01 * glitch_intensity;
    
    vec4 color;
    color.r = texture(SCREEN_TEXTURE, distorted_uv + vec2(aberration, 0.0)).r;
    color.g = texture(SCREEN_TEXTURE, distorted_uv).g;
    color.b = texture(SCREEN_TEXTURE, distorted_uv - vec2(aberration, 0.0)).b;
    color.a = 0.36;
    
    // Color channel swapping glitch
    if (hash(vec2(floor(time * 3.0), block)) > 0.95) {
        color.rgb = color.gbr; // Swap channels randomly
    }
    
    // Digital noise bands
    if (hash(vec2(uv.y * 10.0, floor(time * 4.0))) > 0.92) {
        color.rgb += (hash(vec2(uv.x, time)) - 0.5) * 0.5 * glitch_intensity;
    }
    
    COLOR = color;
}