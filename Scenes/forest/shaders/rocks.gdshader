shader_type spatial; //Just edited from the grass shader :D
render_mode unshaded, cull_back;

//Size
uniform float heigth = 0.5;
uniform float width = 0.001;
uniform float density = 0.2;

//Color
uniform vec3 base_color: source_color =vec3(0.0,0.0,0.0);
uniform vec3 tip_color: source_color =vec3(0.0,0.0,0.0);

varying float height_ratio;



varying vec3 worldPos;
varying float dist;
const float max_dist=50.0;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}



void vertex(){
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	dist = distance(CAMERA_POSITION_WORLD, worldPos);
	if (dist<max_dist){

	float rnd=random(worldPos.xz);
	float h;


	if(rnd>1.0-density)	{
		h= heigth * (0.2 + random(vec2(VERTEX.x, VERTEX.z)) *0.5);

		VERTEX.y += h;
		VERTEX.x += sin(rnd) * width;
		VERTEX.z += sin(rnd) * width;

	}
	else{
		h=0.0;
	}
	height_ratio = clamp(VERTEX.y/h,0.0, 1.0);
}
}

void fragment(){
	ALPHA_SCISSOR_THRESHOLD=0.2;
	if (dist<max_dist){
		ALBEDO = mix(base_color, tip_color,height_ratio);
		ALPHA = mix(0.0,1.0,height_ratio);
	}
	else{
		ALPHA=0.0;
	}
}