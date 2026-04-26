shader_type spatial;
render_mode skip_vertex_transform, unshaded, cull_disabled, depth_draw_opaque;

#include "res://shared/shaders/include/dither_setup.gdshaderinc"
const vec2 res = vec2(320, 240);
const bool billboard = false;

// Large numbers that are not simple multiplications of each others
// for a simple pseudo randomness
const float MULT_X = 78340.0;
const float MULT_Y = 93560.0;

uniform float min_radius_mult = 0.2;
uniform float max_radius_mult = 3;
uniform float anim_start = 1.0;
uniform float length_start = 1.0;
uniform float length_curr = 1.0;
uniform float segment_density = 2.0;
uniform float width = 0.3;
uniform float softness = 0.1;
uniform float speed = 0.2;
uniform vec3 main_col_def : source_color = vec3(1.0);
uniform vec3 main_col_stretch : source_color = vec3(1.0);
uniform vec3 main_col_squish : source_color = vec3(1.0);
uniform vec3 sec_col_def : source_color = vec3(0.0);
uniform vec3 sec_col_stretch : source_color = vec3(0.0);
uniform vec3 sec_col_squish : source_color = vec3(0.0);
uniform float vibrate_time = 0.3;

uniform float max_length = 32.0;
uniform float min_length = 0.3;

varying vec4 clip_pos;

void vertex() {
	vec3 vert_temp = VERTEX;
	vert_temp.y *= length_curr;
	
	//Squash and stretch
	float t = (length_curr - min_length)/(max_length-min_length);
	float peak_change = mix(max_radius_mult, min_radius_mult, t);
	float mid = sqrt(1.0 - abs(VERTEX.y * 2.0));
	vert_temp.xz *= mix(1.0, peak_change, mid) ;
	
	vec4 world_space = MODEL_MATRIX * vec4(vert_temp, 1);
	
	vec4 clip_space = PROJECTION_MATRIX * VIEW_MATRIX * world_space;
	vec4 vertex = clip_space;
	//Ofsset in clip space for vibrations
	vec2 offset = vec2(
	round(sin(MULT_X * VERTEX.x * VERTEX.y * VERTEX.z * floor(TIME/vibrate_time))),
	round(sin(MULT_Y * VERTEX.x * VERTEX.y * VERTEX.z * floor(TIME/vibrate_time))));
	
	// Vertex snapping
	vertex.xy = (round(clip_space.xy / clip_space.w * VIEWPORT_SIZE.xy + offset))/ VIEWPORT_SIZE.xy * clip_space.w;
	
	POSITION = vertex;
	
	clip_pos = vertex;
	
	COLOR *= clip_pos.w;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	uv.y = 1.0-uv.y;
	
	#include "res://shared/shaders/include/get_dither.gdshaderinc"
	
	if (step(4.0, dit + uv.y + anim_start*8.0*2.0) == 0.0)
		discard;
	
	float segments = uv.y * length_curr*segment_density;
	segments += TIME*speed*sign(length_curr-length_start);
	segments = mod(segments, 1.0);
	segments = smoothstep(width, width+softness, segments);
	
	vec3 scaling_main = (length_curr > length_start)? main_col_stretch : main_col_squish;
	vec3 main_col = mix(scaling_main, main_col_def, pow(min(length_start, length_curr)/max(length_start, length_curr), 2.0));
	vec3 scaling_sec = (length_curr > length_start)? sec_col_stretch : sec_col_squish;
	vec3 sec_col = mix(scaling_sec, sec_col_def, pow(min(length_start, length_curr)/max(length_start, length_curr), 2.0));
	
	ALBEDO.rgb = mix(sec_col, main_col, segments).rgb;
}
