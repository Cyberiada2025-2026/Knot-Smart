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