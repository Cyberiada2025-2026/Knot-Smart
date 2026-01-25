shader_type spatial;
render_mode unshaded;

const vec2 resolution = vec2(320,240);

uniform bool billboard = false;
uniform bool use_vertex_color = false;

uniform sampler2D main_texture : source_color, filter_nearest, repeat_disable;

uniform vec3 tint : source_color = vec3(1.0);

varying vec4 clip_pos;

void vertex() {
	// Called for every vertex the material is visible on.
	mat4 model_matrix = MODEL_MATRIX;
	
	if (billboard) {
		mat4 mat_world = mat4(
				normalize(INV_VIEW_MATRIX[0]),
				vec4(0, 1, 0, 0),
				normalize(INV_VIEW_MATRIX[2]),
				MODEL_MATRIX[3]);
				
		model_matrix = mat_world;
		
		MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
	
	vec4 world_space = model_matrix * vec4(VERTEX, 1);
	vec4 clip_space = PROJECTION_MATRIX * VIEW_MATRIX * world_space;
	vec4 vertex = clip_space;
	
	// Vertex snapping
	vertex.xy = round(clip_space.xy / clip_space.w * resolution.xy) / resolution.xy * clip_space.w;
	
	POSITION = vertex;
	
	clip_pos = vertex;
	
	UV = UV * clip_pos.w;
	//COLOR *= clip_pos.w;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = UV;
	
	uv /= clip_pos.w;
	vec3 texture_color = texture(main_texture, uv).rgb;
	if (use_vertex_color)
		texture_color *= COLOR.rgb;
	
	ALBEDO = texture_color * tint;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
