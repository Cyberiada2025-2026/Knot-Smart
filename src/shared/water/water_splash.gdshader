shader_type spatial;
render_mode cull_disabled, vertex_lighting;

uniform float scale_bot = 1.0;
uniform float scale_top = 1.0;
uniform float height = 1.0;

uniform sampler2D main_tex: filter_nearest;
uniform sampler2D water_col;
uniform float white_height = 1.0;
uniform vec2 speed1;
uniform vec2 speed2;
uniform vec2 speed3;
uniform vec3 scales = vec3(1.0);

void vertex() {
	vec3 vert = VERTEX;
	vert *= scale_bot;
	vert.y = VERTEX.y * height;
	vert.xz += VERTEX.y * scale_top * VERTEX.xz;
	VERTEX = vert;
}

void fragment() {
	
	float n1 = texture(main_tex, UV * scales.r + vec2(1.0) * speed1 * TIME).r;
	float n2 = texture(main_tex, UV * scales.g + vec2(1.0) * speed2 * TIME).g;
	float n3 = texture(main_tex, UV * scales.b + vec2(1.0) * speed3 * TIME).b;
	
	if (step(1.0 - UV.y, n3) == 0.0)
		discard;
	
	float noise = n1 * n2 * n3;
	vec4 col = texture(water_col, vec2(noise, 0.0));
	col = mix(col, vec4(1.0), step(UV.y, n3 - white_height));
	ALBEDO = col.rgb;
}
