shader_type spatial;
render_mode cull_disabled;

const vec2 resolution = vec2(320,240);
const int dither_mat[16] = {
	    		-4, 0, -3, 1,
	    		2, -2, 3, -1,
	    		-3, 1, -4, 0,
	    		3, -1, 2, -2
};

uniform sampler2D main_texture : source_color, filter_nearest, repeat_disable;
uniform float alpha_treshold = 0.1f;
uniform vec3 main_col: source_color;
uniform vec3 sec_col: source_color;
uniform vec2 dot_cutoff = vec2(0.0, 1.0);

varying vec4 clip_pos;

void vertex() {
	// Called for every vertex the material is visible on.
	mat4 model_matrix = MODEL_MATRIX;
	
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
	vec2 screen = SCREEN_UV;
	screen = floor(screen.xy*resolution.xy);
	float dit = float( dither_mat[ (int(screen.x) % 4) + (int(screen.y) % 4)*4 ] );
	dit = (1.0 + dit*0.5*0.1);
	
	float dotprod = abs(dot(NORMAL, VIEW));
	
	if (texture_color.r * COLOR.a * dit * smoothstep(dot_cutoff.x, dot_cutoff.y, dotprod) < 0.1)
		discard;
	
	ALBEDO = mix(main_col, sec_col, texture_color.b) * vec3(1.0-texture_color.g);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
