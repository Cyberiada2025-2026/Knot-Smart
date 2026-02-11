shader_type spatial;
render_mode skip_vertex_transform, unshaded, cull_disabled;

#include "res://shared/shaders/include/dither_setup.gdshaderinc"
const vec2 res = vec2(320, 240);
const bool billboard = false;

uniform float mesh_width_change = 1.0;
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

varying vec4 clip_pos;

void vertex() {
	vec3 vert_temp = VERTEX;
	vert_temp.y *= length_curr;
	vec4 world_space = MODEL_MATRIX * vec4(vert_temp, 1);
	vec4 clip_space = PROJECTION_MATRIX * VIEW_MATRIX * world_space;
	vec4 vertex = clip_space;
	
	vec2 offset = vec2(
		round(sin(78340.0*VERTEX.x*VERTEX.y*VERTEX.z * floor(TIME/vibrate_time))),
		round(sin(93560.0*VERTEX.x*VERTEX.y*VERTEX.z * floor(TIME/vibrate_time))));
		
	// Vertex snapping
	vertex.xy = (round(clip_space.xy / clip_space.w * VIEWPORT_SIZE.xy + offset))/ VIEWPORT_SIZE.xy * clip_space.w;
	
	float mid = sqrt(1.0-abs(VERTEX.y/length_curr*2.0));
	vertex.xz += mid*VERTEX.xz*(length_start/length_curr-1.0)*mesh_width_change;
	
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
	
	vec3 main_col = main_col_def;
	vec3 sec_col = sec_col_def;
	
	if (length_curr > length_start)
	{
		main_col = mix(main_col_stretch, main_col_def, pow(length_start/length_curr, 2.0));
		sec_col = mix(sec_col_stretch, sec_col_def, pow(length_start/length_curr, 2.0));
	}
	else
	{
		main_col = mix(main_col_squish, main_col_def, pow(length_curr/length_start, 2.0));
		sec_col = mix(sec_col_squish, sec_col_def, pow(length_curr/length_start, 2.0));
	}
	
	ALBEDO.rgb = mix(sec_col, main_col, segments).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
