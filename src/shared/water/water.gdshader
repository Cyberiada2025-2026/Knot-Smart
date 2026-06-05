shader_type spatial;

uniform sampler2D main_tex: filter_nearest;
uniform sampler2D water_col;
uniform vec4 ripple_col: source_color;
uniform vec2 ripple_egdes;
uniform vec2 speed1;
uniform vec2 speed2;
uniform vec2 speed3;
uniform vec2 speed4;
uniform vec4 scales = vec4(1.0);
uniform float warp_noise: hint_range(0.0, 0.3);
uniform float warp_ripple: hint_range(0.0, 0.3);

void fragment() {
	vec2 uv = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	float r1 = texture(main_tex, uv * scales.r + speed1 * TIME).r;
	float r2 = texture(main_tex, uv * scales.g + speed2 * TIME).g;
	float n1 = texture(main_tex, uv * scales.r + speed1 * TIME).b;
	float n2 = texture(main_tex, uv * scales.g + speed2 * TIME).a;
	
	float r1_warp = texture(main_tex, mix(uv * scales.r + speed1 * TIME, vec2(n1), warp_ripple)).r;
	float r2_warp = texture(main_tex, mix(uv * scales.g + speed2 * TIME, vec2(n2), warp_ripple)).g;
	float n1_warp = texture(main_tex, mix(uv * scales.b + speed3 * TIME, vec2(r1), warp_noise)).b;
	float n2_warp = texture(main_tex, mix(uv * scales.a + speed4 * TIME, vec2(r2), warp_noise)).a;
	
	float noise = (n1_warp + n2_warp) / 2.0;
	vec4 col = texture(water_col, vec2(noise, 0.0));
	
	float ripple = r1_warp * r2_warp;
	col = mix(col, ripple_col, smoothstep(ripple_egdes.x, ripple_egdes.y, 1.0 - ripple));
	
	ALBEDO = col.rgb;
	ALPHA = col.a;
}
