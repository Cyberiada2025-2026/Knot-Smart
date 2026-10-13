shader_type spatial;
render_mode skip_vertex_transform, unshaded, cull_disabled, depth_draw_opaque;

#include "res://shared/shaders/include/dither_setup.gdshaderinc"
const vec2 res = vec2(320, 240);
const bool billboard = false;

// Large numbers that are not simple multiplications of each others
// for a simple pseudo randomness
const float MULT_X = 78340.0;
const float MULT_Y = 93560.0;

group_uniforms RopeDeformation.SquashAndStretch;
uniform float max_length = 32.0;
uniform float min_length = 0.3;
uniform float length_start = 1.0;
uniform float length_current = 1.0;
uniform float min_radius_multiplier = 0.0;
uniform float max_radius_multiplier = 3.0;
group_uniforms;

group_uniforms RopeDeformation.Vibration;
uniform float vibrate_time = 0.3;
uniform float vibrate_distance = 2.0;
uniform bool smooth_vibration = false;
group_uniforms;

group_uniforms Colors.MainColor;
uniform vec3 main_col_default : source_color = vec3(1.0);
uniform vec3 main_col_stretch : source_color = vec3(1.0);
uniform vec3 main_col_squish : source_color = vec3(1.0);
group_uniforms;

group_uniforms Colors.SecondaryColor;
uniform vec3 sec_col_default : source_color = vec3(0.0);
uniform vec3 sec_col_stretch : source_color = vec3(0.0);
uniform vec3 sec_col_squish : source_color = vec3(0.0);
group_uniforms;

group_uniforms Colors.Segments;
uniform float segment_density = 2.0;
uniform float segment_width = 0.3;
uniform float softness = 0.1;
uniform float speed = 0.2;
group_uniforms;

group_uniforms Colors.Transparency;
uniform float alpha = 1.0;
group_uniforms;

varying vec4 clip_pos;

void vertex() {
	vec3 vert_temp = VERTEX;
	vert_temp.y *= length_current;
	
	// Squash and stretch
	float t = (length_current - min_length) / (max_length - min_length);
	float peak_change = mix(max_radius_multiplier, min_radius_multiplier, t);
	float mid = sqrt(1.0 - abs(VERTEX.y * 2.0));
	vert_temp.xz *= mix(1.0, peak_change, mid) ;
	
	vec4 world_space = MODEL_MATRIX * vec4(vert_temp, 1);
	
	vec4 clip_space = PROJECTION_MATRIX * VIEW_MATRIX * world_space;
	vec4 vertex = clip_space;
	// Offset in clip space for vibrations
	vec2 offset = vec2(
		sin(MULT_X * VERTEX.x * VERTEX.y * VERTEX.z * floor(TIME / vibrate_time)),
		sin(MULT_Y * VERTEX.x * VERTEX.y * VERTEX.z * floor(TIME / vibrate_time))
	);
	
	offset = vec2(
		(smooth_vibration ? offset.x : round(offset.x * float(!smooth_vibration))) * vibrate_distance,
		(smooth_vibration ? offset.y : round(offset.y * float(!smooth_vibration))) * vibrate_distance
	);
	//below is an "optimized" version of the above ternary (I have not profiled it)
	//offset = vec2(
	//	(offset.x * float(smooth_vibration) + round(offset.x * float(!smooth_vibration))) * vibrate_distance,
	//	(offset.y * float(smooth_vibration) + round(offset.y * float(!smooth_vibration))) * vibrate_distance
	//);
	
	// Vertex snapping
	vertex.xy = (round(clip_space.xy / clip_space.w * VIEWPORT_SIZE.xy + offset)) / VIEWPORT_SIZE.xy * clip_space.w;
	
	POSITION = vertex;
	
	clip_pos = vertex;
	
	COLOR *= clip_pos.w;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	uv.y = 1.0 - uv.y;
	
	#include "res://shared/shaders/include/get_dither.gdshaderinc"
	
	if (step(4.0, dit + uv.y + alpha * 8.0 * 2.0) == 0.0)
		discard;
	
	float segments = uv.y * length_current * segment_density;
	segments += TIME * speed * sign(length_current - length_start);
	segments = mod(segments, 1.0);
	segments = smoothstep(segment_width, segment_width + softness, segments);
	
	vec3 scaling_main = (length_current > length_start) ? main_col_stretch : main_col_squish;
	vec3 main_col = mix(scaling_main, main_col_default, pow(min(length_start, length_current) / max(length_start, length_current), 2.0));
	vec3 scaling_sec = (length_current > length_start) ? sec_col_stretch : sec_col_squish;
	vec3 sec_col = mix(scaling_sec, sec_col_default, pow(min(length_start, length_current) / max(length_start, length_current), 2.0));
	
	ALBEDO.rgb = mix(sec_col, main_col, segments).rgb;
}
