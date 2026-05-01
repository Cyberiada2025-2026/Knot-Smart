shader_type spatial;
render_mode cull_disabled;

uniform sampler2D main_tex: filter_nearest;
uniform sampler2D water_col;
uniform vec2 speed1;
uniform vec2 speed2;
uniform vec2 speed3;
uniform vec3 scales = vec3(1.0);

void fragment() {
	float n1 = texture(main_tex, UV * scales.r + vec2(1.0) * speed1 * TIME).r;
	float n2 = texture(main_tex, UV * scales.g + vec2(1.0) * speed2 * TIME).g;
	float n3 = texture(main_tex, UV * scales.b + vec2(1.0) * speed3 * TIME).b;
	
	float noise = n1 * n2 * n3;
	vec4 col = texture(water_col, vec2(noise, 0.0));
	ALBEDO = col.rgb;
	ALPHA = step(1.0 - UV.y, n1*n2);
}
